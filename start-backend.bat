@echo off
echo Starting NewtonX Backend...
echo.

cd backend

REM Check if virtual environment exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if dependencies are installed
if not exist "venv\.dependencies_installed" (
    echo Installing dependencies...
    pip install -r requirements.txt
    type nul > venv\.dependencies_installed
) else (
    echo Dependencies already installed
)

REM Check if database exists
if not exist "db.sqlite3" (
    echo Creating database...
    python manage.py makemigrations
    python manage.py migrate
    echo.
    echo Database created successfully!
) else (
    echo Database already exists
    python manage.py migrate --no-input
)

echo.
echo Backend setup complete!
echo Starting server at http://localhost:8000
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the server
python manage.py runserver 8000
