$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$paths = @(
  "apps\pasus_client\lib\features\home",
  "apps\pasus_client\lib\features\onboarding",
  "apps\pasus_client\lib\features\protection",
  "apps\pasus_client\lib\features\settings",
  "apps\pasus_client\lib\features\scan",
  "apps\pasus_client\lib\shared\widgets",
  "apps\pasus_client\lib\app\router.dart",
  "apps\pasus_client\lib\app\pasus_app.dart",
  "apps\pasus_website\app",
  "apps\pasus_website\components",
  "apps\pasus_website\lib",
  "README.md",
  "docs\client-ui.md"
)

$forbidden = @(
  "anti-cheat",
  "fair play",
  "gaming protection",
  "game setup",
  "player session",
  "match telemetry",
  "fake checkout",
  "fake license",
  "100% protection",
  "perfect protection",
  "certified by av-test",
  "fake reviews",
  "fake awards"
)

$violations = @()
foreach ($relative in $paths) {
  $path = Join-Path $root $relative
  if (-not (Test-Path $path)) { continue }
  $files = if ((Get-Item $path).PSIsContainer) {
    Get-ChildItem -LiteralPath $path -Recurse -File -Include *.dart,*.tsx,*.ts,*.md,*.css
  } else {
    @(Get-Item $path)
  }
  foreach ($file in $files) {
    $content = (Get-Content -Raw -LiteralPath $file.FullName).ToLowerInvariant()
    foreach ($phrase in $forbidden) {
      if ($content.Contains($phrase)) {
        $violations += "$($file.FullName): forbidden phrase '$phrase'"
      }
    }
  }
}

if ($violations.Count -gt 0) {
  $violations | ForEach-Object { Write-Error $_ }
  exit 1
}

Write-Host "Pasus product copy gate passed."
