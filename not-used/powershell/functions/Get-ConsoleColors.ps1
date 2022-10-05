Function Get-ConsoleColors {
    Param(
        [switch]$Colorize
    )
 
    $wsh = New-Object -ComObject wscript.shell
 
    $data = [enum]::GetNames([consolecolor])
 
    if ($Colorize) {
        Foreach ($color in $data) {
            Write-Host $color -ForegroundColor $Color
        }
        [void]$wsh.Popup("The current background color is $([console]::BackgroundColor)", 16, "Get-ConsoleColor")
    }
    else {
        #display values
        $data
    }
 
} #Get-ConsoleColor
