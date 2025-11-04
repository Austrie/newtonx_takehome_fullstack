#!/bin/bash

echo "Starting NewtonX Professional Management System..."
echo ""

# Check if required commands exist
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed. Please install Python 3.8+ first."
    exit 1
fi

if ! command -v pnpm &> /dev/null && ! command -v npm &> /dev/null; then
    echo "ERROR: Neither pnpm nor npm found. Please install Node.js first."
    exit 1
fi

# Make scripts executable
chmod +x start-backend.sh start-frontend.sh

echo "This will start both backend and frontend servers."
echo "Backend: http://localhost:8000"
echo "Frontend: http://localhost:5173"
echo ""
echo "Choose an option:"
echo "  1) Start both (in separate terminal tabs/windows)"
echo "  2) Start backend only"
echo "  3) Start frontend only"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "Starting both servers..."
        echo ""
        echo "IMPORTANT: You need to run these in separate terminals:"
        echo ""
        echo "   Terminal 1: ./start-backend.sh"
        echo "   Terminal 2: ./start-frontend.sh"
        echo ""
        echo "Or use this command to run both in background:"
        echo ""
        echo "   ./start-backend.sh > backend.log 2>&1 & ./start-frontend.sh"
        echo ""
        read -p "Press Enter to start backend in this terminal, or Ctrl+C to cancel..."
        ./start-backend.sh
        ;;
    2)
        ./start-backend.sh
        ;;
    3)
        ./start-frontend.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
