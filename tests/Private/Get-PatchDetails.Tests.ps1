BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\..\src\PatchCompliance') -Force
}

Describe 'Get-PatchDetails' {
    BeforeAll {
        $osBaseline = [pscustomobject]@{
            EffectiveDate = [datetime]'2026-07-10'
            Patches       = @{
                'KB1' = [pscustomobject]@{ KB = 'KB1'; Severity = 'Critical';  ReleaseDate = [datetime]'2026-07-01' }
                'KB2' = [pscustomobject]@{ KB = 'KB2'; Severity = 'Important'; ReleaseDate = [datetime]'2026-06-10' }
            }
        }
    }

    It 'Returns the patch details when the KB exists' {
        InModuleScope PatchCompliance -Parameters @{ OSBaseline = $osBaseline } {
            param($OSBaseline)

            $expected = [pscustomobject]@{ KB = 'KB1'; Severity = 'Critical'; ReleaseDate = [datetime]'2026-07-01' }

            Get-PatchDetails -OSBaseline $OSBaseline -KB 'KB1' | Should-BeEquivalent $expected
        }
    }

    It 'Returns $null if there is no matching KB' {
        InModuleScope PatchCompliance -Parameters @{ OSBaseline = $osBaseline } {
            param($OSBaseline)

            Get-PatchDetails -OSBaseline $OSBaseline -KB 'KB-NOT-IN-BASELINE' | Should-BeNull
        }
    }
}
