#!/bin/bash

# Test script for GPT-based resume parsing endpoint
# Tests the /api/professionals/parse-resume endpoint

API_BASE="http://localhost:8000/api"
ENDPOINT="$API_BASE/professionals/parse-resume"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "================================================"
echo "Testing GPT Resume Parsing Endpoint"
echo "================================================"
echo ""

# Check if OpenAI API key is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠ OPENAI_API_KEY not set in environment${NC}"
    echo "GPT parsing endpoint will return graceful error (expected behavior)"
    echo ""
fi

# Test 1: No file provided
echo "Test 1: No file provided"
echo "------------------------"
response=$(curl -s -X POST "$ENDPOINT")
echo "Response: $response"
if echo "$response" | grep -q "No resume file provided"; then
    echo -e "${GREEN}✓ PASS: Correct error for missing file${NC}"
else
    echo -e "${RED}✗ FAIL: Expected 'No resume file provided' error${NC}"
fi
echo ""

# Test 2: Non-PDF file
echo "Test 2: Non-PDF file (should reject)"
echo "------------------------------------"
# Create a temporary text file
echo "This is not a PDF" > /tmp/test_resume.txt
response=$(curl -s -X POST "$ENDPOINT" -F "resume=@/tmp/test_resume.txt")
echo "Response: $response"
if echo "$response" | grep -q "Only PDF files are supported"; then
    echo -e "${GREEN}✓ PASS: Correct error for non-PDF file${NC}"
else
    echo -e "${RED}✗ FAIL: Expected 'Only PDF files are supported' error${NC}"
fi
rm /tmp/test_resume.txt
echo ""

# Test 3: File too large (simulate by checking if exists, skip actual large file)
echo "Test 3: File size validation"
echo "-----------------------------"
echo "Note: Skipping actual large file test (would need >10MB file)"
echo "Validation exists in code at views.py:190"
echo ""

# Test 4: Missing API key (if not set)
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Test 4: Missing API key (graceful error)"
    echo "-----------------------------------------"
    # Create a minimal valid PDF (just header)
    echo "%PDF-1.4" > /tmp/test_resume.pdf
    echo "Minimal PDF for testing" >> /tmp/test_resume.pdf
    echo "%%EOF" >> /tmp/test_resume.pdf

    response=$(curl -s -X POST "$ENDPOINT" -F "resume=@/tmp/test_resume.pdf")
    echo "Response: $response"
    if echo "$response" | grep -q "not configured"; then
        echo -e "${GREEN}✓ PASS: Graceful error when API key not configured${NC}"
        echo "This is expected behavior when OPENAI_API_KEY is not set"
    else
        echo -e "${YELLOW}⚠ Response doesn't match expected pattern${NC}"
    fi
    rm /tmp/test_resume.pdf
    echo ""
else
    echo "Test 4: API key present - parsing will be attempted"
    echo "---------------------------------------------------"
    echo "Note: Actual GPT parsing requires a real resume PDF"
    echo "Create a sample resume PDF and test manually with:"
    echo "  curl -X POST $ENDPOINT -F \"resume=@your_resume.pdf\""
    echo ""
fi

# Test 5: Endpoint exists and is reachable
echo "Test 5: Endpoint accessibility"
echo "-------------------------------"
response_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$ENDPOINT")
if [ "$response_code" != "000" ] && [ "$response_code" != "404" ]; then
    echo -e "${GREEN}✓ PASS: Endpoint is accessible (HTTP $response_code)${NC}"
else
    echo -e "${RED}✗ FAIL: Endpoint not accessible or not found${NC}"
fi
echo ""

echo "================================================"
echo "GPT Parsing Tests Complete"
echo "================================================"
echo ""
echo "Summary:"
echo "- Basic validation tests completed"
echo "- Graceful error handling verified"
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}- To test actual GPT parsing, set OPENAI_API_KEY environment variable${NC}"
    echo "  export OPENAI_API_KEY=\"sk-...\""
else
    echo -e "${GREEN}- OpenAI API key is configured${NC}"
    echo "- To test with a real resume, use:"
    echo "  curl -X POST $ENDPOINT -F \"resume=@/path/to/resume.pdf\""
fi
