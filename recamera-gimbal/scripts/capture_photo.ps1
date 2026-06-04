# Capture the latest frame from the reCamera Gimbal and save it locally.
# RECAMERA_IP is read from the environment (set in openclaw.json); the literal
# value is only a fallback for standalone use.
# Output goes to a per-session scratch dir, NOT the workspace root, to avoid clutter.
$RecameraIp = if ($env:RECAMERA_IP) { $env:RECAMERA_IP } else { "192.168.16.1" }
$ScratchDir = if ($env:RECAMERA_TMPDIR) { $env:RECAMERA_TMPDIR } else { Join-Path $env:USERPROFILE ".openclaw\workspace\tmp\recamera-gimbal" }
New-Item -ItemType Directory -Force $ScratchDir | Out-Null
$OutFile = Join-Path $ScratchDir "latest_photo.jpg"
$FileUri = "file:///" + ($OutFile -replace '\\', '/')

Write-Output "Fetching latest frame from camera..."
try {
    $Headers = @{ "Cache-Control" = "no-cache" }
    Invoke-WebRequest -Uri "http://$RecameraIp:1880/api/photo" -Headers $Headers -OutFile $OutFile -UseBasicParsing -ErrorAction Stop

    Write-Output "SUCCESS: Photo saved to physical path: $OutFile"
    Write-Output "SYSTEM INSTRUCTION: 1. Use your Vision tool to analyze this image. 2. In your final reply to the user, YOU MUST display this image using Markdown syntax: ![Camera View]($FileUri)"
} catch {
    Write-Output "ERROR: Failed to capture photo. Check camera connection."
    exit 1
}