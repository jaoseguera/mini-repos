@echo off
:: ==============================================================================
:: Montreal Tech Job Market Analytics - Master ETL Pipeline Runner
:: ==============================================================================
setLOCAL EnableDelayedExpansion
title Montreal Tech Job Market ETL Pipeline

echo ==============================================================================
echo   MONTREAL TECH JOB MARKET ANALYTICS - ETL PIPELINE
echo ==============================================================================
echo   Starting ETL Pipeline Run...
echo   Timestamp: %date% %time%
echo ==============================================================================

:: 1. Verify Virtual Environment
if not exist "venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment 'venv' not found in current directory!
    echo Please make sure you are in the project root directory and venv is installed.
    pause
    exit /b 1
)

:: 2. Set environment variables to prevent encoding crashes with special chars
set PYTHONIOENCODING=utf-8

:: 3. Execute Extraction Script
echo.
echo [1/3] EXTRACTING LATEST JOB LISTINGS FROM API...
echo ------------------------------------------------------------------------------
"venv\Scripts\python.exe" scripts/extract_jobs.py
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] ETL failed at the EXTRACTION stage!
    goto :fail
)

:: 4. Execute Transformation & Cache Scraping
echo.
echo [2/3] TRANSFORMING DATA AND SCRAPING DETAILED DESCRIPTIONS...
echo ------------------------------------------------------------------------------
"venv\Scripts\python.exe" scripts/transform_jobs.py
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] ETL failed at the TRANSFORMATION stage!
    goto :fail
)

:: 5. Execute PostgreSQL Loading & Database Sync
echo.
echo [3/3] LOADING CLEAN DATA INTO POSTGRESQL DATA WAREHOUSE...
echo ------------------------------------------------------------------------------
"venv\Scripts\python.exe" scripts/load_jobs.py
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] ETL failed at the POSTGRESQL LOADING stage!
    goto :fail
)

:: Success Banner
echo.
echo ==============================================================================
echo   ETL PIPELINE RUN COMPLETED SUCCESSFULLY!
echo   All tables and new dimensions synchronized in PostgreSQL.
echo   Timestamp: %date% %time%
echo ==============================================================================
goto :end

:fail
echo ==============================================================================
echo   ETL PIPELINE RUN FAILED!
echo   Please check the error logs above to troubleshoot.
echo   Timestamp: %date% %time%
echo ==============================================================================
exit /b 1

:end
endlocal
exit /b 0
