param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $Path,
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $UserName,
    [Parameter(Mandatory = $false, Position = 2)]
    [int] $MaxFolders = 100
)
begin {
    $folderCount = Get-Random -Minimum ([math]::Round($MaxFolders / 2)) -Maximum $MaxFolders
    if (-not (Test-Path $Path)) {
        [void] (New-Item -ItemType Directory -Force -Path $Path)
    }
}
process {
    for ($i = 1; $i -le $folderCount; $i++) {
        $rootFolder = Join-Path $Path "RootFolder$i"
        [void] (New-Item -ItemType Directory -Force -Path $rootFolder)
    
        # Create nested folders inside each root folder
        $nestedFolderCount = Get-Random -Minimum 5 -Maximum 10
        for ($j = 1; $j -le $nestedFolderCount; $j++) {
            $nestedFolder = Join-Path $rootFolder "NestedFolder$j"
            [void] (New-Item -ItemType Directory -Force -Path $nestedFolder)
        }
    }
    $denyCount = Get-Random -Minimum 1 -Maximum $folderCount
    $folders = Get-ChildItem $Path -Recurse |
        Where-Object { $_.PSIsContainer } | Select-Object -ExpandProperty FullName
    $foldersToDeny = Get-Random -InputObject $folders -Count $denyCount
    foreach ($folder in $foldersToDeny) {
        $acl = Get-Acl $folder
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserName, "FullControl", "Deny")
        $acl.AddAccessRule($accessRule)
        Set-Acl $folder $acl
    }
}
end {

}