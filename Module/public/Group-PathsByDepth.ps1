function Group-PathsByDepth {
    param (
        [array] $Paths
    )
    $groupedPaths = @{}
    foreach ($path in $Paths) {
        $depth = (Split-PathToArray -path $path).Count
        if (-not $groupedPaths.ContainsKey($depth)) {
            $groupedPaths[$depth] = New-Object System.Collections.Generic.List[object]
        }
        $groupedPaths[$depth].Add($path)
    }
    return $groupedPaths
}