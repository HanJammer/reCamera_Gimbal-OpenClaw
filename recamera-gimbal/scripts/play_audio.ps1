# Play back the recorded audio (/home/recamera/test.wav) on the reCamera speaker
$RecameraIp = if ($env:RECAMERA_IP) { $env:RECAMERA_IP } else { "192.168.16.1" }
$RecameraPass = if ($env:RECAMERA_PASS) { $env:RECAMERA_PASS } else { "recamera" }

ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=5 recamera@$RecameraIp "echo '$RecameraPass' | sudo -S aplay -D hw:1,0 /home/recamera/test.wav"
