#!/bin/bash

echo "=========================================="
echo "NewtonX Integration Tests"
echo "=========================================="
echo ""

# Check if backend is running
echo "Checking if backend is running on http://localhost:8000..."
BACKEND_RUNNING=0
if curl -s -f http://localhost:8000/api/professionals/ > /dev/null 2>&1; then
    BACKEND_RUNNING=1
    echo "✓ Backend is running"
else
    echo "❌ Backend is not running!"
fi

# Check if frontend is running
echo "Checking if frontend is running on http://localhost:5173..."
FRONTEND_RUNNING=0
if curl -s -f http://localhost:5173 > /dev/null 2>&1; then
    FRONTEND_RUNNING=1
    echo "✓ Frontend is running"
else
    echo "❌ Frontend is not running!"
fi

echo ""

# Exit if either is not running
if [ $BACKEND_RUNNING -eq 0 ] || [ $FRONTEND_RUNNING -eq 0 ]; then
    echo "Please start the required servers:"
    if [ $BACKEND_RUNNING -eq 0 ]; then
        echo "  Terminal 1: ./start-backend.sh"
    fi
    if [ $FRONTEND_RUNNING -eq 0 ]; then
        echo "  Terminal 2: ./start-frontend.sh"
    fi
    echo ""
    echo "Then run this script again."
    exit 1
fi

echo "All servers are running. Proceeding with tests..."
echo ""

# Navigate to manual_tests directory
cd manual_tests

# Make scripts executable if they aren't already
chmod +x automated_test.sh 2>/dev/null
chmod +x clear_database.sh 2>/dev/null

echo "=========================================="
echo "Step 1: Clearing database for clean test"
echo "=========================================="
echo ""

# Clear database silently (auto-confirm)
cd ..
rm -f backend/db.sqlite3
cd backend
if [ -d "venv" ]; then
    source venv/bin/activate
    python manage.py migrate --no-input > /dev/null 2>&1
    echo "✓ Database cleared and reset"
else
    echo "❌ Virtual environment not found"
    exit 1
fi
cd ..

echo ""
echo "=========================================="
echo "Step 2: Running API integration tests"
echo "=========================================="
echo ""

# Run the automated test script
cd manual_tests
./automated_test.sh

# Capture exit code
TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ All integration tests passed!"
else
    echo "✗ Some integration tests failed"
fi

exit $TEST_EXIT_CODE
