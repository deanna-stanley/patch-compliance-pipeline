function Test-PatchCompliance {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject[]]$Inventory,

        [Parameter(Mandatory)]
        [string[]]$ApprovedPatches,

        [int]$HighRiskMissingPatchThreshold = 5
    )

    foreach ($machine in $Inventory) {
        $missing = @($machine.MissingPatches)
        $missingApproved = @($missing | Where-Object { $_ -in $ApprovedPatches })
        $missingUnapproved = @($missing | Where-Object { $_ -notin $ApprovedPatches })

        $status =
            if ($missingApproved.Count -eq 0) { 'Compliant' }
            elseif ($missingApproved.Count -ge $HighRiskMissingPatchThreshold) { 'HighRisk' }
            else { 'NonCompliant' }

        [pscustomobject]@{
            Hostname           = $machine.Hostname
            OS                 = $machine.OS
            LastPatchDate      = $machine.LastPatchDate
            MissingApproved    = $missingApproved
            MissingUnapproved  = $missingUnapproved
            MissingApprovedCount   = $missingApproved.Count
            MissingUnapprovedCount = $missingUnapproved.Count
            Status             = $status
            CheckedAt          = (Get-Date)
        }
    }
}