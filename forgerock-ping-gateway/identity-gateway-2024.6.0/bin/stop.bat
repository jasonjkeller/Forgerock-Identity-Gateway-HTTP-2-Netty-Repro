@echo off
rem :: Copyright 2022 ForgeRock AS. All Rights Reserved
rem ::
rem :: Use of this code requires a commercial software license with ForgeRock AS.
rem :: or with one of its affiliates. All use shall be exclusively subject
rem :: to such license between the licensee and ForgeRock AS.

rem :: ------------------------------------------------------------------------------
rem :: Environment Variable Prerequisites
rem :: ------------------------------------------------------------------------------
rem ::   JAVA_OPTS       (Optional) Java runtime options used when any command
rem ::                   is executed.
rem ::                   Include here and not in IG_OPTS all options, that
rem ::                   should be used by IG and also by the stop process.
rem :: ------------------------------------------------------------------------------

goto :main

:main
SetLocal EnableDelayedExpansion
set _ig_install_dir=%~dp0

:execCmd
rem :: Get remaining unshifted command line arguments and save them
set CMD_LINE_ARGS=
:setArgs
if ""%1""=="""" goto doneSetArgs
set CMD_LINE_ARGS=%CMD_LINE_ARGS% %1
shift
goto setArgs
:doneSetArgs

rem :: Use default or given instance directory
if "!CMD_LINE_ARGS!" == "" (
    set "INSTANCE_DIR=%AppData%\OpenIG"
    echo "No instance dir provided"
) else (
    call :TRIM CMD_LINE_ARGS
	if exist "!CMD_LINE_ARGS!" (
		call :IS_DIRECTORY !CMD_LINE_ARGS! isDirectory
		if "!isDirectory!" == "1" (
			set "INSTANCE_DIR=!CMD_LINE_ARGS!"
		) else (
			echo "Expecting a directory as an argument"
			set /a INVALID_ARGUMENT = 1
			exit /b !INVALID_ARGUMENT!
		)
	) else (
		set "INSTANCE_DIR=!CMD_LINE_ARGS!"
	)
)

set INSTANCE_DIR=%INSTANCE_DIR:"=%
call :TRIM INSTANCE_DIR
if not %INSTANCE_DIR:~-1%==\ (
    set INSTANCE_DIR_TRAILING_SLASH=%INSTANCE_DIR:"=%\
) else (
    set INSTANCE_DIR_TRAILING_SLASH=%INSTANCE_DIR:"=%
    rem :: Removing the trailing backslash
	set "INSTANCE_DIR=%INSTANCE_DIR:~0,-1%"
)
echo "Using '%INSTANCE_DIR_TRAILING_SLASH%' for IG installation directory"

rem :: Reading the env.bat file if it exists
set ENV_FILE=!INSTANCE_DIR_TRAILING_SLASH!bin\env.bat
if exist "!ENV_FILE!." (
    FOR %%i IN ("%ENV_FILE%") DO echo Using environment file located at: %%~fi
    call "%ENV_FILE%" || set _runenvstatus=!errorlevel!
	if !_runenvstatus! NEQ 0 (
         echo "An error occurred when loading env file"
         exit /b !_runenvstatus!
    )
)
rem :: The JAVA_HOME MUST be defined!
if "!JAVA_HOME!"=="" (
    echo "No java executable found in the JAVA_HOME or through the PATH environment variable."
    set /a ERROR_PATH_NOT_FOUND = 3
    exit /b !ERROR_PATH_NOT_FOUND!
)
set "_java=!JAVA_HOME!\bin\java.exe"
rem :: The JAVA_OPTS could be defined in an env. file
rem :: and must not contain single or double quotes.
rem :: These are removed within the lines underneath.
if not "!JAVA_OPTS!" == "" (
    set JAVA_OPTS_UNQUOTED=%JAVA_OPTS:"=%
)

set _EXECJAVA="!_java!"
set MAINCLASS=org.forgerock.openig.launcher.Stop
rem :: Note that there are no quotes into the CLASSPATH.
rem :: The trailing backslashes are used in the classpath
rem :: but must not be set within the instance directory.
set CLASSES_DIR=%_ig_install_dir%\..
set "CLASSPATH=%CLASSES_DIR%\classes;%CLASSES_DIR%\lib\*;%INSTANCE_DIR%\extra\*"
rem :: Main command line
%_EXECJAVA% -classpath "%CLASSPATH%" %JAVA_OPTS_UNQUOTED% %MAINCLASS% "%INSTANCE_DIR%"
EndLocal
GOTO :EOF

rem ::
rem :: Trim methods
rem :: Usage:
rem :: call :TRIM <var>
rem :: ex: call :TRIM INSTANCE_DIR
rem ::
:TRIM
SetLocal
Call :TRIMSUB %%%1%%
EndLocal & set %1=%tempvar%
GOTO :EOF

:TRIMSUB
set tempvar=%*
GOTO :EOF

rem ::
rem :: Checks if the given value is a directory and
rem :: stores the result in the given param. 1 if the
rem :: given path is a directory, 0 otherwise.
rem :: Usage:
rem :: call :IS_DIRECTORY <path> <var>
rem :: ex: call :IS_DIRECTORY %PATH% isDirectory
rem ::
:IS_DIRECTORY
SetLocal
set file_attribute=%~a1
if "%file_attribute:~0,1%"=="d" (
	set "result=1"
) else (
	set "result=0"
)
EndLocal & set %2=%result%
GOTO :EOF