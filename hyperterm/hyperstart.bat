@ECHO off
:top
CLS
ECHO Choose a shell:
ECHO [1] zsh
ECHO [2] bash
ECHO [3] cmd
ECHO [4] Windows PowerShell
ECHO [5] PowerShell
ECHO [6] Python
ECHO [7] Node
ECHO.
ECHO [8] restart elevated
ECHO [9] exit
ECHO.

CHOICE /N /C:123456789 /D 5 /T 2 /M "> "
CLS
IF ERRORLEVEL ==9 GOTO end
IF ERRORLEVEL ==8 powershell -Command "Start-Process hyper -Verb RunAs"
IF ERRORLEVEL ==7 node
IF ERRORLEVEL ==6 python
IF ERRORLEVEL ==5 pwsh -nologo
IF ERRORLEVEL ==4 powershell
IF ERRORLEVEL ==3 cmd
IF ERRORLEVEL ==2 bash
IF ERRORLEVEL ==1 bash --login -c zsh

CLS
ECHO Switch or exit?
ECHO [1] Switch
ECHO [2] Exit

CHOICE /N /C:12 /D 2 /T 3 /M "> "
IF ERRORLEVEL ==2 GOTO end
IF ERRORLEVEL ==1 GOTO top

:end
