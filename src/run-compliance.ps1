$ErrorActionPreference = 'Stop'

# Import module from local path
$modulePath = Join-Path $PSScriptRoot 'PatchCompliance'
Import-Module $modulePath -Force

$inventoryPath = Join-Path $PSScriptRoot '..\data\sample-inventory.json'
$approvedPath  = Join-Path $PSScriptRoot '..\data\approved-patches.json'
$reportPath    = Join-Path $PSScriptRoot '..\reports\compliance-summary.md'

$inventory = Get-PatchInventory -Path $inventoryPath

$approvedRaw = Get-Content -Path $approvedPath -Raw | ConvertFrom-Json
$approved = @($approvedRaw.approvedPatches)

$results = Test-PatchCompliance -Inventory $inventory -ApprovedPatches $approved

Write-ComplianceReport -Results $results -OutputPath $reportPath

# Console summary
$results |
    Group-Object Status |
    Sort-Object Name |
    Select-Object Name, Count |
    Format-Table -AutoSize

Write-Host ""
Write-Host "Report written to: $reportPath"
