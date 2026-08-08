# ComplianceEnums.ps1
enum ExemptionStatus {
    None
    Active
    Expired
}

enum RiskTier {
    Watch
    Elevated
    Severe
}

enum ComplianceStatus {
    Compliant
    Watch
    Elevated
    Severe
}