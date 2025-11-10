<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Website}}</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <!-- Thêm Font Awesome cho icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin:0;
            padding:0;
            display:flex;
            flex-direction:column;
            min-height:100vh;
            background:#0d1117;
            color:#c9d1d9;
        }
        /* Header */
        header {
            background: linear-gradient(90deg,#0d1117,#1f1f1f);
            padding:30px 0;
            text-align:center;
        }
        header h1 { 
            margin:0; 
            font-size:2.5rem; 
            color:#58a6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        header p { 
            margin:5px 0 0 0; 
            font-size:1.1rem; 
            color:#8b949e; 
        }
        /* Navbar */
        nav {
            background:#161b22;
            padding:10px 0;
            text-align:center;
        }
        nav a {
            color:#58a6ff;
            margin:0 10px;
            text-decoration:none;
            font-weight:bold;
            transition: color 0.2s ease;
            padding: 5px 10px;
            border-radius: 4px;
        }
        nav a:hover { 
            color:#1f6feb; 
            background: rgba(88, 166, 255, 0.1);
        }
        nav a.active { 
            color:#ff7b72; 
            background: rgba(255, 123, 114, 0.2);
        }
        /* Main content */
        .main-content { 
            flex:1; 
            padding:40px 20px; 
            max-width:1200px; 
            margin:0 auto; 
            text-align:center; 
        }
        /* Hero section */
        .hero {
            background: linear-gradient(135deg, #1f1f1f, #0d1117);
            border-radius: 12px;
            padding: 40px;
            margin-bottom: 40px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.5);
        }
        .hero h2 {
            font-size: 2rem;
            color: #58a6ff;
            margin-bottom: 10px;
        }
        .hero p {
            font-size: 1.1rem;
            color: #8b949e;
            line-height: 1.6;
        }
        /* Warning box - làm dismissible */
        .warning {
            background:#f85149;
            color:#fff;
            padding:15px;
            border-radius:8px;
            margin:20px auto;
            font-size:1.1rem;
            width:90%;
            max-width:700px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
        }
        .warning i { margin-right: 10px; }
        .warning button {
            background: none;
            border: none;
            color: #fff;
            font-size: 1.2rem;
            cursor: pointer;
            padding: 0 5px;
            opacity: 0.8;
        }
        .warning button:hover { opacity: 1; }
        .warning.hidden { display: none; }
        .highlight { font-weight:bold; text-decoration:underline; }
        /* Dashboard cards */
        .dashboard { 
            display:grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap:25px; 
            margin-top:40px; 
        }
        .card {
            background:#161b22;
            border-radius:12px;
            padding:30px 20px;
            text-align:center;
            box-shadow:0 4px 12px rgba(0,0,0,0.5);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            border: 1px solid #30363d;
            position: relative;
            overflow: hidden;
        }
        .card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: linear-gradient(90deg, #58a6ff, #238636);
        }
        .card:hover { 
            transform: translateY(-8px); 
            box-shadow:0 12px 32px rgba(0,0,0,0.6); 
        }
        .card i {
            font-size: 3rem;
            color: #58a6ff;
            margin-bottom: 15px;
            display: block;
        }
        .card h3 { 
            margin:0 0 10px 0; 
            color:#58a6ff; 
            font-size: 1.2rem;
        }
        .card p { 
            margin:0; 
            font-size:1.5rem; 
            color:#c9d1d9; 
            font-weight: bold;
        }
        /* Loading spinner nếu data loading */
        .loading {
            border: 4px solid #30363d;
            border-top: 4px solid #58a6ff;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        @media(max-width:600px){
            .card{ padding:25px 15px; }
            nav a{ margin:0 5px; font-size:14px; }
            .warning{ font-size:1rem; padding:12px; flex-direction: column; gap:10px; }
            .hero { padding: 20px; }
            header h1 { font-size: 2rem; }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <h1><i class="fas fa-cloud-sun"></i> {{.Website}}</h1>
        <p>Version: {{.VersionInfo}} | Optimize Your Multi-Cloud Scheduling</p>
    </header>
    <!-- Navbar -->
    <nav>
        <a href="/" class="active">Home</a>
        <a href="/application">Application</a>
        <a href="/cloud">Cloud</a>
        <a href="/vm">VM</a>
        <a href="/k8sNode">Kubernetes Node</a>
        <a href="/container">Container</a>
        <a href="/image">Image</a>
        <a href="/network">Network</a>
        <a href="/state">State</a>
    </nav>
    <!-- Main content -->
    <div class="main-content">
        <!-- Hero section -->
        <div class="hero">
            <h2>Welcome to Multi-Cloud Manager</h2>
            <p>Effortlessly schedule containerized services across AWS, GCP, Azure, and more. Monitor resources, optimize RTT-based placement, and scale with ease using advanced algorithms like MCSSGA.</p>
        </div>
        
        <!-- Warning message - dismissible -->
        <div id="warningBox" class="warning">
            <span><i class="fas fa-exclamation-triangle"></i> Please use your browser's <span class="highlight">Incognito Mode</span> to visit this website; cached resources may break some features.</span>
            <button onclick="dismissWarning()">&times;</button>
        </div>
        
        <!-- Dashboard cards -->
        <div class="dashboard">
            <div class="card">
                <i class="fas fa-cloud"></i>
                <h3>Total Clouds</h3>
                <p id="totalClouds">{{.TotalClouds}}</p>
            </div>
            <div class="card">
                <i class="fas fa-server"></i>
                <h3>Total VMs</h3>
                <p id="totalVMs">{{.TotalVMs}}</p>
            </div>
            <div class="card">
                <i class="fas fa-tachometer-alt"></i>
                <h3>Available Resources</h3>
                <p id="availableResources">{{.AvailableResources}}</p>
            </div>
            <div class="card">
                <i class="fas fa-chart-line"></i>
                <h3>Occupied Resources</h3>
                <p id="occupiedResources">{{.OccupiedResources}}</p>
            </div>
        </div>
        
        <!-- Nếu data đang load, show spinner (tùy chọn) -->
        <!-- <div class="loading" id="loadingSpinner" style="display:none;"></div> -->
    </div>
    <!-- Footer -->
    {{template "footer" .}}
    <script>
        // Dismiss warning
        function dismissWarning() {
            document.getElementById('warningBox').classList.add('hidden');
        }
        
        // Highlight active navbar link (cải thiện: check pathname thay href)
        document.addEventListener('DOMContentLoaded', function() {
            const currentPath = window.location.pathname;
            document.querySelectorAll('nav a').forEach(link => {
                const href = link.getAttribute('href');
                if (href === currentPath || (currentPath === '/' && href === '/')) {
                    link.classList.add('active');
                } else {
                    link.classList.remove('active');
                }
            });
            
            // Lưu dismiss warning vào localStorage
            if (localStorage.getItem('dismissWarning') === 'true') {
                dismissWarning();
            }
            // Event cho dismiss
            document.querySelector('.warning button').addEventListener('click', function() {
                localStorage.setItem('dismissWarning', 'true');
                dismissWarning();
            });
        });
        
        // Tùy chọn: Fetch real-time data (AJAX từ /api/stats)
        // fetch('/api/stats').then(res => res.json()).then(data => {
        //     document.getElementById('totalClouds').textContent = data.totalClouds;
        //     // Tương tự cho các card khác
        // });
    </script>
</body>
</html>