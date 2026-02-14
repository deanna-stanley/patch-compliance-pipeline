$modulePath = Join-Path $PSScriptRoot '..\src\PatchCompliance'
Import-Module $modulePath -Force

Describe 'PatchCompliance Module' {

    Context 'Get-PatchInventory' {

        It 'Loads inventory from JSON and normalizes objects' {
            $testData = @(
                @{
                    hostname = 'SRV-TEST-01'
                    os = 'Windows Server 2022'
                    lastPatchDate = '2025-01-01'
                    missingPatches = @('KB1', 'KB2')
                }
            ) | ConvertTo-Json -Depth 5

            $tempFile = New-TemporaryFile
            $testData | Set-Content -Path $tempFile.FullName

            $result = Get-PatchInventory -Path $tempFile.FullName

            $result | Should -HaveCount 1
            $result[0].Hostname | Should -Be 'SRV-TEST-01'
            $result[0].MissingPatches | Should -HaveCount 2
        }
    }

    Context 'Test-PatchCompliance' {

        It 'Marks system compliant when no approved patches are missing' {
            $inventory = @(
                [pscustomobject]@{
                    Hostname = 'SRV-OK'
                    OS = 'Windows Server 2022'
                    LastPatchDate = Get-Date
                    MissingPatches = @('KB-UNAPPROVED')
                }
            )

            $approved = @('KB-APPROVED')

            $result = Test-PatchCompliance -Inventory $inventory -ApprovedPatches $approved

            $result.Status | Should -Be 'Compliant'
        }

        It 'Marks system non-compliant when approved patches are missing' {
            $inventory = @(
                [pscustomobject]@{
                    Hostname = 'SRV-BAD'
                    OS = 'Windows Server 2022'
                    LastPatchDate = Get-Date
                    MissingPatches = @('KB-APPROVED')
                }
            )

            $approved = @('KB-APPROVED')

            $result = Test-PatchCompliance -Inventory $inventory -ApprovedPatches $approved

            $result.Status | Should -Be 'NonCompliant'
        }
    }
}
