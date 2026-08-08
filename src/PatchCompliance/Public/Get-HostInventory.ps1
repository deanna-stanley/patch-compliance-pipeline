function Get-HostInventory {
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Inventory file not found: $Path"
    }

    $items = Get-Content -Path $Path -Raw | ConvertFrom-Json

    $results = [System.Collections.Generic.List[pscustomobject]]::new()
    foreach ($item in $items) {
        $exemptions = [System.Collections.Generic.List[pscustomobject]]::new()
        foreach ($ex in $item.exemptions) {
            $exemptions.Add([pscustomobject]@{
                KB      = $ex.kb
                Reason  = $ex.reason
                Expires = [datetime]$ex.expires
            })
        }
        
        $results.Add([pscustomobject]@{
            Hostname             = $item.hostname
            OS                   = $item.os
            LastScanDate         = [datetime]$item.lastScanDate
            LastPatchInstallDate = [datetime]$item.lastPatchInstallDate
            MissingPatches       = @($item.missingPatches)
            Exemptions           = $exemptions
        })
    }

    return $results
}