function Get-ApprovedBaseline {
    [OutputType([hashtable])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "Baseline file not found: $Path"
    }

    $json = Get-Content -Path $Path -Raw | ConvertFrom-Json -AsHashtable

    $normalized = @{}
    foreach ($os in $json.baselines.Keys) {
        $osBaseline = $json.baselines[$os]

        $patches = @{}
        foreach ($patch in $osBaseline.patches) {
            $patches[$patch.kb] = [pscustomobject]@{
                KB          = $patch.kb
                Severity    = $patch.severity
                ReleaseDate = [datetime]$patch.releaseDate
            }
        }

        $normalized[$os] = [pscustomobject]@{
            EffectiveDate = [datetime]$osBaseline.effectiveDate
            Patches       = $patches
        }
    }

    return $normalized
}

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