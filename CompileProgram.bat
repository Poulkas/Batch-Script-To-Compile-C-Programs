@ECHO off
setlocal enableDelayedExpansion
SET ThisPath=%cd%\
SET OUTPUT_PATH=bin\Debug\
SET OBJECT_PATH=obj\Debug\

:::::::SELECT BUILT TYPE:::::::
ECHO For BUILT press Enter, for REBUILT type r
CALL SET /P "compileType=Type:" || SET compileType=BUILT

IF NOT EXIST FilesLogs.log type nul > FilesLogs.log
IF %compileType%==r type nul > FilesLogs.log

:::::::LOAD COMPILE OPTIONS:::::::
FOR /f %%I IN (CompilationFlags.options) DO CALL SET "COMPILE_FLAGS=!COMPILE_FLAGS!%%I "
FOR /f %%I IN (IncludeFiles.linker) DO CALL SET "INCLUDE_PATH=-I!INCLUDE_PATH!%%I "
FOR /f %%I IN (LinkerFiles.linker) DO CALL SET "LIB_PATH=-L!LIB_PATH!%%I "
FOR /f %%I IN (LinkerOptions.options) DO CALL SET "LINKER_OP=!LINKER_OP!%%I "

:::::::LOAD C AND C++ FILES AND VERIFY LAST MODIFICATED:::::::
SET /A iter=0
SET /A numberCompileFiles=0
FOR /R "%ThisPath%" %%I IN (*.c *.cpp) DO (
    CALL SET addFile=false
    CALL SET NEW_STRING=%%I
    CALL SET NEW_STRING=%%NEW_STRING:%ThisPath%=%%
    CALL SET ARRAY_FILES[!iter!]=!NEW_STRING!
    CALL SET fileFound=false
    FOR /F "tokens=1,2,3" %%A IN ('FINDSTR /C:"!NEW_STRING!" "FilesLogs.log"') DO (
        SET dateToCompare=%%B%%C
        CALL :compareDateModification !NEW_STRING! !dateToCompare!
        CALL SET fileFound=true
    )
    IF !fileFound!==false CALL SET addFile=true
    IF !addFile!==true (
        CALL SET FILES_TO_COMPILE[!numberCompileFiles!]=!NEW_STRING!
        CALL SET /A numberCompileFiles=!numberCompileFiles!+1
    )
    CALL SET /A iter=!iter!+1
)
SET /A iter=%iter%-1
SET /A numberCompileFiles=%numberCompileFiles%-1

:::::::MAKE OBJECT FILE PATH::::::
FOR /L %%I IN (0,1,%iter%) DO (
    CALL :SubStringPath !ARRAY_FILES[%%I]!
    CALL SET NEW_PATH=%OBJECT_PATH%!NEW_PATH!
    IF NOT EXIST !NEW_PATH! MD "!NEW_PATH!"
    SET NEW_PATH=""
)

IF %numberCompileFiles% GEQ 0 (
:::::::MAKE OBJECTS FILES:::::::
    FOR /L %%I IN (0, 1, %numberCompileFiles%) DO (
        CALL SET AUX_T=!FILES_TO_COMPILE[%%I]!
        CALL SET AUX=%%AUX_T:*.=%%
        CALL SET AUX_T=%%AUX_T:!AUX!=%%
        g++ %COMPILE_FLAGS% %INCLUDE_PATH% -c "%ThisPath%!ARRAY_FILES[%%I]!" -o "%OBJECT_PATH%!AUX_T!o"
    )
:::::::MAKE EXECUTABLE:::::::::
    FOR /R "%ThisPath%%OBJECT_PATH%" %%F IN (*.o) DO (
         CALL SET TEMP_STRING=%%F
         CALL SET AUX=%%TEMP_STRING:!ThisPath!=%%
         CALL SET TEMP_STRING=!AUX!
         CALL SET AUX=!OBJECT_PATHS!
         CALL SET "OBJECT_PATHS=!AUX! !TEMP_STRING!"
    )
    g++ %LIB_PATH% -o "%OUTPUT_PATH%main.exe" !OBJECT_PATHS! %LINKER_OP%
:::::::UPDATE FILE DATES:::::::
    type nul > FilesLogs.log
    FOR /L %%I IN (0,1,%iter%) DO CALL :writeLastModificated !ARRAY_FILES[%%I]!
) ELSE (
    ECHO The files are updated
)

ECHO Compile Completed
PAUSE

EXIT /B

:SubStringPath
setlocal
    SET NEW_STRING=%~1
    SET TEMP_PATH=
    SET PATH_T=%~1
    :WHILE_SubStringPath
        SET AUX=%NEW_STRING:*\=%
        SET NEW_TEMP=%NEW_STRING%
        IF NOT %AUX%==%NEW_TEMP% (
            SET NEW_STRING=!AUX!
            GOTO WHILE_SubStringPath
        ) ELSE (
            CALL SET TEMP_PATH=%%PATH_T:!AUX!=%%
        )
endlocal & SET NEW_PATH=%TEMP_PATH%
GOTO :EOF

:compareDateModification ::File Name, Date to Compare
setlocal
SET needsToUpdate=false
FOR /F "skip=5 tokens=1,2 delims= " %%X IN ('DIR /TW %~1') DO (
    CALL SET dateCompare=%%X%%Y
    IF NOT !dateCompare!==%~2 CALL SET needsToUpdate=true
    GOTO :END_COMPARE_DATE
)
:END_COMPARE_DATE
endlocal & SET addFile=%needsToUpdate%
GOTO :EOF

:writeLastModificated ::File Name
setlocal
FOR /F "skip=5 tokens=1,2 delims= " %%A IN ('DIR %~1') DO (
    @ECHO %~1 %%A %%B >> FilesLogs.log
    GOTO :END_WRITE_MODIFICATION
)
:END_WRITE_MODIFICATION
endlocal
GOTO :EOF
