$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$paths = @(
  "apps\zentor_client\lib\features\home",
  "apps\zentor_client\lib\features\onboarding",
  "apps\zentor_client\lib\features\protection",
  "apps\zentor_client\lib\features\settings",
  "apps\zentor_client\lib\features\scan",
  "apps\zentor_client\lib\shared\widgets",
  "apps\zentor_client\lib\app\router.dart",
  "apps\zentor_client\lib\app\zentor_app.dart",
  "README.md",
  "docs\client-ui.md"
)

$forbidden = @(
  ("pa" + "sus"),
  ("anti" + "-cheat"),
  ("fair" + " play"),
  ("gaming" + " protection"),
  ("game" + " setup"),
  ("player" + " session"),
  ("match" + " telemetry"),
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

Write-Host "Zentor product copy gate passed."
