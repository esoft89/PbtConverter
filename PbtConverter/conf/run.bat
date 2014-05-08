@echo off
rem -------------------------------------------------------------------------
rem PbtConverter Script for Windows
rem -------------------------------------------------------------------------
rem $Id: run.bat lpage@esoft89.com $

set DIRNAME=..\..
if "x%JAVA_HOME%" == "x" (
  set  JAVA=java
  echo JAVA_HOME is not set. Unexpected results may occur.
  echo Set JAVA_HOME to the directory of your local JDK to avoid this message.
) else (
  set "JAVA=%JAVA_HOME%\bin\java"
)

pushd %DIRNAME%..
if "x%PBT_HOME%" == "x" (
  set "PBT_HOME=%CD%"
) 
popd
CD %PBT_HOME%

if exist "%PBT_HOME%\lib\PbtConverter.jar" (
    set "RUNJAR=%PBT_HOME%\lib\PbtConverter.jar;%PBT_HOME%\lib\commons-lang-2.3.jar;%PBT_HOME%\lib\mysql-connector-java-5.1.30-bin.jar"
) else (
  echo Could not locate "%PBT_HOME%\lib\PbtConverter.jar".
  echo Please check that you are in the bin directory when running this script.
  goto END
)

set "RUN_CLASSPATH=%RUNJAR%"

if /I "%1" == "install"      goto RESTART
if /I "%1" == "uninstall"    goto RESTART
if /I "%1" == "import"       goto RESTART
if /I "%1" == "undo_import"  goto RESTART
echo Usage: install^|uninstall^|import^|undo_import
goto END

:RESTART
echo ===============================================================================
echo.
echo   Bootstrap Environment
echo.
echo   PBT_HOME: %PBT_HOME%
echo.
echo   PBT_ARG: %1
echo.
echo   JAVA: %JAVA%
echo.
echo   JAVA_OPTS: %JAVA_OPTS%
echo.
echo   CLASSPATH: %RUN_CLASSPATH%
echo.
echo ===============================================================================
echo.
"%JAVA%" %JAVA_OPTS% ^
   -classpath "%RUN_CLASSPATH%" ^
   com.esoft.PbtConverter %*

if ERRORLEVEL 10 goto RESTART

:END
CD bin