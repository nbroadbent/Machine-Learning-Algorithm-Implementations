Import-Module $env:HOMEPATH\documents\Code\Powershell\ML\PowerSOM.ps1

$som = Import-Clixml $env:HOMEPATH\documents\Code\Powershell\ML\OrganizeFiles\som.xml
$som = [PowerSOM]::new($som)

$folders = New-Object string[] 200
if (([system.io.directory]::Exists($env:HOMEPATH + "\documents\Code\Powershell\ML\folders.xml"))) {
    $folders = Import-Clixml $env:HOMEPATH\documents\Code\Powershell\folders.xml
}

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

# Read files
$files = Get-ChildItem $env:HOMEPATH\Source
if ($files -eq $null) {
    return
}

# Get file data
$data = ,@($files[0].Extension)
for ($i = 1; $i -lt $files.Count; $i++) {
    Write-Host "i:" $i "   name:" $files[$i].Name
    $data += ,@($files[$i].Extension)
}

# Hash strings
$hash = @()
foreach ($d in $data) {
    $hash += ,@($d)
}
for ($i = 0; $i -lt $data.Count; $i++) {
    for ($j = 0; $j -lt $data[$j].Count; $j++) {
        if ($data[$i][$j] -eq $null) {
            $data[$i][$j] = "null"
        }
        Write-Host $data[$i][$j]
        $hash[$i][$j] = Hash($data[$i][$j])
        Write-Host $hash[$i][$j]
    }
}

# Normalize data
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
Write-Host "norm:" $hash[0]

# Concatenate like-clusters
$map = New-Object 'object[,]' $som.x, $som.y
#$som.mapData($hash, $false)
$distMap = $som.getDistanceMap()


# Map documents
$newFolders = New-Object string[] $som.x
for ($i = 0; $i -lt $hash.Count; $i++) {
    # Find winning node for each piece of data
    $node = $som.findBMU($hash[$i])
    $node.addVector($hash[$i])
    $map[$node.x, $node.y] = $node
    
    if ($folders.Count -le 0 -or [string]::IsNullOrEmpty($folders[$node.x])) {
        Write-Host $folders[$node.x] " x:" $node.x
        $path = $env:HOMEPATH + "\Documents\" + $node.x
    } else {
        $path = $folders[$node.x]
    }
    
    # Create directory
    if (!([system.io.directory]::Exists($path))){
        [system.io.directory]::CreateDirectory($path)
        $newFolders[$node.x] = $path
    }

    # Move file
    Write-Host $files[$i] "path: " $path
    Move-Item -Path ($env:HOMEPATH + "\Source\" + $files[$i]) -Destination $path
}

# Name new folder clusters
for ($i = 0; $i -lt $newFolders.Count; $i++) {
    #cls
    if ([string]::IsNullOrEmpty($newFolders[$i])) {
        continue
    }

    Write-Host "New Cluster Found! What would you like to name it?"
    Write-Host "Cluster path:" $newFolders[$i]
    $name = Read-Host 'Name'

    # Rename and store
    Rename-Item -Path $newFolders[$i] -NewName $name
    $folders[$i] = $env:HOMEPATH + "\Documents\" + $name
}

# Store folders
$folders | Export-Clixml $env:HOMEPATH\documents\Code\Powershell\ML\OrganizeFiles\folders.xml