function Get-PatchDetails {
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$OSBaseline,
        [Parameter(Mandatory)][string]$KB
    )

    if (-not $OSBaseline.Patches.ContainsKey($KB)) {
        return $null
    }

    return $OSBaseline.Patches[$KB]
}
