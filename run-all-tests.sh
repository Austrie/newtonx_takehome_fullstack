#!/bin/bash

echo "=========================================="
echo "Running All NewtonX Tests"
echo "=========================================="
echo ""

# Check if --with-integration flag is passed
RUN_INTEGRATION=0
if [[ "$1" == "--with-integration" ]]; then
    RUN_INTEGRATION=1
fi

# Track overall success
BACKEND_FAILED=0
FRONTEND_FAILED=0
INTEGRATION_FAILED=0

# Run backend tests
echo "1. Backend Unit Tests"
echo "=========================================="
./run-backend-tests.sh
if [ $? -ne 0 ]; then
    BACKEND_FAILED=1
fi

echo ""
echo ""

# Run frontend tests
echo "2. Frontend Unit Tests"
echo "=========================================="
./run-frontend-tests.sh
if [ $? -ne 0 ]; then
    FRONTEND_FAILED=1
fi

echo ""
echo ""

# Run integration tests if requested
if [ $RUN_INTEGRATION -eq 1 ]; then
    echo "3. API Integration Tests"
    echo "=========================================="
    ./run-integration-tests.sh
    if [ $? -ne 0 ]; then
        INTEGRATION_FAILED=1
    fi
    echo ""
    echo ""
fi

echo "=========================================="
echo "Test Summary"
echo "=========================================="

if [ $BACKEND_FAILED -eq 0 ]; then
    echo "✓ Backend unit tests: PASSED"
else
    echo "✗ Backend unit tests: FAILED"
fi

if [ $FRONTEND_FAILED -eq 0 ]; then
    echo "✓ Frontend unit tests: PASSED"
else
    echo "✗ Frontend unit tests: FAILED"
fi

if [ $RUN_INTEGRATION -eq 1 ]; then
    if [ $INTEGRATION_FAILED -eq 0 ]; then
        echo "✓ Integration tests: PASSED"
    else
        echo "✗ Integration tests: FAILED"
    fi
fi

echo ""

# Exit with failure if any test suite failed
if [ $BACKEND_FAILED -ne 0 ] || [ $FRONTEND_FAILED -ne 0 ] || [ $INTEGRATION_FAILED -ne 0 ]; then
    echo "✗ Some tests failed"
    exit 1
else
    echo "✓ All tests passed!"
    exit 0
fi
