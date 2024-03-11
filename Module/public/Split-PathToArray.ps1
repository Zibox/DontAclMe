function Split-PathToArray {
    [CmdletBinding()]
    param (
        [string]$path
    )
    $path -split '\\' | Where-Object { $_ -ne '' }
}
