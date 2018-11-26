function Add-Path($Path) {
  $Path = [Environment]::GetEnvironmentVariable("PATH", "Machine") + [IO.Path]::PathSeparator + $Path
  [Environment]::SetEnvironmentVariable( "Path", $Path, "Machine" )
}