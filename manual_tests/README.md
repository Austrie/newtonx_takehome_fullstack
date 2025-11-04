# Manual Testing Scripts

This directory contains scripts for manual API testing and database management.

## Prerequisites

- Backend server must be running on `http://localhost:8000`
- For macOS/Linux: `curl` and `json_pp` (should be pre-installed)
- For Windows: Git Bash or WSL recommended for shell scripts

## Scripts Overview

### 1. Test All Endpoints (`test_endpoints.sh`)

Comprehensive test suite that hits every API endpoint with various scenarios.

**What it tests:**
- GET `/api/professionals/` - List all (empty and populated)
- GET `/api/professionals/?source=<source>` - Filter by source
- POST `/api/professionals/` - Create single professional
- POST `/api/professionals/bulk` - Bulk create/upsert
- Validation errors (missing fields, invalid source, duplicate email)

**Usage:**
```bash
cd manual_tests
chmod +x test_endpoints.sh
./test_endpoints.sh
```

**Output:** JSON responses for each test with colored headers.

---

### 2. Seed Database (`seed_database.sh`)

Populates the database with 25 realistic sample professionals.

**Sample data includes:**
- 11 professionals from "direct" source
- 9 professionals from "partner" source
- 5 professionals from "internal" source
- Diverse job titles: CEO, CTO, VP, Director, Manager, etc.
- Various industries: Tech, Finance, Healthcare, Marketing, etc.

**Usage:**
```bash
cd manual_tests
chmod +x seed_database.sh
./seed_database.sh
```

**When to use:**
- Showcasing the frontend with populated data
- Testing filtering and list views
- Demonstrating the full application

---

### 3. Clear Database (`clear_database.sh` / `.bat`)

Completely wipes the database and recreates it fresh.

**What it does:**
1. Asks for confirmation (safety check)
2. Deletes `backend/db.sqlite3`
3. Recreates database with fresh migrations
4. Leaves database empty

**Usage (Mac/Linux):**
```bash
cd manual_tests
chmod +x clear_database.sh
./clear_database.sh
```

**Usage (Windows):**
```cmd
cd manual_tests
clear_database.bat
```

**When to use:**
- Showcasing the frontend in an empty state
- Starting fresh for a demo
- Testing the "no data" UI states

---

## Common Workflows

### Workflow 1: Demo with Full Database

```bash
# 1. Make sure backend is running
cd backend
source venv/bin/activate
python manage.py runserver 8000

# 2. In another terminal, seed the database
cd manual_tests
./seed_database.sh

# 3. Open frontend
# Visit http://localhost:5173/professionals
# You'll see 25 professionals with various sources
```

### Workflow 2: Demo with Empty State

```bash
# 1. Clear the database
cd manual_tests
./clear_database.sh
# Type "yes" to confirm

# 2. Open frontend
# Visit http://localhost:5173/professionals
# You'll see "No professionals yet" message
```

### Workflow 3: Full API Test Suite

```bash
# Run comprehensive tests
cd manual_tests
./test_endpoints.sh

# Review all outputs to verify API behavior
```

### Workflow 4: Custom Data Creation

Use curl commands directly to create specific professionals:

```bash
# Create a professional via API
curl -X POST http://localhost:8000/api/professionals/ \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Your Name",
    "email": "your.email@example.com",
    "phone": "+1 555-000-0000",
    "company_name": "Your Company",
    "job_title": "Your Title",
    "source": "direct"
  }'
```

---

## API Endpoint Reference

### List Professionals
```bash
# All professionals
curl http://localhost:8000/api/professionals/

# Filter by source
curl http://localhost:8000/api/professionals/?source=direct
curl http://localhost:8000/api/professionals/?source=partner
curl http://localhost:8000/api/professionals/?source=internal
```

### Create Professional
```bash
curl -X POST http://localhost:8000/api/professionals/ \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+1 555-123-4567",
    "company_name": "Acme Inc",
    "job_title": "CEO",
    "source": "direct"
  }'
```

### Bulk Upsert
```bash
curl -X POST http://localhost:8000/api/professionals/bulk \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Person 1",
      "email": "person1@example.com",
      "source": "direct"
    },
    {
      "full_name": "Person 2",
      "phone": "+1 555-999-8888",
      "source": "partner"
    }
  ]'
```

---

## Troubleshooting

### "Connection refused" errors
- Make sure backend server is running: `python manage.py runserver 8000`
- Check that you're in the backend directory with virtual environment activated

### "command not found: json_pp"
- On macOS/Linux: `json_pp` should be pre-installed with Perl
- Alternative: Remove `| json_pp` from curl commands to see raw JSON
- Or install `jq`: `brew install jq` and replace `json_pp` with `jq`

### Scripts not executable
```bash
chmod +x test_endpoints.sh
chmod +x seed_database.sh
chmod +x clear_database.sh
```

### Windows: Scripts don't run
- Use Git Bash or WSL to run `.sh` files
- Or use the `.bat` version for `clear_database.bat`

---

## Sample Professional Data

The seed script creates professionals with these characteristics:

**Direct Source (11 professionals)**
- Tech industry roles (VP Engineering, CTO, Product Manager)
- Startup founders
- Various technical leadership positions

**Partner Source (9 professionals)**
- Consulting firms
- Investment/Venture Capital
- Advisory services
- External partnerships

**Internal Source (5 professionals)**
- HR, Operations, Training
- Compliance, Research
- Internal company roles

All professionals have:
- Full name
- Email address
- Phone number
- Company name
- Job title
- Source designation
- Created timestamp

---

## Tips

1. **Always run `clear_database.sh` with "yes" confirmation** - It's destructive!
2. **Seed data is idempotent** - Running it multiple times updates existing records
3. **Filter testing** - Use the frontend dropdown to test source filtering
4. **Check admin panel** - Visit http://localhost:8000/admin/ to see all data
5. **JSON formatting** - Use `| json_pp` or `| jq` for readable output

---

## Adding Your Own Test Data

Edit `seed_database.sh` to add more professionals:

```bash
{
  "full_name": "Your Professional",
  "email": "email@example.com",
  "phone": "+1 555-000-0000",
  "company_name": "Company Name",
  "job_title": "Job Title",
  "source": "direct"
}
```

Make sure to:
- Use unique email addresses
- Include at least email OR phone
- Use valid source: "direct", "partner", or "internal"
