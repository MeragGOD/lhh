<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Application - {{.Website}}</title>
<link rel="stylesheet" href="/static/css/style.css">
<script src="/static/js/application.js"></script>
<style>
body { font-family:'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin:0; padding:0; display:flex; flex-direction:column; min-height:100vh; background:#0d1117; color:#c9d1d9; }
header { background: linear-gradient(90deg,#0d1117,#1f1f1f); padding:20px 0; text-align:center; }
header h1 { margin:0; font-size:2rem; }
nav { background:#161b22; padding:10px 0; text-align:center; }
nav a { color:#58a6ff; margin:0 15px; text-decoration:none; font-weight:bold; transition: color 0.2s; }
nav a:hover { color:#1f6feb; }
nav a.active { color:#ff7b72; }
.main-content { flex:1; padding:40px 20px; max-width:1000px; margin:0 auto; }
h2, h3 { color:#58a6ff; text-align:center; }
form { text-align:center; margin:20px 0; }
input[type=submit] { padding:8px 16px; background:#238636; color:#fff; border:none; border-radius:6px; cursor:pointer; }
input[type=submit]:hover { background:#2ea043; }
.table-container { overflow-x:auto; margin-top:20px; }
table { width:100%; border-collapse:collapse; background:#161b22; border-radius:12px; overflow:hidden; }
table th, table td { padding:12px 15px; text-align:left; border-bottom:1px solid #272b33; }
table th { background:#1f1f1f; color:#58a6ff; }
table tr:hover { background:#272b33; }
button { padding:6px 12px; border:none; border-radius:6px; cursor:pointer; background:#238636; color:#fff; }
button:hover { background:#2ea043; }
@media(max-width:600px){ table th, table td{padding:8px;} nav a{margin:0 10px;} }
</style>
</head>
<body>

<header>
    <h1>{{.Website}}</h1>
    <p>Version: {{.VersionInfo}}</p>
</header>

<nav>
    <a href="/" >Home</a>
    <a href="/application" class="active">Application</a>
    <a href="/cloud">Cloud</a>
    <a href="/vm">VM</a>
</nav>

<div class="main-content">

    <h3>New Application</h3>
    <form method="get" action="/newApplication" target="_blank">
        <input type="radio" name="mode" value="basic" checked="checked" />Basic Mode
        <input type="radio" name="mode" value="advanced" />Advanced Mode <br><br>
        <input type="submit" value="New">
    </form>

    <h3>Existing Applications</h3>
    <div style="text-align:center; margin-bottom:10px;">
        <button id="deleteSelectedButton" type="button" onclick="deleteBatchApps()">Delete Selected Applications</button>
    </div>

    <div class="table-container">
        <table>
            <tr>
                <th></th>
                <th></th>
                <th>App Name</th>
                <th>Internal Access</th>
                <th>External Access</th>
                <th>Status</th>
                <th>Host Kubernetes Node<br>(PodIP/NodeName/NodeIP)</th>
            </tr>
            {{range $appIdx, $app := .applicationList}}
            {{$statusID := printf "appStatus%s" $app.AppName}}
            <tr>
                <td><input type="checkbox" class="appCheckbox"></td>
                <td><button type="button" onclick="deleteApp('{{$app.AppName}}', '{{$statusID}}')">Delete</button></td>
                <td>{{$app.AppName}}</td>
                <td>
                    {{if not (eq $app.ClusterIP "" "None") }}
                        {{range $idx, $svcPort := $app.SvcPort}}
                        {{$app.SvcName}}:{{$svcPort}} <br>
                        {{$app.ClusterIP}}:{{$svcPort}} <br>
                        {{end}}
                    {{end}}
                </td>
                <td>
                    {{range $idx, $nodePortIP := $app.NodePortIP}}
                        {{range $idx, $nodePort := $app.NodePort}}
                            {{$nodePortIP}}:{{$nodePort}} <br>
                        {{end}}
                    {{end}}
                </td>
                <td id="{{$statusID}}">{{$app.Status}}</td>
                <td>
                    {{range $idx, $podHost := $app.Hosts}}
                    {{$podHost.PodIP}}/{{$podHost.HostName}}/{{$podHost.HostIP}}<br>
                    {{end}}
                </td>
            </tr>
            {{end}}
        </table>
    </div>

</div>

{{template "footer" .}}

</body>
</html>
