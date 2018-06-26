class MLHelper {
    $magnitudes = @()

    [Object] normalizeData($data) {
        # Check if 1-dimensional
        if ($data[0].Count -eq 1) {
            #Write-Host "1 dimensional"
            # Calculate vector magnitude
            for ($i = 0; $i -lt $data.Count; $i++) {
                $magnitude += [Math]::Pow($data[$i], 2)
            }
            $this.magnitudes = [Math]::Sqrt($magnitude)
            #Write-Host $this.magnitudes

            # Calculate unit vector
            for($i = 0; $i -lt $data.Count; $i++) {
                $data[$i] = $data[$i]/$this.magnitudes
            }
        } else {
            #Write-Host "x dimensional"
            for ($i = 0; $i -lt $data.Count; $i++) {
                [double] $magnitude = 0
                # Calculate vector magnitude
                for($j = 0; $j -lt $data[$i].Count; $j++) {
                    $magnitude += [Math]::Pow($data[$i][$j], 2)
                }
                $this.magnitudes += [Math]::Sqrt($magnitude)
                #Write-Host $this.magnitudes

                # Calculate unit vector
                for($j = 0; $j -lt $data[$i].Count; $j++) {
                    $data[$i][$j] = $data[$i][$j]/$this.magnitudes[$i]
                }
            }
        }
        return $data
    }

    [Object] denormalizeVector($vector, $magnitude) {
        for($i = 0; $i -lt $vector.count; $i++) {
            $vector[$i] *= $magnitude
        }
        return $vector
    }

    [Object] denormalizeData($data) {
        for($i = 0; $i -lt $data.Count; $i++) {
            for($j = 0; $j -lt $data.Count; $j++) {
                $data[$i][$j] *= $this.magnitudes[$i]
            }
        }
        return $data
    }

    [Object] encodeLabels($data) {
        # Returns a map key: label, value: index
        $map = @{ }
        $count = 0
        for ($i = 0; $i -lt $data.Count; $i++) {
            for ($j = 0; $j -lt $data[$i].Count; $j++) {
                if ($data[$i][$j] -eq $null) {
                    $data[$i][$j] = "null"
                }
           
                if ($map.Item($data[$i][$j]) -eq $null) {
                    $map.Add($data[$i][$j], $count++)
                }
                #Write-Host "d:" $data[$i][$j] "   m:" $map.Item($data[$i][$j])
            }
        }
        return $map
    }
    
    [Object] oneHotEncode($data) {
        $map = $this.encodeLabels($data)
        #$vectors = New-Object 'object[,]' $data.Count, ($map.Count-1)
        # Write-Host "data2:" $data.Count "v:" $vectors.GetLength(0) $vectors.GetLength(1) "m:" $map.count
        

        # Initialize to 0, removed one column for dummy
        $vectors = ,@(,@(0) * ($map.Count -1))
        for ($i = 1; $i -lt $data.Count; $i++) {
            $vectors += ,@(,@(0) * ($map.Count -1))
           # for ($j = 0; $j -lt ($map.Count-1); $j++) {
                #$row[$j] = 0
            #}
        }
        Write-Host $vectors[0]
        Write-Host "data2:" $data.Count "v:" $vectors.count $vectors[0].count "m:" $map.count

        for ($i = 0; $i -lt $data.Count; $i++) {
            for ($j = 0; $j -lt $data[$i].Count; $j++) {
                # Set data index to 1
                if ($map.Item($data[$i][$j]) -lt $vectors[$i].Count) {
                    $vectors[$i][$map.Item($data[$i][$j])] = 1
                    #Write-Host "i: " $i " j:" $j "v:" $vectors[$i, $j] "   m:" $map.Item($data[$i][$j])
                }
            }
        }

        Write-Host $vectors[0]

        foreach($key in $map.keys) {
            
            Write-Host $map.Item($key) " k:" $key

        }

        
        for ($i = 0; $i -lt $data.Count; $i++) {
            <#$row = @()
            for ($j = 0; $j -lt $map.Count; $j++) {
                $row += $vectors[$i, $j]
            }#>

            Write-Host "i:" $i "  r:" $vectors[$i]

            
        }
        

        return $vectors
    }    

    [int] getRandomNum($range, $exclude) {
        return Get-Random -InputObject $range | Where-Object { $exclude -notcontains $_ }
    }
}