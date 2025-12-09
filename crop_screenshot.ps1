Add-Type -AssemblyName System.Drawing
$in = Join-Path $PSScriptRoot 'assets\screenshot.png'
if (-not (Test-Path $in)) { Write-Error "Input screenshot not found: $in"; exit 1 }
$bmp = [System.Drawing.Bitmap]::FromFile($in)
$width = $bmp.Width; $height = $bmp.Height
$bg = $bmp.GetPixel(0,0)
$minx = $width; $miny = $height; $maxx = 0; $maxy = 0
$threshold = 30
for ($x=0; $x -lt $width; $x++) {
    for ($y=0; $y -lt $height; $y++) {
        $p = $bmp.GetPixel($x,$y)
        $dr = [math]::Abs($p.R - $bg.R)
        $dg = [math]::Abs($p.G - $bg.G)
        $db = [math]::Abs($p.B - $bg.B)
        if (($dr -gt $threshold) -or ($dg -gt $threshold) -or ($db -gt $threshold)) {
            if ($x -lt $minx) { $minx = $x }
            if ($y -lt $miny) { $miny = $y }
            if ($x -gt $maxx) { $maxx = $x }
            if ($y -gt $maxy) { $maxy = $y }
        }
    }
}
if ($minx -gt $maxx -or $miny -gt $maxy) {
    Write-Host "No non-background area detected; leaving original image."; exit 0
}
# add margin
$margin = [int]([math]::Round(([math]::Min($width,$height) * 0.03)))
$minx = [math]::Max(0, $minx - $margin)
$miny = [math]::Max(0, $miny - $margin)
$maxx = [math]::Min($width - 1, $maxx + $margin)
$maxy = [math]::Min($height - 1, $maxy + $margin)
$cw = $maxx - $minx + 1
$ch = $maxy - $miny + 1
$crop = New-Object System.Drawing.Bitmap $cw, $ch
$g = [System.Drawing.Graphics]::FromImage($crop)
$g.DrawImage($bmp, 0,0, [System.Drawing.Rectangle]::new($minx,$miny,$cw,$ch), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$bmp.Dispose()
$out = $in
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
Write-Host "CROPPED:$out"
