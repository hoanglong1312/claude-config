$inputJson = [Console]::In.ReadToEnd()
try { $data = $inputJson | ConvertFrom-Json } catch { Write-Output 'Claude Code'; exit 0 }
$parts = @()
if ($data.model.display_name) { $parts += $data.model.display_name } elseif ($data.model.name) { $parts += $data.model.name }
if ($data.permission_mode) { $parts += $data.permission_mode }
if ($data.context.remaining_percent) { $parts += "ctx:$($data.context.remaining_percent)%" }
$cwd = $data.workspace.current_dir
if (-not $cwd) { $cwd = $data.cwd }
if ($cwd) { $parts += Split-Path $cwd -Leaf }
Write-Output ($parts -join ' | ')
