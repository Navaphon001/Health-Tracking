@echo off
setlocal

REM === Configuration ===
set COMPOSE_FILE=src\my_server\db\docker-compose.yaml

REM === Menu ===
:MENU
cls
echo.
echo ====================================
echo     Docker DB Management Script    
echo ====================================
echo [1] Start DB Container
echo [2] Stop DB Container
echo [3] Restart DB Container
echo [4] View Container Logs
echo [5] Remove DB Container + Volume
echo [6] Rebuild DB (Recreate Schema)
echo [0] Exit
echo ====================================
set /p choice=Choose an option: 

if "%choice%"=="1" goto START
if "%choice%"=="2" goto STOP
if "%choice%"=="3" goto RESTART
if "%choice%"=="4" goto LOGS
if "%choice%"=="5" goto REMOVE
if "%choice%"=="6" goto REBUILD
if "%choice%"=="0" exit
goto MENU

:START
echo Starting DB container...
docker-compose -f %COMPOSE_FILE% up -d
pause
goto MENU

:STOP
echo Stopping DB container...
docker-compose -f %COMPOSE_FILE% down
pause
goto MENU

:RESTART
echo Restarting DB container...
docker-compose -f %COMPOSE_FILE% down
docker-compose -f %COMPOSE_FILE% up -d
pause
goto MENU

:LOGS
echo Showing DB container logs...
docker-compose -f %COMPOSE_FILE% logs -f
pause
goto MENU

:REMOVE
echo Removing container and volume...
docker-compose -f %COMPOSE_FILE% down -v
pause
goto MENU

:REBUILD
echo WARNING: This will delete the database and re-create it!
pause
docker-compose -f %COMPOSE_FILE% down -v
docker-compose -f %COMPOSE_FILE% up -d
pause
goto MENU
