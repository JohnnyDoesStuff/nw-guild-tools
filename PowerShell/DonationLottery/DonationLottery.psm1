# refer to https://gist.github.com/davidwallis3101/58de8462bf37c8683b377cb0c7a5a95b

$public  = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1  -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
foreach ($import in @($public + $private)) {
    Write-Verbose "Importing $import"
    try {
        . $import.Fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($import.Fullname): $_"
    }
}
Export-ModuleMember -Function $public.Basename
