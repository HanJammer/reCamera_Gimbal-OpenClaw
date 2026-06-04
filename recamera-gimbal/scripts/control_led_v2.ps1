param (
    [string]$Action
)
$RecameraIp = if ($env:RECAMERA_IP) { $env:RECAMERA_IP } else { "192.168.16.1" }
$RecameraPass = if ($env:RECAMERA_PASS) { $env:RECAMERA_PASS } else { "recamera" }

if (-not $RecameraIp -or -not $RecameraPass) {
    Write-Error "Missing environment variables"
    exit 1
}

$Val = if ($Action -eq "on") { 1 } elseif ($Action -eq "off") { 0 } else { throw "Invalid argument, must be 'on' or 'off'" }

# Create a temporary script file that carries the password and command
$tempFile = [System.IO.Path]::GetTempFileName()
$tempScript = @"
#!/bin/bash
echo '$RecameraPass' | sudo -S sh -c 'echo $Val > /sys/class/leds/white/brightness'
"@
$tempScript | Out-File -FilePath $tempFile -Encoding ASCII

# Copy the temporary script to the remote host with SCP
scp -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 $tempFile recamera@$RecameraIp:/tmp/control_led.sh

# Execute the remote script
ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 recamera@$RecameraIp "chmod +x /tmp/control_led.sh && /tmp/control_led.sh"

# Clean up the temporary file
Remove-Item $tempFile
