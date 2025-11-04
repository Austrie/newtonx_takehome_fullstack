@echo off
echo Starting NewtonX Frontend...
echo.

cd frontend\newtonx_takehome

REM Check if node_modules exists
if not exist "node_modules" (
    echo Installing dependencies...

    REM Try pnpm first, fallback to npm
    where pnpm >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo Using pnpm...
        pnpm install
    ) else (
        where npm >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo Using npm...
            npm install
        ) else (
            echo Error: Neither pnpm nor npm found. Please install Node.js first.
            pause
            exit /b 1
        )
    )
) else (
    echo Dependencies already installed
)

echo.
echo Frontend setup complete!
echo Starting dev server at http://localhost:5173
echo.
echo Press Ctrl+C to stop the server
echo.

REM Start the dev server
where pnpm >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    pnpm dev
) else (
    npm run dev
)
