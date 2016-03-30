@REM Home dotfiles

@echo off

del /A:H %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %USERPROFILE%\dotfiles\gitconfig
attrib /L +H %USERPROFILE%\.gitconfig

del /A:H %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %USERPROFILE%\dotfiles\vimrc
attrib /L +H %USERPROFILE%\_vimrc

del /A:H %USERPROFILE%\.vrapperrc
mklink %USERPROFILE%\.vrapperrc %USERPROFILE%\dotfiles\vrapperrc
attrib /L +H %USERPROFILE%\.vrapperrc

del /A:H %USERPROFILE%\.ideavimrc
mklink %USERPROFILE%\.ideavimrc %USERPROFILE%\dotfiles\ideavimrc
attrib /L +H %USERPROFILE%\.ideavimrc


@REM Other links

del c:\cmder\config\aliases
mklink c:\cmder\config\aliases %USERPROFILE%\dotfiles\windows\aliases-cmder

del c:\cmder\config\ConEmu.xml
mklink c:\cmder\config\ConEmu.xml %SYNC_DIR%\conf\cmder\cmder-settings-%PLACE%.xml

del %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml
mklink %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml %SYNC_DIR%\conf\mremoteng\extApps.xml


@REM Directories

rmdir %USERPROFILE%\vimfiles\colors
mklink /d %USERPROFILE%\vimfiles\colors %USERPROFILE%\dotfiles\vim\colors

rmdir %USERPROFILE%\vimfiles\syntax
mklink /d %USERPROFILE%\vimfiles\syntax %USERPROFILE%\dotfiles\vim\syntax

rmdir %USERPROFILE%\.docear
mklink /d %USERPROFILE%\.docear %SYNC_DIR%\conf\docear
attrib /L +H %USERPROFILE%\.docear

rmdir %USERPROFILE%\.dbeaver
mklink /d %USERPROFILE%\.dbeaver %SYNC_DIR%\conf\dbeaver
attrib /L +H %USERPROFILE%\.dbeaver

rmdir %USERPROFILE%\.freemind
mklink /d %USERPROFILE%\.freemind %SYNC_DIR%\conf\freemind
attrib /L +H %USERPROFILE%\.freemind

