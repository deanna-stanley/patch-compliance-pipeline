# Patch Compliance Pipeline

A PowerShell-based patch compliance reporting pipeline (inventory → compliance evaluation → report).

## Status
Active development. Core pipeline executes end-to-end and generates a compliance summary from sample inventory data.

## Tech
- PowerShell 7 (pwsh)
- GitHub Actions (planned)
- Pester tests (planned)

## Run
Requires PowerShell 7+.

```powershell
pwsh ./src/run-compliance.ps1

This generates a markdown compliance report at:
reports/compliance-summary.md