using namespace System.Collections.Generic
$global:permissionsCache = @{}
$pathsToAnalyze = (Get-ChildItem -Path "D:\source\DontAclMeTestPaths\" -Recurse  -Directory).FullName
$groupedPaths = Group-PathsByDepth -paths $pathsToAnalyze
$sortedGroupKeys = $groupedPaths.Keys | Sort-Object -Descending
foreach ($depth in $sortedGroupKeys) {
    $pathsAtDepth = $groupedPaths[$depth]
    foreach ($path in $pathsAtDepth) {
        Find-PermissionOrigin -Path $path
    }
}

$aclLists = $global:permissionsCache.Values | ForEach-Object {
    $_ | ForEach-Object {
        Get-AccessRuleKey -accessRule $_
    }
} | Sort-Object -Unique

# Initialize commonAcls with the ACLs of the first folder and uncommonAcls as an empty array
$commonAcls = $null
$uncommonAcls = [list[string]]::new()

# For each folder, update commonAcls to only include ACLs that are also in the folder
# and add removed ACLs to uncommonAcls
foreach ($folderAcls in $global:permissionsCache.Values) {
    $folderAclKeys = $folderAcls | ForEach-Object {
        Get-AccessRuleKey -accessRule $_
    } | Sort-Object | Get-Unique

    if ($null -eq $commonAcls) {
        $commonAcls = $folderAclKeys
    } else {
        $removedAcls = $folderAclKeys | Where-Object { $commonAcls -notcontains $_ }
        $commonAcls = $folderAclKeys | Where-Object { $commonAcls -contains $_ }
        foreach ($unique in $removedAcls) {
            if (-not $uncommonAcls.Contains($unique)) {
                $uncommonAcls.Add($unique)
            }
        }
        #$commonAcls = $commonAcls | Where-Object { $folderAclKeys -contains $_ }
    }
}

# Add any ACLs from the last folder that are not in commonAcls to uncommonAcls
#$uncommonAcls += $folderAclKeys | Where-Object { $commonAcls -notcontains $_ }

# Output the common ACLs and uncommon ACLs
$commonAcls
$uncommonAcls

$foldersWithOnlyCommonAcls = [list[pscustomobject]]::new()
$foldersWithUncommonAcls = [list[pscustomobject]]::new()

foreach ($folderPath in $global:permissionsCache.Keys) {
    $folderAcls = $global:permissionsCache[$folderPath] | ForEach-Object {
        Get-AccessRuleKey -accessRule $_
    } | Sort-Object | Get-Unique

    if (($folderAcls | Where-Object { $uncommonAcls -contains $_ }).Count -gt 0) {
        $foldersWithUncommonAcls.Add(([pscustomobject]@{ Path = $folderPath; Acls = $global:permissionsCache[$folderPath]}))
    } else {
        $foldersWithOnlyCommonAcls.Add($folderPath)
    }
}

# Output the folders
$foldersWithOnlyCommonAcls
$foldersWithUncommonAcls