from pymongo import MongoClient
from bottle import *
from passlib.hash import pbkdf2_sha256
import re
import io
import subprocess
import os
import atexit
import secrets
from math import ceil 
import logging
import threading
from pymongo.collection import ASCENDING
from bottle import Bottle, request, response, redirect, view, static_file, template
from html import escape

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

secret_key = secrets.token_hex(18)
mongo_database = "DBleaks"
app = Bottle()

# Initialize MongoDB connection
try:
    client = MongoClient(serverSelectionTimeoutMS=5000)
    db = client[mongo_database]
    db.command("ping")  # Test connection
    
    # Ensure indexes for faster queries
    db["credentials"].create_index([("p", ASCENDING)])
    db["credentials"].create_index([("url", ASCENDING)])
    db["credentials"].create_index([("leakname", ASCENDING)])
    db["phone_numbers"].create_index([("phone", ASCENDING)])
    db["miscfiles"].create_index([("donnee", ASCENDING)])
except Exception as e:
    logging.error("Failed to connect to MongoDB: %s", e)
    exit(1)


def is_authenticated():
    """Check if the user is authenticated."""
    auth_cookie = request.get_cookie("authenticated", secret=secret_key)
    return bool(auth_cookie)


@app.route('/', method='GET')
def home_redirect():
    """Redirect root to index page (public access)"""
    return redirect('/index')


@app.route('/login', method='GET')
@view('views/login.tpl')
def login_form():
    """Show login form (public)"""
    # If already authenticated, redirect to index
    if is_authenticated():
        return redirect('/index')
    return template('login', failed=False)


@app.route('/login', method='POST')
@view('views/login.tpl')
def do_login():
    """Process login (public)"""
    password = escape(request.forms.get('password', '').strip())
    if not password:
        logging.warning("Login attempt with empty password")
        return template('login', failed=True)

    access = db['access'].find_one({'type': 'admin_password'}, {'password': 1})
    stored_password = access.get('password') if access else None

    if not stored_password or not pbkdf2_sha256.verify(password, stored_password):
        logging.warning("Failed login attempt")
        return template('login', failed=True)

    response.set_cookie("authenticated", "true", secret=secret_key, httponly=True, secure=False)  # secure=False for development
    logging.info("User logged in successfully")
    return redirect('/index')


@app.route('/logout')
def logout():
    """Logout (requires authentication)"""
    response.delete_cookie('authenticated', secret=secret_key)
    logging.info("User logged out")
    redirect('/index')


@app.route('/index', method='GET')
@view('views/index.tpl')
def index():
    """Public search page - no login required"""
    # Remove authentication check - public access

    query = escape(request.query.get('search', '').strip())
    name_query = escape(request.query.get('p', '').strip())
    url_query = escape(request.query.get('url', '').strip())
    leak_name = escape(request.query.get('leakname', '').strip())
    page_number = request.query.get('page', '1')
    
    try:
        page_number = int(page_number)
    except ValueError:
        page_number = 1

    page_size = 250  # Pagination size
    query_conditions = {}
    
    if query:
        query_conditions["$text"] = {"$search": query}
    if name_query:
        query_conditions["p"] = {"$regex": re.escape(name_query), "$options": "i"}
    if url_query:
        query_conditions["url"] = {"$regex": re.escape(url_query), "$options": "i"}
    if leak_name:
        query_conditions["leakname"] = leak_name

    total_filtered_results = db["credentials"].count_documents(query_conditions) if query_conditions else 0
    total_pages = max(1, ceil(total_filtered_results / page_size))
    page_number = max(1, min(page_number, total_pages))
    skip = (page_number - 1) * page_size
    creds = list(db["credentials"].find(query_conditions, {"_id": 0}).skip(skip).limit(page_size))
    nbRes = len(creds)

    logging.info("Fetched %d results for search query '%s'", nbRes, query)

    count = db["credentials"].estimated_document_count()
    
    # Add authentication status to template
    authenticated = is_authenticated()
    
    return dict(
        count=count,
        creds=creds,
        total_filtered_results=total_filtered_results,
        nbRes=nbRes,
        query={
            "search": query,
            "p": name_query,
            "url": url_query,
            "leakname": leak_name
        },
        page=page_number,
        total=total_pages,
        prevPage=max(1, page_number - 1),
        nextPage=min(total_pages, page_number + 1),
        authenticated=authenticated
    )


@app.route('/phone', method=['GET'])
@view('views/phone.tpl')
def phone_search():
    """Public phone search - no login required"""
    # Remove authentication check - public access
    
    query = request.query.get('search', '').strip()
    client = MongoClient()
    db = client[mongo_database]
    phone_numbers = db["phone_numbers"]
    count = '{:,}'.format(phone_numbers.count_documents({})).replace(',', ' ')  

    search_results = []
    if query:
        regex_query = {"$regex": re.escape(query), "$options": "i"}
        search_results = list(phone_numbers.find({"phone": regex_query}))

    authenticated = is_authenticated()
    return {"results": search_results, "count": count, "query": query, "authenticated": authenticated}


@app.route('/miscsearch', method=['GET'])
@view('views/miscsearch.tpl')
def misc_search():
    """Public misc search - no login required"""
    # Remove authentication check - public access
    
    query = request.query.get('search', '').strip()
    client = MongoClient()
    db = client[mongo_database]
    misc_data = db["miscfiles"]
    count = '{:,}'.format(misc_data.count_documents({})).replace(',', ' ')

    search_results = []
    if query:
        regex_query = {"$regex": re.escape(query), "$options": "i"}
        search_results = list(misc_data.find({"donnee": regex_query}))

    authenticated = is_authenticated()
    return {"results": search_results, "count": count, "query": query, "authenticated": authenticated}


@app.route('/leaks', method='GET')
@view('views/leaks.tpl')
def getLeaks():
    """Leak inventory - no authentication"""    
    client = MongoClient()
    db = client[mongo_database]
    creds_leaks_info = []
    phone_leaks_info = []
    miscfiles_leaks_info = []
    all_leaks = list(db["leaks"].find({}))
    for leak in all_leaks:
        leak_name = leak["name"]
        leak_date = leak["date"]
        leak_id = leak["id"]
        if db["credentials"].count_documents({"leakname": leak_name}):
            imported_creds_count = db["credentials"].count_documents({"leakname": leak_name})
            creds_leaks_info.append({
                "id": leak_id,
                "name": leak_name,
                "imported": imported_creds_count,
                "date": leak_date
            })
        elif db["phone_numbers"].count_documents({"leak_name": leak_name}):
            imported_phone_count = db["phone_numbers"].count_documents({"leak_name": leak_name})
            phone_leaks_info.append({
                "id": leak_id,
                "name": leak_name,
                "imported": imported_phone_count,
                "date": leak_date
            })
        elif db["miscfiles"].count_documents({"leak_name": leak_name}):
            imported_phone_count = db["miscfiles"].count_documents({"leak_name": leak_name})
            miscfiles_leaks_info.append({
                "id": leak_id,
                "name": leak_name,
                "imported": imported_phone_count,
                "date": leak_date
            })
    nbLeaks = len(all_leaks)
    authenticated = is_authenticated()
    return dict(nbLeaks=nbLeaks, creds_leaks_info=creds_leaks_info, 
                phone_leaks_info=phone_leaks_info, miscfiles_leaks_info=miscfiles_leaks_info,
                authenticated=authenticated)


@app.route('/export', method='GET')
def export():
    """Export data - requires authentication"""
    if not is_authenticated():
        logging.warning("Unauthorized export attempt")
        return redirect('/login')
    
    domain_query = request.query.d
    name_query = request.query.p
    url_query = request.query.url 
    if domain_query or name_query or url_query:
        client = MongoClient()
        db = client[mongo_database]
        credentials = db["credentials"]
        query_conditions = {}
        if domain_query:
            query_conditions["d"] = {"$regex": re.escape(domain_query)}
        if name_query:
            query_conditions["p"] = {"$regex": re.escape(name_query)}
        if url_query:
            query_conditions["url"] = {"$regex": re.escape(url_query)}

        r = credentials.find(query_conditions)
        res = "\n".join([f"{x.get('url', 'N/A')},{x.get('p', 'N/A')},{x.get('d', 'N/A')},{x.get('P', 'N/A')}" for x in r])
        output = io.BytesIO()
        output.write(res.encode('utf-8'))
        output.seek(0)
        response.content_type = 'application/force-download; UTF-8'
        response.set_header("Content-Disposition", "attachment;filename=creds-" + (domain_query or name_query or url_query) + ".csv")
        return output
    else:
        redirect("/index")


@app.route('/removeLeak', method='GET')
def removeLeak():
    """Remove leak - requires authentication"""
    if not is_authenticated():
        logging.warning("Unauthorized delete attempt")
        return redirect('/login')
    
    if request.query.id:
        client = MongoClient()
        db = client[mongo_database]
        credentials = db["credentials"]
        phone_numbers = db["phone_numbers"]
        miscfiles = db["miscfiles"]
        leaks = db["leaks"]
        print("\tRemoving leak " + str(request.query.id) + " ...")
        credentials.delete_many({"l": int(request.query.id)})
        phone_numbers.delete_many({"l": int(request.query.id)})
        miscfiles.delete_many({"l": int(request.query.id)})
        leaks.delete_one({"id": int(request.query.id)})
        print("\tdone.")
    redirect("/leaks")


@app.route('/upload', method='GET')
@view('views/upload.tpl')
def upload_form():
    """Upload form - requires authentication"""
    if not is_authenticated():
        logging.warning("Unauthorized upload form access")
        return redirect('/login')
    
    authenticated = is_authenticated()
    return {"authenticated": authenticated}


def run_leak_importer(cmd):
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    log_filename = "leak_import.log"
    upload_folder = "uploads"
    log_path = os.path.join(upload_folder, log_filename)
    with open(log_path, "w") as log_file:
        while proc.poll() is None:
            stdout = proc.stdout.readline()
            stderr = proc.stderr.readline()
            log_file.write(stdout.decode())
            log_file.write(stderr.decode())
    stdout, stderr = proc.communicate()
    stdout = stdout.decode()
    stderr = stderr.decode()
    with open(log_path, "a") as log_file:
        log_file.write(stdout)
        log_file.write(stderr)
    os.remove(log_path)


@app.route('/upload', method='POST')
@view('views/upload.tpl')
def upload_file():
    """Process upload - requires authentication"""
    if not is_authenticated():
        logging.warning("Unauthorized upload attempt")
        return redirect('/login')

    leak_name = escape(request.forms.get('leakName', '').strip())
    leak_date = escape(request.forms.get('leakDate', '').strip())
    data_type = escape(request.forms.get('dataType', '').strip())
    upload = request.files.get('file')

    if not upload or not leak_name or not leak_date:
        logging.warning("Missing fields in upload request")
        return "Missing required fields", 400
    
    upload_folder = "uploads"
    # Ensure upload directory exists
    os.makedirs(upload_folder, exist_ok=True)
    
    # safer way - renaming filename with underscores
    safe_filename = re.sub(r'[^a-zA-Z0-9._-]', '_', os.path.basename(upload.filename))
    filepath = os.path.join(upload_folder, safe_filename)
    upload.save(filepath, overwrite=True)
    
    if data_type == "credentials":
        cmd = ["python3", "import.py", "-f", filepath, "-d", leak_date, "-n", leak_name, "-t", "creds"]
    elif data_type == "phone_numbers":
        cmd = ["python3", "import.py", "-f", filepath, "-d", leak_date, "-n", leak_name, "-t", "phone"]
    elif data_type == "misc_file":
        cmd = ["python3", "import.py", "-f", filepath, "-d", leak_date, "-n", leak_name, "-t", "misc"]
    else:
        logging.warning("Unsupported data type: %s", data_type)
        return "Unsupported data type", 400
    
    threading.Thread(target=run_leak_importer, args=(cmd,)).start()
    logging.info("Started leak import process for %s", leak_name)
    
    authenticated = is_authenticated()
    return {"message": "Import started", "authenticated": authenticated}


@app.route('/links-directory', method='GET')
@view('views/links.tpl')
def link_directory():
    """Public links directory - no login required"""
    # Remove authentication check - public access
    
    links = [
        {"title": "HIBP", "url": "https://haveibeenpwned.com/", "description": "Check if your email or password has been exposed in a data breach."},
        {"title": "Intelligence X", "url": "https://intelx.io/", "description": "Search for leaked data, archives, and dark web content."},
        {"title": "InfoStealers", "url": "https://www.infostealers.com/", "description": "Latest updates on credential-stealing malware and cyber threats."},
        {"title": "DarkWebInformer", "url": "https://darkwebinformer.com/tag/data-breaches/", "description": "Daily news and insights on data breaches and leaks."},
        {"title": "CavalierGPT", "url": "https://chatgpt.com/g/g-Rddxw5Vyc-cavaliergpt-cybersecurity-osint-investigations", "description": "Infostealer Intelligence AI Bot by Hudson Rock."}
    ]
    
    authenticated = is_authenticated()
    return dict(links=links, authenticated=authenticated)


@app.route('/static/css/<filename:path>')
def send_static_css(filename):
    print(f"Requested CSS file: {filename}")  # Debug print
    return static_file(filename, root='./views/css/')


@app.route('/static/js/<filename:path>')
def send_static_js(filename):
    return static_file(filename, root='./views/js/')


@app.hook('before_request')
def enable_protection():
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['Server'] = 'Leaky'
    response.headers['X-Powered-By'] = 'Leaky'

@atexit.register
def close_mongo():
    client.close()

if __name__ == "__main__":
    # Create uploads directory if it doesn't exist
    os.makedirs("uploads", exist_ok=True)
    app.run(host="0.0.0.0", port=9999, debug=True, reloader=True)
