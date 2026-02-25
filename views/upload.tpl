% include("header")
<style>
    @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap");

    * { font-family: 'Inter', sans-serif; }

    body {
        background-color: #050505;
        color: #e0e0e0;
    }

    /* Card de formulaire */
    .upload-card {
        background: #0f0f0f;
        border: 1px solid #1e1e1e;
        border-radius: 20px;
        padding: 40px;
        margin: 0 auto;
        max-width: 800px;
        box-shadow: 0 10px 30px rgba(0,0,0,0.4);
    }

    .form-group-custom {
        margin-bottom: 20px;
    }

    .label-custom {
        font-size: 0.75rem;
        text-transform: uppercase;
        letter-spacing: 0.1em;
        color: #666;
        font-weight: 700;
        margin-bottom: 8px;
        display: block;
    }

    .form-select, .upload-input, .file-input-custom {
        background-color: #121212 !important;
        border: 1px solid #2a2a2a !important;
        border-radius: 12px !important;
        color: #ffffff !important;
        padding: 14px 18px !important;
        font-family: 'JetBrains Mono', monospace !important;
        font-size: 15px;
        width: 100%;
        transition: all 0.3s ease;
        outline: none;
    }

    .form-select:focus, .upload-input:focus {
        border-color: #7F0000 !important;
        box-shadow: 0 0 0 4px rgba(127, 0, 0, 0.15);
    }

    .btn-upload {
        background: linear-gradient(135deg, #7F0000 0%, #4d0000 100%) !important;
        border: none !important;
        border-radius: 12px !important;
        padding: 16px 30px !important;
        font-weight: 600 !important;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: white;
        transition: all 0.3s ease !important;
        cursor: pointer;
        width: 100%;
        margin-top: 10px;
    }

    .btn-upload:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(127, 0, 0, 0.4);
    }

    #messageArea {
        margin-top: 10px;
        font-size: 13px;
        color: #888;
        font-style: italic;
        padding: 12px;
        background: rgba(255, 255, 255, 0.02);
        border-radius: 10px;
        border-left: 3px solid #7F0000;
        display: block;
    }

    h4 {
        color: #ffffff;
        font-weight: 700;
        letter-spacing: -1px;
    }

    /* Progress Popup Styles */
    .progress-popup {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.85);
        backdrop-filter: blur(8px);
        z-index: 9999;
        justify-content: center;
        align-items: center;
    }

    .progress-card {
        background: #0f0f0f;
        border: 1px solid #2a2a2a;
        border-radius: 24px;
        padding: 30px;
        width: 90%;
        max-width: 500px;
        box-shadow: 0 20px 60px rgba(0,0,0,0.8);
        animation: slideIn 0.3s ease;
    }

    @keyframes slideIn {
        from { transform: translateY(-20px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
    }

    .progress-header {
        display: flex;
        align-items: center;
        gap: 15px;
        margin-bottom: 25px;
    }

    .progress-header i {
        font-size: 2rem;
        color: #7F0000;
    }

    .progress-header h3 {
        margin: 0;
        font-size: 1.5rem;
        font-weight: 700;
        color: #fff;
    }

    .file-info {
        background: #161616;
        border-radius: 12px;
        padding: 15px;
        margin-bottom: 20px;
        border: 1px solid #222;
    }

    .file-name {
        font-family: 'JetBrains Mono', monospace;
        font-size: 0.9rem;
        color: #ffaa00;
        word-break: break-all;
        margin-bottom: 5px;
    }

    .file-size {
        font-size: 0.8rem;
        color: #666;
    }

    .progress-stats {
        display: flex;
        justify-content: space-between;
        margin: 15px 0 5px 0;
        color: #888;
        font-size: 0.9rem;
    }

    .progress-bar-container {
        width: 100%;
        height: 8px;
        background: #222;
        border-radius: 4px;
        overflow: hidden;
        margin: 10px 0;
    }

    .progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, #7F0000, #ff4d4d);
        width: 0%;
        transition: width 0.3s ease;
        border-radius: 4px;
    }

    .speed-indicator {
        display: flex;
        justify-content: space-between;
        color: #ffaa00;
        font-family: 'JetBrains Mono', monospace;
        font-size: 0.9rem;
        margin-top: 10px;
    }

    .cancel-btn {
        background: transparent;
        border: 1px solid #333;
        color: #888;
        padding: 10px 20px;
        border-radius: 8px;
        cursor: pointer;
        transition: all 0.3s ease;
        margin-top: 20px;
        width: 100%;
        font-weight: 600;
    }

    .cancel-btn:hover {
        background: #ff4d4d;
        border-color: #ff4d4d;
        color: white;
    }

    .complete-message {
        text-align: center;
        color: #28a745;
        font-size: 1.1rem;
        margin-top: 20px;
        display: none;
    }
</style>

<div class="container-fluid py-5">
    <div class="text-center mb-5">
        <h4 class="text-4xl m-0">Data Ingestion</h4>
        <p class="text-gray-500 mt-2">Upload and index new leak files into the database</p>
    </div>

    <div class="upload-card">
        <form id="uploadForm" method="POST" action="/upload" enctype="multipart/form-data">
            
            <div class="form-group-custom">
                <label class="label-custom"><i class="fas fa-layer-group mr-2"></i> Data Category</label>
                <select name="dataType" id="dataType" class="form-select" required>
                    <option value="credentials">Credentials (User/Pass)</option>
                    <option value="phone_numbers">Phone Numbers</option>
                    <option value="misc_file">Misc (SQL/CSV/JSON)</option>
                </select>
                <div id="messageArea"></div>
            </div>

            <div class="form-group-custom">
                <label class="label-custom"><i class="fas fa-file-upload mr-2"></i> Source File</label>
                <input class="file-input-custom" type="file" name="file" id="fileInput" accept=".txt,.sql,.json,.csv" required />
            </div>

            <div class="row">
                <div class="col-md-8 form-group-custom">
                    <label class="label-custom"><i class="fas fa-tag mr-2"></i> Leak Name</label>
                    <input class="upload-input" type="text" name="leakName" id="leakName" placeholder="e.g. LinkedIn 2024 Breach" required />
                </div>
                <div class="col-md-4 form-group-custom">
                    <label class="label-custom"><i class="fas fa-calendar-alt mr-2"></i> Year</label>
                    <input class="upload-input" type="text" name="leakDate" id="leakDate" placeholder="YYYY" required />
                </div>
            </div>

            <button type="submit" class="btn-upload" id="submitBtn">
                <i class="fas fa-cloud-upload-alt mr-2"></i> Start Import Process
            </button>
        </form>
    </div>
</div>

<!-- Progress Popup -->
<div id="progressPopup" class="progress-popup">
    <div class="progress-card">
        <div class="progress-header">
            <i class="fas fa-cloud-upload-alt"></i>
            <h3>Uploading...</h3>
        </div>
        
        <div class="file-info">
            <div class="file-name" id="uploadFileName"></div>
            <div class="file-size" id="uploadFileSize"></div>
        </div>
        
        <div class="progress-stats">
            <span id="uploadPercent">0%</span>
            <span id="uploadedAmount">0 MB / 0 MB</span>
        </div>
        
        <div class="progress-bar-container">
            <div class="progress-bar-fill" id="progressBar"></div>
        </div>
        
        <div class="speed-indicator">
            <span><i class="fas fa-tachometer-alt"></i> <span id="uploadSpeed">0 MB/s</span></span>
            <span><span id="timeRemaining">Calculating...</span></span>
        </div>
        
        <button class="cancel-btn" onclick="cancelUpload()">
            <i class="fas fa-times-circle"></i> Cancel Upload
        </button>
        
        <div id="completeMessage" class="complete-message">
            <i class="fas fa-check-circle"></i> Upload Complete! Processing...
        </div>
    </div>
</div>

<script>
    let uploadXHR = null;
    
    function formatBytes(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    function formatSpeed(bytesPerSecond) {
        if (bytesPerSecond < 1024) return bytesPerSecond.toFixed(1) + ' B/s';
        if (bytesPerSecond < 1024 * 1024) return (bytesPerSecond / 1024).toFixed(1) + ' KB/s';
        return (bytesPerSecond / (1024 * 1024)).toFixed(1) + ' MB/s';
    }

    document.getElementById('uploadForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Get file
        const fileInput = document.getElementById('fileInput');
        const file = fileInput.files[0];
        
        if (!file) {
            alert('Please select a file');
            return;
        }
        
        // Show popup
        document.getElementById('progressPopup').style.display = 'flex';
        document.getElementById('uploadFileName').textContent = file.name;
        document.getElementById('uploadFileSize').textContent = formatBytes(file.size);
        document.getElementById('uploadPercent').textContent = '0%';
        document.getElementById('progressBar').style.width = '0%';
        document.getElementById('uploadedAmount').textContent = `0 MB / ${(file.size / (1024*1024)).toFixed(2)} MB`;
        document.getElementById('completeMessage').style.display = 'none';
        
        // Prepare form data
        const formData = new FormData(this);
        
        // Create XHR for upload tracking
        uploadXHR = new XMLHttpRequest();
        
        // Track progress
        const startTime = Date.now();
        let lastLoaded = 0;
        let lastTime = startTime;
        
        uploadXHR.upload.addEventListener('progress', function(e) {
            if (e.lengthComputable) {
                const percentComplete = (e.loaded / e.total) * 100;
                const currentTime = Date.now();
                const timeDiff = (currentTime - lastTime) / 1000; // in seconds
                const loadedDiff = e.loaded - lastLoaded;
                
                // Calculate speed
                const speed = loadedDiff / timeDiff; // bytes per second
                const avgSpeed = e.loaded / ((currentTime - startTime) / 1000);
                
                // Calculate remaining time
                const remainingBytes = e.total - e.loaded;
                const remainingSeconds = remainingBytes / avgSpeed;
                
                // Update UI
                document.getElementById('progressBar').style.width = percentComplete + '%';
                document.getElementById('uploadPercent').textContent = Math.round(percentComplete) + '%';
                document.getElementById('uploadedAmount').textContent = 
                    `${(e.loaded / (1024*1024)).toFixed(2)} MB / ${(e.total / (1024*1024)).toFixed(2)} MB`;
                document.getElementById('uploadSpeed').textContent = formatSpeed(speed);
                
                if (remainingSeconds > 0 && remainingSeconds < 3600) {
                    const mins = Math.floor(remainingSeconds / 60);
                    const secs = Math.floor(remainingSeconds % 60);
                    document.getElementById('timeRemaining').textContent = 
                        `${mins}:${secs.toString().padStart(2, '0')} remaining`;
                } else if (remainingSeconds >= 3600) {
                    document.getElementById('timeRemaining').textContent = '> 1 hour remaining';
                } else {
                    document.getElementById('timeRemaining').textContent = 'Calculating...';
                }
                
                lastLoaded = e.loaded;
                lastTime = currentTime;
            }
        });
        
        // Handle completion
        uploadXHR.onload = function() {
            if (uploadXHR.status === 200) {
                document.getElementById('completeMessage').style.display = 'block';
                document.getElementById('completeMessage').innerHTML = '<i class="fas fa-check-circle"></i> Upload Complete! Processing...';
                document.querySelector('.cancel-btn').style.display = 'none';
                
                setTimeout(function() {
                    window.location.href = '/leaks';
                }, 3000);
            } else {
                alert('Upload failed: ' + uploadXHR.statusText);
                document.getElementById('progressPopup').style.display = 'none';
            }
        };
        
        uploadXHR.onerror = function() {
            alert('Upload failed. Please try again.');
            document.getElementById('progressPopup').style.display = 'none';
        };
        
        // Open and send
        uploadXHR.open('POST', '/upload', true);
        uploadXHR.send(formData);
    });

    function cancelUpload() {
        if (uploadXHR) {
            uploadXHR.abort();
            document.getElementById('progressPopup').style.display = 'none';
            alert('Upload cancelled');
        }
    }

    // Close popup with ESC key
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && document.getElementById('progressPopup').style.display === 'flex') {
            cancelUpload();
        }
    });

    // Update message based on data type
    function showMessage() {
        var dataType = document.getElementById('dataType').value;
        var messageArea = document.getElementById('messageArea');
        messageArea.innerHTML = '';
        switch (dataType) {
            case 'credentials':
                messageArea.innerHTML = 'Format: email:password OR url:user:password';
                break;
            case 'phone_numbers':
                messageArea.innerHTML = 'Format: One phone number per line';
                break;
            case 'misc_file':
                messageArea.innerHTML = 'Format: Raw SQL, CSV, or JSON structure';
                break;
            default:
                messageArea.innerHTML = '';
                break;
        }
    }
    
    document.getElementById('dataType').addEventListener('change', showMessage);
    showMessage();
</script>

% include("footer")
