BeforeAll {
    Import-Module (Join-Path $PSScriptRoot '..\..\src\PatchCompliance') -Force
}

Describe 'Get-PatchAge' {
    It 'Returns <Expected> when ReleaseDate is <ReleaseDate> and AsOfDate is <AsOfDate>' -ForEach @(
        @{ ReleaseDate = '2026-01-15';  AsOfDate = '2026-01-20';  Expected = 5 }
        @{ ReleaseDate = '2026-01-15 05:00';  AsOfDate = '2026-01-20';  Expected = 4 }
        @{ ReleaseDate = '2026-01-13';  AsOfDate = '2026-01-21 17:00';  Expected = 8 }
    ) {
        InModuleScope PatchCompliance -Parameters $_ {
            param($ReleaseDate, $AsOfDate, $Expected)

            Get-PatchAge -ReleaseDate $ReleaseDate -AsOfDate $AsOfDate | Should -Be $Expected
        }
    }

    It 'Returns a negative age when ReleaseDate is after AsOfDate' {
        InModuleScope PatchCompliance {
            Get-PatchAge -ReleaseDate '2026-01-15' -AsOfDate '2026-01-13' | Should -Be -2
        }
    }
}
