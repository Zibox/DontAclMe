function Find-PermissionOrigin {
    param (
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [Parameter(Mandatory = $false)]
        [string] $LimitPath = (Split-Path -Path $Path -Parent)
    )
    # Initialize a hashtable to track permission origins
    $permissionOrigins = @{}
    $currentPath = $path
    if (-not $global:permissionsCache) {
        $global:permissionsCache = @{}
    }
    # Traverse up the directory hierarchy
    while ($currentPath -ne $limitPath) {
        if ($global:permissionsCache.ContainsKey($currentPath)) {
            # Use cached permissions if available
            $accessRules = $global:permissionsCache[$currentPath]
        } else {
            # Retrieve permissions and cache them
            $acl = Get-Acl -Path $currentPath
            $accessRules = $acl.Access #| Where-Object { $_.IsInherited -eq $true }
            $global:permissionsCache[$currentPath] = $accessRules
        }

        foreach ($rule in $accessRules) {
            $ruleKey = Get-AccessRuleKey -accessRule $rule

            # If the rule hasn't been seen before, add it and its path to the hashtable
            if (-not $permissionOrigins.ContainsKey($ruleKey)) {
                $permissionOrigins[$ruleKey] = $currentPath
            }
        }

        # Move up one directory level
        $parentPath = Split-Path -Path $currentPath -Parent

        # Stop if reached the limit path or no further parent exists
        if ($parentPath -eq "" -or $parentPath -eq $currentPath) {
            break
        }

        $currentPath = $parentPath
    }
}