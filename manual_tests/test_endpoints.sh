#!/bin/bash

# Manual API Testing Script for NewtonX Professionals API
# Tests all endpoints with various scenarios

BASE_URL="http://localhost:8000/api"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "======================================"
echo "NewtonX API Manual Test Suite"
echo "======================================"
echo ""
echo "Base URL: $BASE_URL"
echo ""

# Test 1: GET /api/professionals/ (empty)
echo -e "${BLUE}[TEST 1]${NC} GET /api/professionals/ - Empty list"
curl -s -X GET "$BASE_URL/professionals/" | json_pp
echo ""
echo "---"
echo ""

# Test 2: POST /api/professionals/ - Create professional (direct)
echo -e "${BLUE}[TEST 2]${NC} POST /api/professionals/ - Create professional (direct source)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Smith",
    "email": "jane.smith@example.com",
    "phone": "+1 555-123-4567",
    "company_name": "Tech Corp",
    "job_title": "Senior Engineer",
    "source": "direct"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 3: POST /api/professionals/ - Create professional (partner)
echo -e "${BLUE}[TEST 3]${NC} POST /api/professionals/ - Create professional (partner source)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "email": "john.doe@partner.com",
    "company_name": "Partner Solutions Inc",
    "job_title": "VP of Sales",
    "source": "partner"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 4: POST /api/professionals/ - Create professional (internal)
echo -e "${BLUE}[TEST 4]${NC} POST /api/professionals/ - Create professional (internal source)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Alice Johnson",
    "phone": "+1 555-999-8888",
    "company_name": "Internal Team",
    "job_title": "Product Manager",
    "source": "internal"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 5: GET /api/professionals/ (with data)
echo -e "${BLUE}[TEST 5]${NC} GET /api/professionals/ - List all professionals"
curl -s -X GET "$BASE_URL/professionals/" | json_pp
echo ""
echo "---"
echo ""

# Test 6: GET /api/professionals/?source=direct
echo -e "${BLUE}[TEST 6]${NC} GET /api/professionals/?source=direct - Filter by source"
curl -s -X GET "$BASE_URL/professionals/?source=direct" | json_pp
echo ""
echo "---"
echo ""

# Test 7: GET /api/professionals/?source=partner
echo -e "${BLUE}[TEST 7]${NC} GET /api/professionals/?source=partner - Filter by source"
curl -s -X GET "$BASE_URL/professionals/?source=partner" | json_pp
echo ""
echo "---"
echo ""

# Test 8: GET /api/professionals/?source=internal
echo -e "${BLUE}[TEST 8]${NC} GET /api/professionals/?source=internal - Filter by source"
curl -s -X GET "$BASE_URL/professionals/?source=internal" | json_pp
echo ""
echo "---"
echo ""

# Test 9: POST /api/professionals/bulk - Bulk upsert
echo -e "${BLUE}[TEST 9]${NC} POST /api/professionals/bulk - Bulk upsert (3 records)"
curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Bob Wilson",
      "email": "bob.wilson@startup.com",
      "phone": "+1 555-111-2222",
      "company_name": "Startup XYZ",
      "job_title": "CTO",
      "source": "direct"
    },
    {
      "full_name": "Carol Martinez",
      "email": "carol.m@consulting.com",
      "company_name": "Consulting Group",
      "job_title": "Principal Consultant",
      "source": "partner"
    },
    {
      "full_name": "David Chen",
      "phone": "+1 555-333-4444",
      "company_name": "Innovation Labs",
      "job_title": "Research Lead",
      "source": "internal"
    }
  ]' | json_pp
echo ""
echo "---"
echo ""

# Test 10: POST /api/professionals/bulk - Update existing (upsert)
echo -e "${BLUE}[TEST 10]${NC} POST /api/professionals/bulk - Upsert (update existing by email)"
curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Jane Smith",
      "email": "jane.smith@example.com",
      "phone": "+1 555-123-4567",
      "company_name": "Tech Corp (Updated)",
      "job_title": "Lead Engineer",
      "source": "direct"
    }
  ]' | json_pp
echo ""
echo "---"
echo ""

# Test 11: POST /api/professionals/ - Validation error (no email or phone)
echo -e "${BLUE}[TEST 11]${NC} POST /api/professionals/ - Validation error (missing email and phone)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Invalid User",
    "source": "direct"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 12: POST /api/professionals/ - Validation error (invalid source)
echo -e "${BLUE}[TEST 12]${NC} POST /api/professionals/ - Validation error (invalid source)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "source": "invalid_source"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 13: POST /api/professionals/ - Duplicate email error
echo -e "${BLUE}[TEST 13]${NC} POST /api/professionals/ - Duplicate email error"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Duplicate User",
    "email": "jane.smith@example.com",
    "source": "direct"
  }' | json_pp
echo ""
echo "---"
echo ""

# Test 14: GET /api/professionals/ - Final state
echo -e "${BLUE}[TEST 14]${NC} GET /api/professionals/ - Final list of all professionals"
curl -s -X GET "$BASE_URL/professionals/" | json_pp
echo ""
echo "---"
echo ""

echo -e "${GREEN}All tests completed!${NC}"
echo ""
echo "Summary:"
echo "- Created professionals via POST"
echo "- Listed professionals via GET"
echo "- Filtered by source (direct, partner, internal)"
echo "- Tested bulk upsert"
echo "- Tested validation errors"
echo "- Tested duplicate email handling"
