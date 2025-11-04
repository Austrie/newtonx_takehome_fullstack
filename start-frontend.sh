#!/bin/bash

echo "Starting NewtonX Frontend..."
echo ""

cd frontend/newtonx_takehome

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."

    # Try pnpm first, fallback to npm
    if command -v pnpm &> /dev/null; then
        echo "Using pnpm..."
        pnpm install
    elif command -v npm &> /dev/null; then
        echo "Using npm..."
        npm install
    else
        echo "ERROR: Neither pnpm nor npm found. Please install Node.js first."
        exit 1
    fi
else
    echo "Dependencies already installed"
fi

echo ""
echo "Frontend setup complete!"
echo "Starting dev server at http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the dev server
if command -v pnpm &> /dev/null; then
    pnpm dev
else
    npm run dev
fi
