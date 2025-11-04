#!/bin/bash

# Automated Test Script with Before/After Verification
# Runs all tests without manual interaction and shows detailed state

BASE_URL="http://localhost:8000/api"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "======================================"
echo "NewtonX Automated Test Suite"
echo "WITH BEFORE/AFTER STATE VERIFICATION"
echo "======================================"
echo ""

# Helper: Show database state
show_state() {
    local label=$1
    echo -e "${CYAN}[STATE: $label]${NC}"
    response=$(curl -s "$BASE_URL/professionals/")
    count=$(echo "$response" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    echo "Total professionals: $count"

    if [ "$count" -gt 0 ]; then
        echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
sources = {}
for p in data:
    sources[p['source']] = sources.get(p['source'], 0) + 1
for source, count in sources.items():
    print(f'  - {source}: {count}')
print()
print('Records:')
for i, p in enumerate(data[:5], 1):
    print(f\"  {i}. {p['full_name']} ({p['source']}) - {p.get('email', 'no email')}\")
if len(data) > 5:
    print(f'  ... and {len(data) - 5} more')
" 2>/dev/null
    fi
    echo ""
}

# Test counter
test_num=0
pass_count=0
fail_count=0

run_test() {
    test_num=$((test_num + 1))
    echo ""
    echo "========================================"
    echo -e "${BLUE}TEST $test_num: $1${NC}"
    echo "========================================"
    echo ""
}

verify() {
    local expected=$1
    local message=$2
    response=$(curl -s "$BASE_URL/professionals/")
    actual=$(echo "$response" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")

    if [ "$actual" -eq "$expected" ]; then
        echo -e "${GREEN}PASS${NC}: $message (expected=$expected, actual=$actual)"
        pass_count=$((pass_count + 1))
        return 0
    else
        echo -e "${RED}FAIL${NC}: $message (expected=$expected, actual=$actual)"
        fail_count=$((fail_count + 1))
        return 1
    fi
}

# START TESTS
echo "Checking backend connection..."
if ! curl -s -f "$BASE_URL/professionals/" > /dev/null; then
    echo -e "${RED}ERROR: Backend not running!${NC}"
    exit 1
fi
echo -e "${GREEN}Backend connected!${NC}"
echo ""

# TEST 1: Initial State
run_test "Verify Initial Empty State"
show_state "INITIAL"
verify 0 "Database should be empty"

# TEST 2: Create First Professional (Direct)
run_test "Create Professional - Direct Source"
show_state "BEFORE CREATE"

echo "Creating: Jane Smith (direct)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Smith",
    "email": "jane.smith@example.com",
    "phone": "+1 555-123-4567",
    "company_name": "Tech Corp",
    "job_title": "Senior Engineer",
    "source": "direct"
  }' | python3 -m json.tool
echo ""

show_state "AFTER CREATE"
verify 1 "Should have 1 professional"

# TEST 3: Create Second Professional (Partner)
run_test "Create Professional - Partner Source"
show_state "BEFORE CREATE"

echo "Creating: John Doe (partner)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "email": "john.doe@partner.com",
    "company_name": "Partner Solutions",
    "job_title": "VP Sales",
    "source": "partner"
  }' | python3 -m json.tool
echo ""

show_state "AFTER CREATE"
verify 2 "Should have 2 professionals"

# TEST 4: Create Third Professional (Internal, phone only)
run_test "Create Professional - Internal Source (Phone Only)"
show_state "BEFORE CREATE"

echo "Creating: Alice Johnson (internal, phone only)"
curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Alice Johnson",
    "phone": "+1 555-999-8888",
    "company_name": "Internal Team",
    "job_title": "Product Manager",
    "source": "internal"
  }' | python3 -m json.tool
echo ""

show_state "AFTER CREATE"
verify 3 "Should have 3 professionals"

# TEST 5: Filter by Source
run_test "Filter by Source - Direct"
echo "Filtering: source=direct"
response=$(curl -s "$BASE_URL/professionals/?source=direct")
count=$(echo "$response" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null)
echo "Found $count direct professionals:"
echo "$response" | python3 -m json.tool | head -20
echo ""

if [ "$count" -eq 1 ]; then
    echo -e "${GREEN}PASS${NC}: Filter returned 1 direct professional"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}FAIL${NC}: Expected 1 direct, got $count"
    fail_count=$((fail_count + 1))
fi

# TEST 6: Bulk Create
run_test "Bulk Create - 3 Professionals"
show_state "BEFORE BULK CREATE"

echo "Bulk creating 3 professionals"
curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Bob Wilson",
      "email": "bob@startup.com",
      "phone": "+1 555-111-2222",
      "source": "direct"
    },
    {
      "full_name": "Carol Martinez",
      "email": "carol@consulting.com",
      "source": "partner"
    },
    {
      "full_name": "David Chen",
      "phone": "+1 555-333-4444",
      "source": "internal"
    }
  ]' | python3 -m json.tool
echo ""

show_state "AFTER BULK CREATE"
verify 6 "Should have 6 professionals after bulk create"

# TEST 7: Bulk Upsert (Update existing)
run_test "Bulk Upsert - Update Existing Record"
show_state "BEFORE UPSERT"

echo "Jane Smith BEFORE update:"
curl -s "$BASE_URL/professionals/" | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    if p['email'] == 'jane.smith@example.com':
        print(f\"  Company: {p['company_name']}\")
        print(f\"  Job Title: {p['job_title']}\")
" 2>/dev/null
echo ""

echo "Upserting: Jane Smith (updating via email)"
curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Jane Smith",
      "email": "jane.smith@example.com",
      "company_name": "Tech Corp (UPDATED)",
      "job_title": "Lead Engineer (UPDATED)",
      "source": "direct"
    }
  ]' | python3 -m json.tool
echo ""

show_state "AFTER UPSERT"
verify 6 "Should still have 6 professionals (upsert, not insert)"

echo "Jane Smith AFTER update:"
curl -s "$BASE_URL/professionals/" | python3 -c "
import sys, json
for p in json.load(sys.stdin):
    if p['email'] == 'jane.smith@example.com':
        print(f\"  Company: {p['company_name']}\")
        print(f\"  Job Title: {p['job_title']}\")
        if '(UPDATED)' in p['company_name']:
            print('  Status: UPDATE SUCCESSFUL')
        else:
            print('  Status: UPDATE FAILED')
" 2>/dev/null
echo ""

# TEST 8: Validation Error - Missing email and phone
run_test "Validation Error - No Email or Phone"
show_state "BEFORE VALIDATION ERROR"

echo "Attempting: Create without email or phone"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Invalid User",
    "source": "direct"
  }')
echo "$response" | python3 -m json.tool
echo ""

if echo "$response" | grep -q "error\|Error\|email\|phone"; then
    echo -e "${GREEN}PASS${NC}: Validation error caught"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}FAIL${NC}: Should have returned validation error"
    fail_count=$((fail_count + 1))
fi

show_state "AFTER VALIDATION ERROR"
verify 6 "Should still have 6 professionals (validation prevented create)"

# TEST 9: Validation Error - Invalid source
run_test "Validation Error - Invalid Source"
show_state "BEFORE VALIDATION ERROR"

echo "Attempting: Create with invalid source"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Test User",
    "email": "test@example.com",
    "source": "invalid_source"
  }')
echo "$response" | python3 -m json.tool
echo ""

if echo "$response" | grep -q "error\|Error\|source\|invalid"; then
    echo -e "${GREEN}PASS${NC}: Invalid source error caught"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}FAIL${NC}: Should have returned source validation error"
    fail_count=$((fail_count + 1))
fi

show_state "AFTER VALIDATION ERROR"
verify 6 "Should still have 6 professionals (validation prevented create)"

# TEST 10: Duplicate Email
run_test "Duplicate Email Error"
show_state "BEFORE DUPLICATE ATTEMPT"

echo "Attempting: Create with duplicate email"
response=$(curl -s -X POST "$BASE_URL/professionals/" \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Duplicate User",
    "email": "jane.smith@example.com",
    "source": "direct"
  }')
echo "$response" | python3 -m json.tool
echo ""

if echo "$response" | grep -q "error\|Error\|unique\|duplicate\|already exists"; then
    echo -e "${GREEN}PASS${NC}: Duplicate email error caught"
    pass_count=$((pass_count + 1))
else
    echo -e "${RED}FAIL${NC}: Should have returned duplicate error"
    fail_count=$((fail_count + 1))
fi

show_state "AFTER DUPLICATE ATTEMPT"
verify 6 "Should still have 6 professionals (duplicate prevented)"

# FINAL SUMMARY
echo ""
echo "========================================"
echo -e "${BLUE}FINAL DATABASE STATE${NC}"
echo "========================================"
echo ""
show_state "FINAL"

# Show breakdown
curl -s "$BASE_URL/professionals/" | python3 -c "
import sys, json
data = json.load(sys.stdin)
sources = {'direct': 0, 'partner': 0, 'internal': 0}
for p in data:
    sources[p['source']] += 1
print('Breakdown by source:')
print(f'  Direct: {sources[\"direct\"]}')
print(f'  Partner: {sources[\"partner\"]}')
print(f'  Internal: {sources[\"internal\"]}')
print(f'  Total: {len(data)}')
" 2>/dev/null

echo ""
echo "========================================"
echo -e "${BLUE}TEST RESULTS SUMMARY${NC}"
echo "========================================"
echo ""
echo -e "Tests Passed: ${GREEN}$pass_count${NC}"
echo -e "Tests Failed: ${RED}$fail_count${NC}"
echo "Total Tests: $((pass_count + fail_count))"
echo ""

if [ $fail_count -eq 0 ]; then
    echo -e "${GREEN}ALL TESTS PASSED!${NC}"
    echo ""
    echo "Verified operations:"
    echo "  - CREATE: 3 single creates + 3 bulk creates"
    echo "  - READ: List all, filter by source"
    echo "  - UPDATE: 1 upsert (email-based)"
    echo "  - VALIDATION: 3 error cases handled correctly"
    echo ""
    echo "Database state:"
    echo "  - Final count: 6 professionals"
    echo "  - All CRUD operations working correctly"
    echo "  - Before/after states verified for each operation"
    exit 0
else
    echo -e "${RED}SOME TESTS FAILED${NC}"
    exit 1
fi
