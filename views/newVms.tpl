<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create New VMs</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <!-- Thêm Font Awesome cho icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin:0;
            padding:0;
            background:#0d1117;
            color:#c9d1d9;
            display:flex;
            flex-direction:column;
            min-height:100vh;
        }
        /* Header */
        header {
            background: linear-gradient(90deg,#0d1117,#1f1f1f);
            padding:20px 0;
            text-align:center;
        }
        header h1 { margin:0; font-size:2rem; color:#58a6ff; }
        header p { margin:5px 0 0 0; font-size:1rem; color:#8b949e; }
        /* Navbar */
        nav {
            background:#161b22;
            padding:10px 0;
            text-align:center;
        }
        nav a {
            color:#58a6ff;
            margin:0 15px;
            text-decoration:none;
            font-weight:bold;
            transition: color 0.2s ease;
        }
        nav a:hover { color:#1f6feb; }
        nav a.active { color:#ff7b72; }
        /* Main content */
        .main-content {
            flex:1;
            padding:40px 20px;
            max-width:1000px;
            margin:0 auto;
            text-align:center;
        }
        /* VM cards */
        .dashboard { 
            display:flex; 
            flex-wrap:wrap; 
            justify-content:center; 
            gap:20px; 
            margin-top:20px; 
        }
        .card {
            background:#161b22;
            border-radius:12px;
            padding:20px;
            width:280px;  /* Tăng width để fit inputs */
            text-align:left;  /* Đổi thành left cho form */
            box-shadow:0 4px 12px rgba(0,0,0,0.5);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border:1px solid #30363d;
        }
        .card:hover { transform: translateY(-5px); box-shadow:0 8px 20px rgba(0,0,0,0.6); }
        .card h3 { 
            margin-bottom:10px; 
            color:#58a6ff; 
            text-align:center;
            display:flex;
            align-items:center;
            justify-content:center;
            gap:5px;
        }
        .card input, .card select {
            width:100%;  /* Full width cho inputs */
            padding:8px;
            margin:5px 0;
            border-radius:6px;
            border:1px solid #30363d;
            background:#0d1117;
            color:#c9d1d9;
            box-sizing:border-box;
        }
        .card input:focus, .card select:focus {
            border-color:#58a6ff;
            outline:none;
        }
        .card button.remove-vm {
            width:100%;
            margin-top:10px;
            padding:6px 12px;
            cursor:pointer;
            border:none;
            border-radius:8px;
            background:#da3633;
            color:#fff;
            font-weight:bold;
        }
        .card button.remove-vm:hover { background:#f85149; }
        /* Controls */
        .controls { margin:20px 0; }
        #btnAddVm {
            background:#58a6ff;
            color:#fff;
            border:none;
            border-radius:8px;
            padding:10px 20px;
            font-weight:bold;
            cursor:pointer;
            transition: background 0.2s;
        }
        #btnAddVm:hover { background:#1f6feb; }
        #vmsInfoSubmit {
            background:#238636;
            color:#fff;
            border:none;
            border-radius:8px;
            padding:12px 24px;
            font-weight:bold;
            cursor:pointer;
            margin-top:20px;
            font-size:1.1rem;
        }
        #vmsInfoSubmit:hover { background:#2ea043; }
        #vmsInfoSubmit:disabled { background:#8b949e; cursor:not-allowed; }
        /* Alert cho note */
        .alert-warning {
            background:#f0c14b;
            color:#000;
            padding:10px;
            border-radius:6px;
            margin:10px 0;
            border:1px solid #f0c14b;
        }
        @media(max-width:600px){
            .card { width:90%; padding:15px; }
            nav a { margin:0 10px; font-size:14px; }
            .dashboard { flex-direction:column; align-items:center; }
        }
    </style>
</head>
<body>
    <header>
        <h1><i class="fas fa-server"></i> EM Controller</h1>
        <p>Create New Virtual Machines</p>
    </header>
    <nav>
        <a href="/">Home</a>
        <a href="/application">Application</a>
        <a href="/cloud">Cloud</a>
        <a href="/vm" class="active">VM</a>
        <a href="/k8sNode">K8s Node</a>
        <a href="/container">Container</a>
        <a href="/image">Image</a>
        <a href="/network">Network</a>
        <a href="/state">State</a>
    </nav>
    <div class="main-content">
        <!-- Note từ template con, nhưng làm alert trực tiếp cho gọn -->
        <div class="alert-warning">
            <i class="fas fa-exclamation-triangle"></i> 
            Note: All names should follow the DNS label standard as defined in RFC 1123 (contain at most 63 characters, only lowercase alphanumeric or "-", start/end with alphanumeric).
        </div>
        
        <div class="controls">
            <button type="button" id="btnAddVm">
                <i class="fas fa-plus"></i> Add VM
            </button>
        </div>
        
        <div class="dashboard" id="vmsStart">
            <!-- JS sẽ add VM card vào đây -->
        </div>
        
        <form id="vmsInfo" action="/vm/doNew" method="post">
            <input type="hidden" id="newVmNum" name="newVmNumber" value="0">
            <input type="submit" id="vmsInfoSubmit" value="Create VMs" disabled>  <!-- Disable ban đầu, enable khi có VM -->
        </form>
    </div>
    
    <!-- JS Inline: Xóa defer script cũ, thay bằng cái này -->
    <script>
        let vmCount = 0;  // Đếm số VM
        
        // Template cho 1 VM card (HTML string)
        function getVmCard(index) {
            return `
                <div class="card" data-vm-index="${index}">
                    <h3><i class="fas fa-laptop"></i> VM ${index + 1}</h3>
                    <input type="text" name="vm[${index}][name]" placeholder="VM Name (e.g., my-vm-01)" required maxlength="63">
                    <select name="vm[${index}][cloud_type]" required>
                        <option value="">Select Cloud Type</option>
                        <option value="AWS">AWS</option>
                        <option value="GCP">GCP</option>
                        <option value="Azure">Azure</option>
                    </select>
                    <input type="number" name="vm[${index}][cpu]" placeholder="CPU Cores (e.g., 2)" min="1" required>
                    <input type="number" name="vm[${index}][memory]" placeholder="Memory (MB, e.g., 2048)" min="512" required>
                    <input type="number" name="vm[${index}][storage]" placeholder="Storage (GB, e.g., 50)" min="10" required>
                    <input type="text" name="vm[${index}][ip]" placeholder="IP Address (optional)">
                    <button type="button" class="remove-vm" onclick="removeVm(${index})" style="display: ${vmCount > 0 ? 'block' : 'none'};">
                        <i class="fas fa-trash"></i> Remove VM
                    </button>
                </div>
            `;
        }
        
        // Add VM card
        document.getElementById('btnAddVm').addEventListener('click', function() {
            const dashboard = document.getElementById('vmsStart');
            const newCard = getVmCard(vmCount);
            dashboard.insertAdjacentHTML('beforeend', newCard);
            vmCount++;
            document.getElementById('newVmNum').value = vmCount;
            document.getElementById('vmsInfoSubmit').disabled = false;  // Enable submit
            updateRemoveButtons();  // Update remove cho card đầu
        });
        
        // Remove VM card
        function removeVm(index) {
            const card = document.querySelector(`[data-vm-index="${index}"]`);
            if (card) {
                card.remove();
                vmCount--;
                document.getElementById('newVmNum').value = vmCount;
                if (vmCount === 0) {
                    document.getElementById('vmsInfoSubmit').disabled = true;
                }
                // Renumber remaining cards (tùy chọn, để tránh gap index)
                renumberVms();
            }
        }
        
        // Renumber VMs sau remove
        function renumberVms() {
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, newIndex) => {
                card.setAttribute('data-vm-index', newIndex);
                card.querySelector('h3').innerHTML = `<i class="fas fa-laptop"></i> VM ${newIndex + 1}`;
                const inputs = card.querySelectorAll('input, select');
                inputs.forEach(input => {
                    const name = input.name.replace(/vm\[\d+\]/, `vm[${newIndex}]`);
                    input.name = name;
                });
            });
            vmCount = cards.length;
            document.getElementById('newVmNum').value = vmCount;
        }
        
        // Update remove button (ẩn ở card đầu nếu chỉ 1)
        function updateRemoveButtons() {
            const cards = document.querySelectorAll('.card');
            cards.forEach((card, index) => {
                const removeBtn = card.querySelector('.remove-vm');
                if (removeBtn) {
                    removeBtn.style.display = cards.length > 1 ? 'block' : 'none';
                }
            });
        }
        
        // Validation trước submit (DNS name + required)
        document.getElementById('vmsInfo').addEventListener('submit', function(e) {
            let valid = true;
            const nameInputs = document.querySelectorAll('input[name^="vm["][name$="[name]"]');
            nameInputs.forEach(input => {
                const name = input.value.trim();
                if (!name) {
                    valid = false;
                    return;
                }
                // Regex DNS label (RFC 1123)
                const dnsRegex = /^[a-z0-9]([a-z0-9-]*[a-z0-9])?$/;
                if (!dnsRegex.test(name) || name.length > 63) {
                    alert(`Invalid name "${name}": Must be lowercase alphanumeric + '-', start/end with alphanumeric, max 63 chars.`);
                    valid = false;
                    input.focus();
                    return;
                }
            });
            if (!valid) {
                e.preventDefault();
            }
        });
        
        // Tự add 1 VM đầu để demo (tùy chọn, uncomment nếu muốn)
        // document.getElementById('btnAddVm').click();
    </script>
    
    {{template "footer" .}}  <!-- Giữ footer nếu có -->
</body>
</html>