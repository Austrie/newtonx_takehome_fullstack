#!/bin/bash

echo "Running NewtonX Frontend Tests..."
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
echo "=========================================="
echo "Running Frontend Tests"
echo "=========================================="
echo ""

# Run tests
if command -v pnpm &> /dev/null; then
    pnpm test
    TEST_EXIT_CODE=$?
else
    npm test
    TEST_EXIT_CODE=$?
fi

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ All frontend tests passed!"
else
    echo "✗ Some frontend tests failed"
fi

exit $TEST_EXIT_CODE
