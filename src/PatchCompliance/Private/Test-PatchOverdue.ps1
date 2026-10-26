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
