<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <title>Leaky | Admin Login</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<style>
    /* Harmonisation avec le thème sombre moderne 2026 */
    @import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;600&family=JetBrains+Mono:wght@400;700&display=swap");

    * {
        box-sizing: border-box;
        font-family: 'Inter', sans-serif;
    }

    body {
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
        background-color: #050505;
        color: #FFFFFF;
    }

    .back-link {
        position: absolute;
        top: 20px;
        left: 20px;
        color: #888;
        text-decoration: none;
        font-size: 0.9rem;
        transition: color 0.3s;
    }
    
    .back-link:hover {
        color: #ff4d4d;
    }

    /* Conteneur du formulaire avec effet Glassmorphism */
    form {
        width: 100%;
        max-width: 400px;
        padding: 40px;
        background-color: #0f0f0f;
        border: 1px solid #1e1e1e;
        border-radius: 20px;
        box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
        text-align: center;
    }

    .login-icon {
        font-size: 3rem;
        color: #7F0000;
        margin-bottom: 20px;
    }

    form label {
        display: block;
        font-size: 1.2rem;
        font-weight: 600;
        margin-bottom: 25px;
        color: #ffffff;
        letter-spacing: -0.5px;
    }

    /* Champ password stylisé */
    form input[type="password"] {
        width: 100%;
        padding: 14px 18px;
        font-size: 16px;
        background-color: #161616;
        color: #FFFFFF;
        border: 1px solid #2a2a2a;
        border-radius: 12px;
        margin-bottom: 20px;
        outline: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        font-family: 'JetBrains Mono', monospace;
    }

    form input[type="password"]:focus {
        border-color: #7F0000;
        box-shadow: 0 0 0 4px rgba(127, 0, 0, 0.15);
        background-color: #1a1a1a;
    }

    /* Bouton de soumission avec dégradé */
    form input[type="submit"] {
        width: 100%;
        padding: 14px;
        font-size: 14px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        background: linear-gradient(135deg, #7F0000 0%, #4d0000 100%);
        color: #FFFFFF;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        transition: all 0.3s ease;
    }

    form input[type="submit"]:hover {
        background: linear-gradient(135deg, #a30000 0%, #7F0000 100%);
        transform: translateY(-2px);
        box-shadow: 0 10px 25px rgba(127, 0, 0, 0.3);
    }

    /* Message d'erreur moderne */
    .error {
        margin-top: 20px;
        color: #FF5555;
        font-size: 14px;
        text-align: center;
        padding: 10px;
        background: rgba(255, 85, 85, 0.1);
        border-radius: 8px;
        border: 1px solid rgba(255, 85, 85, 0.2);
    }
    
    .public-note {
        margin-top: 20px;
        color: #666;
        font-size: 0.8rem;
    }
    
    .public-note a {
        color: #ff4d4d;
        text-decoration: none;
    }
    
    .public-note a:hover {
        text-decoration: underline;
    }
</style>
    </head>
<body>
    <a href="/index" class="back-link"><i class="fas fa-arrow-left mr-1"></i> Back to Public Search</a>
    <div>
        <form method="post" action="/login">
            <div class="login-icon">
                <i class="fas fa-lock"></i>
            </div>
            <label for="password">Admin Access</label>
            <input id="password" type="password" name="password" required placeholder="Enter admin password">
            <input type="submit" value="Authenticate">
            
            % if failed:
                <p class="error"><i class="fas fa-exclamation-triangle mr-1"></i> Incorrect credentials</p>
            % end
            
            <div class="public-note">
                <i class="fas fa-globe mr-1"></i> Public users can search without login.<br>
                <a href="/index">Continue as guest →</a>
            </div>
        </form>
    </div>
</body>
</html>