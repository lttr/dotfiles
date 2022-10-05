Function Import-ConsoleColor {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0)]
        [ValidateScript( {Test-Path $_})]
        [string]$Path = '.\PSConsoleSettings.csv'
    )
     
    #verify this is the console and not the ISE
    if ($host.name -eq 'ConsoleHost') {
        Write-Verbose "Importing color settings from $path"
        $data = Import-CSV -Path $Path
        Write-Verbose ($data | out-string)
     
        if ($PSCmdlet.ShouldProcess($Path)) {
            $host.ui.RawUI.ForegroundColor = $data.ForegroundColor
            $host.ui.RawUI.BackgroundColor = $data.BackgroundColor
            $host.PrivateData.ErrorForegroundColor = $data.ErrorForegroundColor
            $host.PrivateData.ErrorBackgroundColor = $data.ErrorBackgroundColor
            $host.PrivateData.WarningForegroundColor = $data.WarningForegroundColor
            $host.PrivateData.WarningBackgroundColor = $data.WarningBackgroundColor
            $host.PrivateData.DebugForegroundColor = $data.DebugForegroundColor
            $host.PrivateData.DebugBackgroundColor = $data.DebugBackgroundColor
            $host.PrivateData.VerboseForegroundColor = $data.VerboseForegroundColor
            $host.PrivateData.VerboseBackgroundColor = $data.VerboseBackgroundColor
            $host.PrivateData.ProgressForegroundColor = $data.ProgressForegroundColor
            $host.PrivateData.ProgressBackgroundColor = $data.ProgressBackgroundColor
     
            Clear-Host
        } #should process
     
    }
    else {
        Write-Warning "This only works in the console host, not the ISE."
    }
     
} #Import-ConsoleColor