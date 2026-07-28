$publicFunctionsPath = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'Get-HostInventory',
    'Get-ApprovedBaseline',
    'Test-PatchCompliance',
    'Write-ComplianceReport'
)