<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <title>Leaky | Leak Database</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <link rel="stylesheet" href="/static/css/bootstrap.min.css" />
    <link rel="stylesheet" href="/static/css/style.css" />
    
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js"></script>

    <style>
        .brand-logo {
            font-weight: 800;
            letter-spacing: -1px;
            background: linear-gradient(135deg, #fff 0%, #888 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-transform: lowercase;
            font-size: 1.8rem;
        }
        
        .masthead {
            padding: 20px 0 40px 0;
            border: none;
        }

        .nav-logout {
            color: #ff4d4d !important;
            font-weight: 600 !important;
        }
        
        .nav-logout:hover {
            background: rgba(255, 77, 77, 0.1) !important;
        }
        
        .nav-login {
            color: #4CAF50 !important;
            font-weight: 600 !important;
        }
        
        .nav-login:hover {
            background: rgba(76, 175, 80, 0.1) !important;
        }

        /* Animation d'apparition de la navbar */
        .navbar {
            animation: fadeInDown 0.5s ease-out;
        }

        @keyframes fadeInDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .badge-public {
            background: rgba(255, 193, 7, 0.1);
            border: 1px solid rgba(255, 193, 7, 0.3);
            color: #ffc107;
            border-radius: 20px;
            padding: 5px 15px;
            font-size: 0.8rem;
        }
        
        .badge-admin {
            background: rgba(127, 0, 0, 0.1);
            border: 1px solid rgba(127, 0, 0, 0.3);
            color: #ff4d4d;
            border-radius: 20px;
            padding: 5px 15px;
            font-size: 0.8rem;
        }
    </style>
</head>
<body id="home">
    <div class="container-fluid">
      <div class="masthead">
        <div class="d-flex justify-content-between align-items-center mb-4 px-2">
            <div class="d-flex align-items-center">
                <h3 class="brand-logo m-0 mr-3">leaky_mod</h3>
                % if authenticated:
                    <span class="badge-admin">
                        <i class="fas fa-shield-alt mr-1"></i> Admin Mode
                    </span>
                % else:
                    <span class="badge-public">
                        <i class="fas fa-globe mr-1"></i> Public Access
                    </span>
                % end
            </div>
            <span class="badge badge-dark border border-secondary px-3 py-2" style="border-radius: 20px; font-weight: 400; opacity: 0.7;">
                <span class="text-danger">●</span> System Online
            </span>
        </div>
        <nav class="navbar navbar-expand-md">
          <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarCollapse" aria-controls="navbarCollapse" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon" style="filter: invert(1);"></span>
          </button>
          
          <div class="collapse navbar-collapse" id="navbarCollapse">
            <ul class="navbar-nav nav-justified w-100">
              <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownSearch" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                  <i class="fas fa-search mr-1"></i> Search
                </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdownSearch">
                  <a class="dropdown-item" href="/index"><i class="fas fa-key mr-2"></i>Credentials</a>
                  <a class="dropdown-item" href="/phone"><i class="fas fa-phone mr-2"></i>Phone numbers</a>
                  <a class="dropdown-item" href="/miscsearch"><i class="fas fa-file mr-2"></i>Misc files</a>
                </div>
              </li>
              <li class="nav-item">
                <a class="nav-link" href="/leaks"><i class="fas fa-database mr-1"></i> Breach inventory</a>
              </li>

              % if authenticated:
              <li class="nav-item">
                <a class="nav-link" href="/upload"><i class="fas fa-cloud-upload-alt mr-1"></i> Upload</a>
              </li>
              % end

              <li class="nav-item dropdown">
                <a class="nav-link dropdown-toggle" href="#" id="navbarDropdownMisc" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                  <i class="fas fa-ellipsis-h mr-1"></i> MISC
                </a>
                <div class="dropdown-menu" aria-labelledby="navbarDropdownMisc">
                  <a class="dropdown-item" href="/links-directory"><i class="fas fa-link mr-2"></i>Links</a>
                % if authenticated:
                <li class="nav-item">
                  <a class="nav-link nav-logout" href="/logout">Logout</a>
                % end
                </div>
              </li>
            </ul>
          </div>
        </nav>
      </div>
