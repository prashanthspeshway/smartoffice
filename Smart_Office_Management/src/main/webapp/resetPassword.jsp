<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reset Password</title>
<link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap" rel="stylesheet">
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg: #dce6f0;
    --card: #ffffff;
    --purple-start: #7b5ea7;
    --purple-end: #5b3f8c;
    --purple-icon-bg: #7c5cbf;
    --label: #374151;
    --input-border: #d1d5db;
    --input-focus: #7b5ea7;
    --placeholder: #9ca3af;
    --text: #1f2937;
    --muted: #6b7280;
    --link: #6d4fc2;
    --error-bg: #fef2f2;
    --error-border: #fca5a5;
    --error-text: #dc2626;
    --shadow: 0 8px 40px rgba(90,70,140,0.13);
  }

  body {
    min-height: 100vh;
    background: var(--bg);
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Geist', system-ui, sans-serif;
  }

  .card {
    background: var(--card);
    border-radius: 22px;
    box-shadow: var(--shadow);
    padding: 48px 44px 40px;
    width: 100%;
    max-width: 430px;
    animation: fadeUp 0.55s cubic-bezier(0.22,1,0.36,1) both;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(24px); }
    to   { opacity: 1; transform: translateY(0); }
  }

  .header {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 30px;
    text-align: center;
  }

  .icon-wrap {
    width: 58px; height: 58px;
    background: #1c1c1c;
    border-radius: 14px;
    display: flex; align-items: center; justify-content: center;
    margin-bottom: 14px;
    box-shadow: 0 4px 14px rgba(124,92,191,0.35);
    transition: transform 0.25s, box-shadow 0.25s;
    cursor: default;
  }
  .icon-wrap:hover {
    transform: translateY(-3px) scale(1.05);
    box-shadow: 0 8px 22px rgba(124,92,191,0.45);
  }
  .icon-wrap svg { width: 28px; height: 28px; stroke: #fff; fill: none; stroke-width: 2; }

  h2 {
    font-size: 1.75rem;
    font-weight: 700;
    color: var(--text);
    letter-spacing: -0.01em;
    margin-bottom: 6px;
  }
  .subtitle {
    font-size: 0.875rem;
    color: var(--muted);
    line-height: 1.55;
    max-width: 290px;
  }

  /* Error message */
  .error-box {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    background: var(--error-bg);
    border: 1.5px solid var(--error-border);
    border-radius: 10px;
    padding: 12px 14px;
    margin-bottom: 20px;
    animation: shake 0.4s ease;
  }
  @keyframes shake {
    0%,100% { transform: translateX(0); }
    20%,60%  { transform: translateX(-5px); }
    40%,80%  { transform: translateX(5px); }
  }
  .error-box svg { width: 18px; height: 18px; stroke: var(--error-text); fill: none; stroke-width: 2; flex-shrink: 0; margin-top: 1px; }
  .error-box span { font-size: 0.85rem; color: var(--error-text); font-weight: 600; line-height: 1.4; }

  .field { margin-bottom: 20px; }

  label {
    display: block;
    font-size: 0.88rem;
    font-weight: 600;
    color: var(--label);
    margin-bottom: 8px;
  }

  .input-wrap { position: relative; }
  .input-wrap .ico {
    position: absolute;
    left: 14px; top: 50%; transform: translateY(-50%);
    width: 18px; height: 18px;
    stroke: var(--placeholder);
    fill: none; stroke-width: 1.8;
    pointer-events: none;
    transition: stroke 0.2s;
  }
  .toggle-pw {
    position: absolute;
    right: 14px; top: 50%; transform: translateY(-50%);
    background: none; border: none; cursor: pointer; padding: 0;
    display: flex; align-items: center;
  }
  .toggle-pw svg { width: 18px; height: 18px; stroke: var(--placeholder); fill: none; stroke-width: 1.8; transition: stroke 0.2s; }
  .toggle-pw:hover svg { stroke: var(--purple-start); }

  input[type="password"],
  input[type="text"] {
    width: 100%;
    padding: 13px 44px 13px 44px;
    border: 1.5px solid var(--input-border);
    border-radius: 11px;
    font-family: 'Geist', system-ui, sans-serif;
    font-size: 0.95rem;
    color: var(--text);
    background: #fff;
    outline: none;
    transition: border-color 0.22s, box-shadow 0.22s, background 0.22s;
  }
  input[type="password"]::placeholder,
  input[type="text"]::placeholder { color: var(--placeholder); }
  input[type="password"]:hover,
  input[type="text"]:hover { border-color: #b0b8c9; }
  input[type="password"]:focus,
  input[type="text"]:focus {
    border-color: var(--input-focus);
    box-shadow: 0 0 0 3.5px rgba(123,94,167,0.14);
    background: #fcfaff;
  }
  .input-wrap:focus-within .ico { stroke: var(--input-focus); }

  /* Password strength bar */
  .strength-bar {
    display: flex; gap: 5px; margin-top: 8px;
  }
  .strength-bar span {
    flex: 1; height: 4px; border-radius: 99px;
    background: #e5e7eb;
    transition: background 0.3s;
  }
  .strength-label {
    font-size: 0.75rem; color: var(--muted);
    margin-top: 5px; font-weight: 600;
    min-height: 16px;
    transition: color 0.3s;
  }

  .btn {
    width: 100%;
    padding: 14px;
    background: #1c1c1c;
    color: #fff;
    border: none;
    border-radius: 11px;
    font-family: 'Geist', system-ui, sans-serif;
    font-size: 1rem;
    font-weight: 700;
    letter-spacing: 0.02em;
    cursor: pointer;
    display: flex; align-items: center; justify-content: center; gap: 8px;
    transition: opacity 0.2s, transform 0.18s, box-shadow 0.2s;
    box-shadow: 0 4px 18px rgba(91,63,140,0.35);
    margin-top: 6px;
  }
  .btn svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; }
  .btn:hover  { opacity: 0.91; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(91,63,140,0.42); }
  .btn:active { opacity: 1; transform: translateY(0); }

  .divider {
    display: flex; align-items: center; gap: 10px;
    margin: 26px 0 0;
    color: var(--muted); font-size: 0.78rem;
  }
  .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #e5e7eb; }


  .back-link {
    display: flex; align-items: center; justify-content: center; gap: 6px;
    margin-top: 14px;
    font-size: 0.87rem; font-weight: 600;
    color:#1c1c1c; text-decoration: none;
    transition: color 0.2s, gap 0.2s;
  }
  .back-link svg { width: 15px; height: 15px; stroke: currentColor; fill: none; stroke-width: 2.2; transition: transform 0.2s; }
  .back-link:hover { color: var(--purple-end); gap: 10px; }
  .back-link:hover svg { transform: translateX(-3px); }
</style>
</head>
<body>

<div class="card">
  <div class="header">
    <div class="icon-wrap">
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <rect x="5" y="11" width="14" height="10" rx="2.5" stroke-linecap="round" stroke-linejoin="round"/>
        <path d="M8 11V7a4 4 0 0 1 8 0v4" stroke-linecap="round" stroke-linejoin="round"/>
        <circle cx="12" cy="16" r="1.2" fill="white" stroke="none"/>
      </svg>
    </div>
    <h2>Reset Password</h2>
    <p class="subtitle">Create a new strong password for your account.</p>
  </div>

  <!-- Error message (JSTL) -->
  <c:if test="${not empty errorMessage}">
    <div class="error-box">
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12" stroke-linecap="round"/>
        <line x1="12" y1="16" x2="12.01" y2="16" stroke-linecap="round"/>
      </svg>
      <span>${errorMessage}</span>
    </div>
  </c:if>

  <form action="ResetPasswordServlet" method="post" id="resetForm">
    <input type="hidden" name="token" value="<%= request.getParameter("token") %>"/>

    <!-- New Password -->
    <div class="field">
      <label for="password">New Password</label>
      <div class="input-wrap">
        <svg class="ico" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <rect x="5" y="11" width="14" height="10" rx="2.5"/>
          <path d="M8 11V7a4 4 0 0 1 8 0v4" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        <input type="password" id="password" name="password" placeholder="Enter new password" required oninput="checkStrength(this.value)" />
        <button type="button" class="toggle-pw" onclick="toggleVis('password', this)" tabindex="-1">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z" stroke-linecap="round" stroke-linejoin="round"/>
            <circle cx="12" cy="12" r="3" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
      </div>
<!--       <div class="strength-bar"> -->
<!--         <span id="s1"></span><span id="s2"></span><span id="s3"></span><span id="s4"></span> -->
<!--       </div> -->
      <div class="strength-label" id="strengthLabel"></div>
    </div>

    <!-- Confirm Password -->
    <div class="field">
      <label for="confirmPassword">Confirm Password</label>
      <div class="input-wrap">
        <svg class="ico" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <path d="M9 12l2 2 4-4m6 2a9 9 0 1 1-18 0 9 9 0 0 1 18 0z" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm your new password" required />
        <button type="button" class="toggle-pw" onclick="toggleVis('confirmPassword', this)" tabindex="-1">
          <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M1 12s4-7 11-7 11 7 11 7-4 7-11 7S1 12 1 12z" stroke-linecap="round" stroke-linejoin="round"/>
            <circle cx="12" cy="12" r="3" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
        </button>
      </div>
    </div>

    <button type="submit" class="btn">
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M20 6L9 17l-5-5" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      Reset Password
    </button>
  </form>

  <div class="divider">or</div>
  <a href="index.html" class="back-link">
    <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
      <path d="M19 12H5M5 12l7-7M5 12l7 7" stroke-linecap="round" stroke-linejoin="round"/>
    </svg>
    Return to Login
  </a>
</div>

<script>
  function toggleVis(id, btn) {
    const inp = document.getElementById(id);
    const isHidden = inp.type === 'password';
    inp.type = isHidden ? 'text' : 'password';
    btn.querySelector('svg').style.opacity = isHidden ? '0.5' : '1';
  }

  function checkStrength(val) {
    const bars = [document.getElementById('s1'), document.getElementById('s2'),
                  document.getElementById('s3'), document.getElementById('s4')];
    const label = document.getElementById('strengthLabel');
    bars.forEach(b => b.style.background = '#e5e7eb');

    let score = 0;
    if (val.length >= 8) score++;
    if (/[A-Z]/.test(val)) score++;
    if (/[0-9]/.test(val)) score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;

    const colors = ['#ef4444','#f97316','#eab308','#22c55e'];
    const labels = ['Weak','Fair','Good','Strong'];
    const lColors = ['#ef4444','#f97316','#ca8a04','#16a34a'];

    for (let i = 0; i < score; i++) bars[i].style.background = colors[score - 1];
    label.textContent = val.length > 0 ? labels[score - 1] : '';
    label.style.color = val.length > 0 ? lColors[score - 1] : '#6b7280';
  }
</script>

</body>
</html>
