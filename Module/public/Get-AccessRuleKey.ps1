function Get-AccessRuleKey {
    [CmdletBinding()]
    param (
        [System.Security.AccessControl.FileSystemAccessRule] $AccessRule
    )
    return "$($accessRule.FileSystemRights)-$($accessRule.AccessControlType)-$($accessRule.IdentityReference)"
}