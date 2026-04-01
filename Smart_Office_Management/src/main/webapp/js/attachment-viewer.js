/* ═══════════════════════════════════════════════════════════════
   Smart Office — Attachment Viewer  v4
   src/main/webapp/js/attachment-viewer.js

   Role-based access:
     ADMIN      → view only  (Download button hidden)
     MANAGER    → view + download
     EMPLOYEE   → view + download

   Usage in JSP:
     1. Set role before loading this script:
        <script>var AV_USER_ROLE = '${sessionScope.role}';</script>
        <script src=".../attachment-viewer.js"></script>

     2. On attachment link click:
        AttachmentViewer.open(event, url, filename)

   Supported formats:
     PDF    → native browser PDF via blob URL
     Images → jpg jpeg png gif webp bmp svg  (zoomable)
     Video  → mp4 webm ogg mov
     Word   → doc docx  (mammoth.js → HTML render)
     Excel  → xls xlsx  (SheetJS → HTML table)
     CSV    → csv        (SheetJS → HTML table)
     Text   → txt
     Other  → unsupported panel (Download shown only if not admin)
═══════════════════════════════════════════════════════════════ */
(function (global) {
  'use strict';

  /* ─── Role check ─────────────────────────────────────────── */
  // AV_USER_ROLE must be set in the JSP before this script loads.
  // Defaults to 'ADMIN' (most restrictive) if not set.
  function _isAdmin() {
    var role = (global.AV_USER_ROLE || 'ADMIN').toString().toUpperCase().trim();
    return role === 'ADMIN';
  }

  /* ─── inject CSS ─────────────────────────────────────────── */
  var S = document.createElement('style');
  S.textContent =
    /* overlay */
    '#av-overlay{position:fixed;inset:0;z-index:2147483647;background:rgba(15,23,42,.6);' +
    'display:none;align-items:center;justify-content:center;padding:14px;}' +
    '#av-overlay.av-open{display:flex;}' +

    /* modal */
    '#av-modal{background:#fff;border-radius:14px;width:100%;max-width:960px;' +
    'max-height:94vh;display:flex;flex-direction:column;overflow:hidden;' +
    'box-shadow:0 32px 80px rgba(0,0,0,.35);}' +

    /* header */
    '#av-header{display:flex;align-items:center;gap:10px;padding:12px 18px;' +
    'border-bottom:1.5px solid #e2e8f0;flex-shrink:0;background:#f8fafc;}' +
    '#av-icon{width:32px;height:32px;border-radius:8px;background:#eef2ff;' +
    'display:flex;align-items:center;justify-content:center;flex-shrink:0;}' +
    '#av-icon svg{width:15px;height:15px;}' +
    '#av-filename{flex:1;font-size:13px;font-weight:700;color:#1e293b;' +
    'white-space:nowrap;overflow:hidden;text-overflow:ellipsis;min-width:0;}' +
    '#av-type-badge{font-size:9.5px;font-weight:800;padding:2px 9px;letter-spacing:.05em;' +
    'border-radius:99px;background:#eef2ff;color:#4338ca;flex-shrink:0;text-transform:uppercase;}' +

    /* read-only badge (admin only) */
    '#av-readonly-badge{display:none;align-items:center;gap:5px;font-size:9.5px;font-weight:800;' +
    'padding:2px 10px;letter-spacing:.05em;border-radius:99px;' +
    'background:#fee2e2;color:#b91c1c;flex-shrink:0;text-transform:uppercase;}' +
    '#av-readonly-badge svg{width:10px;height:10px;}' +

    /* toolbar */
    '#av-toolbar{display:flex;align-items:center;gap:6px;padding:8px 16px;' +
    'border-bottom:1px solid #f1f5f9;flex-shrink:0;background:#f8fafc;flex-wrap:wrap;}' +
    '.av-btn{display:inline-flex;align-items:center;gap:5px;font-size:11.5px;font-weight:600;' +
    'padding:5px 12px;border-radius:7px;border:1.5px solid #e2e8f0;background:#fff;' +
    'color:#475569;cursor:pointer;transition:all .12s;white-space:nowrap;}' +
    '.av-btn:hover{border-color:#6366f1;color:#6366f1;background:#f5f3ff;}' +
    '.av-btn.primary{background:#6366f1;color:#fff;border-color:#6366f1;}' +
    '.av-btn.primary:hover{background:#4f46e5;}' +
    '.av-btn.danger{color:#dc2626;border-color:#fca5a5;}' +
    '.av-btn.danger:hover{background:#fee2e2;}' +
    '#av-zoom-val{font-size:11px;font-weight:700;color:#64748b;min-width:36px;text-align:center;}' +
    '.av-sep{width:1px;height:20px;background:#e2e8f0;margin:0 2px;}' +
    '.av-spacer{flex:1;}' +

    /* admin notice bar */
    '#av-admin-notice{display:none;align-items:center;gap:7px;' +
    'padding:7px 16px;background:#fff7ed;border-bottom:1px solid #fed7aa;' +
    'font-size:11.5px;color:#92400e;flex-shrink:0;}' +
    '#av-admin-notice svg{width:13px;height:13px;flex-shrink:0;color:#f97316;}' +

    /* body */
    '#av-body{flex:1;overflow:auto;background:#dde3ec;display:flex;' +
    'align-items:flex-start;justify-content:center;padding:20px;min-height:180px;}' +

    /* pdf */
    '#av-pdf-wrap{width:100%;}' +
    '#av-pdf-wrap iframe{width:100%;height:68vh;min-height:420px;border:none;' +
    'border-radius:8px;box-shadow:0 2px 16px rgba(0,0,0,.14);}' +

    /* image */
    '#av-img-wrap{display:flex;align-items:flex-start;justify-content:center;' +
    'overflow:auto;width:100%;}' +
    '#av-viewer-img{border-radius:8px;box-shadow:0 2px 16px rgba(0,0,0,.18);' +
    'display:block;transform-origin:top center;transition:transform .15s ease;max-width:100%;}' +

    /* video */
    '#av-video-wrap{display:flex;align-items:center;justify-content:center;width:100%;}' +
    '#av-video-wrap video{max-width:100%;max-height:70vh;border-radius:8px;' +
    'box-shadow:0 2px 16px rgba(0,0,0,.18);}' +

    /* word rendered html */
    '#av-word-wrap{width:100%;max-width:860px;}' +
    '#av-word-content{background:#fff;border-radius:8px;padding:32px 40px;' +
    'box-shadow:0 2px 16px rgba(0,0,0,.10);font-family:Georgia,serif;font-size:13.5px;' +
    'line-height:1.8;color:#1e293b;min-height:200px;}' +
    '#av-word-content h1,#av-word-content h2,#av-word-content h3{margin:.6em 0 .3em;font-family:inherit;}' +
    '#av-word-content p{margin:.4em 0;}' +
    '#av-word-content table{border-collapse:collapse;width:100%;margin:.8em 0;}' +
    '#av-word-content td,#av-word-content th{border:1px solid #e2e8f0;padding:6px 10px;font-size:12px;}' +
    '#av-word-content th{background:#f8fafc;font-weight:700;}' +

    /* excel / csv table */
    '#av-sheet-wrap{width:100%;overflow:auto;}' +
    '#av-sheet-nav{display:flex;gap:6px;flex-wrap:wrap;margin-bottom:10px;}' +
    '.av-sheet-tab{padding:4px 14px;border-radius:6px;font-size:11.5px;font-weight:600;' +
    'border:1.5px solid #e2e8f0;background:#fff;color:#64748b;cursor:pointer;transition:all .12s;}' +
    '.av-sheet-tab:hover{border-color:#6366f1;color:#6366f1;}' +
    '.av-sheet-tab.active{background:#6366f1;color:#fff;border-color:#6366f1;}' +
    '#av-sheet-table-wrap{overflow:auto;border-radius:8px;' +
    'box-shadow:0 2px 16px rgba(0,0,0,.10);}' +
    '#av-sheet-table-wrap table{border-collapse:collapse;background:#fff;' +
    'font-size:12px;white-space:nowrap;}' +
    '#av-sheet-table-wrap th{background:#f1f5f9;color:#475569;font-weight:700;' +
    'padding:7px 12px;border:1px solid #e2e8f0;position:sticky;top:0;z-index:1;}' +
    '#av-sheet-table-wrap td{padding:6px 12px;border:1px solid #f1f5f9;color:#334155;}' +
    '#av-sheet-table-wrap tr:nth-child(even) td{background:#f8fafc;}' +

    /* text */
    '#av-text-wrap{width:100%;max-width:820px;}' +
    '#av-text-wrap pre{background:#fff;border-radius:8px;padding:18px 22px;font-size:12px;' +
    'font-family:monospace;white-space:pre-wrap;word-break:break-word;' +
    'box-shadow:0 2px 16px rgba(0,0,0,.10);color:#1e293b;margin:0;}' +

    /* unsupported */
    '#av-unsupported{display:flex;flex-direction:column;align-items:center;' +
    'justify-content:center;gap:12px;min-height:200px;text-align:center;width:100%;}' +
    '#av-unsupported svg{width:48px;height:48px;color:#cbd5e1;}' +
    '#av-unsupported p{font-size:15px;font-weight:600;color:#94a3b8;margin:0;}' +
    '#av-unsupported span{font-size:13px;color:#b0bec5;line-height:1.7;}' +

    /* loading */
    '#av-loading{display:flex;flex-direction:column;align-items:center;' +
    'justify-content:center;gap:12px;min-height:200px;width:100%;}' +
    '.av-spin{width:32px;height:32px;border:3px solid #e2e8f0;border-top-color:#6366f1;' +
    'border-radius:50%;animation:av-spin .6s linear infinite;}' +
    '@keyframes av-spin{to{transform:rotate(360deg)}}' +
    '#av-loading p{font-size:12.5px;color:#94a3b8;margin:0;}' +

    /* error */
    '#av-error{display:flex;flex-direction:column;align-items:center;' +
    'justify-content:center;gap:10px;min-height:180px;text-align:center;width:100%;}' +
    '#av-error p{font-size:13.5px;font-weight:700;color:#ef4444;margin:0;}' +
    '#av-error span{font-size:12px;color:#94a3b8;}' +

    '@media(max-width:600px){#av-modal{border-radius:10px;max-height:97vh;}' +
    '#av-pdf-wrap iframe{height:62vh;}#av-word-content{padding:18px 16px;}}';

  document.head.appendChild(S);

  /* ─── tiny helpers ───────────────────────────────────────── */
  function _svg(inner, w, h) {
    w = w || 13; h = h || 13;
    return '<svg width="' + w + '" height="' + h + '" viewBox="0 0 24 24" fill="none"' +
           ' stroke="currentColor" stroke-width="2" stroke-linecap="round"' +
           ' stroke-linejoin="round">' + inner + '</svg>';
  }
  function _esc(s) {
    return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
  }
  function _ext(f)  { return ((f||'').split('.').pop()||'').toLowerCase().trim(); }
  function _typeOf(f) {
    var e = _ext(f);
    if (e==='pdf')  return 'pdf';
    if (['jpg','jpeg','png','gif','webp','bmp','svg'].indexOf(e)!==-1) return 'image';
    if (['mp4','webm','ogg','mov'].indexOf(e)!==-1) return 'video';
    if (['doc','docx'].indexOf(e)!==-1) return 'word';
    if (['xls','xlsx'].indexOf(e)!==-1) return 'excel';
    if (e==='csv') return 'csv';
    if (e==='txt') return 'text';
    return 'other';
  }
  function _mimeOf(f) {
    var m={pdf:'application/pdf',jpg:'image/jpeg',jpeg:'image/jpeg',png:'image/png',
      gif:'image/gif',webp:'image/webp',bmp:'image/bmp',svg:'image/svg+xml',
      mp4:'video/mp4',webm:'video/webm',ogg:'video/ogg',mov:'video/quicktime',
      doc:'application/msword',
      docx:'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      xls:'application/vnd.ms-excel',
      xlsx:'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      csv:'text/csv',txt:'text/plain'};
    return m[_ext(f)]||'application/octet-stream';
  }
  function _badge(type) {
    return {pdf:'PDF',image:'IMAGE',video:'VIDEO',word:'WORD',
            excel:'EXCEL',csv:'CSV',text:'TEXT',other:'FILE'}[type]||'FILE';
  }
  function _fileIcon(type) {
    var p = type==='image'
      ? '<rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/>'
      : type==='video'
      ? '<polygon points="5 3 19 12 5 21 5 3"/>'
      : type==='word'
      ? '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="9" y1="13" x2="15" y2="13"/><line x1="9" y1="17" x2="15" y2="17"/>'
      : type==='excel'||type==='csv'
      ? '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="16" y2="17"/><line x1="12" y1="9" x2="12" y2="21"/>'
      : '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>';
    return '<svg viewBox="0 0 24 24" fill="none" stroke="#6366f1" stroke-width="2"' +
           ' stroke-linecap="round" stroke-linejoin="round">' + p + '</svg>';
  }

  /* ─── build DOM ──────────────────────────────────────────── */
  var overlay = document.createElement('div');
  overlay.id  = 'av-overlay';
  overlay.innerHTML =
    '<div id="av-modal" role="dialog" aria-modal="true">' +
      '<div id="av-header">' +
        '<div id="av-icon">' + _fileIcon('other') + '</div>' +
        '<div id="av-filename">Attachment</div>' +
        '<div id="av-type-badge">FILE</div>' +
        /* lock badge — visible for admin only */
        '<div id="av-readonly-badge">' +
          _svg('<rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>') +
          ' View Only' +
        '</div>' +
      '</div>' +
      /* orange notice bar — visible for admin only */
      '<div id="av-admin-notice">' +
        _svg('<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>') +
        ' You are viewing this file in read-only mode. Downloading is restricted for Admin accounts.' +
      '</div>' +
      '<div id="av-toolbar">' +
        /* zoom controls (images only) */
        '<button class="av-btn" id="av-zout" style="display:none" onclick="AttachmentViewer._zoom(-0.2)">' + _svg('<circle cx="11" cy="11" r="8"/><line x1="8" y1="11" x2="14" y2="11"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>') + '</button>' +
        '<span id="av-zoom-val" style="display:none">100%</span>' +
        '<button class="av-btn" id="av-zin"  style="display:none" onclick="AttachmentViewer._zoom(0.2)">'  + _svg('<circle cx="11" cy="11" r="8"/><line x1="11" y1="8" x2="11" y2="14"/><line x1="8" y1="11" x2="14" y2="11"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>') + '</button>' +
        '<button class="av-btn" id="av-zrst" style="display:none" onclick="AttachmentViewer._zoomReset()">Reset</button>' +
        '<span class="av-spacer"></span>' +
        /* Download button — hidden for admin, visible for manager/employee */
        '<button class="av-btn primary" id="av-dl-btn" onclick="AttachmentViewer._download()">' +
          _svg('<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>') +
          ' Download' +
        '</button>' +
        '<button class="av-btn danger" onclick="AttachmentViewer.close()">' +
          _svg('<line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>') +
          ' Close' +
        '</button>' +
      '</div>' +
      '<div id="av-body"><div id="av-loading"><div class="av-spin"></div><p>Loading…</p></div></div>' +
    '</div>';
  document.body.appendChild(overlay);

  overlay.addEventListener('click', function(e){ if(e.target===overlay) AV.close(); });
  document.addEventListener('keydown', function(e){ if(e.key==='Escape') AV.close(); });

  /* ─── state ──────────────────────────────────────────────── */
  var _scale=1, _blobUrl=null, _origUrl=null, _fname='';
  var _xlsWorkbook=null, _xlsSheets=[];

  /* ─── helpers ────────────────────────────────────────────── */
  function _loading(msg) {
    document.getElementById('av-body').innerHTML =
      '<div id="av-loading"><div class="av-spin"></div><p>' + _esc(msg||'Loading…') + '</p></div>';
  }
  function _error(msg) {
    document.getElementById('av-body').innerHTML =
      '<div id="av-error">' + _svg('<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>',18,18) +
      '<p>Could not load file</p><span>' + _esc(msg||'Try again later.') + '</span></div>';
  }
  function _zoomShow(yes) {
    ['av-zout','av-zoom-val','av-zin','av-zrst'].forEach(function(id){
      document.getElementById(id).style.display = yes ? '' : 'none';
    });
  }

  /* ─── apply role-based UI each time modal opens ──────────── */
  function _applyRoleUI() {
    var admin = _isAdmin();

    /* Download button: hide for admin, show for everyone else */
    var dlBtn = document.getElementById('av-dl-btn');
    if (dlBtn) dlBtn.style.display = admin ? 'none' : '';

    /* Red "View Only" badge in header: show for admin only */
    var roBadge = document.getElementById('av-readonly-badge');
    if (roBadge) roBadge.style.display = admin ? 'inline-flex' : 'none';

    /* Orange notice bar below header: show for admin only */
    var notice = document.getElementById('av-admin-notice');
    if (notice) notice.style.display = admin ? 'flex' : 'none';
  }

  /* ─── load external lib once ─────────────────────────────── */
  function _loadScript(src, cb) {
    if (document.querySelector('script[src="' + src + '"]')) { cb(); return; }
    var el = document.createElement('script');
    el.src = src;
    el.onload  = cb;
    el.onerror = function(){ cb(new Error('Failed to load ' + src)); };
    document.head.appendChild(el);
  }
  var MAMMOTH_CDN = 'https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.6.0/mammoth.browser.min.js';
  var XLSX_CDN    = 'https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js';

  /* ─── render functions ───────────────────────────────────── */
  function _renderPdf(blobUrl, filename) {
    document.getElementById('av-body').innerHTML =
      '<div id="av-pdf-wrap"><iframe src="' + blobUrl + '" title="' + _esc(filename) + '"></iframe></div>';
  }

  function _renderImage(blobUrl, filename) {
    document.getElementById('av-body').innerHTML =
      '<div id="av-img-wrap"><img id="av-viewer-img" src="' + blobUrl + '" alt="' + _esc(filename) + '"></div>';
    _zoomShow(true);
    document.getElementById('av-zoom-val').textContent = '100%';
  }

  function _renderVideo(blobUrl) {
    document.getElementById('av-body').innerHTML =
      '<div id="av-video-wrap"><video controls src="' + blobUrl + '">Your browser cannot play this video.</video></div>';
  }

  function _renderText(blobUrl) {
    fetch(blobUrl).then(function(r){ return r.text(); }).then(function(txt){
      document.getElementById('av-body').innerHTML =
        '<div id="av-text-wrap"><pre>' + _esc(txt) + '</pre></div>';
    }).catch(function(){ _error('Could not read text file.'); });
  }

  function _renderWord(arrayBuffer) {
    _loadScript(MAMMOTH_CDN, function(err) {
      if (err || !global.mammoth) { _error('Word preview library failed to load.'); return; }
      global.mammoth.convertToHtml({ arrayBuffer: arrayBuffer })
        .then(function(result) {
          document.getElementById('av-body').innerHTML =
            '<div id="av-word-wrap"><div id="av-word-content">' + result.value + '</div></div>';
        })
        .catch(function(e){ _error('Could not parse Word document: ' + e.message); });
    });
  }

  function _renderSheetByIndex(idx) {
    if (!_xlsWorkbook || !_xlsSheets.length) return;
    var XLSX = global.XLSX;
    var sheetName = _xlsSheets[idx];
    var ws   = _xlsWorkbook.Sheets[sheetName];
    var html = XLSX.utils.sheet_to_html(ws, { header:'', footer:'' });
    html = html.replace('<table>', '<table style="border-collapse:collapse;width:100%;font-size:12px;">');
    var wrap = document.getElementById('av-sheet-table-wrap');
    if (wrap) {
      wrap.innerHTML = html;
      wrap.querySelectorAll('th,td').forEach(function(cell){
        cell.style.border  = '1px solid #e2e8f0';
        cell.style.padding = '6px 10px';
      });
      wrap.querySelectorAll('th').forEach(function(th){
        th.style.background = '#f1f5f9';
        th.style.fontWeight = '700';
        th.style.color      = '#475569';
        th.style.position   = 'sticky';
        th.style.top        = '0';
      });
      wrap.querySelectorAll('tr:nth-child(even) td').forEach(function(td){
        td.style.background = '#f8fafc';
      });
    }
    document.querySelectorAll('.av-sheet-tab').forEach(function(btn, i){
      btn.classList.toggle('active', i === idx);
    });
  }

  function _renderExcel(arrayBuffer, filename) {
    _loadScript(XLSX_CDN, function(err) {
      if (err || !global.XLSX) { _error('Spreadsheet preview library failed to load.'); return; }
      try {
        var XLSX = global.XLSX;
        _xlsWorkbook = XLSX.read(new Uint8Array(arrayBuffer), { type:'array' });
        _xlsSheets   = _xlsWorkbook.SheetNames;
        var tabsHtml = _xlsSheets.map(function(name, i){
          return '<button class="av-sheet-tab' + (i===0?' active':'') + '" onclick="AttachmentViewer._switchSheet(' + i + ')">' + _esc(name) + '</button>';
        }).join('');
        document.getElementById('av-body').innerHTML =
          '<div id="av-sheet-wrap">' +
            (_xlsSheets.length > 1 ? '<div id="av-sheet-nav">' + tabsHtml + '</div>' : '') +
            '<div id="av-sheet-table-wrap"></div>' +
          '</div>';
        _renderSheetByIndex(0);
      } catch(e) {
        _error('Could not parse spreadsheet: ' + e.message);
      }
    });
  }

  function _renderCsv(blobUrl) {
    _loadScript(XLSX_CDN, function(err) {
      if (err || !global.XLSX) { _renderText(blobUrl); return; }
      fetch(blobUrl).then(function(r){ return r.text(); }).then(function(csvText){
        try {
          var XLSX = global.XLSX;
          var ws   = XLSX.utils.csv_to_sheet(csvText);
          _xlsWorkbook = { SheetNames:['Sheet1'], Sheets:{ Sheet1:ws } };
          _xlsSheets   = ['Sheet1'];
          document.getElementById('av-body').innerHTML =
            '<div id="av-sheet-wrap"><div id="av-sheet-table-wrap"></div></div>';
          _renderSheetByIndex(0);
        } catch(e) { _renderText(blobUrl); }
      }).catch(function(){ _renderText(blobUrl); });
    });
  }

  /* ─── core fetch → blob → dispatch ──────────────────────── */
  function _fetchAndRender(url, filename, type) {
    _loading('Loading ' + _badge(type) + '…');
    _zoomShow(false);
    _scale = 1;
    _xlsWorkbook = null;
    _xlsSheets   = [];

    fetch(url, { credentials:'same-origin' })
      .then(function(res) {
        if (!res.ok) throw new Error('Server returned ' + res.status);
        return res.blob();
      })
      .then(function(blob) {
        if (_blobUrl) { URL.revokeObjectURL(_blobUrl); }
        var typed = new Blob([blob], { type: _mimeOf(filename) });
        _blobUrl  = URL.createObjectURL(typed);

        switch(type) {
          case 'pdf':   _renderPdf(_blobUrl, filename); break;
          case 'image': _renderImage(_blobUrl, filename); break;
          case 'video': _renderVideo(_blobUrl); break;
          case 'text':  _renderText(_blobUrl); break;
          case 'csv':   _renderCsv(_blobUrl); break;
          case 'word':
            blob.arrayBuffer
              ? blob.arrayBuffer().then(_renderWord).catch(function(e){ _error(e.message); })
              : new Response(blob).arrayBuffer().then(_renderWord).catch(function(e){ _error(e.message); });
            break;
          case 'excel':
            blob.arrayBuffer
              ? blob.arrayBuffer().then(function(ab){ _renderExcel(ab, filename); }).catch(function(e){ _error(e.message); })
              : new Response(blob).arrayBuffer().then(function(ab){ _renderExcel(ab, filename); }).catch(function(e){ _error(e.message); });
            break;
          default:
            /* For unsupported types: only show Download hint if not admin */
            var canDl = !_isAdmin();
            document.getElementById('av-body').innerHTML =
              '<div id="av-unsupported">' +
                _svg('<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/>',48,48) +
                '<p>Preview not available</p>' +
                '<span>This file type cannot be previewed in the browser.' +
                (canDl ? '<br>Use <strong>Download</strong> to open it locally.' : '') +
                '</span>' +
              '</div>';
        }
      })
      .catch(function(err) { _error(err.message); });
  }

  /* ─── public API ─────────────────────────────────────────── */
  var AV = {
    /**
     * Open the viewer.
     * @param {Event}  event    – click event (will be prevented)
     * @param {string} url      – servlet URL e.g. /taskAttachment?id=5
     * @param {string} filename – original filename e.g. "report.xlsx"
     */
    open: function(event, url, filename) {
      if (event) { event.preventDefault(); event.stopPropagation(); }
      if (!url) return;

      _origUrl = url;
      _fname   = filename || 'attachment';
      var type = _typeOf(_fname);

      document.getElementById('av-filename').textContent   = _fname;
      document.getElementById('av-type-badge').textContent = _badge(type);
      document.getElementById('av-icon').innerHTML         = _fileIcon(type);

      /* Apply role-specific UI every time the modal opens */
      _applyRoleUI();

      overlay.classList.add('av-open');
      document.body.style.overflow = 'hidden';

      _fetchAndRender(url, _fname, type);
    },

    close: function() {
      overlay.classList.remove('av-open');
      document.body.style.overflow = '';
      document.getElementById('av-body').innerHTML = '';
      if (_blobUrl) { URL.revokeObjectURL(_blobUrl); _blobUrl = null; }
      _xlsWorkbook = null; _xlsSheets = [];
    },

    _download: function() {
      /* Double-check on client: admin must never be able to download */
      if (_isAdmin()) return;
      if (!_origUrl) return;
      var a = document.createElement('a');
      a.href = _origUrl; a.download = _fname;
      a.style.display = 'none';
      document.body.appendChild(a); a.click(); document.body.removeChild(a);
    },

    _zoom: function(d) {
      var img = document.getElementById('av-viewer-img'); if (!img) return;
      _scale = Math.min(4, Math.max(0.2, _scale + d));
      img.style.transform = 'scale(' + _scale + ')';
      document.getElementById('av-zoom-val').textContent = Math.round(_scale*100) + '%';
    },

    _zoomReset: function() {
      var img = document.getElementById('av-viewer-img'); if (!img) return;
      _scale = 1; img.style.transform = 'scale(1)';
      document.getElementById('av-zoom-val').textContent = '100%';
    },

    _switchSheet: function(idx) { _renderSheetByIndex(idx); }
  };

  global.AttachmentViewer = AV;

})(window);