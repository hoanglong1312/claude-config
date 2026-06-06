param(
  [string]$ProjectDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)
$ErrorActionPreference = 'Stop'
$RepoDir = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$Date = (Get-Date -Format 'yyyy-MM-dd')

function Get-HashForFiles([string[]]$Paths) {
  $sha = [System.Security.Cryptography.SHA256]::Create()
  $bytes = New-Object System.Collections.Generic.List[byte]
  foreach ($p in $Paths) { $bytes.AddRange([System.IO.File]::ReadAllBytes($p)) }
  ($sha.ComputeHash($bytes.ToArray()) | ForEach-Object { $_.ToString('x2') }) -join ''
}

function Get-ProjectNotes([string]$Path) {
  $default = "<!-- BEGIN PROJECT NOTES -->`n<!-- Project-specific Codex notes live here. Sync scripts preserve this block. -->`n<!-- END PROJECT NOTES -->"
  if (!(Test-Path $Path)) { return $default }
  $s = Get-Content $Path -Raw
  $start = '<!-- BEGIN PROJECT NOTES -->'
  $end = '<!-- END PROJECT NOTES -->'
  $a = $s.IndexOf($start)
  $b = $s.IndexOf($end)
  if ($a -ge 0 -and $b -ge $a) { return $s.Substring($a, $b - $a + $end.Length) }
  return $default
}

$WorkflowNames = @('intent-routing.md','planning.md','debugging.md','tdd.md','verification.md','review.md','response-style.md','tool-output-discipline.md')
$AgentsPath = Join-Path $ProjectDir 'AGENTS.md'
$Notes = Get-ProjectNotes $AgentsPath
$Shared = Join-Path $RepoDir 'templates/shared-agent-rules.md'
$WorkflowPaths = $WorkflowNames | ForEach-Object { Join-Path $RepoDir "templates/shared-workflows/$_" }
$Template = Join-Path $RepoDir 'templates/AGENTS.md'

$Out = New-Object System.Collections.Generic.List[string]
$Out.Add('<!-- BEGIN GENERATED AGENT RULES -->')
$Out.Add('<!-- generated-from: templates/shared-agent-rules.md + templates/shared-workflows/*.md + templates/AGENTS.md -->')
$Out.Add("<!-- generated-date: $Date -->")
$Out.Add("<!-- shared-rules-sha256: $(Get-HashForFiles @($Shared)) -->")
$Out.Add("<!-- workflows-sha256: $(Get-HashForFiles $WorkflowPaths) -->")
$Out.Add("<!-- template-sha256: $(Get-HashForFiles @($Template)) -->")
$Out.Add('')
$Out.Add((Get-Content $Shared -Raw).TrimEnd())
foreach ($p in $WorkflowPaths) { $Out.Add(''); $Out.Add('---'); $Out.Add(''); $Out.Add((Get-Content $p -Raw).TrimEnd()) }
$Out.Add(''); $Out.Add('---'); $Out.Add(''); $Out.Add((Get-Content $Template -Raw).TrimEnd())
$Out.Add(''); $Out.Add('<!-- END GENERATED AGENT RULES -->'); $Out.Add(''); $Out.Add($Notes)
Set-Content -Path $AgentsPath -Value ($Out -join "`n") -NoNewline

New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir 'templates/shared-workflows') | Out-Null
Copy-Item $Shared (Join-Path $ClaudeDir 'templates/shared-agent-rules.md') -Force
Copy-Item (Join-Path $RepoDir 'templates/shared-workflows/*.md') (Join-Path $ClaudeDir 'templates/shared-workflows') -Force
Write-Host "Synced shared rules to $ClaudeDir and rendered $AgentsPath"
