#!/bin/bash

# Clear Database Script - Remove all data and reset

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Clear NewtonX Database"
echo "======================================"
echo ""

echo -e "${YELLOW}WARNING: This will delete ALL professionals from the database!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

echo ""
echo -e "${RED}Clearing database...${NC}"
echo ""

# Navigate to backend directory
cd "$(dirname "$0")/../backend" || exit 1

# Check if virtual environment exists and activate it
if [ -d "venv" ]; then
    source venv/bin/activate
else
    echo "Virtual environment not found. Please run setup first."
    exit 1
fi

# Delete the database file
if [ -f "db.sqlite3" ]; then
    rm db.sqlite3
    echo "Database file deleted."
else
    echo "Database file not found."
fi

# Recreate the database with fresh migrations
echo ""
echo "Recreating database..."
python manage.py makemigrations
python manage.py migrate

echo ""
echo -e "${GREEN}Database cleared and recreated successfully!${NC}"
echo ""
echo "The database is now empty and ready for fresh data."
echo ""
echo "To seed with sample data, run:"
echo "  ./manual_tests/seed_database.sh"
