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
    $ReturnHashtable = @{}
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