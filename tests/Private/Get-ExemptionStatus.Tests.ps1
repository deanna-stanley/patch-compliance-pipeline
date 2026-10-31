BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\..\src\PatchCompliance') -Force
}

Describe 'Get-ExemptionStatus' {
    It 'Returns None when the host has no exemptions' {
        InModuleScope PatchCompliance {
            $hostRecord = [PSCustomObject]@{
                Exemptions = @()
            }

            Get-ExemptionStatus -HostRecord $hostRecord -KB 'KB1' -AsOfDate '2026-01-15' |
                Should -Be ([ExemptionStatus]::None)
        }
    }

    It 'Returns None when exemptions exist only for other KBs' {
        InModuleScope PatchCompliance {
            $hostRecord = [pscustomobject]@{
                Exemptions = @([pscustomobject]@{ KB = 'KB2'; Expires = [datetime]'2026-02-01' })
            }

            Get-ExemptionStatus -HostRecord $hostRecord -KB 'KB1' -AsOfDate '2026-01-15' |
                Should -Be ([ExemptionStatus]::None)
        }
    }
    
    It 'Returns <Expected> when AsOfDate is <AsOfDate> and Expires is 2026-01-15' -ForEach @(
        @{ AsOfDate = '2026-01-10';       Expected = 'Active'  }
        @{ AsOfDate = '2026-01-14 23:59'; Expected = 'Active'  }
        @{ AsOfDate = '2026-01-15';       Expected = 'Expired' }
        @{ AsOfDate = '2026-01-15 00:01'; Expected = 'Expired' }
        @{ AsOfDate = '2026-01-20';       Expected = 'Expired' }
    ) {
        InModuleScope PatchCompliance -Parameters $_ {
            param($AsOfDate, $Expected)

            $hostRecord = [pscustomobject]@{
                Exemptions = @([pscustomobject]@{ KB = 'KB1'; Expires = [datetime]'2026-01-15' })
            }

            Get-ExemptionStatus -HostRecord $hostRecord -KB 'KB1' -AsOfDate $AsOfDate |
                Should -Be ([ExemptionStatus]$Expected)
        }
    }
    
    It 'Returns Active when a renewed exemption is still active' {
        InModuleScope PatchCompliance {
            $hostRecord = [pscustomobject]@{
                Exemptions = @(
                    [pscustomobject]@{ KB = 'KB1'; Expires = [datetime]'2026-01-01' },
                    [pscustomobject]@{ KB = 'KB1'; Expires = [datetime]'2026-03-01' }
                )
            }

            Get-ExemptionStatus -HostRecord $hostRecord -KB 'KB1' -AsOfDate '2026-01-15' |
                Should -Be ([ExemptionStatus]::Active)
        }
    }
    
    It 'Returns Expired when every exemption for the KB has expired' {
        InModuleScope PatchCompliance {
            $hostRecord = [pscustomobject]@{
                Exemptions = @(
                    [pscustomobject]@{ KB = 'KB1'; Expires = [datetime]'2026-01-01' },
                    [pscustomobject]@{ KB = 'KB1'; Expires = [datetime]'2026-01-10' }
                )
            }

            Get-ExemptionStatus -HostRecord $hostRecord -KB 'KB1' -AsOfDate '2026-01-15' |
                Should -Be ([ExemptionStatus]::Expired)
        }
    }
}
