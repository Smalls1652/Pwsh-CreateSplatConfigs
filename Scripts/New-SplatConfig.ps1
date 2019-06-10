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