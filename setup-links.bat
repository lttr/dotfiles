@REM Files

@REM Unfortunatelly git does not follow this symlink
del /A:H %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %USERPROFILE%\dotfiles\gitconfig
attrib /L +H %USERPROFILE%\.gitconfig

del /A:H %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %USERPROFILE%\dotfiles\vimrc
attrib /L +H %USERPROFILE%\_vimrc

del /A:H %USERPROFILE%\.vrapperrc
mklink %USERPROFILE%\.vrapperrc %USERPROFILE%\dotfiles\vrapperrc
attrib /L +H %USERPROFILE%\.vrapperrc

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

rmdir %USERPROFILE%\.vim
mklink /d %USERPROFILE%\.vim %SYNC_DIR%\conf\vim
attrib /L +H %USERPROFILE%\.vim
rmdir %USERPROFILE%\vimfiles
mklink /d %USERPROFILE%\vimfiles %SYNC_DIR%\conf\vim
attrib /L +H %USERPROFILE%\vimfiles

