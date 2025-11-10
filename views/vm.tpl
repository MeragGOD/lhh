<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VM - {{.Website}}</title>
    <link rel="stylesheet" href="/static/css/style.css">
    <link rel="stylesheet" href="/static/css/button.css">
    <!-- Thêm Font Awesome cho icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" rel="stylesheet">
    <style>
        body { font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin:0; padding:0; display:flex; flex-direction:column; min-height:100vh; background:#0d1117; color:#c9d1d9; }
        header { background: linear-gradient(90deg,#0d1117,#1f1f1f); padding:20px 0; text-align:center; }
        header h1 { margin:0; font-size:2rem; color:#58a6ff; }
        nav { background:#161b22; padding:10px 0; text-align:center; }
        nav a { color:#58a6ff; margin:0 15px; text-decoration:none; font-weight:bold; transition: color 0.2s; }
        nav a:hover { color:#1f6feb; }
        nav a.active { color:#ff7b72; }
        .main-content { flex:1; padding:40px 20px; max-width:1200px; margin:0 auto; }
        h2, h3 { color:#58a6ff; text-align:center; }
        button.button { padding:8px 16px; border-radius:6px; border:none; cursor:pointer; background:#238636; color:#fff; }
        button.button:hover { background:#2ea043; }
        .btn-danger { background:#da3633; }
        .btn-danger:hover { background:#f85149; }
        .btn-sm { padding:4px 8px; font-size:0.8rem; }
        .btn-group { text-align:center; margin-bottom:10px; }
        .btn-group input[type="checkbox"] { margin-right:10px; transform: scale(1.2); }
        /* Search nhẹ */
        .search-container { text-align:center; margin-bottom:10px; }
        .search-container input {
            padding:8px;
            border-radius:6px;
            border:1px solid #30363d;
            background:#0d1117;
            color:#c9d1d9;
            width:250px;
            max-width:100%;
        }
        .search-container input::placeholder { color:#8b949e; }
        .table-container { overflow-x:auto; margin-top:20px; background:#161b22; border-radius:12px; box-shadow:0 4px 12px rgba(0,0,0,0.5); }
        table { width:100%; border-collapse:collapse; background:#161b22; }
        table th, table td { padding:12px 15px; text-align:left; border-bottom:1px solid #272b33; }
        table th { background:#1f1f1f; color:#58a6ff; position:sticky; top:0; }
        table tr:hover { background:#272b33; }
        table tr:nth-child(even) { background:#0d1117; }
        /* Status badges */
        .status-badge {
            padding:4px 8px;
            border-radius:4px;
            font-size:0.8rem;
            font-weight:bold;
        }
        .status-running { background:#238636; color:#fff; }
        .status-stopped { background:#da3633; color:#fff; }
        .status-pending { background:#58a6ff; color:#fff; }
        /* MCM created */
        .mcm-created { color:#238636; font-weight:bold; }
        .mcm-manual { color:#da3633; font-weight:bold; }
        /* IPs */
        .ip-list { line-height:1.4; }
        .ip-badge { background:#6c757d; color:#fff; padding:2px 6px; border-radius:3px; font-size:0.8rem; margin-right:5px; margin-bottom:2px; display:inline-block; }
        /* Cloud badges */
        .badge { padding:4px 8px; border-radius:4px; font-size:0.8rem; font-weight:bold; color:#fff; }
        .bg-primary { background:#58a6ff; }
        .bg-secondary { background:#6c757d; }
        @media(max-width:600px){ table th, table td{padding:8px; font-size:0.9rem;} nav a{margin:0 10px;} .search-container input { width:100%; } }
    </style>
</head>
<body>
<header>
    <h1><i class="fas fa-laptop"></i> {{.Website}}</h1>
    <p>Version: {{.VersionInfo}}</p>
</header>
<nav>
    <a href="/" >Home</a>
    <a href="/application">Application</a>
    <a href="/cloud">Cloud</a>
    <a href="/vm" class="active">VM</a>
    <a href="/k8sNode">Kubernetes Node</a>
    <a href="/container">Container</a>
    <a href="/image">Image</a>
    <a href="/network">Network</a>
    <a href="/state">State</a>
</nav>
<div class="main-content">
    <div class="btn-group">
        <button class="button btn-primary" onclick="window.open('/vm/new', '_blank')"><i class="fas fa-plus"></i> Create VMs</button>
        <label><input type="checkbox" id="selectAllCheckbox"> Select All</label>
        <button id="deleteSelectedButton" type="button" class="button btn-danger" onclick="deleteBatchVMs()" disabled><i class="fas fa-trash"></i> Delete Selected</button>
    </div>
    <div class="search-container">
        <input type="text" id="vmSearch" placeholder="Search VMs by name, cloud, or ID..." onkeyup="searchVMs()">
    </div>
    <h3>Existing VMs in All Clouds <i class="fas fa-list"></i></h3>
    <div class="table-container">
        <table id="vmTable">
            <tr>
                <th><input type="checkbox" id="headerCheckbox"></th>
                <th>Actions</th>
                <th>MCM Created</th>
                <th>Name</th>
                <th>Cloud Type</th>
                <th>Cloud</th>
                <th>ID</th>
                <th>IP Addresses</th>
                <th>CPU</th>
                <th>RAM</th>
                <th>Storage</th>
                <th>Status</th>
            </tr>
            {{range $vmIdx, $vm := .allVms}}
            {{$statusID := printf "vmStatus-%s-%s" $vm.Cloud $vm.ID}}
            <tr class="vm-row">
                <td><input type="checkbox" class="vmCheckbox" value="{{$vm.ID}}"></td>
                <td><button type="button" class="button btn-danger btn-sm" onclick="deleteVM('{{$vm.Cloud}}', '{{$vm.ID}}', '{{$statusID}}')"><i class="fas fa-trash"></i></button></td>
                <td class="{{if $vm.McmCreate}}mcm-created{{else}}mcm-manual{{end}}">{{if $vm.McmCreate}}Yes{{else}}Manual{{end}}</td>
                <td><i class="fas fa-tag"></i> {{$vm.Name}}</td>
                <td><span class="badge bg-primary">{{$vm.CloudType}}</span></td>
                <td><span class="badge bg-secondary">{{$vm.Cloud}}</span></td>
                <td>{{$vm.ID}}</td>
                <td class="ip-list">
                    {{range $idx, $ip := $vm.IPs}}
                        <span class="ip-badge">{{$ip}}</span><br>
                    {{end}}
                </td>
                <td><i class="fas fa-microchip"></i> {{$vm.VCpu}}</td>
                <td><i class="fas fa-memory"></i> {{$vm.Ram}}</td>
                <td><i class="fas fa-hdd"></i> {{$vm.Storage}}</td>
                <td><span class="status-badge {{if eq $vm.Status "Running"}}status-running{{else if eq $vm.Status "Stopped"}}status-stopped{{else}}status-pending{{end}}">{{$vm.Status}}</span></td>
            </tr>
            {{end}}
        </table>
    </div>
</div>
{{template "footer" .}}
<script src="/static/js/vm.js"></script>
<script>
    // Select all
    document.getElementById('headerCheckbox').addEventListener('change', function() {
        document.querySelectorAll('.vmCheckbox').forEach(cb => cb.checked = this.checked);
        updateDeleteButton();
    });
    document.querySelectorAll('.vmCheckbox').forEach(cb => cb.addEventListener('change', updateDeleteButton));
    function updateDeleteButton() {
        const checked = document.querySelectorAll('.vmCheckbox:checked').length > 0;
        document.getElementById('deleteSelectedButton').disabled = !checked;
    }
    // Search
    function searchVMs() {
        const input = document.getElementById('vmSearch').value.toLowerCase();
        document.querySelectorAll('.vm-row').forEach(row => {
            row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none';
        });
    }
    // Delete confirm
    function deleteVM(cloud, id, statusId) {
        if (confirm(`Delete VM '${id}' from ${cloud}?`)) {
            document.getElementById(statusId).innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
            // TODO: AJAX call
        }
    }
    function deleteBatchVMs() {
        const checked = document.querySelectorAll('.vmCheckbox:checked');
        if (checked.length === 0) return;
        if (confirm(`Delete ${checked.length} selected VMs?`)) {
            checked.forEach(cb => cb.closest('tr').remove());
            updateDeleteButton();
        }
    }
    updateDeleteButton();
</script>
</body>
</html>