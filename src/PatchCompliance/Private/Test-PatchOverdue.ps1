function Test-PatchOverdue {
    [OutputType([Boolean])]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Severity,
        [Parameter(Mandatory)][int]$Age,
        [hashtable]$OverdueThresholdDays = (Get-DefaultOverdueThresholds)
    )

    if (-not $OverdueThresholdDays.ContainsKey($Severity)) {
        throw "No overdue threshold defined for severity: $Severity"
    }

    return $Age -gt $OverdueThresholdDays[$Severity]
}
