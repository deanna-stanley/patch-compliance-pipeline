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