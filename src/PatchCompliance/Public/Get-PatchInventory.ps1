function Get-PatchInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Inventory file not found: $Path"
    }

    $raw = Get-Content -Path $Path -Raw
    $items = $raw | ConvertFrom-Json

    # Normalize to predictable objects
    foreach ($item in $items) {
        [pscustomobject]@{
            Hostname       = $item.hostname
            OS             = $item.os
            LastPatchDate  = [datetime]$item.lastPatchDate
            MissingPatches = @($item.missingPatches)
        }
    }
}