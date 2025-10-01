@echo off
setlocal

REM Set defaults
if "%PORT%"=="" set PORT=8000
if "%RELOAD%"=="" set RELOAD=true

REM Try to use poetry+uvicorn if available
where poetry >nul 2>&1
if %ERRORLEVEL%==0 (
	echo Running with poetry + uvicorn...
	poetry run uvicorn my_server.main:app --reload=%RELOAD% --app-dir src --port %PORT%
	exit /b %ERRORLEVEL%
)

REM Fallback: try uvicorn in PATH
where uvicorn >nul 2>&1
if %ERRORLEVEL%==0 (
	echo Running with uvicorn from PATH...
	uvicorn my_server.main:app --reload=%RELOAD% --app-dir src --port %PORT%
	exit /b %ERRORLEVEL%
)

REM Final fallback: run using python -m (requires PYTHONPATH to include project root or use -m with package)
echo Falling back to python -m my_server.main
python -m my_server.main
endlocal
