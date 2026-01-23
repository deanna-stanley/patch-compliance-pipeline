function Write-ComplianceReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject[]]$Results,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $total = $Results.Count
    $compliant = ($Results | Where-Object Status -eq 'Compliant').Count
    $nonCompliant = ($Results | Where-Object Status -eq 'NonCompliant').Count
    $highRisk = ($Results | Where-Object Status -eq 'HighRisk').Count

    $highRiskSystems = $Results |
        Where-Object Status -eq 'HighRisk' |
        Sort-Object MissingApprovedCount -Descending

    $md = New-Object System.Collections.Generic.List[string]
    $md.Add("# Patch Compliance Summary")
    $md.Add("")
    $md.Add("- Total Systems: $total")
    $md.Add("- Fully Compliant: $compliant")
    $md.Add("- Non-Compliant: $nonCompliant")
    $md.Add("- High Risk: $highRisk")
    $md.Add("")
    $md.Add("## High Risk Systems")

    if ($highRiskSystems.Count -eq 0) {
        $md.Add("_None_")
    } else {
        foreach ($s in $highRiskSystems) {
            $md.Add("- $($s.Hostname) ($($s.MissingApprovedCount) missing approved patches)")
        }
    }

    $dir = Split-Path -Parent $OutputPath
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    $md -join "`n" | Set-Content -Path $OutputPath -Encoding UTF8
}
