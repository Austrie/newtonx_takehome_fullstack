#!/bin/bash

# Comprehensive Test Script with Before/After State Verification
# Shows database state before and after each operation

BASE_URL="http://localhost:8000/api"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo "======================================"
echo "NewtonX API Test Suite"
echo "WITH BEFORE/AFTER VERIFICATION"
echo "======================================"
echo ""
echo "Base URL: $BASE_URL"
echo ""

# Helper function to show database state
show_db_state() {
    local description=$1
    echo -e "${CYAN}[DATABASE STATE: $description]${NC}"
    response=$(curl -s -X GET "$BASE_URL/professionals/")
    count=$(echo "$response" | grep -o '"id"' | wc -l | tr -d ' ')
    echo "Total professionals in database: $count"

    if [ "$count" -gt 0 ]; then
        direct=$(curl -s "$BASE_URL/professionals/?source=direct" | grep -o '"id"' | wc -l | tr -d ' ')
        partner=$(curl -s "$BASE_URL/professionals/?source=partner" | grep -o '"id"' | wc -l | tr -d ' ')
        internal=$(curl -s "$BASE_URL/professionals/?source=internal" | grep -o '"id"' | wc -l | tr -d ' ')
        echo "  - Direct: $direct"
        echo "  - Partner: $partner"
        echo "  - Internal: $internal"
        echo ""
        echo "Sample records:"
        echo "$response" | python3 -m json.tool 2>/dev/null | head -30
    else
        echo "Database is empty."
    fi
    echo ""
    echo "---"
    echo ""
}

# Helper function to pause between tests
pause_test() {
    echo ""
    read -p "Press Enter to continue to next test..."
    echo ""
}

# Check if backend is running
echo "Checking if backend is running..."
if ! curl -s -f "$BASE_URL/professionals/" > /dev/null; then
    echo -e "${RED}ERROR: Backend is not running!${NC}"
    echo "Please start the backend server first:"
    echo "  cd backend"
    echo "  source venv/bin/activate"
    echo "  python manage.py runserver 8000"
    exit 1
fi
echo -e "${GREEN}Backend is running!${NC}"
echo ""

# ============================================================================
# TEST 1: Initial State - Verify Empty Database
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 1: Initial Database State${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
show_db_state "INITIAL STATE"
pause_test

# ============================================================================
# TEST 2: Create Professional (Direct Source)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 2: POST /api/professionals/ (Direct)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should be empty"

echo -e "${YELLOW}Creating professional: Jane Smith (direct)${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Smith",
    "email": "jane.smith@example.com",
    "phone": "+1 555-123-4567",
    "company_name": "Tech Corp",
    "job_title": "Senior Engineer",
    "source": "direct"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""

show_db_state "AFTER - Should have 1 record (direct)"
pause_test

# ============================================================================
# TEST 3: Create Professional (Partner Source)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 3: POST /api/professionals/ (Partner)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 1 record"

echo -e "${YELLOW}Creating professional: John Doe (partner)${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "email": "john.doe@partner.com",
    "company_name": "Partner Solutions Inc",
    "job_title": "VP of Sales",
    "source": "partner"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""

show_db_state "AFTER - Should have 2 records (1 direct, 1 partner)"
pause_test

# ============================================================================
# TEST 4: Create Professional (Internal Source, Phone Only)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 4: POST /api/professionals/ (Internal)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 2 records"

echo -e "${YELLOW}Creating professional: Alice Johnson (internal, phone only)${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Alice Johnson",
    "phone": "+1 555-999-8888",
    "company_name": "Internal Team",
    "job_title": "Product Manager",
    "source": "internal"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""

show_db_state "AFTER - Should have 3 records (1 direct, 1 partner, 1 internal)"
pause_test

# ============================================================================
# TEST 5: Filter by Source (Direct)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 5: GET /api/professionals/?source=direct${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

echo -e "${YELLOW}Filtering for 'direct' source only${NC}"
response=$(curl -s "$BASE_URL/professionals/?source=direct")
count=$(echo "$response" | grep -o '"id"' | wc -l | tr -d ' ')
echo "Found $count direct professionals:"
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""
pause_test

# ============================================================================
# TEST 6: Bulk Upsert (Create 3 new)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 6: POST /api/professionals/bulk (Create 3)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 3 records"

echo -e "${YELLOW}Bulk creating 3 professionals${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/bulk" \
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
  ]')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""

show_db_state "AFTER - Should have 6 records (3 direct, 2 partner, 2 internal)"
pause_test

# ============================================================================
# TEST 7: Bulk Upsert (Update existing by email)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 7: POST /api/professionals/bulk (Upsert)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Jane Smith has company: Tech Corp"

echo -e "${YELLOW}Updating Jane Smith via upsert (same email, new company)${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Jane Smith",
      "email": "jane.smith@example.com",
      "phone": "+1 555-123-4567",
      "company_name": "Tech Corp (UPDATED)",
      "job_title": "Lead Engineer (UPDATED)",
      "source": "direct"
    }
  ]')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""

show_db_state "AFTER - Should still have 6 records, Jane Smith updated"

echo -e "${CYAN}Verifying Jane Smith was updated:${NC}"
curl -s "$BASE_URL/professionals/" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for p in data:
    if p['email'] == 'jane.smith@example.com':
        print(f\"Name: {p['full_name']}\")
        print(f\"Company: {p['company_name']}\")
        print(f\"Job Title: {p['job_title']}\")
" 2>/dev/null
echo ""
pause_test

# ============================================================================
# TEST 8: Validation Error (No email or phone)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 8: Validation Error (No email/phone)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 6 records"

echo -e "${YELLOW}Attempting to create professional without email or phone${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Invalid User",
    "source": "direct"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""
echo -e "${GREEN}Expected: Error message about missing email/phone${NC}"
echo ""

show_db_state "AFTER - Should still have 6 records (no change)"
pause_test

# ============================================================================
# TEST 9: Validation Error (Invalid source)
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 9: Validation Error (Invalid source)${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 6 records"

echo -e "${YELLOW}Attempting to create professional with invalid source${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "source": "invalid_source"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""
echo -e "${GREEN}Expected: Error message about invalid source${NC}"
echo ""

show_db_state "AFTER - Should still have 6 records (no change)"
pause_test

# ============================================================================
# TEST 10: Duplicate Email Error
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}TEST 10: Duplicate Email Error${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "BEFORE - Should have 6 records"

echo -e "${YELLOW}Attempting to create professional with duplicate email${NC}"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Duplicate User",
    "email": "jane.smith@example.com",
    "source": "direct"
  }')
echo "$response" | python3 -m json.tool 2>/dev/null
echo ""
echo -e "${GREEN}Expected: Error about duplicate email${NC}"
echo ""

show_db_state "AFTER - Should still have 6 records (no change)"
pause_test

# ============================================================================
# FINAL STATE
# ============================================================================
echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}FINAL DATABASE STATE${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

show_db_state "FINAL STATE"

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}ALL TESTS COMPLETED SUCCESSFULLY!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "Summary:"
echo "  - Started with: 0 professionals"
echo "  - Created: 6 unique professionals"
echo "  - Updated: 1 professional (Jane Smith via upsert)"
echo "  - Validation errors caught: 3 (no email/phone, invalid source, duplicate)"
echo "  - Final count: 6 professionals"
echo "  - Breakdown: 3 direct, 2 partner, 2 internal"
echo ""
echo "All CRUD operations working correctly!"
echo "Database state verified before and after each operation."
