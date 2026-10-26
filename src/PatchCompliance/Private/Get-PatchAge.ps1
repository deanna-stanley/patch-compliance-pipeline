function Get-PatchAge {
    [OutputType([int])]
    param(
        [Parameter(Mandatory)][datetime]$ReleaseDate,
        [datetime]$AsOfDate = (Get-Date)
    )

    return ($AsOfDate - $ReleaseDate).Days
}
