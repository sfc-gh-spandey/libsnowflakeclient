::
:: Build ARROW library
::
@echo off
set arrow_version=0.17.0
call %*
goto :EOF

:get_version
    set version=%arrow_version%
    goto :EOF

:build
@echo on
setlocal
set platform=%1
set build_type=%2
set vs_version=%3

set scriptdir=%~dp0
call "%scriptdir%_init.bat" %platform% %build_type% %vs_version%
if %ERRORLEVEL% NEQ 0 goto :error

set curdir=%cd%
set dependencydir=%scriptdir%..\deps-build\
cd %dependencydir%

rd /S /Q %build_dir%\arrow
rd /S /Q %build_dir%\arrow_deps
rd /S /Q %build_dir%\boost
if defined GITHUB_ACTIONS (
    rd /S /Q C:\Temp\snowflake
    mkdir C:\Temp\snowflake
    echo "after create c:\Temp\snowflake"
    dir C:\
    dir D:\
    7z x %dependencydir%\arrow_%arcdir%_%vsdir%_%build_type%-%arrow_version%.zip -oarrowlibs
    move arrowlibs C:\Temp\snowflake
    echo "after move arrowlibs"
    dir C:\Temp
    dir C:\Temp\snowflake\arrowlibs\arrow
    dir C:\Temp\snowflake\arrowlibs\arrow\include
    cd %dependencydir%
    cd %build_dir%
    mkdir arrow arrow_deps boost
    mkdir arrow\lib arrow_deps\lib boost\lib
    xcopy ^
        "C:\Temp\snowflake\arrowlibs\arrow\include" ^
        "arrow\include\" ^
        /v /y /e

    mklink /h arrow\lib\arrow.lib C:\Temp\snowflake\arrowlibs\arrow\lib\arrow.lib
    FOR %%A IN ("C:\Temp\snowflake\arrowlibs\arrow_deps\lib\*") DO (
        MKLINK /h "arrow_deps\lib\%%~NXA" "%%~A"
    )
    FOR %%A IN ("C:\Temp\snowflake\arrowlibs\boost\lib\*") DO (
        MKLINK /h "boost\lib\%%~NXA" "%%~A"
    )
    del %dependencydir%\*.zip
    del %dependencydir%\*.gz
) else (
    7z x %dependencydir%\arrow_%arcdir%_%vsdir%_%build_type%-%arrow_version%.zip -o%build_dir%
)
goto :success

:success
cd "%curdir%"
exit /b 0

:error
cd "%curdir%"
exit /b 1
