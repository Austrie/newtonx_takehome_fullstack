#!/bin/bash

echo "Running NewtonX Backend Tests..."
echo ""

cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if dependencies are installed
if [ ! -f "venv/.dependencies_installed" ]; then
    echo "Installing dependencies..."
    pip install -r requirements.txt
    touch venv/.dependencies_installed
else
    echo "Dependencies already installed"
fi

# Check if database exists, if not create it
if [ ! -f "db.sqlite3" ]; then
    echo "Creating database..."
    python manage.py makemigrations
    python manage.py migrate
    echo ""
    echo "Database created successfully!"
else
    echo "Database already exists"
    # Run migrations in case there are new ones
    python manage.py migrate --no-input
fi

echo ""
echo "=========================================="
echo "Running Django Tests"
echo "=========================================="
echo ""

# Run tests
python manage.py test

# Capture exit code
TEST_EXIT_CODE=$?

echo ""
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ All backend tests passed!"
else
    echo "✗ Some backend tests failed"
fi

exit $TEST_EXIT_CODE
