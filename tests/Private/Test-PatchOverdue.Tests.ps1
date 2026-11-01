BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\..\src\PatchCompliance') -Force
}

Describe 'Test-PatchOverdue' {
    Context 'With custom thresholds' {
        It 'Returns <Expected> when Age is <Age> and Severity is <Severity>' -ForEach @(
            @{ Age = 3;  Severity = 'Critical';  Expected = $false }
            @{ Age = 4;  Severity = 'Critical';  Expected = $true  }
            @{ Age = 10; Severity = 'Important'; Expected = $false }
            @{ Age = 11; Severity = 'Important'; Expected = $true  }
            @{ Age = 20; Severity = 'Moderate';  Expected = $false }
            @{ Age = 21; Severity = 'Moderate';  Expected = $true  }
        ) {
            InModuleScope PatchCompliance -Parameters $_ {
                param($Age, $Severity, $Expected)

                $thresholds = @{ Critical = 3; Important = 10; Moderate = 20 }

                Test-PatchOverdue -Severity $Severity -Age $Age -OverdueThresholdDays $thresholds |
                    Should -Be $Expected
            }
        }
    }

    Context 'With default thresholds' {
        It 'Uses the default Critical threshold when none are passed' {
            InModuleScope PatchCompliance {
                Test-PatchOverdue -Severity 'Critical' -Age 7 | Should -BeFalse
                Test-PatchOverdue -Severity 'Critical' -Age 8 | Should -BeTrue
            }
        }
    }
    
    Context 'When no threshold exists for the severity' {
        It 'Throws for a severity not in the default thresholds' {
            InModuleScope PatchCompliance {
                { Test-PatchOverdue -Severity 'Low' -Age 0 } | Should -Throw '*Low*'
            }
        }

        It 'Throws when a custom threshold table is missing the severity' {
            InModuleScope PatchCompliance {
                $thresholds = @{ Critical = 3 }

                { Test-PatchOverdue -Severity 'Moderate' -Age 0 -OverdueThresholdDays $thresholds } |
                    Should -Throw '*Moderate*'
            }
        }
    }
}
