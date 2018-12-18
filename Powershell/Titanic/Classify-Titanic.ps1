Import-Module $env:HOMEPATH\documents\Code\Powershell\ML\MLHelper.ps1
Import-Module $env:HOMEPATH\documents\Code\Powershell\ML\PowerANN.ps1

$mlx = [MLHelper]::new()
$mly = [MLHelper]::new()
$n = [PowerANN]::new()

# Preprocess Data
$data = Get-Content "$env:HOMEPATH\documents\Code\Powershell\ML\Titanic\train.csv"

# Split sets
$num = [Math]::Round($data.Count * 0.7)
Write-Host $data.Count $num ($data.Count-$num)
$trainx = @(0) * $num
$trainy = @(0) * $num
$testx = @(0) * ($data.Count - $num)
$testy = @(0) * ($data.Count - $num)

# Training set
$map = @(0) * $data.Count
for ($i = 0; $i -lt $num; $i++) {
    # Choose a unique random vector to add to training set
    $k = Get-Random -Minimum 0 -Maximum $data.Count
    if ($map[$k] -eq 1) {
        $i--
        continue
    }

    $data[$k] = $data[$k].Split(',')
    $trainx[$i] = $data[$k][1..($data[$k].Count-2)]   
    $y = $data[$k][$data[$k].Count-1]

    if ($y -eq 0) {
        $trainy[$i] = (0, 1)
    } else {
        $trainy[$i] = (1, 0)
    }
    Write-Host $k $trainx[$i]       "  y:"  $trainy[$i]           

    $map[$k] = 1
}

# Test set
$num = 0
for ($i = 0; $i -lt $data.Count; $i++) {
    if ($map[$i] -eq 0) {
        $data[$i] = $data[$i].Split(',')
        #write-host "data: " $data[$i]
        #write-host "d0: " $data[$i][0]
        $testx[$num] = $data[$i][1..($data[$i].Count-2)]
        
        Write-Host $i $testx[$num]       "  y:"  $testy[$num]  

        $y = $data[$i][$data[$i].Count-1] 

        if ($y -eq 0) {
            $testy[$num] = (0, 1)
        } else {
            $testy[$num] = (1, 0)
        }

        $num++
        #pause
    }
}

$trainx = $mlx.normalizeUV($trainx)
$testx = $mly.normalizeUV($testx)

#Write-Host $trainx

# Sigmoid hidden Layer
$n.addLayer(6, 3)


# Softmax output layer
$n.addLayer(2, 2)

pause
$n.train($trainx, $trainy, 1, 0.00001, 100, 0.05)
pause
$n.test($testx, $testy)

# Store model
$n | Export-Clixml $env:HOMEPATH\documents\Code\Powershell\ML\Titanic\model.xml