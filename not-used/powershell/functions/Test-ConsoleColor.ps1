Function Test-ConsoleColor {
    [cmdletbinding()]
    Param()
    
    Clear-Host
    $heading = "White"
    Write-Host "Pipeline Output" -ForegroundColor $heading
    Get-Service | Select -first 5
    
    Write-Host "`nError" -ForegroundColor $heading
    Write-Error "I made a mistake"
    
    Write-Host "`nWarning" -ForegroundColor $heading
    Write-Warning "Let this be a warning to you."
    
    Write-Host "`nVerbose" -ForegroundColor $heading
    $VerbosePreference = "Continue"
    Write-Verbose "I have a lot to say."
    $VerbosePreference = "SilentlyContinue"
    
    Write-Host "`nDebug" -ForegroundColor $heading
    $DebugPreference = "Continue"
    Write-Debug "`nSomething is bugging me. Figure it out."
    $DebugPreference = "SilentlyContinue"
    
    Write-Host "`nProgress" -ForegroundColor $heading
    1..10 | foreach -Begin {$i = 0} -process {
        $i++
        $p = ($i / 10) * 100
        Write-Progress -Activity "Progress Test" -Status "Working" -CurrentOperation $_ -PercentComplete $p
        Start-Sleep -Milliseconds 250
    }
} #Test-ConsoleColor