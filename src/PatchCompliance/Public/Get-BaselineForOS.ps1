function Get-BaselineForOS {
    [OutputType([pscustomobject])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][hashtable]$Baseline,
        [Parameter(Mandatory)][string]$OS
    )

    if (-not $Baseline.ContainsKey($OS)) {
        Write-Warning "No baseline defined for OS: $OS"
        return $null
    }

    return $Baseline[$OS]
}