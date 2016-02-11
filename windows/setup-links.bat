@REM Home dotfiles

del /A:H %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %USERPROFILE%\dotfiles\gitconfig
attrib /L +H %USERPROFILE%\.gitconfig

del /A:H %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %USERPROFILE%\dotfiles\vimrc
attrib /L +H %USERPROFILE%\_vimrc

del /A:H %USERPROFILE%\.vrapperrc
mklink %USERPROFILE%\.vrapperrc %USERPROFILE%\dotfiles\vrapperrc
attrib /L +H %USERPROFILE%\.vrapperrc


@REM Other links

del c:\tools\cmder\config\aliases
mklink c:\tools\cmder\config\aliases %USERPROFILE%\dotfiles\aliases-cmder

del c:\tools\cmder\config\ConEmu.xml
mklink c:\tools\cmder\config\ConEmu.xml %SYNC_DIR%\conf\cmder\cmder-settings-%PLACE%.xml

del %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml
mklink %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml %SYNC_DIR%\conf\mremoteng\extApps.xml


@REM Directories

rmdir %USERPROFILE%\.docear
mklink /d %USERPROFILE%\.docear %SYNC_DIR%\conf\docear
attrib /L +H %USERPROFILE%\.docear

rmdir %USERPROFILE%\.dbeaver
mklink /d %USERPROFILE%\.dbeaver %SYNC_DIR%\conf\dbeaver
attrib /L +H %USERPROFILE%\.dbeaver

rmdir %USERPROFILE%\.freemind
mklink /d %USERPROFILE%\.freemind %SYNC_DIR%\conf\freemind
attrib /L +H %USERPROFILE%\.freemind

