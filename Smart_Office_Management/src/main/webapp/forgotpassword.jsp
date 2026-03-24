<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Forgot Password</title>
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
    --shadow: 0 8px 40px rgba(90,70,140,0.13);
  }

  body {
    min-height: 100vh;
    background: #c3cfe2;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Geist', system-ui, sans-serif;
  }

  .card {
    background: #ffffff;
     border-radius: 22px;
    box-shadow:rgba(0,0,10,0.4);
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
    margin-bottom: 32px;
    text-align: center;
  }

  .icon-wrap {
    width: 58px; height: 58px;
    background: var(--purple-icon-bg);
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

  .field { margin-bottom: 22px; }

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

  input[type="email"] {
    width: 100%;
    padding: 13px 16px 13px 44px;
    border: 1.5px solid var(--input-border);
    border-radius: 11px;
    font-family: 'Geist', system-ui, sans-serif;
    font-size: 0.95rem;
    color: var(--text);
    background: #fff;
    outline: none;
    transition: border-color 0.22s, box-shadow 0.22s, background 0.22s;
  }
  input[type="email"]::placeholder { color: var(--placeholder); }
  input[type="email"]:hover { border-color: #b0b8c9; }
  input[type="email"]:focus {
    border-color: var(--input-focus);
    box-shadow: 0 0 0 3.5px rgba(123,94,167,0.14);
    background: #fcfaff;
  }
  .input-wrap:focus-within .ico { stroke: var(--input-focus); }

  .btn {
    width: 100%;
    padding: 14px;
    background: linear-gradient(135deg, var(--purple-start) 0%, #c3cfe2 100%);
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
    margin-top: 4px;
  }
  .btn svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; }
  .btn:hover  { opacity: 0.91; transform: translateY(-2px); box-shadow: 0 8px 24px rgba(91,63,140,0.42); }
  .btn:active { opacity: 1; transform: translateY(0); }

  .divider {
    display: flex; align-items: center; gap: 10px;
    margin: 26px 0 0;
    color: var(--muted);
    font-size: 0.78rem;
  }
  .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #e5e7eb; }

  .back-link {
    display: flex; align-items: center; justify-content: center; gap: 6px;
    margin-top: 14px;
    font-size: 0.87rem;
    font-weight: 600;
    color: var(--link);
    text-decoration: none;
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
        <path d="M15 7a2 2 0 0 1 2 2m4 0a6 6 0 0 1-7.743 5.743L11 17H9v2H7v2H4a1 1 0 0 1-1-1v-2.586a1 1 0 0 1 .293-.707l5.964-5.964A6 6 0 1 1 21 9z" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
    </div>
    <h2>Forgot Password?</h2>
    <p class="subtitle">Enter your email and we'll send you a link to reset your password.</p>
  </div>

  <form action="ForgotPasswordServlet" method="post">
    <div class="field">
      <label for="email">Email Address</label>
      <div class="input-wrap">
        <svg class="ico" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
          <rect x="2" y="4" width="20" height="16" rx="2.5"/>
          <path d="M2 7l10 7 10-7" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        <input type="email" id="email" name="email" placeholder="Enter your email address" required />
      </div>
    </div>

    <button type="submit" class="btn">
      <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path d="M22 2L11 13M22 2L15 22l-4-9-9-4 20-7z" stroke-linecap="round" stroke-linejoin="round"/>
      </svg>
      Send Reset Link
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

</body>
</html>
