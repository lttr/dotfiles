@REM Files

del /A:H %USERPROFILE%\.gitconfig
mklink %USERPROFILE%\.gitconfig %SYNC_DIR%\conf\git-%PLACE%\.gitconfig
attrib /L +H %USERPROFILE%\.gitconfig

del /A:H %USERPROFILE%\.gitk
mklink %USERPROFILE%\.gitk %SYNC_DIR%\conf\git-%PLACE%\.gitk
attrib /L +H %USERPROFILE%\.gitk

del /A:H %USERPROFILE%\_vimrc
mklink %USERPROFILE%\_vimrc %SYNC_DIR%\conf\dotfiles\.vimrc
attrib /L +H %USERPROFILE%\_vimrc

del /A:H %USERPROFILE%\_gvimrc
mklink %USERPROFILE%\_gvimrc %SYNC_DIR%\conf\dotfiles\.gvimrc
attrib /L +H %USERPROFILE%\_gvimrc

del /A:H %USERPROFILE%\_vimsize
mklink %USERPROFILE%\_vimsize %SYNC_DIR%\conf\vim\.vimsize-%PLACE%
attrib /L +H %USERPROFILE%\_vimsize

del /A:H %USERPROFILE%\.vrapperrc
mklink %USERPROFILE%\.vrapperrc %SYNC_DIR%\conf\eclipse\.vrapperrc
attrib /L +H %USERPROFILE%\.vrapperrc

@REM Directories

rmdir %USERPROFILE%\.docear
mklink /d %USERPROFILE%\.docear %SYNC_DIR%\conf\docear
attrib /L +H %USERPROFILE%\.docear

rmdir %USERPROFILE%\.freemind
mklink /d %USERPROFILE%\.freemind %SYNC_DIR%\conf\freemind
attrib /L +H %USERPROFILE%\.freemind

rmdir %USERPROFILE%\vimfiles
mklink /d %USERPROFILE%\vimfiles %SYNC_DIR%\conf\vim
attrib /L +H %USERPROFILE%\vimfiles

