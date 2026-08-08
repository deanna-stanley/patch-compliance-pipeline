function Get-DefaultOverdueThresholds {
    [OutputType([hashtable])]
    param()

    return @{
        Critical  = 7
        Important = 30
        Moderate  = 90
    }
}

function Get-PatchAge {
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][datetime]$ReleaseDate,
        [datetime]$AsOfDate = (Get-Date)
    )

    return ($AsOfDate - $ReleaseDate).Days
}

function Test-PatchOverdue {
    [OutputType([Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][int]$Age,
        [hashtable]$OverdueThresholdDays = (Get-DefaultOverdueThresholds)
    )

    return $Age -gt $OverdueThresholdDays[$Severity]
}

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

function Get-ExemptionStatus {
    [OutputType([ExemptionStatus])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$HostRecord,
        [Parameter(Mandatory)][string]$KB,
        [datetime]$AsOfDate = (Get-Date)
    )

    $exemption = $HostRecord.Exemptions | Where-Object { $_.KB -eq $kb }

    # The exemption expires at the start of the Expires date
    if ($null -eq $exemption) {
        return [ExemptionStatus]::None
    } elseif ($exemption.Expires -le $AsOfDate) {
        return [ExemptionStatus]::Expired
    } else {
        return [ExemptionStatus]::Active
    }
}

function Test-Compliance {
    [OutputType([pscustomobject[]])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject[]]$Inventory,
        [Parameter(Mandatory)][hashtable]$Baseline,
        [datetime]$AsOfDate = (Get-Date),
        [hashtable]$OverdueThresholdDays = (Get-DefaultOverdueThresholds)
    )

    $results = [System.Collections.Generic.List[pscustomobject]]::new()

    foreach ($hostRecord in $Inventory) {
        $osBaseline = Get-BaselineForOS -Baseline $Baseline -OS $hostRecord.OS

        $patchEvaluations = [System.Collections.Generic.List[pscustomobject]]::new()

        foreach ($kb in $hostRecord.MissingPatches) {
            $patchDetails = Get-PatchDetails -OSBaseline $osBaseline -KB $kb
            $exemptionStatus = Get-ExemptionStatus -HostRecord $hostRecord -KB $kb -AsOfDate $AsOfDate

            if ($null -eq $patchDetails) {
                $patchEvaluations.Add([pscustomobject]@{
                    KB              = $kb
                    InBaseline      = $false
                    Severity        = $null
                    ReleaseDate     = $null
                    DaysOutstanding = $null
                    IsOverdue       = $null
                    RiskTier        = $null
                    ExemptionStatus = $exemptionStatus
                })
                continue
            }
            
            $age = Get-PatchAge -ReleaseDate $patchDetails.ReleaseDate -AsOfDate $AsOfDate
            $isOverdue = Test-PatchOverdue -Severity $patchDetails.Severity -Age $age -OverdueThresholdDays $OverdueThresholdDays
            
            [RiskTier]$riskTier = switch ($patchDetails.Severity) {
                "Critical"  { [RiskTier]::Severe; break }
                "Important" { if ($isOverdue) { [RiskTier]::Severe }   else { [RiskTier]::Elevated }; break }
                "Moderate"  { if ($isOverdue) { [RiskTier]::Elevated } else { [RiskTier]::Watch };    break }
                default     { throw "Unhandled severity value: $($patchDetails.Severity)" }
            }
            
            $patchEvaluations.Add([pscustomobject]@{
                KB              = $kb
                InBaseline      = $true
                Severity        = $patchDetails.Severity
                ReleaseDate     = $patchDetails.ReleaseDate
                DaysOutstanding = $age
                IsOverdue       = $isOverdue
                RiskTier        = $riskTier
                ExemptionStatus = $exemptionStatus
            })
        }

        $scoredPatches = $patchEvaluations | Where-Object {
            $_.InBaseline -and $_.ExemptionStatus -ne [ExemptionStatus]::Active
        }

        [ComplianceStatus]$overallStatus = if (-not $scoredPatches) {
            [ComplianceStatus]::Compliant
        } elseif ($scoredPatches.RiskTier -contains [RiskTier]::Severe) {
            [ComplianceStatus]::Severe
        } elseif ($scoredPatches.RiskTier -contains [RiskTier]::Elevated) {
            [ComplianceStatus]::Elevated
        } else {
            [ComplianceStatus]::Watch
        }

        $results.Add([pscustomobject]@{
            Hostname      = $hostRecord.Hostname
            OS            = $hostRecord.OS
            EvaluatedAsOf = $AsOfDate
            Status        = $overallStatus
            Patches       = $patchEvaluations
        })
    }

    return $results

}