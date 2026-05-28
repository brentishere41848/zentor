param(
    [string]$Root = (Resolve-Path "$PSScriptRoot\..\..").Path
)

$ErrorActionPreference = "Stop"

$legacy = ("Pa" + "sus")
$terms = @(
    $legacy,
    $legacy.ToUpperInvariant(),
    $legacy.ToLowerInvariant(),
    ("anti" + "-cheat"),
    ("fair" + " play"),
    ("gaming" + " protection"),
    ("game" + " setup"),
    ("player" + " session"),
    ("match" + " telemetry")
)

$migrationNote = "docs/migration-from-" + $legacy.ToLowerInvariant() + ".md"
$exclude = @(
    "!.git/**",
    "!archive/**",
    "!**/target/**",
    "!**/build/**",
    "!**/.dart_tool/**",
    "!**/node_modules/**",
    "!**/dist/**",
    "!$migrationNote"
)

$failures = @()
foreach ($term in $terms) {
    $args = @("-n", "-S", [regex]::Escape($term), $Root)
    foreach ($glob in $exclude) {
        $args += "--glob"
        $args += $glob
    }
    $matches = & rg @args 2>$null
    if ($LASTEXITCODE -eq 0 -and $matches) {
        $failures += "Forbidden active branding term [$term]:"
        $failures += $matches
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "Zentor branding check passed."
