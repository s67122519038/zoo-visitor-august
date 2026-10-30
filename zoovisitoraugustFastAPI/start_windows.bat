@echo off
cd /d "%~dp0"
if not exist ".venv\Scripts\python.exe" (
  echo [INFO] Create Python virtual environment...
  py -m venv .venv
  if errorlevel 1 (echo ERROR: Python not installed & pause & exit /b 1)
  ".venv\Scripts\python.exe" -m pip install -r requirements.txt
  if errorlevel 1 (echo ERROR: pip install failed & pause & exit /b 1)
)
echo.
echo Local Swagger UI: http://127.0.0.1:8000/docs
echo Local API: http://127.0.0.1:8000/api/zoo-visitors
".venv\Scripts\python.exe" -m uvicorn main:app --host 127.0.0.1 --port 8000
pause
