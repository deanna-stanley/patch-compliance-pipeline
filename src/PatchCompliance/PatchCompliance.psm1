$publicFunctionsPath = Join-Path $PSScriptRoot 'Public'
Get-ChildItem -Path $publicFunctionsPath -Filter '*.ps1' | ForEach-Object {
    . $_.FullName
}

Export-ModuleMember -Function @(
    'Get-PatchInventory',
    'Test-PatchCompliance',
    'Write-ComplianceReport'
)