Import-Module $env:HOMEPATH\documents\Code\Powershell\ML\PowerSOM.ps1

function Hash($textToHash)
{
    $hasher = new-object System.Security.Cryptography.SHA256Managed

    $toHash = [System.Text.Encoding]::UTF8.GetBytes($textToHash)

    $hashByteArray = $hasher.ComputeHash($toHash)

    foreach($byte in $hashByteArray)
    {
         $res += $byte.ToString()
    }

    return $res;
}

# Read file
$files = Get-ChildItem $env:HOMEPATH\Train
if ($files -eq $null) {
    return
}

# Read file features
$data = ,@($files[0].Extension)
for ($i = 1; $i -lt $files.Count; $i++) {
    $data += ,@($files[$i].Extension)
}

# Hash strings
Write-Host "Hashing"
$hash = @()
foreach ($d in $data) {
    $hash += ,@($d)
}
for ($i = 0; $i -lt $data.Count; $i++) {
    for ($j = 0; $j -lt $data[$j].Count; $j++) {
        if ($data[$i][$j] -eq $null) {
            $data[$i][$j] = "null"
        }
        $hash[$i][$j] = Hash($data[$i][$j])
    }
}

# Normalize
Write-Host "Normalizing"
$max = $hash[0]
foreach ($num in $hash) {
    if ($max -lt $num[0]) {
        $max = $num[0]
        Write-Host "max:" $max
    }
}

for ($i = 0; $i -lt $hash.Count; $i++) {
    for ($j = 0; $j -lt $hash[$j].Count; $j++) {
        Write-Host "i:" $i " j:" $j "max:" $max " v:" $hash[$i][$j]
        Write-Host ""
        $hash[$i][$j] = $hash[$i][$j] / $max
        Write-Host ""
        Write-Host "norm:" $hash[$i][$j]
        if ($hash[$i][$j] -gt 1) {
            $hash[$i][$j] = $hash[$i][$j] / $max  
        }
    }
}


# Train
Write-Host "Training"
$som = [PowerSOM]::new(120, 1, 1, 0.45)

# Time training
$stopwatch = New-Object System.Diagnostics.Stopwatch
$stopwatch.Start()

$som.train($hash, 10000)

$stopwatch.Stop()
$stopwatch

# Store model
$som | Export-Clixml $env:HOMEPATH\documents\Code\Powershell\ML\OrganizeFiles\som.xml