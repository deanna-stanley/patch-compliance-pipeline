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
