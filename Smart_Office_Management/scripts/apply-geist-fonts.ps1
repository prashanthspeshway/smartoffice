$root = Join-Path $PSScriptRoot "..\src\main\webapp" | Resolve-Path
$geist = "https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@400;500&display=swap"

$files = Get-ChildItem -Path $root -Recurse -Include *.jsp,*.html,*.css,*.js
$n = 0
foreach ($f in $files) {
  $t = [System.IO.File]::ReadAllText($f.FullName)
  $o = $t
  $t = $t.Replace("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap", $geist)
  $t = $t.Replace("https://fonts.googleapis.com/css2?family=Nunito:wght@400;500;600;700&display=swap", $geist)
  $t = $t.Replace("https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&display=swap", $geist)
  $t = $t.Replace("https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:ital,wght@0,600;1,400&display=swap", $geist)
  $t = $t.Replace("https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Fraunces:wght@600&family=JetBrains+Mono:wght@400;700&display=swap", $geist)
  $t = $t.Replace("'Inter', system-ui, sans-serif", "'Geist', system-ui, sans-serif")
  $t = $t.Replace("'Inter', system-ui, -apple-system, sans-serif", "'Geist', system-ui, -apple-system, sans-serif")
  $t = $t.Replace("font-family: 'Inter', system-ui, sans-serif", "font-family: 'Geist', system-ui, sans-serif")
  $t = $t.Replace("font-family:'Inter',system-ui,sans-serif", "font-family:'Geist',system-ui,sans-serif")
  $t = $t.Replace("'DM Sans', system-ui, sans-serif", "'Geist', system-ui, sans-serif")
  $t = $t.Replace("'DM Sans', system-ui, -apple-system, sans-serif", "'Geist', system-ui, -apple-system, sans-serif")
  $t = $t.Replace("'DM Sans',system-ui,sans-serif", "'Geist',system-ui,sans-serif")
  $t = $t.Replace("font-family:'DM Sans',system-ui,sans-serif", "font-family:'Geist',system-ui,sans-serif")
  $t = $t.Replace("'Fraunces', Georgia, serif", "'Geist', system-ui, sans-serif")
  $t = $t.Replace("'Fraunces',Georgia,serif", "'Geist',system-ui,sans-serif")
  $t = $t.Replace("font-family: 'Nunito', sans-serif", "font-family: 'Geist', system-ui, sans-serif")
  $t = $t.Replace("'JetBrains Mono', monospace", "'Geist Mono', monospace")
  $t = $t.Replace('font-family: "Segoe UI", Arial, sans-serif', "font-family: 'Geist', system-ui, sans-serif")
  $t = $t.Replace('font-family: "Segoe UI", sans-serif', "font-family: 'Geist', system-ui, sans-serif")
  $t = $t.Replace("'Inter', system-ui, -apple-system, 'Segoe UI', sans-serif", "'Geist', system-ui, -apple-system, sans-serif")
  $t = $t.Replace("font-family: ui-monospace, 'Cascadia Code', 'Segoe UI Mono', monospace", "font-family: 'Geist Mono', monospace")
  $t = $t.Replace("'DM Sans', 'Inter', system-ui, sans-serif", "'Geist', system-ui, sans-serif")
  $t = $t.Replace("bold 20px DM Sans, sans-serif", "bold 20px Geist, sans-serif")
  $t = $t.Replace("10px DM Sans, sans-serif", "10px Geist, sans-serif")
  if ($t -ne $o) {
    [System.IO.File]::WriteAllText($f.FullName, $t)
    $n++
    Write-Host "updated:" $f.Name
  }
}
Write-Host "files changed: $n"
