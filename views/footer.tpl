{{define "footer"}}
<footer style="
    background: linear-gradient(90deg, #0d1117, #1f1f1f);
    color: #c9d1d9;
    padding: 20px 40px;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    font-size: 14px;
    text-align: center;
    flex-shrink: 0;
">
    <div style="display:flex; flex-direction:column; align-items:center; gap:8px;">
        <span><strong>Multi-Cloud Manager UI</strong> &middot; Version: {{.VersionInfo}}</span>
        <span>&copy; 2025 All rights reserved</span>
        <a href="https://github.com/Quangtrungzuitinh/emcontroller" target="_blank" style="
            text-decoration:none;
            color:#58a6ff;
            display:flex;
            align-items:center;
            gap:5px;
            font-weight:bold;
        ">
            <img src="/static/icons/github.svg" alt="GitHub" width="20" height="20">
            GitHub Repository
        </a>
    </div>
</footer>

<style>
    html, body { height:100%; margin:0; padding:0; display:flex; flex-direction:column; background:#0d1117; color:#c9d1d9; }
    body > .main-content { flex:1; }
    @media(max-width:600px){ footer{padding:15px 20px; font-size:13px;} footer img{width:16px; height:16px;} }
</style>
{{end}}
