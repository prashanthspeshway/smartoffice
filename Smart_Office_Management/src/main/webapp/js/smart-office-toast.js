/**
 * Smart Office — unified toast: showToast(message, type?, placement?)
 * type: 'success' | 'error' | 'info' | 'warning' | true | false
 * placement: 'bottom' | 'bottom-center' (centered) | 'left' | 'bottom-left' (full-width bar)
 *
 * Uses inline SVG icons so toasts look correct even without Font Awesome on the page.
 */
(function (global) {
  'use strict';

  var DURATION_MS = 4000;
  var timer = null;

  /* width/height on <svg> are required: Tailwind v4 preflight can otherwise scale inline SVGs to full width in flex layouts. */
  var SVG = {
    success:
      '<svg class="so-toast__svg" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" focusable="false" aria-hidden="true"><path d="M20 6L9 17l-5-5"/></svg>',
    error:
      '<svg class="so-toast__svg" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" focusable="false" aria-hidden="true"><path d="M18 6L6 18M6 6l12 12"/></svg>',
    warning:
      '<svg class="so-toast__svg" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" focusable="false" aria-hidden="true"><path d="M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z"/><path d="M12 9v4M12 17h.01"/></svg>',
    info:
      '<svg class="so-toast__svg" xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" focusable="false" aria-hidden="true"><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>'
  };

  function escapeHtml(s) {
    if (s == null) return '';
    var d = document.createElement('div');
    d.textContent = String(s);
    return d.innerHTML;
  }

  function normalizeType(type) {
    if (type === true || type === 'ok') return 'success';
    if (type === false) return 'error';
    var t = String(type || 'info').toLowerCase();
    if (t === 'warn' || t === 'warning') return 'warning';
    if (t === 'danger') return 'error';
    if (t === 'success' || t === 'error' || t === 'info') return t;
    return 'info';
  }

  function svgFor(kind) {
    return SVG[kind] || SVG.info;
  }

  function showToast(message, type, placement) {
    var kind = normalizeType(type);
    var el = document.getElementById('toast');
    if (!el) {
      el = document.createElement('div');
      el.id = 'toast';
      el.setAttribute('role', 'status');
      el.setAttribute('aria-live', 'polite');
      (document.body || document.documentElement).appendChild(el);
    }

    el.className = 'so-toast so-toast--' + kind;
    el.classList.add('so-toast--visible');

    if (placement === 'bottom' || placement === 'bottom-center') {
      el.classList.add('so-toast--placement-bottom');
    } else if (placement === 'left' || placement === 'bottom-left') {
      el.classList.add('so-toast--placement-left');
    }

    el.innerHTML =
      '<span class="so-toast__badge">' +
      svgFor(kind) +
      '</span>' +
      '<span class="so-toast__text">' +
      escapeHtml(message) +
      '</span>' +
      '<button type="button" class="so-toast__close" aria-label="Dismiss">&times;</button>';

    var closeBtn = el.querySelector('.so-toast__close');
    if (closeBtn) {
      closeBtn.addEventListener('click', function dismiss() {
        closeBtn.removeEventListener('click', dismiss);
        hideToast(el);
      });
    }

    if (timer) clearTimeout(timer);
    timer = setTimeout(function () {
      hideToast(el);
      timer = null;
    }, DURATION_MS);
  }

  function hideToast(el) {
    if (!el) return;
    el.classList.remove('so-toast--visible');
    if (timer) {
      clearTimeout(timer);
      timer = null;
    }
  }

  global.showToast = showToast;
  global.showSmartOfficeToast = showToast;
})(typeof window !== 'undefined' ? window : this);
