param (
    [string]$Action
)
$RecameraIp = if ($env:RECAMERA_IP) { $env:RECAMERA_IP } else { "192.168.16.1" }
$RecameraPass = if ($env:RECAMERA_PASS) { $env:RECAMERA_PASS } else { "recamera" }

if ($Action -eq "on") { 
    $Val = 1 
} elseif ($Action -eq "off") { 
    $Val = 0 
} else { 
    Write-Output "Error: Action must be on or off"
    exit 1 
}

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 recamera@$RecameraIp "echo '$RecameraPass' | sudo -S sh -c 'echo $Val > /sys/class/leds/white/brightness'"