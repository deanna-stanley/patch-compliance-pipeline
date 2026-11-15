BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\..\src\PatchCompliance') -Force
}

Describe 'Get-DefaultOverdueThresholds' {
    It 'Returns the default overdue threshold in days for each severity' {
        InModuleScope PatchCompliance {
            $expected = @{ Critical = 7; Important = 30; Moderate = 90 }

            Get-DefaultOverdueThresholds | Should-BeEquivalent $expected
        }
    }
}
