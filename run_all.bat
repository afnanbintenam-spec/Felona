@echo off
REM ============================================
REM  FeloNa - Run Backend + Flutter Web together
REM ============================================

echo Starting FeloNa Backend (Node.js)...
start "FeloNa Backend" cmd /k "cd /d %~dp0backend && npm run dev"

echo Starting Flutter Web (Chrome)...
start "FeloNa Flutter Web" cmd /k "cd /d %~dp0 && flutter run -d chrome"

echo.
echo Both services are starting in separate windows.
echo Close this window anytime - the services will keep running.
