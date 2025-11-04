@echo off
REM Clear Database Script - Windows version

echo ======================================
echo Clear NewtonX Database
echo ======================================
echo.

echo WARNING: This will delete ALL professionals from the database!
echo.
set /p confirm="Are you sure you want to continue? (yes/no): "

if not "%confirm%"=="yes" (
    echo Operation cancelled.
    exit /b 0
)

echo.
echo Clearing database...
echo.

REM Navigate to backend directory
cd "%~dp0\..\backend"

REM Check if virtual environment exists and activate it
if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
) else (
    echo Virtual environment not found. Please run setup first.
    exit /b 1
)

REM Delete the database file
if exist "db.sqlite3" (
    del db.sqlite3
    echo Database file deleted.
) else (
    echo Database file not found.
)

REM Recreate the database with fresh migrations
echo.
echo Recreating database...
python manage.py makemigrations
python manage.py migrate

echo.
echo Database cleared and recreated successfully!
echo.
echo The database is now empty and ready for fresh data.
echo.
echo To seed with sample data, run:
echo   bash manual_tests/seed_database.sh
pause
