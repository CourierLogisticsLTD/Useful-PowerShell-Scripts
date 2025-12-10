foreach ($file in Get-ChildItem -Path "$PSScriptRoot" -Filter *.ps1 -Recurse) {
    . $file.FullName
}
