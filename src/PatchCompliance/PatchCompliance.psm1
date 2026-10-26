foreach ($folder in 'Classes', 'Private', 'Public') {
    $folderPath = Join-Path $PSScriptRoot $folder
    if (-not (Test-Path $folderPath)) { continue }

    foreach ($file in Get-ChildItem -Path $folderPath -Filter '*.ps1') {
        try {
            . $file.FullName
        } catch {
            throw "Failed to import $($file.FullName): $_"
        }
    }
}

$publicFunctions = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1'
Export-ModuleMember -Function $publicFunctions.BaseName