/**
 * Leave calendar: "Single day" (one tap, from=to) or "Date range" (first tap → last tap).
 * #leaveFlatpickrEl, #leaveFromDate, #leaveToDate, #leaveModeSingleBtn, #leaveModeRangeBtn, #leaveModeHint, #leaveRangeSummary
 */
(function () {
  function pad(n) {
    return n < 10 ? '0' + n : '' + n;
  }
  function ymd(d) {
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
  }
  function daysInclusive(start, end) {
    var a = new Date(start.getFullYear(), start.getMonth(), start.getDate());
    var b = new Date(end.getFullYear(), end.getMonth(), end.getDate());
    return Math.round((b - a) / 86400000) + 1;
  }
  function formatNice(d) {
    try {
      return d.toLocaleDateString(undefined, {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
        year: 'numeric'
      });
    } catch (e) {
      return ymd(d);
    }
  }

  var fpInstance = null;
  var currentMode = 'single';

  function setModeButtons(mode) {
    var bSingle = document.getElementById('leaveModeSingleBtn');
    var bRange = document.getElementById('leaveModeRangeBtn');
    if (!bSingle || !bRange) return;
    var active =
      'flex-1 py-2 px-3 text-sm font-semibold rounded-md transition-all bg-white text-indigo-700 shadow-sm ring-1 ring-slate-200';
    var idle =
      'flex-1 py-2 px-3 text-sm font-semibold rounded-md transition-all text-slate-600 hover:text-slate-800';
    if (mode === 'single') {
      bSingle.className = active;
      bRange.className = idle;
    } else {
      bRange.className = active;
      bSingle.className = idle;
    }
  }

  function setHint(mode) {
    var hint = document.getElementById('leaveModeHint');
    if (!hint) return;
    if (mode === 'single') {
      hint.textContent =
        'Choose the calendar day you will be away. One tap is enough — no separate start and end.';
    } else {
      hint.textContent =
        'Tap the first day you are away, then the last day. The highlighted span is your leave period.';
    }
  }

  function clearSummary(summary) {
    if (!summary) return;
    summary.textContent = '';
    summary.classList.add('hidden');
  }

  function destroyPicker() {
    if (fpInstance) {
      try {
        fpInstance.destroy();
      } catch (e) {}
      fpInstance = null;
    }
  }

  function buildPicker(mode, mount, from, to, summary) {
    destroyPicker();
    from.value = '';
    to.value = '';
    clearSummary(summary);

    if (mode === 'single') {
      fpInstance = flatpickr(mount, {
        inline: true,
        mode: 'single',
        minDate: 'today',
        dateFormat: 'Y-m-d',
        showMonths: 1,
        disableMobile: true,
        onChange: function (dates) {
          if (dates.length === 1) {
            var s = ymd(dates[0]);
            from.value = s;
            to.value = s;
            if (summary) {
              summary.textContent = 'Leave on ' + formatNice(dates[0]);
              summary.classList.remove('hidden');
            }
          } else {
            from.value = '';
            to.value = '';
            clearSummary(summary);
          }
        }
      });
    } else {
      fpInstance = flatpickr(mount, {
        inline: true,
        mode: 'range',
        minDate: 'today',
        dateFormat: 'Y-m-d',
        showMonths: 1,
        disableMobile: true,
        onChange: function (selectedDates) {
          if (selectedDates.length === 2) {
            from.value = ymd(selectedDates[0]);
            to.value = ymd(selectedDates[1]);
            if (summary) {
              var n = daysInclusive(selectedDates[0], selectedDates[1]);
              summary.textContent =
                n === 1
                  ? '1 calendar day'
                  : n + ' calendar days (' +
                    formatNice(selectedDates[0]) +
                    ' → ' +
                    formatNice(selectedDates[1]) +
                    ')';
              summary.classList.remove('hidden');
            }
          } else {
            from.value = '';
            to.value = '';
            clearSummary(summary);
          }
        }
      });
    }
  }

  function initLeaveRangeCalendar() {
    var mount = document.getElementById('leaveFlatpickrEl');
    var from = document.getElementById('leaveFromDate');
    var to = document.getElementById('leaveToDate');
    var summary = document.getElementById('leaveRangeSummary');
    var bSingle = document.getElementById('leaveModeSingleBtn');
    var bRange = document.getElementById('leaveModeRangeBtn');

    if (!mount || !from || !to || typeof flatpickr === 'undefined') return;

    var form = mount.closest('form');

    function switchMode(mode) {
      currentMode = mode;
      setModeButtons(mode);
      setHint(mode);
      buildPicker(mode, mount, from, to, summary);
    }

    if (bSingle && bRange) {
      bSingle.addEventListener('click', function () {
        if (currentMode !== 'single') switchMode('single');
      });
      bRange.addEventListener('click', function () {
        if (currentMode !== 'range') switchMode('range');
      });
    }

    switchMode('single');

    if (form) {
      form.addEventListener('submit', function (e) {
        if (!from.value || !to.value) {
          e.preventDefault();
          var msg =
            currentMode === 'single'
              ? 'Please select the day for your leave.'
              : 'Please select your leave period (first day and last day) on the calendar.';
          if (typeof showToast === 'function') {
            showToast(msg, 'error');
          } else {
            alert(msg);
          }
        }
      });
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initLeaveRangeCalendar);
  } else {
    initLeaveRangeCalendar();
  }
})();
