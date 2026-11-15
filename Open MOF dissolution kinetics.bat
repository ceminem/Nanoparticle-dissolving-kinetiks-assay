@echo off
rem Opens the MOF dissolution kinetics app in the default browser.
if not exist "%~dp0MOF_dissolution_kinetics.html" (
  echo MOF_dissolution_kinetics.html was not found next to this file.
  pause
  exit /b 1
)
start "" "%~dp0MOF_dissolution_kinetics.html"
