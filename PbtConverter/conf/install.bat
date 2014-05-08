@echo off
rem -------------------------------------------------------------------------
rem PbtConverter Script for Windows
rem -------------------------------------------------------------------------
rem $Id: run.bat lpage@esoft89.com $

if exist ".\run.bat" (
  call .\run.bat install
) else (
  echo Could not locate ".\run.bat".
  echo Please check that you are in the bin directory when running this script.
  goto END
)

:END
