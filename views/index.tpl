<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{.Website}}</title>
    <link rel="stylesheet" href="/static/css/style.css">
<<<<<<< HEAD
    <!-- Font Awesome for icons -->
=======
    <!-- Thêm Font Awesome cho icons -->
>>>>>>> origin/main
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin:0;
            padding:0;
            display:flex;
            flex-direction:column;
            min-height:100vh;
<<<<<<< HEAD
            background: linear-gradient(135deg, #0d1117 0%, #1a1a2e 100%);
=======
            background:#0d1117;
>>>>>>> origin/main
            color:#c9d1d9;
        }
        /* Header */
        header {
<<<<<<< HEAD
            background: linear-gradient(90deg, #0d1117 0%, #16213e 100%);
            padding:40px 0;
            text-align:center;
            box-shadow: 0 4px 20px rgba(0,0,0,0.3);
        }
        header h1 {
            margin:0;
            font-size:2.8rem;
=======
            background: linear-gradient(90deg,#0d1117,#1f1f1f);
            padding:30px 0;
            text-align:center;
        }
        header h1 { 
            margin:0; 
            font-size:2.5rem; 
>>>>>>> origin/main
            color:#58a6ff;
            display: flex;
            align-items: center;
            justify-content: center;
<<<<<<< HEAD
            gap: 15px;
            text-shadow: 0 2px 4px rgba(88, 166, 255, 0.3);
        }
        header p {
            margin:5px 0 0 0;
            font-size:1.2rem;
            color:#8b949e;
            letter-spacing: 0.5px;
=======
            gap: 10px;
        }
        header p { 
            margin:5px 0 0 0; 
            font-size:1.1rem; 
            color:#8b949e; 
>>>>>>> origin/main
        }
        /* Navbar */
        nav {
            background:#161b22;
<<<<<<< HEAD
            padding:12px 0;
            text-align:center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.5);
        }
        nav a {
            color:#58a6ff;
            margin:0 12px;
            text-decoration:none;
            font-weight:bold;
            transition: all 0.3s ease;
            padding: 8px 16px;
            border-radius: 6px;
            position: relative;
        }
        nav a:hover {
            color:#1f6feb;
            background: rgba(88, 166, 255, 0.15);
            transform: translateY(-2px);
        }
        nav a.active {
            color:#ff7b72;
            background: rgba(255, 123, 114, 0.2);
        }
        /* Main content */
        .main-content {
            flex:1;
            padding:50px 20px;
            max-width:1200px;
            margin:0 auto;
            text-align:center;
=======
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
>>>>>>> origin/main
        }
        /* Hero section */
        .hero {
            background: linear-gradient(135deg, #1f1f1f, #0d1117);
<<<<<<< HEAD
            border-radius: 16px;
            padding: 50px 30px;
            margin-bottom: 50px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.4);
            border: 1px solid rgba(88, 166, 255, 0.1);
        }
        .hero h2 {
            font-size: 2.5rem;
            color: #58a6ff;
            margin-bottom: 15px;
            text-shadow: 0 2px 4px rgba(88, 166, 255, 0.2);
        }
        .hero p {
            font-size: 1.2rem;
            color: #8b949e;
            line-height: 1.7;
            max-width: 800px;
            margin: 0 auto;
        }
        /* Warning box - làm dismissible */
        .warning {
            background: linear-gradient(90deg, #f85149, #da3633);
            color:#fff;
            padding:18px 20px;
            border-radius:10px;
=======
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
>>>>>>> origin/main
            margin:20px auto;
            font-size:1.1rem;
            width:90%;
            max-width:700px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            position: relative;
<<<<<<< HEAD
            box-shadow: 0 4px 12px rgba(248, 81, 73, 0.3);
=======
>>>>>>> origin/main
        }
        .warning i { margin-right: 10px; }
        .warning button {
            background: none;
            border: none;
            color: #fff;
<<<<<<< HEAD
            font-size: 1.3rem;
            cursor: pointer;
            padding: 0 8px;
            opacity: 0.9;
            transition: opacity 0.2s;
=======
            font-size: 1.2rem;
            cursor: pointer;
            padding: 0 5px;
            opacity: 0.8;
>>>>>>> origin/main
        }
        .warning button:hover { opacity: 1; }
        .warning.hidden { display: none; }
        .highlight { font-weight:bold; text-decoration:underline; }
<<<<<<< HEAD
        /* Weather Section – Chọn thành phố & Hiển thị issues/gợi ý */
        .weather-section {
            background: linear-gradient(145deg, #16213e, #0f3460);
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 40px;
            box-shadow: 0 8px 25px rgba(88, 166, 255, 0.1);
            border: 1px solid rgba(88, 166, 255, 0.2);
            text-align: center;
        }
        .city-selector {
            margin-bottom: 20px;
        }
        .city-selector label {
            color: #58a6ff;
            font-weight: bold;
            margin-right: 10px;
        }
        .city-selector select {
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px solid #30363d;
            background: #0d1117;
            color: #c9d1d9;
            font-size: 1rem;
            cursor: pointer;
        }
        .weather-display {
            font-size: 2.5rem;
            color: #ffeb3b;
            font-weight: bold;
            margin: 10px 0;
            text-shadow: 0 2px 4px rgba(255, 235, 59, 0.3);
        }
        .weather-time {
            color: #8b949e;
            font-size: 1rem;
            margin-bottom: 15px;
        }
        .weather-issues {
            background: rgba(255, 123, 114, 0.1);
            border: 1px solid rgba(255, 123, 114, 0.3);
            border-radius: 8px;
            padding: 15px;
            margin: 15px 0;
            text-align: left;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .weather-issues h4 {
            color: #ff7b72;
            margin: 0 0 10px 0;
            font-size: 1.1rem;
        }
        .weather-issues ul {
            list-style: none;
            padding: 0;
            margin: 0;
            color: #c9d1d9;
        }
        .weather-issues li {
            padding: 5px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .weather-issues li i {
            color: #ff7b72;
            margin-right: 8px;
        }
        .weather-suggestion {
            background: rgba(35, 134, 54, 0.1);
            border: 1px solid rgba(35, 134, 54, 0.3);
            border-radius: 8px;
            padding: 15px;
            margin: 15px 0;
            text-align: left;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .weather-suggestion h4 {
            color: #238636;
            margin: 0 0 10px 0;
            font-size: 1.1rem;
        }
        .weather-suggestion ul {
            list-style: none;
            padding: 0;
            margin: 0;
            color: #c9d1d9;
        }
        .weather-suggestion li {
            padding: 5px 0;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .weather-suggestion li i {
            color: #238636;
            margin-right: 8px;
        }
        .update-btn {
            background: #58a6ff;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            margin-top: 10px;
            transition: background 0.3s;
        }
        .update-btn:hover {
            background: #1f6feb;
        }
        /* Dashboard cards */
        .dashboard {
            display:grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap:25px;
            margin-top:40px;
=======
        /* Dashboard cards */
        .dashboard { 
            display:grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap:25px; 
            margin-top:40px; 
>>>>>>> origin/main
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
<<<<<<< HEAD
        .card:hover {
            transform: translateY(-8px);
            box-shadow:0 12px 32px rgba(0,0,0,0.6);
=======
        .card:hover { 
            transform: translateY(-8px); 
            box-shadow:0 12px 32px rgba(0,0,0,0.6); 
>>>>>>> origin/main
        }
        .card i {
            font-size: 3rem;
            color: #58a6ff;
            margin-bottom: 15px;
            display: block;
        }
<<<<<<< HEAD
        .card h3 {
            margin:0 0 10px 0;
            color:#58a6ff;
            font-size: 1.2rem;
        }
        .card p {
            margin:0;
            font-size:1.5rem;
            color:#c9d1d9;
=======
        .card h3 { 
            margin:0 0 10px 0; 
            color:#58a6ff; 
            font-size: 1.2rem;
        }
        .card p { 
            margin:0; 
            font-size:1.5rem; 
            color:#c9d1d9; 
>>>>>>> origin/main
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
<<<<<<< HEAD
            .dashboard { grid-template-columns: 1fr; gap:20px; }
            .weather-section { padding: 20px; }
=======
>>>>>>> origin/main
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
<<<<<<< HEAD
        <h1><i class="fas fa-cloud-sun-rain"></i> {{.Website}}</h1>
        <p>Version: {{.VersionInfo}} | Optimize Your Multi-Cloud Scheduling with Smart Weather Insights</p>
=======
        <h1><i class="fas fa-cloud-sun"></i> {{.Website}}</h1>
        <p>Version: {{.VersionInfo}} | Optimize Your Multi-Cloud Scheduling</p>
>>>>>>> origin/main
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
<<<<<<< HEAD
            <p>Effortlessly schedule containerized services across AWS, GCP, Azure, and more. Monitor resources, optimize RTT-based placement, and scale with ease using advanced algorithms like MCSSGA – now with real-time weather insights for adaptive scheduling.</p>
        </div>
       
=======
            <p>Effortlessly schedule containerized services across AWS, GCP, Azure, and more. Monitor resources, optimize RTT-based placement, and scale with ease using advanced algorithms like MCSSGA.</p>
        </div>
        
>>>>>>> origin/main
        <!-- Warning message - dismissible -->
        <div id="warningBox" class="warning">
            <span><i class="fas fa-exclamation-triangle"></i> Please use your browser's <span class="highlight">Incognito Mode</span> to visit this website; cached resources may break some features.</span>
            <button onclick="dismissWarning()">&times;</button>
        </div>
<<<<<<< HEAD

        <!-- Weather Section – Chọn thành phố & Hiển thị issues/gợi ý -->
        <div class="weather-section">
            <div class="city-selector">
                <label for="citySelect"><i class="fas fa-map-marker-alt"></i> Chọn Thành Phố:</label>
                <select id="citySelect" onchange="updateWeather()">
                    <option value="hanoi">Hà Nội (21.0285, 105.8542)</option>
                    <option value="hcm">TP. Hồ Chí Minh (10.8231, 106.6297)</option>
                    <option value="singapore">Singapore (1.3521, 103.8198)</option>
                    <option value="tokyo">Tokyo (35.6762, 139.6503)</option>
                </select>
                <button class="update-btn" onclick="updateWeather()"><i class="fas fa-sync-alt"></i> Cập Nhật</button>
            </div>
            <div id="weatherDisplay">
                <p class="weather-display" id="weatherTemp">{{.WeatherTemp}}</p>
                <p class="weather-time" id="weatherTime">Cập nhật: {{.WeatherTime}}</p>
            </div>
            <div id="weatherIssues" class="weather-issues" style="display:none;">
                <h4><i class="fas fa-exclamation-triangle"></i> Vấn Đề Ảnh Hưởng Cloud:</h4>
                <ul id="issuesList">
                    <!-- Dynamic list, e.g., <li><i class="fas fa-thermometer-half"></i> Nhiệt độ cao: Tăng tải CPU 15%.</li> -->
                </ul>
            </div>
            <div id="weatherSuggestion" class="weather-suggestion" style="display:none;">
                <h4><i class="fas fa-lightbulb"></i> Gợi Ý Quản Lý Cloud:</h4>
                <ul id="suggestionList">
                    <!-- Dynamic, e.g., <li><i class="fas fa-arrow-up"></i> Scale up VMs ở AWS Singapore nếu temp >35°C.</li> -->
                </ul>
            </div>
        </div>
       
=======
        
>>>>>>> origin/main
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
<<<<<<< HEAD
       
=======
        
>>>>>>> origin/main
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
<<<<<<< HEAD
       
        // Highlight active navbar link
=======
        
        // Highlight active navbar link (cải thiện: check pathname thay href)
>>>>>>> origin/main
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
<<<<<<< HEAD
           
=======
            
>>>>>>> origin/main
            // Lưu dismiss warning vào localStorage
            if (localStorage.getItem('dismissWarning') === 'true') {
                dismissWarning();
            }
            // Event cho dismiss
            document.querySelector('.warning button').addEventListener('click', function() {
                localStorage.setItem('dismissWarning', 'true');
                dismissWarning();
            });
<<<<<<< HEAD

            // Weather update function (AJAX to /api/weather?city=hanoi) – Global để onchange gọi được
            window.updateWeather = function() {
                const city = document.getElementById('citySelect').value;
                console.log('Updating weather for city:', city); // Debug log

                const spinner = '<i class="fas fa-spinner fa-spin"></i> Đang tải...';
                document.getElementById('weatherTemp').innerHTML = spinner;
                document.getElementById('weatherIssues').style.display = 'none';
                document.getElementById('weatherSuggestion').style.display = 'none';

                fetch(`/api/weather?city=${city}`)
                    .then(res => {
                        console.log('Response status:', res.status); // Debug status
                        if (!res.ok) {
                            throw new Error(`HTTP ${res.status}: ${res.statusText}`);
                        }
                        return res.json();
                    })
                    .then(data => {
                        console.log('Weather data received:', data); // Debug data
                        document.getElementById('weatherTemp').innerHTML = data.temp + '°C';
                        document.getElementById('weatherTime').innerHTML = 'Cập nhật: ' + new Date().toLocaleTimeString('vi-VN');
                        if (data.issues && data.issues.length > 0) {
                            const issuesList = document.getElementById('issuesList');
                            issuesList.innerHTML = '';
                            data.issues.forEach(issue => {
                                const li = document.createElement('li');
                                li.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${issue}`;
                                issuesList.appendChild(li);
                            });
                            document.getElementById('weatherIssues').style.display = 'block';
                        }
                        if (data.suggestions && data.suggestions.length > 0) {
                            const suggestionList = document.getElementById('suggestionList');
                            suggestionList.innerHTML = '';
                            data.suggestions.forEach(suggestion => {
                                const li = document.createElement('li');
                                li.innerHTML = `<i class="fas fa-lightbulb"></i> ${suggestion}`;
                                suggestionList.appendChild(li);
                            });
                            document.getElementById('weatherSuggestion').style.display = 'block';
                        }
                    })
                    .catch(err => {
                        console.error('Weather fetch error:', err); // Full error log
                        document.getElementById('weatherTemp').innerHTML = 'Lỗi: ' + err.message;
                    });
            };
            // Initial load
            updateWeather();
        });
=======
        });
        
        // Tùy chọn: Fetch real-time data (AJAX từ /api/stats)
        // fetch('/api/stats').then(res => res.json()).then(data => {
        //     document.getElementById('totalClouds').textContent = data.totalClouds;
        //     // Tương tự cho các card khác
        // });
>>>>>>> origin/main
    </script>
</body>
</html>