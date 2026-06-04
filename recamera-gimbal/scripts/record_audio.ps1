param (
    [string]$Duration = "5"
)
# Record audio from the reCamera microphone into /home/recamera/test.wav
$RecameraIp = if ($env:RECAMERA_IP) { $env:RECAMERA_IP } else { "192.168.16.1" }
$RecameraPass = if ($env:RECAMERA_PASS) { $env:RECAMERA_PASS } else { "recamera" }

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 recamera@$RecameraIp "echo '$RecameraPass' | sudo -S arecord -D hw:0,0 -r 16000 -f S16_LE -c 1 -d $Duration /home/recamera/test.wav"
