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

del /A:H %USERPROFILE%\.kdiff3rc
mklink %USERPROFILE%\.kdiff3rc %USERPROFILE%\dotfiles\kdiff3rc
attrib /L +H %USERPROFILE%\.kdiff3rc

mklink c:\Users\Lukas\AppData\Roaming\Code\User\settings.json  %USERPROFILE%\dotfiles\vscode\settings.json
mklink c:\Users\Lukas\AppData\Roaming\Code\User\keybindings.json  %USERPROFILE%\dotfiles\vscode\keybindings.json
mklink /d c:\Users\Lukas\AppData\Roaming\Code\User\snippets  %USERPROFILE%\dotfiles\vscode\snippets

@REM Other links

del %CMDER_ROOT%\config\aliases
mklink %CMDER_ROOT%\config\aliases %USERPROFILE%\dotfiles\windows\aliases-cmder

del %CMDER_ROOT%\config\ConEmu.xml
mklink %CMDER_ROOT%\config\ConEmu.xml %SYNC_DIR%\conf\cmder\cmder-settings-%PLACE%.xml

del %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml
mklink %USERPROFILE%\AppData\Roaming\mRemoteNG\extApps.xml %SYNC_DIR%\conf\mremoteng\extApps.xml


@REM Directories

rmdir %USERPROFILE%\vimfiles\colors
mklink /d %USERPROFILE%\vimfiles\colors %USERPROFILE%\dotfiles\vim\colors

rmdir %USERPROFILE%\vimfiles\syntax
mklink /d %USERPROFILE%\vimfiles\syntax %USERPROFILE%\dotfiles\vim\syntax

rmdir %USERPROFILE%\vimfiles\snippets
mklink /d %USERPROFILE%\vimfiles\snippets %USERPROFILE%\dotfiles\vim\snippets

