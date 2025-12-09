Add-Type -AssemblyName System.Windows.Forms,System.Drawing
$size = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize
$bmp = New-Object System.Drawing.Bitmap($size.Width, $size.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.CopyFromScreen(0,0,0,0,$bmp.Size)
$dir = Join-Path $PSScriptRoot 'assets'
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
$path = Join-Path $dir 'screenshot.png'
$bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Host "SAVED:$path"
