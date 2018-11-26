Function Export-ConsoleColor {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullorEmpty()]
        [string]$Path = '.\PSConsoleSettings.csv'
    )
    
    #verify this is the console and not the ISE
    if ($host.name -eq 'ConsoleHost') {
        $host.PrivateData | Add-Member -MemberType NoteProperty -Name ForegroundColor -Value $host.ui.rawui.ForegroundColor -Force
        $host.PrivateData | Add-Member -MemberType NoteProperty -Name BackgroundColor -Value $host.ui.rawui.BackgroundColor -Force
        Write-Verbose "Exporting to $path"
        Write-verbose ($host.PrivateData | out-string)
        $host.PrivateData | Export-CSV -Path $Path -Encoding ASCII -NoTypeInformation
    }
    else {
        Write-Warning "This only works in the console host, not the ISE."
    
    }
} #Export-ConsoleColor