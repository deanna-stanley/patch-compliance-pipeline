function Get-DefaultOverdueThresholds {
    [OutputType([hashtable])]
    param()

    return @{
        Critical  = 7
        Important = 30
        Moderate  = 90
    }
}
