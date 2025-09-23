@echo off

poetry run uvicorn my_server.main:app --reload --app-dir src
