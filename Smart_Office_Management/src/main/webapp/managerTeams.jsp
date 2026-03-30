<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="com.smartoffice.model.Team"%>
<%@ page import="com.smartoffice.model.User"%>
<%@ page import="com.smartoffice.model.Task"%>
<%@ page import="com.smartoffice.dao.TaskDAO"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>

<%
String username = (String) session.getAttribute("username");
if (username == null) {
    response.sendRedirect(request.getContextPath() + "/index.html");
    return;
}

List<Team> myTeams = (List<Team>) request.getAttribute("myTeams");
if (myTeams == null) myTeams = java.util.Collections.emptyList();

Map<String, List<Task>> tasksByEmail = new HashMap<>();
try {
    for (Team tm : myTeams) {
        for (User m : tm.getMembers()) {
            String email = m.getEmail();
            if (email != null && !tasksByEmail.containsKey(email)) {
                List<Task> empTasks = TaskDAO.getTasksForEmployee(email);
                tasksByEmail.put(email, empTasks != null ? empTasks : new ArrayList<>());
            }
        }
    }
} catch (Exception ignored) {}

java.text.SimpleDateFormat sdfDate = new java.text.SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>My Teams • Manager</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
<style>
/* ══════════════════════════════════════════
   DESIGN TOKENS
══════════════════════════════════════════ */
:root {
  --brand:        #4F6EF7;
  --brand-dark:   #3B57E3;
  --brand-light:  #EEF2FF;
  --brand-glow:   rgba(79,110,247,.15);

  --green:        #10B981;
  --green-bg:     #D1FAE5;
  --amber:        #F59E0B;
  --amber-bg:     #FEF3C7;
  --red:          #EF4444;
  --red-bg:       #FEE2E2;
  --violet:       #8B5CF6;
  --violet-bg:    #EDE9FE;

  --surface:      #FFFFFF;
  --surface-2:    #F8FAFC;
  --surface-3:    #F1F5F9;
  --border:       #E2E8F0;
  --border-mid:   #CBD5E1;
  --text-1:       #0F172A;
  --text-2:       #334155;
  --text-3:       #64748B;
  --text-4:       #94A3B8;
  --text-5:       #CBD5E1;

  --radius-sm:    6px;
  --radius-md:    10px;
  --radius-lg:    14px;
  --radius-xl:    18px;
  --radius-2xl:   24px;

  --shadow-xs:    0 1px 2px rgba(0,0,0,.05);
  --shadow-sm:    0 2px 8px rgba(0,0,0,.06);
  --shadow-md:    0 4px 16px rgba(0,0,0,.08);
  --shadow-lg:    0 12px 40px rgba(0,0,0,.12);
  --shadow-brand: 0 4px 16px rgba(79,110,247,.25);
}

/* ══════════════════════════════════════════
   RESET & BASE
══════════════════════════════════════════ */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { font-size: 14px; }
body {
  font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
  background: var(--surface-2);
  color: var(--text-2);
  line-height: 1.5;
  -webkit-font-smoothing: antialiased;
}
button { font-family: inherit; cursor: pointer; border: none; background: none; }
input, select, textarea { font-family: inherit; }

::-webkit-scrollbar { width: 4px; height: 4px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--border-mid); border-radius: 99px; }

/* ══════════════════════════════════════════
   PAGE WRAPPER
══════════════════════════════════════════ */
.page { max-width: 1280px; margin: 0 auto; padding: 28px 28px 60px; }

/* ══════════════════════════════════════════
   PAGE HEADER
══════════════════════════════════════════ */
.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 28px;
  gap: 16px;
  flex-wrap: wrap;
}
.page-header-left { display: flex; align-items: center; gap: 14px; }
.page-icon {
  width: 44px; height: 44px;
  background: var(--brand);
  border-radius: var(--radius-lg);
  display: flex; align-items: center; justify-content: center;
  color: white; font-size: 18px;
  box-shadow: var(--shadow-brand);
  flex-shrink: 0;
}
.page-title { font-size: 1.5rem; font-weight: 800; color: var(--text-1); letter-spacing: -.02em; }
.page-subtitle { font-size: .8rem; color: var(--text-4); margin-top: 2px; }

/* ══════════════════════════════════════════
   TEAM CARDS GRID
══════════════════════════════════════════ */
.teams-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 16px;
  margin-bottom: 28px;
}

.team-card {
  background: var(--surface);
  border: 1.5px solid var(--border);
  border-radius: var(--radius-xl);
  padding: 20px;
  cursor: pointer;
  transition: all .2s ease;
  position: relative;
  overflow: hidden;
}
.team-card::after {
  content: '';
  position: absolute; top: 0; left: 0; right: 0; height: 3px;
  background: linear-gradient(90deg, var(--brand), #818CF8);
  transform: scaleX(0); transform-origin: left;
  transition: transform .25s ease;
  border-radius: var(--radius-xl) var(--radius-xl) 0 0;
}
.team-card:hover { border-color: var(--brand); box-shadow: var(--shadow-md), 0 0 0 3px var(--brand-glow); transform: translateY(-2px); }
.team-card:hover::after, .team-card.selected::after { transform: scaleX(1); }
.team-card.selected { border-color: var(--brand); background: #FAFCFF; box-shadow: var(--shadow-md), 0 0 0 3px var(--brand-glow); }

.team-card-top { display: flex; align-items: flex-start; gap: 12px; margin-bottom: 16px; }
.team-avatar {
  width: 42px; height: 42px;
  background: var(--brand-light);
  border-radius: var(--radius-md);
  display: flex; align-items: center; justify-content: center;
  color: var(--brand); font-size: 17px; flex-shrink: 0;
}
.team-name { font-weight: 700; font-size: .9rem; color: var(--text-1); line-height: 1.3; }
.team-manager { font-size: .75rem; color: var(--text-4); margin-top: 3px; display: flex; align-items: center; gap: 5px; }

.team-card-foot {
  display: flex; align-items: center; justify-content: space-between;
  padding-top: 14px;
  border-top: 1px solid var(--surface-3);
}
.team-count { font-size: .75rem; color: var(--text-3); display: flex; align-items: center; gap: 5px; }
.team-count i { color: var(--brand); font-size: .7rem; }
.team-cta { font-size: .72rem; font-weight: 700; color: var(--brand); letter-spacing: .01em; }

/* ══════════════════════════════════════════
   EMPTY STATE
══════════════════════════════════════════ */
.empty-state {
  background: var(--surface); border: 1.5px solid var(--border); border-radius: var(--radius-xl);
  padding: 56px 24px; text-align: center; color: var(--text-4);
}
.empty-state i { font-size: 36px; color: var(--text-5); display: block; margin-bottom: 12px; }
.empty-state strong { display: block; font-size: .9rem; font-weight: 700; color: var(--text-3); margin-bottom: 4px; }
.empty-state p { font-size: .8rem; }

/* ══════════════════════════════════════════
   TEAM DETAIL PANEL
══════════════════════════════════════════ */
.breadcrumb { display: flex; align-items: center; gap: 8px; margin-bottom: 20px; font-size: .8rem; }
.breadcrumb-back {
  display: flex; align-items: center; gap: 5px;
  font-weight: 700; color: var(--brand); background: var(--brand-light);
  border: 1.5px solid #C7D2FE; border-radius: var(--radius-md);
  padding: 5px 12px; transition: all .15s;
}
.breadcrumb-back:hover { background: var(--brand); color: white; border-color: var(--brand); }
.breadcrumb-sep { color: var(--text-5); }
.breadcrumb-cur { font-weight: 600; color: var(--text-2); }

/* Assign Bar */
.assign-bar {
  display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--radius-xl); padding: 16px 20px;
  box-shadow: var(--shadow-xs); margin-bottom: 16px;
}
.assign-bar-icon {
  width: 38px; height: 38px; background: var(--brand-light);
  border-radius: var(--radius-md); display: flex; align-items: center; justify-content: center;
  color: var(--brand); font-size: 15px; flex-shrink: 0;
}
.assign-bar-label { font-weight: 700; font-size: .85rem; color: var(--text-1); }
.assign-bar-sub { font-size: .75rem; color: var(--text-4); }
.btn-primary {
  margin-left: auto;
  display: inline-flex; align-items: center; gap: 7px;
  background: var(--brand); color: white;
  font-weight: 700; font-size: .8rem;
  padding: 9px 18px; border-radius: var(--radius-md);
  box-shadow: var(--shadow-brand);
  transition: all .15s; white-space: nowrap; flex-shrink: 0;
}
.btn-primary:hover { background: var(--brand-dark); transform: translateY(-1px); box-shadow: 0 6px 20px rgba(79,110,247,.35); }
.btn-primary i { font-size: .7rem; }

/* ══════════════════════════════════════════
   EMPLOYEE TABLE
══════════════════════════════════════════ */
.table-card {
  background: var(--surface); border: 1.5px solid var(--border);
  border-radius: var(--radius-xl); overflow: hidden; box-shadow: var(--shadow-sm);
}
.table-header {
  display: flex; align-items: center; justify-content: space-between; gap: 12px; flex-wrap: wrap;
  padding: 18px 22px; border-bottom: 1.5px solid var(--border);
  background: var(--surface);
}
.table-title { font-weight: 800; font-size: .95rem; color: var(--text-1); }
.table-sub { font-size: .75rem; color: var(--text-4); margin-top: 2px; display: flex; align-items: center; gap: 5px; }
.table-header-right { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }

.search-input-wrap { position: relative; }
.search-input-wrap i { position: absolute; left: 10px; top: 50%; transform: translateY(-50%); color: var(--text-4); font-size: .75rem; pointer-events: none; }
.search-input {
  padding: 8px 12px 8px 30px; border: 1.5px solid var(--border);
  border-radius: var(--radius-md); font-size: .8rem; color: var(--text-2);
  background: var(--surface-2); width: 180px;
  outline: none; transition: all .15s;
}
.search-input:focus { border-color: var(--brand); background: white; box-shadow: 0 0 0 3px var(--brand-glow); width: 220px; }

.badge-count {
  font-size: .72rem; font-weight: 700; color: var(--brand);
  background: var(--brand-light); border: 1.5px solid #C7D2FE;
  padding: 5px 12px; border-radius: 99px; white-space: nowrap;
}

/* Table itself */
table { width: 100%; border-collapse: collapse; }
thead tr { background: var(--surface-2); }
thead th {
  padding: 11px 16px; text-align: left;
  font-size: .68rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em;
  color: var(--text-4); white-space: nowrap; border-bottom: 1.5px solid var(--border);
}
tbody tr { border-bottom: 1px solid var(--surface-3); transition: background .12s; cursor: pointer; }
tbody tr:last-child { border-bottom: none; }
tbody tr:hover { background: #F5F8FF; }
tbody td { padding: 14px 16px; font-size: .82rem; color: var(--text-2); vertical-align: middle; }

.emp-avatar {
  width: 36px; height: 36px; border-radius: 50%;
  background: linear-gradient(135deg, var(--brand), #818CF8);
  display: flex; align-items: center; justify-content: center;
  color: white; font-size: .72rem; font-weight: 800; flex-shrink: 0;
  font-family: 'JetBrains Mono', monospace;
}
.emp-name { font-weight: 700; color: var(--text-1); font-size: .83rem; }
.emp-email { font-size: .7rem; color: var(--text-4); font-family: 'JetBrains Mono', monospace; margin-top: 1px; }

.num-badge { font-weight: 700; font-size: .82rem; }
.num-green  { color: var(--green); }
.num-amber  { color: var(--amber); }
.num-red    { color: var(--red); }
.num-muted  { color: var(--text-5); }

.progress-bar-wrap { height: 5px; background: var(--surface-3); border-radius: 99px; overflow: hidden; min-width: 80px; }
.progress-bar-fill { height: 100%; background: linear-gradient(90deg, var(--brand), var(--green)); border-radius: 99px; transition: width .6s ease; }
.progress-pct { font-size: .72rem; font-weight: 700; color: var(--text-3); white-space: nowrap; }

.btn-sm {
  display: inline-flex; align-items: center; gap: 5px;
  font-size: .72rem; font-weight: 700;
  padding: 6px 12px; border-radius: var(--radius-sm);
  transition: all .12s; white-space: nowrap;
}
.btn-sm-primary { background: var(--brand-light); color: var(--brand); border: 1.5px solid #C7D2FE; }
.btn-sm-primary:hover { background: var(--brand); color: white; border-color: var(--brand); }
.btn-sm-ghost { background: var(--surface-2); color: var(--text-3); border: 1.5px solid var(--border); }
.btn-sm-ghost:hover { background: var(--surface-3); color: var(--text-2); border-color: var(--border-mid); }

.desig-chip {
  display: inline-block;
  font-size: .7rem; font-weight: 600; color: var(--text-3);
  background: var(--surface-2); border: 1px solid var(--border);
  padding: 3px 9px; border-radius: 99px;
}

/* ══════════════════════════════════════════
   MODALS
══════════════════════════════════════════ */
.overlay {
  position: fixed; inset: 0; z-index: 900;
  background: rgba(15,23,42,.5); backdrop-filter: blur(6px);
  display: flex; align-items: center; justify-content: center; padding: 16px;
  opacity: 0; pointer-events: none; transition: opacity .22s;
}
.overlay.open { opacity: 1; pointer-events: all; }

.modal {
  background: var(--surface); border-radius: var(--radius-2xl);
  width: 100%; box-shadow: var(--shadow-lg);
  transform: translateY(18px) scale(.97);
  transition: transform .28s cubic-bezier(.34,1.4,.64,1);
  max-height: 90vh; overflow-y: auto;
}
.overlay.open .modal { transform: translateY(0) scale(1); }

.modal-header {
  display: flex; align-items: center; gap: 14px;
  padding: 22px 24px 18px;
  border-bottom: 1.5px solid var(--border);
  position: sticky; top: 0; background: var(--surface); z-index: 10;
  border-radius: var(--radius-2xl) var(--radius-2xl) 0 0;
}
.modal-close {
  width: 32px; height: 32px; border-radius: 50%; margin-left: auto;
  background: var(--surface-2); color: var(--text-3);
  display: flex; align-items: center; justify-content: center;
  font-size: .8rem; transition: all .12s; flex-shrink: 0;
}
.modal-close:hover { background: var(--red-bg); color: var(--red); }

.modal-body { padding: 22px 24px; }

/* Stat cards inside modal */
.stat-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; margin-bottom: 18px; }
.stat-box {
  background: var(--surface-2); border: 1.5px solid var(--border);
  border-radius: var(--radius-lg); padding: 14px; text-align: center;
}
.stat-box .sv { font-size: 1.5rem; font-weight: 800; line-height: 1; color: var(--text-1); }
.stat-box .sl { font-size: .65rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em; color: var(--text-4); margin-top: 4px; }

/* Ring */
.ring-section {
  display: flex; align-items: center; gap: 18px;
  background: var(--surface-2); border: 1.5px solid var(--border);
  border-radius: var(--radius-lg); padding: 18px; margin-bottom: 18px;
}
.ring-wrap { position: relative; display: inline-flex; align-items: center; justify-content: center; flex-shrink: 0; }
.ring-wrap svg { transform: rotate(-90deg); }
.ring-bg   { fill: none; stroke: var(--border); stroke-width: 7; }
.ring-fill { fill: none; stroke-width: 7; stroke-linecap: round; transition: stroke-dashoffset .9s cubic-bezier(.4,0,.2,1); }
.ring-pct  { position: absolute; font-size: 1rem; font-weight: 800; color: var(--text-1); font-family: 'Plus Jakarta Sans', sans-serif; }

/* Task pills */
.t-pill { display: inline-flex; align-items: center; gap: 4px; padding: 3px 10px; border-radius: 99px; font-size: .68rem; font-weight: 700; }
.tp-done    { background: var(--green-bg);  color: #065F46; }
.tp-open    { background: var(--amber-bg);  color: #92400E; }
.tp-overdue { background: var(--red-bg);    color: #991B1B; }
.tp-review  { background: var(--violet-bg); color: #5B21B6; }

/* Modal tabs */
.tab-bar { display: flex; gap: 6px; flex-wrap: wrap; margin-bottom: 16px; }
.tab-btn {
  padding: 6px 16px; border-radius: 99px; font-size: .75rem; font-weight: 700;
  border: 1.5px solid var(--border); color: var(--text-3); background: var(--surface);
  transition: all .13s;
}
.tab-btn:hover { border-color: var(--brand); color: var(--brand); }
.tab-btn.active { background: var(--brand); color: white; border-color: var(--brand); box-shadow: var(--shadow-brand); }

/* Task list items */
.task-item {
  display: flex; align-items: flex-start; gap: 12px;
  padding: 12px 14px; border-radius: var(--radius-md);
  border: 1.5px solid var(--border); background: var(--surface);
  margin-bottom: 8px; transition: all .12s;
}
.task-item:hover { border-color: var(--brand); background: #F5F8FF; }
.task-item-body { flex: 1; min-width: 0; }
.task-item-title { font-size: .83rem; font-weight: 700; color: var(--text-1); }
.task-item-desc { font-size: .72rem; color: var(--text-4); margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.task-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-top: 6px; font-size: .7rem; color: var(--text-4); }
.prio-high   { color: var(--red);   font-weight: 700; }
.prio-medium { color: var(--amber); font-weight: 700; }
.prio-low    { color: var(--green); font-weight: 700; }

/* ══════════════════════════════════════════
   ASSIGN FORM
══════════════════════════════════════════ */
.form-group { margin-bottom: 16px; }
.form-label {
  display: block; font-size: .72rem; font-weight: 700; text-transform: uppercase;
  letter-spacing: .06em; color: var(--text-3); margin-bottom: 6px;
}
.form-label .req { color: var(--red); }
.form-control {
  width: 100%; padding: 9px 12px;
  border: 1.5px solid var(--border); border-radius: var(--radius-md);
  font-size: .82rem; color: var(--text-2); background: var(--surface-2);
  outline: none; transition: all .15s;
}
.form-control:focus { border-color: var(--brand); background: white; box-shadow: 0 0 0 3px var(--brand-glow); }
textarea.form-control { resize: vertical; min-height: 80px; }
.form-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

/* Employee picker */
.picker-wrap { position: relative; }
.picker-trigger {
  width: 100%; min-height: 42px;
  display: flex; align-items: center; justify-content: space-between; gap: 8px;
  padding: 7px 12px; border: 1.5px solid var(--border); border-radius: var(--radius-md);
  background: var(--surface-2); cursor: pointer; transition: all .15s; user-select: none;
}
.picker-trigger:focus, .picker-trigger.open { border-color: var(--brand); background: white; box-shadow: 0 0 0 3px var(--brand-glow); outline: none; }
.picker-chips { display: flex; flex-wrap: wrap; gap: 5px; flex: 1; min-width: 0; }
.picker-ph { font-size: .82rem; color: var(--text-4); }
.picker-chevron { font-size: .7rem; color: var(--text-4); flex-shrink: 0; transition: transform .15s; }

.picker-dropdown {
  position: absolute; z-index: 300; top: calc(100% + 5px); left: 0; right: 0;
  background: white; border: 1.5px solid var(--border); border-radius: var(--radius-lg);
  box-shadow: var(--shadow-lg); max-height: 230px; overflow-y: auto; display: none;
}
.picker-dropdown.open { display: block; }
.picker-search { padding: 8px 12px; border-bottom: 1px solid var(--surface-3); position: sticky; top: 0; background: white; z-index: 1; }
.picker-search input {
  width: 100%; padding: 6px 10px; border: 1.5px solid var(--border); border-radius: var(--radius-sm);
  font-size: .78rem; outline: none; background: var(--surface-2); font-family: inherit;
}
.picker-search input:focus { border-color: var(--brand); background: white; }
.picker-select-all {
  display: flex; align-items: center; gap: 8px; padding: 8px 14px;
  border-bottom: 1.5px solid var(--surface-3); cursor: pointer;
}
.picker-select-all:hover { background: var(--surface-2); }
.picker-select-all label { font-size: .72rem; font-weight: 800; color: var(--brand); text-transform: uppercase; letter-spacing: .05em; cursor: pointer; }
.picker-opt {
  display: flex; align-items: center; gap: 10px; padding: 9px 14px;
  cursor: pointer; border-bottom: 1px solid var(--surface-3); font-size: .82rem; transition: background .1s;
}
.picker-opt:last-child { border-bottom: none; }
.picker-opt:hover { background: #F5F8FF; }
.picker-opt.selected { background: var(--brand-light); }
.picker-opt input[type="checkbox"] { accent-color: var(--brand); width: 15px; height: 15px; flex-shrink: 0; cursor: pointer; }

.chip {
  display: inline-flex; align-items: center; gap: 4px;
  background: var(--brand-light); color: var(--brand);
  border: 1px solid #C7D2FE; border-radius: 99px;
  padding: 2px 8px 2px 10px; font-size: .7rem; font-weight: 700;
}
.chip-x { cursor: pointer; color: #818CF8; font-size: .65rem; margin-left: 2px; transition: color .1s; }
.chip-x:hover { color: var(--red); }

.form-error { font-size: .72rem; color: var(--red); margin-top: 5px; display: none; }
.form-error i { margin-right: 3px; }

.preview-box {
  background: var(--brand-light); border: 1.5px solid #C7D2FE;
  border-radius: var(--radius-md); padding: 12px 14px; display: none;
}
.preview-title { font-size: .72rem; font-weight: 800; color: var(--brand); margin-bottom: 8px; }
.preview-tags { display: flex; flex-wrap: wrap; gap: 5px; }
.preview-tag {
  font-size: .68rem; font-weight: 600; color: var(--brand-dark);
  background: white; border: 1px solid #C7D2FE; border-radius: 99px; padding: 3px 10px;
}

/* ══════════════════════════════════════════
   ANIMATIONS
══════════════════════════════════════════ */
@keyframes fadeUp { from { opacity: 0; transform: translateY(14px); } to { opacity: 1; transform: translateY(0); } }
.fade-up { animation: fadeUp .3s ease both; }
@keyframes scaleIn { from { opacity: 0; transform: scale(.94); } to { opacity: 1; transform: scale(1); } }
.scale-in { animation: scaleIn .22s ease both; }

/* Stagger for cards */
.team-card:nth-child(1) { animation-delay: .04s; }
.team-card:nth-child(2) { animation-delay: .08s; }
.team-card:nth-child(3) { animation-delay: .12s; }
.team-card:nth-child(4) { animation-delay: .16s; }
.team-card:nth-child(5) { animation-delay: .20s; }
.team-card:nth-child(6) { animation-delay: .24s; }

/* Misc */
.section-label { font-size: .68rem; font-weight: 800; text-transform: uppercase; letter-spacing: .08em; color: var(--text-4); margin-bottom: 10px; }
.submitted-pill {
  display: inline-flex; align-items: center; gap: 6px;
  padding: 5px 12px; border-radius: 99px; font-size: .72rem; font-weight: 700;
  background: var(--violet-bg); color: #5B21B6; border: 1.5px solid #DDD6FE;
}
</style>
</head>
<body>

<!-- ════════ JSON DATA ISLAND ════════ -->
<script id="teams-json" type="application/json">
[
<%
boolean firstTeam = true;
for (Team tm : myTeams) {
    if (!firstTeam) out.print(",");
    firstTeam = false;
    String tmName = tm.getName() != null ? tm.getName().replace("\\","\\\\").replace("\"","\\\"") : "";
    String mgr    = tm.getManagerFullname() != null ? tm.getManagerFullname().replace("\\","\\\\").replace("\"","\\\"")
                  : (tm.getManagerUsername() != null ? tm.getManagerUsername().replace("\\","\\\\").replace("\"","\\\"") : "");
%>
{"id":<%=tm.getId()%>,"name":"<%=tmName%>","manager":"<%=mgr%>","memberCount":<%=tm.getMembers().size()%>,"members":[
<%
    boolean firstMem = true;
    for (User m : tm.getMembers()) {
        if (!firstMem) out.print(",");
        firstMem = false;
        String fn = "";
        if (m.getFirstname() != null) fn += m.getFirstname().trim();
        if (m.getLastname()  != null) fn += (fn.isEmpty()?"": " ") + m.getLastname().trim();
        if (fn.isEmpty()) fn = m.getEmail() != null ? m.getEmail() : "";
        String email = m.getEmail()       != null ? m.getEmail().replace("\\","\\\\").replace("\"","\\\"")       : "";
        String desig = m.getDesignation() != null ? m.getDesignation().replace("\\","\\\\").replace("\"","\\\"") : "";
        String role  = m.getRole()        != null ? m.getRole().replace("\\","\\\\").replace("\"","\\\"")        : "";
        fn = fn.replace("\\","\\\\").replace("\"","\\\"");

        List<Task> empTasks = tasksByEmail.getOrDefault(m.getEmail(), new ArrayList<>());
        int total=0, completed=0, open=0, overdue=0, submitted=0;
        java.util.Date todayD = new java.util.Date();
        for (Task t : empTasks) {
            total++;
            String st = t.getStatus() != null ? t.getStatus().trim().toUpperCase() : "";
            if ("COMPLETED".equals(st)) completed++;
            else if ("SUBMITTED".equals(st)||"PROCESSING".equals(st)) { submitted++; open++; }
            else open++;
            if (!"COMPLETED".equals(st) && t.getDeadline()!=null && t.getDeadline().before(todayD)) overdue++;
        }
        int compPct = total>0?(completed*100/total):0;
%>
{"email":"<%=email%>","name":"<%=fn%>","desig":"<%=desig%>","role":"<%=role%>","stats":{"total":<%=total%>,"completed":<%=completed%>,"open":<%=open%>,"overdue":<%=overdue%>,"submitted":<%=submitted%>,"compPct":<%=compPct%>},"tasks":[
<%
        boolean firstTask = true;
        for (Task t : empTasks) {
            if (!firstTask) out.print(",");
            firstTask = false;
            String tTitle    = t.getTitle()       !=null?t.getTitle().replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n"):"Untitled";
            String tStatus   = t.getStatus()      !=null?t.getStatus().trim().toUpperCase():"ASSIGNED";
            String tPriority = t.getPriority()    !=null?t.getPriority().trim().toUpperCase():"MEDIUM";
            String tDeadline = t.getDeadline()    !=null?t.getDeadline().toString():"";
            String tAssigned = t.getAssignedDate()!=null?sdfDate.format(t.getAssignedDate()):"";
            String tDesc     = t.getDescription() !=null?t.getDescription().replace("\\","\\\\").replace("\"","\\\"").replace("\n"," "):"";
%>
{"id":<%=t.getId()%>,"title":"<%=tTitle%>","status":"<%=tStatus%>","priority":"<%=tPriority%>","deadline":"<%=tDeadline%>","assigned":"<%=tAssigned%>","desc":"<%=tDesc%>"}
<%      }%>
]}
<%  }%>
]}
<%}%>
]
</script>

<!-- ════════ PAGE ════════ -->
<div class="page">

  <!-- Header -->
  <div class="page-header">
    <div class="page-header-left">
      <div class="page-icon"><i class="fa-solid fa-people-group"></i></div>
      <div>
        <div class="page-title">My Teams</div>
        <div class="page-subtitle">Select a team to view members and manage tasks</div>
      </div>
    </div>
  </div>

  <!-- Teams Grid -->
  <div id="teamsGrid" class="teams-grid"></div>

  <!-- No teams -->
  <div id="noTeams" class="empty-state" style="display:none;">
    <i class="fa-solid fa-people-group"></i>
    <strong>No teams assigned yet</strong>
    <p>Ask your admin to create a team and assign you as manager.</p>
  </div>

  <!-- Team Detail -->
  <div id="teamDetail" style="display:none;" class="fade-up">

    <!-- Breadcrumb -->
    <div class="breadcrumb">
      <button class="breadcrumb-back" onclick="backToTeams()">
        <i class="fa-solid fa-chevron-left" style="font-size:.65rem;"></i> All Teams
      </button>
      <span class="breadcrumb-sep">›</span>
      <span class="breadcrumb-cur" id="detailTeamName"></span>
    </div>

    <!-- Assign Bar -->
    <div class="assign-bar">
      <div class="assign-bar-icon"><i class="fa-solid fa-paper-plane"></i></div>
      <div>
        <div class="assign-bar-label">Assign a Task</div>
        <div class="assign-bar-sub">Assign to one or multiple team members at once</div>
      </div>
      <button class="btn-primary" onclick="openAssignModal([])">
        <i class="fa-solid fa-plus"></i> Assign to Team Member(s)
      </button>
    </div>

    <!-- Table Card -->
    <div class="table-card">
      <div class="table-header">
        <div>
          <div class="table-title" id="detailTeamLabel"></div>
          <div class="table-sub" id="detailTeamMgr"></div>
        </div>
        <div class="table-header-right">
          <div class="search-input-wrap">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" class="search-input" id="empSearch" placeholder="Search employees…" oninput="filterEmpTable(this.value)">
          </div>
          <span class="badge-count" id="empCountBadge"></span>
        </div>
      </div>

      <div style="overflow-x:auto;">
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Employee</th>
              <th>Designation</th>
              <th>Total</th>
              <th>Done</th>
              <th>Open</th>
              <th>Overdue</th>
              <th>Progress</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody id="empTableBody"></tbody>
        </table>
      </div>

      <div id="empTableEmpty" class="empty-state" style="display:none; border:none; border-radius:0;">
        <i class="fa-solid fa-user-slash"></i>
        <strong>No employees match your search</strong>
      </div>
    </div>
  </div>
</div>

<!-- ════════ EMPLOYEE STATS MODAL ════════ -->
<div id="empModal" class="overlay" onclick="if(event.target===this)closeEmpModal()">
  <div class="modal" style="max-width:760px;" onclick="event.stopPropagation()">

    <div class="modal-header">
      <div id="modalAvatar" class="emp-avatar" style="width:48px;height:48px;font-size:.9rem;border-radius:14px;flex-shrink:0;">?</div>
      <div style="flex:1;min-width:0;">
        <div id="modalName" style="font-size:1.05rem;font-weight:800;color:var(--text-1);"></div>
        <div id="modalDesig" style="font-size:.75rem;color:var(--text-3);margin-top:1px;"></div>
        <div id="modalEmail" style="font-size:.7rem;color:var(--text-4);font-family:'JetBrains Mono',monospace;margin-top:1px;"></div>
      </div>
      <button class="btn-primary" onclick="openAssignFromModal()" style="margin-left:0;">
        <i class="fa-solid fa-plus"></i> Assign Task
      </button>
      <button class="modal-close" onclick="closeEmpModal()"><i class="fa-solid fa-xmark"></i></button>
    </div>

    <div class="modal-body">
      <!-- Stats Row -->
      <div class="stat-row">
        <div class="stat-box"><div class="sv" style="color:var(--brand);" id="mStat-total">0</div><div class="sl">Total</div></div>
        <div class="stat-box"><div class="sv" style="color:var(--green);" id="mStat-done">0</div><div class="sl">Completed</div></div>
        <div class="stat-box"><div class="sv" style="color:var(--amber);" id="mStat-open">0</div><div class="sl">In Progress</div></div>
        <div class="stat-box"><div class="sv" style="color:var(--red);"   id="mStat-over">0</div><div class="sl">Overdue</div></div>
      </div>

      <!-- Ring + completion -->
      <div class="ring-section">
        <div class="ring-wrap">
          <svg width="82" height="82" viewBox="0 0 82 82">
            <circle class="ring-bg" cx="41" cy="41" r="33"></circle>
            <circle class="ring-fill" id="modalRingFill" cx="41" cy="41" r="33"
              stroke="url(#rg)" stroke-dasharray="207.35" stroke-dashoffset="207.35"></circle>
            <defs>
              <linearGradient id="rg" x1="0%" y1="0%" x2="100%" y2="0%">
                <stop offset="0%" stop-color="#4F6EF7"/>
                <stop offset="100%" stop-color="#10B981"/>
              </linearGradient>
            </defs>
          </svg>
          <span class="ring-pct" id="modalRingPct">0%</span>
        </div>
        <div style="flex:1;">
          <div style="font-weight:700;font-size:.85rem;color:var(--text-1);margin-bottom:4px;">Completion Rate</div>
          <div style="font-size:.78rem;color:var(--text-4);" id="modalCompLabel"></div>
          <div style="margin-top:10px;">
            <span id="pill-submitted" class="submitted-pill" style="display:none;">
              <i class="fa-solid fa-hourglass-half" style="font-size:.65rem;"></i>
              <span id="pill-sub-val">0</span> Awaiting Review
            </span>
          </div>
        </div>
      </div>

      <!-- Tabs -->
      <div class="tab-bar" id="modalTabBar">
        <button class="tab-btn active" onclick="switchModalTab('all',this)">All Tasks</button>
        <button class="tab-btn" onclick="switchModalTab('open',this)">Open</button>
        <button class="tab-btn" onclick="switchModalTab('completed',this)">Completed</button>
        <button class="tab-btn" onclick="switchModalTab('overdue',this)">Overdue</button>
      </div>

      <div id="modalTaskList"></div>
    </div>
  </div>
</div>

<!-- ════════ ASSIGN TASK MODAL ════════ -->
<div id="assignModal" class="overlay" onclick="if(event.target===this)closeAssignModal()">
  <div class="modal" style="max-width:520px;" onclick="event.stopPropagation()">

    <div class="modal-header">
      <div style="width:38px;height:38px;background:var(--brand-light);border-radius:var(--radius-md);display:flex;align-items:center;justify-content:center;color:var(--brand);font-size:15px;flex-shrink:0;">
        <i class="fa-solid fa-paper-plane"></i>
      </div>
      <div>
        <div style="font-size:.95rem;font-weight:800;color:var(--text-1);">Assign New Task</div>
        <div style="font-size:.72rem;color:var(--text-4);">Select one or multiple employees</div>
      </div>
      <button class="modal-close" onclick="closeAssignModal()"><i class="fa-solid fa-xmark"></i></button>
    </div>

    <div class="modal-body">
      <form action="<%=request.getContextPath()%>/managerTasks" method="post"
            enctype="multipart/form-data" id="assignModalForm"
            onsubmit="return validateAssignForm()">
        <input type="hidden" name="action" value="assign">

        <!-- Employee Picker -->
        <div class="form-group">
          <label class="form-label">
            Assign To <span class="req">*</span>
            <span id="selCountLabel" style="color:var(--brand);font-weight:600;text-transform:none;letter-spacing:0;margin-left:4px;"></span>
          </label>
          <div class="picker-wrap" id="empPickerWrapper">
            <div class="picker-trigger" id="empPickerTrigger" tabindex="0"
                 onclick="toggleEmpPicker()" onkeydown="if(event.key==='Enter'||event.key===' ')toggleEmpPicker()">
              <div class="picker-chips" id="empPickerChips">
                <span class="picker-ph" id="empPickerPlaceholder">Select employees…</span>
              </div>
              <i class="fa-solid fa-chevron-down picker-chevron" id="empPickerChevron"></i>
            </div>
            <div class="picker-dropdown" id="empPickerDropdown">
              <div class="picker-search">
                <input type="text" placeholder="Search employees…" id="empPickerSearchInput"
                       oninput="filterPickerOptions(this.value)" onclick="event.stopPropagation()">
              </div>
              <div class="picker-select-all" onclick="toggleSelectAll()">
                <input type="checkbox" id="selectAllCb" onclick="event.stopPropagation();toggleSelectAll()" style="accent-color:var(--brand);width:15px;height:15px;cursor:pointer;">
                <label for="selectAllCb"><i class="fa-solid fa-users" style="margin-right:5px;"></i>Select All</label>
              </div>
              <div id="empPickerOptions"></div>
            </div>
          </div>
          <div id="empHiddenInputs"></div>
          <div id="empPickerError" class="form-error"><i class="fa-solid fa-circle-exclamation"></i>Please select at least one employee.</div>
        </div>

        <!-- Title -->
        <div class="form-group">
          <label class="form-label">Title <span class="req">*</span></label>
          <input type="text" name="title" class="form-control" placeholder="e.g. Submit weekly report" required>
        </div>

        <!-- Description -->
        <div class="form-group">
          <label class="form-label">Description <span class="req">*</span></label>
          <textarea name="taskDesc" class="form-control" rows="3" placeholder="Add clear instructions…" required></textarea>
        </div>

        <!-- Deadline + Priority -->
        <div class="form-group form-grid-2">
          <div>
            <label class="form-label">Deadline <span class="req">*</span></label>
            <input type="date" name="deadline" id="assignModalDeadline" class="form-control" required>
          </div>
          <div>
            <label class="form-label">Priority <span class="req">*</span></label>
            <select name="priority" class="form-control" required>
              <option value="HIGH">High</option>
              <option value="MEDIUM" selected>Medium</option>
              <option value="LOW">Low</option>
            </select>
          </div>
        </div>

        <!-- Attachment -->
        <div class="form-group">
          <label class="form-label">Attachment <span style="color:var(--text-4);font-weight:400;text-transform:none;">(optional)</span></label>
          <input type="file" name="attachment" class="form-control" accept=".pdf,.doc,.docx,.xls,.xlsx,.txt,.png,.jpg,.jpeg" style="padding:6px 10px;cursor:pointer;">
        </div>

        <!-- Preview -->
        <div id="assignPreview" class="preview-box form-group">
          <div class="preview-title"><i class="fa-solid fa-paper-plane" style="margin-right:5px;"></i>Task will be assigned to: <span id="assignPreviewCount" style="font-weight:900;"></span></div>
          <div class="preview-tags" id="assignPreviewNames"></div>
        </div>

        <button type="submit" class="btn-primary" style="width:100%;justify-content:center;padding:11px;">
          <i class="fa-solid fa-paper-plane"></i>
          <span id="assignSubmitLabel">Assign Task</span>
        </button>
      </form>
    </div>
  </div>
</div>

<script>
// ══════════════════════ DATA ══════════════════════
const TEAMS = JSON.parse(document.getElementById('teams-json').textContent);
let selectedTeam  = null;
let modalEmployee = null;
let selectedEmails = new Set();

// ══════════════════════ HELPERS ══════════════════════
function getInitials(name) {
  if (!name) return '?';
  const p = name.trim().split(/\s+/);
  return (p[0][0] + (p[1] ? p[1][0] : '')).toUpperCase();
}
function esc(s) {
  if (!s) return '';
  return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ══════════════════════ RENDER TEAMS ══════════════════════
function renderTeams() {
  const grid = document.getElementById('teamsGrid');
  if (!TEAMS.length) { document.getElementById('noTeams').style.display = ''; return; }
  TEAMS.forEach(function(tm) {
    const card = document.createElement('div');
    card.className = 'team-card scale-in';
    card.innerHTML =
      '<div class="team-card-top">' +
        '<div class="team-avatar"><i class="fa-solid fa-people-group"></i></div>' +
        '<div style="flex:1;min-width:0;">' +
          '<div class="team-name">' + esc(tm.name) + '</div>' +
          '<div class="team-manager"><i class="fa-solid fa-user-tie"></i>' + esc(tm.manager) + '</div>' +
        '</div>' +
      '</div>' +
      '<div class="team-card-foot">' +
        '<span class="team-count"><i class="fa-solid fa-users"></i>' + tm.memberCount + ' member' + (tm.memberCount !== 1 ? 's' : '') + '</span>' +
        '<span class="team-cta">View Team →</span>' +
      '</div>';
    card.onclick = function() { selectTeam(tm, card); };
    grid.appendChild(card);
  });
}

// ══════════════════════ TEAM SELECTION ══════════════════════
function selectTeam(tm, cardEl) {
  selectedTeam = tm;
  document.querySelectorAll('.team-card').forEach(function(c){ c.classList.remove('selected'); });
  if (cardEl) cardEl.classList.add('selected');
  document.getElementById('detailTeamName').textContent = tm.name;
  document.getElementById('detailTeamLabel').textContent = tm.name;
  document.getElementById('detailTeamMgr').innerHTML = '<i class="fa-solid fa-user-tie" style="margin-right:5px;color:var(--brand);"></i>Manager: ' + esc(tm.manager);
  document.getElementById('empCountBadge').textContent = tm.memberCount + ' employee' + (tm.memberCount !== 1 ? 's' : '');
  document.getElementById('empSearch').value = '';
  renderEmpTable(tm.members);
  const detail = document.getElementById('teamDetail');
  detail.style.display = '';
  detail.classList.remove('fade-up'); void detail.offsetWidth; detail.classList.add('fade-up');
  setTimeout(function(){ document.getElementById('teamDetail').scrollIntoView({ behavior:'smooth', block:'start' }); }, 50);
}

function backToTeams() {
  selectedTeam = null;
  document.getElementById('teamDetail').style.display = 'none';
  document.querySelectorAll('.team-card').forEach(function(c){ c.classList.remove('selected'); });
}

// ══════════════════════ EMP TABLE ══════════════════════
function renderEmpTable(members) {
  const tbody = document.getElementById('empTableBody');
  tbody.innerHTML = '';
  if (!members.length) { document.getElementById('empTableEmpty').style.display = ''; return; }
  document.getElementById('empTableEmpty').style.display = 'none';

  members.forEach(function(m, i) {
    const s = m.stats;
    const barW = Math.max(0, Math.min(100, s.compPct));
    const tr = document.createElement('tr');
    tr.className = 'emp-table-row';
    tr.dataset.name = (m.name || '').toLowerCase();
    tr.innerHTML =
      '<td style="color:var(--text-4);font-size:.7rem;font-family:\'JetBrains Mono\',monospace;">' + String(i+1).padStart(2,'0') + '</td>' +
      '<td><div style="display:flex;align-items:center;gap:10px;">' +
        '<div class="emp-avatar">' + getInitials(m.name) + '</div>' +
        '<div><div class="emp-name">' + esc(m.name) + '</div>' +
        '<div class="emp-email">' + esc(m.email) + '</div></div>' +
      '</div></td>' +
      '<td><span class="desig-chip">' + esc(m.desig || '—') + '</span></td>' +
      '<td><span class="num-badge" style="color:var(--text-2);">' + s.total + '</span></td>' +
      '<td><span class="num-badge num-green">' + s.completed + '</span></td>' +
      '<td><span class="num-badge num-amber">' + s.open + '</span></td>' +
      '<td>' + (s.overdue > 0 ? '<span class="num-badge num-red">' + s.overdue + '</span>' : '<span class="num-badge num-muted">0</span>') + '</td>' +
      '<td style="min-width:120px;">' +
        '<div style="display:flex;align-items:center;gap:8px;">' +
          '<div class="progress-bar-wrap" style="flex:1;"><div class="progress-bar-fill" style="width:' + barW + '%;"></div></div>' +
          '<span class="progress-pct">' + s.compPct + '%</span>' +
        '</div>' +
      '</td>' +
      '<td><div style="display:flex;align-items:center;gap:6px;">' +
        '<button onclick="openEmpModal(event,\'' + m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") + '\');" class="btn-sm btn-sm-primary"><i class="fa-solid fa-chart-bar"></i> Stats</button>' +
        '<button onclick="openAssignModal([\'' + m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") + '\']);" class="btn-sm btn-sm-ghost"><i class="fa-solid fa-plus"></i> Assign</button>' +
      '</div></td>';
    tr.onclick = function(e){ if(!e.target.closest('button')) openEmpModal(e, m.email); };
    tbody.appendChild(tr);
  });
}

function filterEmpTable(q) {
  let visible = 0;
  document.querySelectorAll('.emp-table-row').forEach(function(r){
    const match = !q || r.dataset.name.includes(q.toLowerCase());
    r.style.display = match ? '' : 'none';
    if (match) visible++;
  });
  document.getElementById('empTableEmpty').style.display = visible > 0 ? 'none' : '';
}

// ══════════════════════ EMP STATS MODAL ══════════════════════
function findMember(email){ return selectedTeam ? (selectedTeam.members.find(function(m){return m.email===email;})||null) : null; }

function openEmpModal(e, email) {
  if (e) e.stopPropagation();
  const m = findMember(email);
  if (!m) return;
  modalEmployee = m;

  document.getElementById('modalAvatar').textContent = getInitials(m.name);
  document.getElementById('modalName').textContent   = m.name;
  document.getElementById('modalDesig').textContent  = m.desig || m.role || '';
  document.getElementById('modalEmail').textContent  = m.email;

  const s = m.stats;
  document.getElementById('mStat-total').textContent = s.total;
  document.getElementById('mStat-done').textContent  = s.completed;
  document.getElementById('mStat-open').textContent  = s.open;
  document.getElementById('mStat-over').textContent  = s.overdue;

  const circ = 207.35;
  const ring = document.getElementById('modalRingFill');
  ring.style.strokeDashoffset = circ;
  setTimeout(function(){ ring.style.strokeDashoffset = circ - (s.compPct / 100) * circ; }, 60);
  document.getElementById('modalRingPct').textContent   = s.compPct + '%';
  document.getElementById('modalCompLabel').textContent = s.completed + ' of ' + s.total + ' tasks completed';

  const pillSub = document.getElementById('pill-submitted');
  if (s.submitted > 0) { document.getElementById('pill-sub-val').textContent = s.submitted; pillSub.style.display = ''; }
  else pillSub.style.display = 'none';

  document.querySelectorAll('#modalTabBar .tab-btn').forEach(function(t){ t.classList.remove('active'); });
  document.querySelector('#modalTabBar .tab-btn').classList.add('active');
  renderModalTasks('all');
  document.getElementById('empModal').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function closeEmpModal() {
  document.getElementById('empModal').classList.remove('open');
  document.body.style.overflow = '';
  modalEmployee = null;
}

function switchModalTab(tab, btn) {
  document.querySelectorAll('#modalTabBar .tab-btn').forEach(function(t){ t.classList.remove('active'); });
  if (btn) btn.classList.add('active');
  renderModalTasks(tab);
}

function renderModalTasks(tab) {
  if (!modalEmployee) return;
  const container = document.getElementById('modalTaskList');
  const tasks = modalEmployee.tasks || [];
  const today = new Date(); today.setHours(0,0,0,0);

  const filtered = tasks.filter(function(t){
    const ic = t.status === 'COMPLETED';
    const io = !ic && t.deadline && new Date(t.deadline) < today;
    switch(tab){
      case 'completed': return ic;
      case 'open':      return !ic;
      case 'overdue':   return io;
      default:          return true;
    }
  });

  if (!filtered.length) {
    container.innerHTML = '<div class="empty-state" style="border:none;padding:32px 24px;"><i class="fa-solid fa-inbox" style="font-size:28px;"></i><strong>No tasks in this category</strong></div>';
    return;
  }

  container.innerHTML = '<div class="section-label">' + filtered.length + ' task' + (filtered.length !== 1 ? 's' : '') + '</div>';
  filtered.forEach(function(t){
    const ic = t.status === 'COMPLETED';
    const io = !ic && t.deadline && new Date(t.deadline) < today;
    const ir = t.status === 'SUBMITTED' || t.status === 'PROCESSING';
    let pillCls, pillLabel;
    if (ic)      { pillCls='tp-done';    pillLabel='<i class="fa-solid fa-check-circle"></i> Done'; }
    else if (ir) { pillCls='tp-review';  pillLabel='<i class="fa-solid fa-hourglass-half"></i> Review'; }
    else if (io) { pillCls='tp-overdue'; pillLabel='<i class="fa-solid fa-exclamation-circle"></i> Overdue'; }
    else         { pillCls='tp-open';    pillLabel='<i class="fa-solid fa-clock"></i> Open'; }
    const prioCls = t.priority === 'HIGH' ? 'prio-high' : t.priority === 'LOW' ? 'prio-low' : 'prio-medium';
    const deadlineLabel = t.deadline ? (io ? '<span style="color:var(--red);font-weight:700;">Due: '+t.deadline+'</span>' : '<span>Due: '+t.deadline+'</span>') : '';
    const row = document.createElement('div');
    row.className = 'task-item';
    row.innerHTML =
      '<div class="task-item-body">' +
        '<div class="task-item-title">' + esc(t.title) + '</div>' +
        (t.desc ? '<div class="task-item-desc">' + esc(t.desc) + '</div>' : '') +
        '<div class="task-meta">' +
          deadlineLabel +
          (t.assigned ? '<span>Assigned: ' + t.assigned + '</span>' : '') +
          '<span class="' + prioCls + '"><i class="fa-solid fa-flag" style="margin-right:3px;font-size:.65rem;"></i>' + t.priority + '</span>' +
        '</div>' +
      '</div>' +
      '<span class="t-pill ' + pillCls + '">' + pillLabel + '</span>';
    container.appendChild(row);
  });
}

// ══════════════════════ PICKER ══════════════════════
function buildPickerOptions(members, preselected) {
  const container = document.getElementById('empPickerOptions');
  container.innerHTML = '';
  members.forEach(function(m){
    const opt = document.createElement('div');
    opt.className = 'picker-opt' + (preselected.includes(m.email) ? ' selected' : '');
    opt.dataset.email = m.email;
    opt.dataset.name  = (m.name || '').toLowerCase();
    opt.innerHTML =
      '<input type="checkbox" ' + (preselected.includes(m.email) ? 'checked' : '') + ' ' +
        'onclick="event.stopPropagation();togglePickerOption(\'' + m.email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") + '\',this.checked)">' +
      '<div class="emp-avatar" style="width:28px;height:28px;font-size:.65rem;flex-shrink:0;">' + getInitials(m.name) + '</div>' +
      '<div style="flex:1;min-width:0;">' +
        '<div style="font-weight:700;font-size:.8rem;color:var(--text-1);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + esc(m.name) + '</div>' +
        '<div style="font-size:.68rem;color:var(--text-4);font-family:\'JetBrains Mono\',monospace;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + esc(m.email) + '</div>' +
      '</div>';
    opt.onclick = function(){ togglePickerOption(m.email, !selectedEmails.has(m.email)); };
    container.appendChild(opt);
  });
}

function filterPickerOptions(q) {
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    opt.style.display = !q || opt.dataset.name.includes(q.toLowerCase()) ? '' : 'none';
  });
}

function togglePickerOption(email, checked) {
  const member = selectedTeam ? selectedTeam.members.find(function(m){return m.email===email;}) : null;
  if (!member) return;
  if (checked) selectedEmails.add(email);
  else selectedEmails.delete(email);
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    if (opt.dataset.email === email) {
      opt.classList.toggle('selected', checked);
      const cb = opt.querySelector('input[type="checkbox"]');
      if (cb) cb.checked = checked;
    }
  });
  updatePickerUI();
}

function toggleSelectAll() {
  if (!selectedTeam) return;
  const allEmails  = selectedTeam.members.map(function(m){return m.email;});
  const allChecked = allEmails.every(function(e){return selectedEmails.has(e);});
  if (allChecked) allEmails.forEach(function(e){selectedEmails.delete(e);});
  else allEmails.forEach(function(e){selectedEmails.add(e);});
  document.querySelectorAll('.picker-opt').forEach(function(opt){
    const checked = selectedEmails.has(opt.dataset.email);
    opt.classList.toggle('selected', checked);
    const cb = opt.querySelector('input[type="checkbox"]');
    if (cb) cb.checked = checked;
  });
  const allCb = document.getElementById('selectAllCb');
  if (allCb) allCb.checked = !allChecked;
  updatePickerUI();
}

function updatePickerUI() {
  const chipsEl      = document.getElementById('empPickerChips');
  const hiddenInputs = document.getElementById('empHiddenInputs');
  const selCount     = document.getElementById('selCountLabel');
  const preview      = document.getElementById('assignPreview');
  const previewCount = document.getElementById('assignPreviewCount');
  const previewNames = document.getElementById('assignPreviewNames');
  const submitLabel  = document.getElementById('assignSubmitLabel');

  hiddenInputs.innerHTML = '';
  selectedEmails.forEach(function(email){
    const inp = document.createElement('input');
    inp.type = 'hidden'; inp.name = 'employeeUsername'; inp.value = email;
    hiddenInputs.appendChild(inp);
  });

  if (selectedEmails.size === 0) {
    chipsEl.innerHTML = '<span class="picker-ph" id="empPickerPlaceholder">Select employees…</span>';
    selCount.textContent = '';
    preview.style.display = 'none';
    submitLabel.textContent = 'Assign Task';
  } else {
    chipsEl.innerHTML = '';
    selectedEmails.forEach(function(email){
      const member = selectedTeam ? selectedTeam.members.find(function(m){return m.email===email;}) : null;
      if (!member) return;
      const chip = document.createElement('span');
      chip.className = 'chip';
      chip.innerHTML = esc(member.name || email) +
        '<span class="chip-x" onclick="event.stopPropagation();togglePickerOption(\'' + email.replace(/\\/g,'\\\\').replace(/'/g,"\\'") + '\',false)">✕</span>';
      chipsEl.appendChild(chip);
    });
    const n = selectedEmails.size;
    selCount.textContent = '(' + n + ' selected)';
    preview.style.display = '';
    previewCount.textContent = n + ' employee' + (n !== 1 ? 's' : '');
    previewNames.innerHTML = '';
    selectedEmails.forEach(function(email){
      const member = selectedTeam ? selectedTeam.members.find(function(m){return m.email===email;}) : null;
      if (!member) return;
      const tag = document.createElement('span');
      tag.className = 'preview-tag';
      tag.textContent = member.name || email;
      previewNames.appendChild(tag);
    });
    submitLabel.textContent = n > 1 ? 'Assign to ' + n + ' Employees' : 'Assign Task';
  }

  if (selectedTeam) {
    const allCb = document.getElementById('selectAllCb');
    if (allCb) allCb.checked = selectedTeam.members.every(function(m){return selectedEmails.has(m.email);});
  }
  if (selectedEmails.size > 0) document.getElementById('empPickerError').style.display = 'none';
}

function toggleEmpPicker() {
  const dd      = document.getElementById('empPickerDropdown');
  const trigger = document.getElementById('empPickerTrigger');
  const chevron = document.getElementById('empPickerChevron');
  const isOpen  = dd.classList.contains('open');
  dd.classList.toggle('open', !isOpen);
  trigger.classList.toggle('open', !isOpen);
  chevron.style.transform = isOpen ? 'rotate(0deg)' : 'rotate(180deg)';
  if (!isOpen) {
    const si = document.getElementById('empPickerSearchInput');
    if (si) { si.value = ''; filterPickerOptions(''); si.focus(); }
  }
}

function closeEmpPickerDropdown() {
  document.getElementById('empPickerDropdown').classList.remove('open');
  document.getElementById('empPickerTrigger').classList.remove('open');
  document.getElementById('empPickerChevron').style.transform = 'rotate(0deg)';
}

// ══════════════════════ ASSIGN MODAL ══════════════════════
function openAssignModal(preselectedEmails) {
  if (!selectedTeam) return;
  selectedEmails.clear();
  if (preselectedEmails && preselectedEmails.length) preselectedEmails.forEach(function(e){selectedEmails.add(e);});
  buildPickerOptions(selectedTeam.members, preselectedEmails || []);
  updatePickerUI();
  closeEmpPickerDropdown();

  const today = new Date();
  const pad = function(n){return n<10?'0'+n:''+n;};
  const todayStr = today.getFullYear()+'-'+pad(today.getMonth()+1)+'-'+pad(today.getDate());
  const dlEl = document.getElementById('assignModalDeadline');
  dlEl.min = todayStr; dlEl.value = '';

  const form = document.getElementById('assignModalForm');
  form.querySelector('input[name="title"]').value = '';
  form.querySelector('textarea[name="taskDesc"]').value = '';

  document.getElementById('empPickerError').style.display = 'none';
  document.getElementById('assignModal').classList.add('open');
  document.body.style.overflow = 'hidden';
}

function openAssignFromModal() {
  const email = modalEmployee ? modalEmployee.email : null;
  closeEmpModal();
  setTimeout(function(){ openAssignModal(email ? [email] : []); }, 200);
}

function closeAssignModal() {
  document.getElementById('assignModal').classList.remove('open');
  document.body.style.overflow = '';
  closeEmpPickerDropdown();
}

function validateAssignForm() {
  if (selectedEmails.size === 0) {
    document.getElementById('empPickerError').style.display = '';
    document.getElementById('empPickerDropdown').classList.add('open');
    document.getElementById('empPickerTrigger').classList.add('open');
    document.getElementById('empPickerChevron').style.transform = 'rotate(180deg)';
    return false;
  }
  return true;
}

document.addEventListener('click', function(e){
  const wrapper = document.getElementById('empPickerWrapper');
  if (wrapper && !wrapper.contains(e.target)) closeEmpPickerDropdown();
});
document.addEventListener('keydown', function(e){
  if (e.key === 'Escape') { closeEmpModal(); closeAssignModal(); }
});

// ══════════════════════ BOOT ══════════════════════
renderTeams();

document.addEventListener('contextmenu', function(e){ e.preventDefault(); });
document.onkeydown = function(e){
  return (e.keyCode===123||(e.ctrlKey&&e.shiftKey&&['I','J','C'].includes(e.key.toUpperCase()))) ? false : true;
};
</script>
</body>
</html>
