$ErrorActionPreference = 'Stop'
$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$BackupDir = Join-Path $ClaudeDir "backups/install-$Stamp"

function Test-SecretKey([string]$Key) {
  return $Key -match '^(ANTHROPIC_|OPENAI_)' -or $Key -match '(_API_KEY|_TOKEN|_SECRET|_PASSWORD|_BASE_URL)$' -or $Key -eq 'BASE_URL'
}
function Merge-Json($Base, $Incoming, [string]$Path = '') {
  foreach ($prop in $Incoming.PSObject.Properties) {
    $k = $prop.Name; $v = $prop.Value; $keyPath = if ($Path) { "$Path.$k" } else { $k }
    if ($Path -eq 'env' -and (Test-SecretKey $k)) { Write-Host "skip secret env: $k"; continue }
    if (-not ($Base.PSObject.Properties.Name -contains $k)) { Add-Member -InputObject $Base -NotePropertyName $k -NotePropertyValue $v; continue }
    $existing = $Base.$k
    if ($existing -is [pscustomobject] -and $v -is [pscustomobject]) { Merge-Json $existing $v $keyPath }
    elseif ($existing -is [System.Array] -and $v -is [System.Array]) { foreach ($item in $v) { if ($existing -notcontains $item) { $Base.$k += $item } } }
    elseif (($existing | ConvertTo-Json -Depth 20) -ne ($v | ConvertTo-Json -Depth 20)) { Write-Host "preserve existing setting: $keyPath" }
  }
}
function Read-JsonFile([string]$Path) { if (Test-Path $Path) { return Get-Content $Path -Raw | ConvertFrom-Json } return [pscustomobject]@{} }

New-Item -ItemType Directory -Force -Path $ClaudeDir, $BackupDir | Out-Null
foreach ($p in @('settings.json','CLAUDE.md','templates','hooks','skills','references','docs')) { $src=Join-Path $ClaudeDir $p; if (Test-Path $src) { Copy-Item $src $BackupDir -Recurse -Force } }
foreach ($p in @('templates','hooks','skills','references','docs')) { New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir $p) | Out-Null }
Copy-Item (Join-Path $RepoDir 'templates/*') (Join-Path $ClaudeDir 'templates') -Recurse -Force
Copy-Item (Join-Path $RepoDir 'hooks/*') (Join-Path $ClaudeDir 'hooks') -Recurse -Force
if (Test-Path (Join-Path $RepoDir 'skills')) { Copy-Item (Join-Path $RepoDir 'skills/*') (Join-Path $ClaudeDir 'skills') -Recurse -Force }
if (Test-Path (Join-Path $RepoDir 'references')) { Copy-Item (Join-Path $RepoDir 'references/*') (Join-Path $ClaudeDir 'references') -Recurse -Force }
if (Test-Path (Join-Path $RepoDir 'docs')) { Copy-Item (Join-Path $RepoDir 'docs/*') (Join-Path $ClaudeDir 'docs') -Recurse -Force }
Copy-Item (Join-Path $RepoDir 'templates/CLAUDE.global.md') (Join-Path $ClaudeDir 'CLAUDE.md') -Force

$settingsPath = Join-Path $ClaudeDir 'settings.json'
$base = Read-JsonFile $settingsPath
foreach ($p in @('settings.shared.json','settings.windows.json','settings.local.json')) { $full=Join-Path $RepoDir $p; if (Test-Path $full) { Merge-Json $base (Read-JsonFile $full) } }
($base | ConvertTo-Json -Depth 50) | Set-Content $settingsPath
Get-Content $settingsPath -Raw | ConvertFrom-Json | Out-Null
foreach ($tool in @('node','claude','codex','rtk','markitdown')) { if (Get-Command $tool -ErrorAction SilentlyContinue) { Write-Host "$tool: installed" } else { Write-Host "$tool: missing" } }
Write-Host "Backup: $BackupDir"
Write-Host "Installed global Claude config to $ClaudeDir"
