/*
 * employeeProfile.js
 * -------------------
 * Drop this script into any page (admin or manager dashboard).
 * It injects the modal HTML + styles automatically, then listens
 * for clicks on any element with  data-profile-email="..."
 *
 * Usage in JSP rows:
 *   <tr data-profile-email="<%=email%>" class="clickable-row"> ... </tr>
 *
 * Or on any element:
 *   <span data-profile-email="john@example.com">John Doe</span>
 */

(function () {
  'use strict';

  /* ── Inject styles ─────────────────────────────────────────────── */
  const STYLES = `
    #empProfileOverlay {
      display: none;
      position: fixed;
      inset: 0;
      background: rgba(15, 20, 40, 0.55);
      backdrop-filter: blur(5px);
      z-index: 99999;
      align-items: center;
      justify-content: center;
      padding: 20px;
      font-family: 'DM Sans', 'Inter', system-ui, sans-serif;
    }
    #empProfileOverlay.show { display: flex; }

    #empProfileBox {
      background: #fff;
      border-radius: 20px;
      box-shadow: 0 24px 60px rgba(0,0,0,.18);
      max-width: 720px;
      width: 100%;
      max-height: 88vh;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      animation: empPop .22s cubic-bezier(.34,1.56,.64,1) both;
    }
    @keyframes empPop {
      from { transform: scale(.88); opacity: 0; }
      to   { transform: scale(1);  opacity: 1; }
    }

    /* ── Header band ── */
    #empProfileHeader {
      background: linear-gradient(135deg, #4f6ef7 0%, #7c3aed 100%);
      padding: 24px 28px 20px;
      display: flex;
      align-items: center;
      gap: 18px;
      flex-shrink: 0;
    }
    #empAvatar {
      width: 60px; height: 60px; border-radius: 50%;
      background: rgba(255,255,255,.25);
      color: #fff; font-size: 22px; font-weight: 700;
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0; letter-spacing: 1px;
      border: 2px solid rgba(255,255,255,.4);
    }
    #empProfileHeader .emp-name {
      font-size: 20px; font-weight: 700; color: #fff; line-height: 1.2;
    }
    #empProfileHeader .emp-sub {
      font-size: 13px; color: rgba(255,255,255,.8); margin-top: 3px;
      display: flex; gap: 10px; flex-wrap: wrap; align-items: center;
    }
    .emp-status-badge {
      display: inline-flex; align-items: center; gap: 5px;
      padding: 2px 10px; border-radius: 99px; font-size: 11px; font-weight: 700;
      text-transform: uppercase; letter-spacing: .4px;
    }
    .emp-status-badge.active  { background: #d1fae5; color: #065f46; }
    .emp-status-badge.inactive{ background: #fee2e2; color: #991b1b; }
    #empCloseBtn {
      margin-left: auto; background: rgba(255,255,255,.2);
      border: none; border-radius: 8px;
      width: 32px; height: 32px; color: #fff; font-size: 16px;
      display: flex; align-items: center; justify-content: center;
      cursor: pointer; flex-shrink: 0; transition: background .15s;
    }
    #empCloseBtn:hover { background: rgba(255,255,255,.35); }

    /* ── Tabs ── */
    #empTabs {
      display: flex; border-bottom: 1.5px solid #e8ecf4;
      background: #f8f9fc; flex-shrink: 0; overflow-x: auto;
    }
    .emp-tab {
      padding: 12px 20px; font-size: 13px; font-weight: 600;
      color: #8d96b0; cursor: pointer; border: none;
      background: none; white-space: nowrap;
      border-bottom: 2.5px solid transparent;
      transition: all .15s; display: flex; align-items: center; gap: 7px;
    }
    .emp-tab:hover { color: #4f6ef7; }
    .emp-tab.active { color: #4f6ef7; border-bottom-color: #4f6ef7; background: #fff; }

    /* ── Body ── */
    #empProfileBody {
      overflow-y: auto; padding: 24px 28px; flex: 1;
    }
    #empProfileBody::-webkit-scrollbar { width: 5px; }
    #empProfileBody::-webkit-scrollbar-thumb { background: #d4daea; border-radius: 99px; }

    .emp-panel { display: none; }
    .emp-panel.active { display: block; }

    /* ── Spinner ── */
    .emp-spinner {
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      padding: 48px; color: #8d96b0; gap: 12px;
    }
    .emp-spinner i { font-size: 28px; color: #4f6ef7; }

    /* ── Info grid ── */
    .emp-info-grid {
      display: grid; grid-template-columns: 1fr 1fr; gap: 16px;
    }
    @media (max-width: 520px) { .emp-info-grid { grid-template-columns: 1fr; } }
    .emp-info-item {
      background: #f8f9fc; border: 1px solid #e8ecf4;
      border-radius: 10px; padding: 14px 16px;
    }
    .emp-info-label {
      font-size: 11px; font-weight: 700; color: #8d96b0;
      text-transform: uppercase; letter-spacing: .5px; margin-bottom: 5px;
    }
    .emp-info-value {
      font-size: 14px; font-weight: 600; color: #1a1d2e; word-break: break-all;
    }

    /* ── Stat cards ── */
    .emp-stat-row {
      display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px; margin-bottom: 22px;
    }
    .emp-stat-card {
      background: #f8f9fc; border: 1px solid #e8ecf4;
      border-radius: 12px; padding: 16px; text-align: center;
    }
    .emp-stat-num { font-size: 28px; font-weight: 700; color: #1a1d2e; line-height: 1; }
    .emp-stat-num.green  { color: #22c55e; }
    .emp-stat-num.red    { color: #ef4444; }
    .emp-stat-num.amber  { color: #f59e0b; }
    .emp-stat-label { font-size: 11px; color: #8d96b0; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; margin-top: 5px; }

    /* ── Mini table ── */
    .emp-mini-table { width: 100%; border-collapse: collapse; font-size: 13px; }
    .emp-mini-table th {
      text-align: left; padding: 8px 12px; font-size: 11px; font-weight: 700;
      color: #8d96b0; text-transform: uppercase; letter-spacing: .5px;
      border-bottom: 1.5px solid #e8ecf4; background: #f8f9fc;
    }
    .emp-mini-table td {
      padding: 10px 12px; border-bottom: 1px solid #f0f2f8; color: #1a1d2e;
    }
    .emp-mini-table tr:last-child td { border-bottom: none; }
    .emp-mini-table tr:hover td { background: #f8f9fc; }

    /* ── Leave stat row ── */
    .emp-leave-stats {
      display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; margin-bottom: 20px;
    }
    @media (max-width: 520px) { .emp-leave-stats { grid-template-columns: repeat(2,1fr); } }

    /* ── Status pills ── */
    .pill {
      display: inline-block; padding: 3px 10px; border-radius: 99px;
      font-size: 11px; font-weight: 700; text-transform: uppercase;
    }
    .pill.present  { background: #d1fae5; color: #065f46; }
    .pill.absent   { background: #fee2e2; color: #991b1b; }
    .pill.halfday  { background: #fef3c7; color: #92400e; }
    .pill.punched  { background: #dbeafe; color: #1e40af; }
    .pill.pending  { background: #fef3c7; color: #92400e; }
    .pill.approved { background: #d1fae5; color: #065f46; }
    .pill.rejected { background: #fee2e2; color: #991b1b; }

    /* ── Team card ── */
    .emp-team-card {
      background: linear-gradient(135deg, #eef1fe 0%, #f0f4ff 100%);
      border: 1px solid #d4daea; border-radius: 14px;
      padding: 18px 20px; margin-bottom: 14px;
    }
    .emp-team-name {
      font-size: 15px; font-weight: 700; color: #1a1d2e;
      display: flex; align-items: center; gap: 8px; margin-bottom: 12px;
    }
    .emp-team-name i { color: #4f6ef7; }
    .emp-team-meta { font-size: 13px; color: #5a6278; display: flex; gap: 20px; flex-wrap: wrap; }
    .emp-team-meta span { display: flex; align-items: center; gap: 6px; }
    .emp-team-meta i { color: #4f6ef7; font-size: 12px; }

    /* ── Section title ── */
    .emp-section-title {
      font-size: 13px; font-weight: 700; color: #5a6278;
      text-transform: uppercase; letter-spacing: .5px;
      margin-bottom: 14px; display: flex; align-items: center; gap: 7px;
    }
    .emp-section-title i { color: #4f6ef7; }

    /* ── Empty ── */
    .emp-empty {
      text-align: center; padding: 32px; color: #8d96b0;
    }
    .emp-empty i { font-size: 32px; opacity: .3; display: block; margin-bottom: 10px; }
    .emp-empty p { font-size: 13px; }

    /* ── Clickable rows ── */
    tr[data-profile-email] { cursor: pointer; }
    tr[data-profile-email]:hover td { background: #f0f4ff !important; }
  `;

  const styleEl = document.createElement('style');
  styleEl.textContent = STYLES;
  document.head.appendChild(styleEl);

  /* ── Inject modal HTML ─────────────────────────────────────────── */
  const MODAL_HTML = `
    <div id="empProfileOverlay" onclick="if(event.target===this)empProfileClose()">
      <div id="empProfileBox" onclick="event.stopPropagation()">

        <div id="empProfileHeader">
          <div id="empAvatar">?</div>
          <div>
            <div class="emp-name" id="empHeaderName">Loading…</div>
            <div class="emp-sub">
              <span id="empHeaderRole"></span>
              <span id="empHeaderStatus"></span>
            </div>
          </div>
          <button id="empCloseBtn" onclick="empProfileClose()">
            <i class="fa-solid fa-xmark"></i>
          </button>
        </div>

        <div id="empTabs">
          <button class="emp-tab active" onclick="empSwitchTab('info',this)">
            <i class="fa-solid fa-user"></i> Info
          </button>
          <button class="emp-tab" onclick="empSwitchTab('attendance',this)">
            <i class="fa-solid fa-calendar-check"></i> Attendance
          </button>
          <button class="emp-tab" onclick="empSwitchTab('leave',this)">
            <i class="fa-solid fa-plane-departure"></i> Leave
          </button>
          <button class="emp-tab" onclick="empSwitchTab('team',this)">
            <i class="fa-solid fa-people-group"></i> Team
          </button>
        </div>

        <div id="empProfileBody">
          <div class="emp-spinner">
            <i class="fa-solid fa-spinner fa-spin"></i>
            <span>Loading profile…</span>
          </div>
        </div>

      </div>
    </div>
  `;

  const wrapper = document.createElement('div');
  wrapper.innerHTML = MODAL_HTML;
  document.body.appendChild(wrapper.firstElementChild);

  /* ── State ─────────────────────────────────────────────────────── */
  let _data = null;
  let _activeTab = 'info';

  /* ── Public API ─────────────────────────────────────────────────── */
  window.empProfileOpen = function (email) {
    _data = null;
    _activeTab = 'info';

    // Reset tabs
    document.querySelectorAll('.emp-tab').forEach(t => t.classList.remove('active'));
    document.querySelector('.emp-tab').classList.add('active');

    // Reset header
    document.getElementById('empAvatar').textContent = '?';
    document.getElementById('empHeaderName').textContent = 'Loading…';
    document.getElementById('empHeaderRole').textContent = '';
    document.getElementById('empHeaderStatus').innerHTML = '';

    // Show spinner
    document.getElementById('empProfileBody').innerHTML = `
      <div class="emp-spinner">
        <i class="fa-solid fa-spinner fa-spin"></i>
        <span>Loading profile…</span>
      </div>`;

    document.getElementById('empProfileOverlay').classList.add('show');

    fetch('employeeProfile?email=' + encodeURIComponent(email))
      .then(r => r.json())
      .then(data => {
        _data = data;
        _populateHeader(data.info);
        _renderTab('info');
      })
      .catch(() => {
        document.getElementById('empProfileBody').innerHTML = `
          <div class="emp-empty">
            <i class="fa-solid fa-triangle-exclamation"></i>
            <p>Failed to load profile. Please try again.</p>
          </div>`;
      });
  };

  window.empProfileClose = function () {
    document.getElementById('empProfileOverlay').classList.remove('show');
  };

  window.empSwitchTab = function (tab, btn) {
    _activeTab = tab;
    document.querySelectorAll('.emp-tab').forEach(t => t.classList.remove('active'));
    btn.classList.add('active');
    if (_data) _renderTab(tab);
  };

  /* ── Header ─────────────────────────────────────────────────────── */
  function _populateHeader(info) {
    if (!info) return;
    document.getElementById('empAvatar').textContent = info.initials || '?';
    document.getElementById('empHeaderName').textContent = info.fullName || '--';
    document.getElementById('empHeaderRole').textContent =
      info.designation ? info.designation + ' · ' + _cap(info.role) : _cap(info.role);
    const isActive = (info.status || '').toLowerCase() === 'active';
    document.getElementById('empHeaderStatus').innerHTML =
      `<span class="emp-status-badge ${isActive ? 'active' : 'inactive'}">
         <i class="fa-solid fa-circle" style="font-size:7px;"></i>
         ${_cap(info.status || 'Unknown')}
       </span>`;
  }

  /* ── Tab renderer ────────────────────────────────────────────────── */
  function _renderTab(tab) {
    const body = document.getElementById('empProfileBody');
    switch (tab) {
      case 'info':       body.innerHTML = _buildInfo(_data.info);         break;
      case 'attendance': body.innerHTML = _buildAttendance(_data.attendance); break;
      case 'leave':      body.innerHTML = _buildLeave(_data.leaves);      break;
      case 'team':       body.innerHTML = _buildTeam(_data.team);         break;
    }
  }

  /* ── Info Panel ──────────────────────────────────────────────────── */
  function _buildInfo(info) {
    if (!info) return _empty('No profile data found.');
    return `
      <div class="emp-info-grid">
        ${_infoItem('fa-envelope', 'Email', info.email || '--')}
        ${_infoItem('fa-phone', 'Phone', info.phone || '--')}
        ${_infoItem('fa-briefcase', 'Designation', info.designation || '--')}
        ${_infoItem('fa-user-tag', 'Role', _cap(info.role) || '--')}
        ${_infoItem('fa-calendar', 'Joined Date', info.joinedDate || '--')}
        ${_infoItem('fa-circle-check', 'Status', _cap(info.status) || '--')}
      </div>`;
  }

  function _infoItem(icon, label, value) {
    return `
      <div class="emp-info-item">
        <div class="emp-info-label"><i class="fa-solid ${icon}" style="margin-right:5px;color:#4f6ef7;"></i>${label}</div>
        <div class="emp-info-value">${_esc(value)}</div>
      </div>`;
  }

  /* ── Attendance Panel ────────────────────────────────────────────── */
  function _buildAttendance(att) {
    if (!att) return _empty('No attendance data.');
    const log = att.recentLog || [];

    let rows = '';
    if (log.length === 0) {
      rows = `<tr><td colspan="4" style="text-align:center;padding:20px;color:#8d96b0;">No recent records</td></tr>`;
    } else {
      log.forEach(e => {
        const cls = _statusCls(e.status);
        rows += `<tr>
          <td>${_esc(e.date)}</td>
          <td>${_esc(e.punchIn)}</td>
          <td>${_esc(e.punchOut)}</td>
          <td><span class="pill ${cls}">${_esc(e.status)}</span></td>
        </tr>`;
      });
    }

    return `
      <div class="emp-section-title">
        <i class="fa-solid fa-chart-bar"></i> This Month's Summary
      </div>
      <div class="emp-stat-row">
        <div class="emp-stat-card">
          <div class="emp-stat-num green">${att.presentCount}</div>
          <div class="emp-stat-label">Present</div>
        </div>
        <div class="emp-stat-card">
          <div class="emp-stat-num amber">${att.halfdayCount}</div>
          <div class="emp-stat-label">Half Days</div>
        </div>
        <div class="emp-stat-card">
          <div class="emp-stat-num red">${att.absentCount}</div>
          <div class="emp-stat-label">Absent</div>
        </div>
      </div>

      <div class="emp-section-title" style="margin-top:8px;">
        <i class="fa-solid fa-clock-rotate-left"></i> Recent Activity (Last 5)
      </div>
      <div style="overflow-x:auto;border-radius:10px;border:1px solid #e8ecf4;">
        <table class="emp-mini-table">
          <thead>
            <tr>
              <th>Date</th><th>Punch In</th><th>Punch Out</th><th>Status</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>`;
  }

  /* ── Leave Panel ─────────────────────────────────────────────────── */
  function _buildLeave(leaves) {
    if (!leaves) return _empty('No leave data.');
    const recent = leaves.recent || [];

    let rows = '';
    if (recent.length === 0) {
      rows = `<tr><td colspan="5" style="text-align:center;padding:20px;color:#8d96b0;">No leave requests</td></tr>`;
    } else {
      recent.forEach(lr => {
        const cls = _statusCls(lr.status);
        rows += `<tr>
          <td>${_esc(lr.type)}</td>
          <td>${_esc(lr.from)}</td>
          <td>${_esc(lr.to)}</td>
          <td>${lr.days} day${lr.days !== 1 ? 's' : ''}</td>
          <td><span class="pill ${cls}">${_esc(lr.status)}</span></td>
        </tr>`;
      });
    }

    return `
      <div class="emp-leave-stats">
        ${_leaveStat(leaves.total,    '#1a1d2e', 'Total')}
        ${_leaveStat(leaves.approved, '#22c55e', 'Approved')}
        ${_leaveStat(leaves.pending,  '#f59e0b', 'Pending')}
        ${_leaveStat(leaves.rejected, '#ef4444', 'Rejected')}
      </div>

      <div class="emp-section-title">
        <i class="fa-solid fa-list"></i> Recent Requests (Last 5)
      </div>
      <div style="overflow-x:auto;border-radius:10px;border:1px solid #e8ecf4;">
        <table class="emp-mini-table">
          <thead>
            <tr>
              <th>Type</th><th>From</th><th>To</th><th>Days</th><th>Status</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>`;
  }

  function _leaveStat(val, color, label) {
    return `
      <div class="emp-stat-card">
        <div class="emp-stat-num" style="color:${color};">${val}</div>
        <div class="emp-stat-label">${label}</div>
      </div>`;
  }

  /* ── Team Panel ──────────────────────────────────────────────────── */
  function _buildTeam(team) {
    if (!team || !team.teams || team.teams.length === 0) {
      return _empty('Not assigned to any team yet.');
    }
    return team.teams.map(t => `
      <div class="emp-team-card">
        <div class="emp-team-name">
          <i class="fa-solid fa-people-group"></i> ${_esc(t.name)}
        </div>
        <div class="emp-team-meta">
          <span><i class="fa-solid fa-user-tie"></i> Manager: <strong>${_esc(t.manager || 'N/A')}</strong></span>
          <span><i class="fa-solid fa-users"></i> ${t.memberCount} member${t.memberCount !== 1 ? 's' : ''}</span>
          ${t.managerEmail ? `<span><i class="fa-solid fa-envelope"></i> ${_esc(t.managerEmail)}</span>` : ''}
        </div>
      </div>`).join('');
  }

  /* ── Helpers ─────────────────────────────────────────────────────── */
  function _empty(msg) {
    return `<div class="emp-empty"><i class="fa-solid fa-inbox"></i><p>${msg}</p></div>`;
  }

  function _cap(s) {
    if (!s) return '';
    return s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
  }

  function _esc(s) {
    if (s == null) return '';
    return String(s)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function _statusCls(status) {
    if (!status) return '';
    const s = status.toLowerCase();
    if (s === 'present')              return 'present';
    if (s === 'absent')               return 'absent';
    if (s.includes('half'))           return 'halfday';
    if (s.includes('punch'))          return 'punched';
    if (s === 'pending')              return 'pending';
    if (s === 'approved')             return 'approved';
    if (s === 'rejected')             return 'rejected';
    return '';
  }

  /* ── Click delegation (works for rows added dynamically too) ─── */
  document.addEventListener('click', function (e) {
    // Walk up from click target to find data-profile-email
    let el = e.target;
    while (el && el !== document.body) {
      // Don't open profile if user clicked an action button / link inside the row
      if (el.tagName === 'A' || el.tagName === 'BUTTON' || el.tagName === 'FORM') return;
      if (el.dataset && el.dataset.profileEmail) {
        empProfileOpen(el.dataset.profileEmail);
        return;
      }
      el = el.parentElement;
    }
  });

  /* ── Close on Escape ────────────────────────────────────────────── */
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') empProfileClose();
  });

})();