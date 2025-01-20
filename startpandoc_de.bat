@echo off & cls
set drive=%~d0
set drivep=%drive%
If $#\#$==$#%drive:~-1%#$ set drivep=%drive:~0,-1%
set drivename=%drivep%

REM :: relative path to absolute path -PATH-
set pathn=%~p0
set pathp=%pathn%
If $#\#$==$#%pathn:~-1%#$ set pathp=%pathn:~0,-1%
set pathname=%pathp%

set HOMEDRIVE=%drivename%
set HOMEPATH=%pathname%
set EXEDIR=%HOMEDRIVE%%HOMEPATH%

REM :: Change into app-dir
%HOMEDRIVE%
cd "%EXEDIR%"

REM :: RUN ASYNC WITHOUT CONSOLE
start "" "%EXEDIR%\busybox.exe" bash -o noiconify -o noconsole pandoc_de.sh
REM :: DEBUG-RUN ASYNC WITH CONSOLE
REM :: start "" "%EXEDIR%\busybox.exe" bash pandoc_de.sh
