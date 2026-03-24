Zinc / professional Admin Overview theme — saved for later
===========================================================

Files (do not deploy as active pages unless you rename/replace):

1) adminOverview.jsp.zinc-theme-snapshot
   - Full copy of the professional Admin Overview (neutral zinc palette, unified charts).
   - To apply later: replace src/main/webapp/adminOverview.jsp with this file (or diff-merge).

2) smart-office-theme.css — optional sidebar tokens used with that look:
   In :root, these were paired with the snapshot:
     --so-sidebar-bg: #505050;
     --so-sidebar-border: #454545;

Current production smart-office-theme.css uses the pre-snapshot sidebar values after revert:
     --so-sidebar-bg: #2d2d2d;
     --so-sidebar-border: #242424;
