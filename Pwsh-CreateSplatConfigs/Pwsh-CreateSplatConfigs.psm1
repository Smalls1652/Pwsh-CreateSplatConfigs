<#
.SYNOPSIS
Convert a hashtable to JSON.

.DESCRIPTION
Convert a hashtable for splatting to JSON.

.PARAMETER SplatTable
Parameters to define for splatting.

.EXAMPLE
PS /> New-SplatConfig -SplatTable @{"ComputerName" = "localhost"; "Count" = 1; "Ping" = $true} | Out-File -FilePath "./LocalHost-Splat.json"

Converts a hashtable for Test-Connection with parameters to ping 'localhost' once. Use Out-File to save to a path.

.NOTES
This function does not save to a file, but returns the content of a JSON. Utilize cmdlets like 'Out-File' to save the JSON.
#>

function New-SplatConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$SplatTable
    )

    process {
        #Convert the hashtable to JSON.
        $JsonFile = $SplatTable | ConvertTo-Json -Depth 10
    }

    end {
        #Return the JSON contents.
        return $JsonFile
    }
}

<#
.SYNOPSIS
Import a JSON file to use for splatting.

.DESCRIPTION
Import a JSON file and convert it to a hashtable to use for splatting.

.PARAMETER Path
The path to the file.

.EXAMPLE
PS /> $LocalhostTestSplat = Import-SplatConfig -Path "./LocalHost-Splat.json"

Converts the JSON file to a hashtable to use for splatting.
#>
function Import-SplatConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    begin {

        #Test to make sure the provided path is correct.
        $null = Test-Path -Path $Path -ErrorAction Stop

        #Convert the path to an object.
        $PathObj = Get-Item -Path $Path

        #Get the contents of the provided file.
        Write-Verbose "Getting contents from file."
        $JsonDataRaw = Get-Content -Path $PathObj -Raw

        #Test the file to make sure it's actually a valid JSON file. If it's successful, convert it to an object.
        try {
            Write-Verbose "Testing to make sure the file contents are JSON."
            $null = Test-Json -Json $JsonDataRaw -ErrorAction Stop

            Write-Verbose "Converting the JSON to an object."
            $JsonData = ConvertFrom-Json -InputObject $JsonDataRaw -ErrorAction Stop
        }
        catch [Exception] {
            $ErrorDetails = $PSItem

            throw $ErrorDetails
        }

        #Set up the return hashtable to write to.
        $ReturnHashtable = @{ }
    }

    process {
        #Process each property in the object and return the data to the hashtable.
        foreach ($Item in $JsonData.PSObject.Properties.Name) {
            Write-Verbose "Adding item, '$($Item)', to the return hashtable."
            $ReturnHashtable.Add($Item, $JsonData.$Item)
        }
    }

    end {
        #Return the hashtable.
        return $ReturnHashtable
    }
}