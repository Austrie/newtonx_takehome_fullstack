# Quick Reference - Manual Testing

## One-Liners

### Seed Database (Populate with 25 professionals)
```bash
./manual_tests/seed_database.sh
```

### Clear Database (Empty state)
```bash
./manual_tests/clear_database.sh
# Type "yes" to confirm
```

### Test All Endpoints
```bash
./manual_tests/test_endpoints.sh
```

---

## Quick Commands

### List All Professionals
```bash
curl http://localhost:8000/api/professionals/ | json_pp
```

### Filter by Source
```bash
# Direct only
curl http://localhost:8000/api/professionals/?source=direct | json_pp

# Partner only
curl http://localhost:8000/api/professionals/?source=partner | json_pp

# Internal only
curl http://localhost:8000/api/professionals/?source=internal | json_pp
```

### Create Single Professional
```bash
curl -X POST http://localhost:8000/api/professionals/ \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Test User","email":"test@example.com","source":"direct"}'
```

### Bulk Create (3 professionals)
```bash
curl -X POST http://localhost:8000/api/professionals/bulk \
  -H "Content-Type: application/json" \
  -d '[
    {"full_name":"User 1","email":"user1@example.com","source":"direct"},
    {"full_name":"User 2","email":"user2@example.com","source":"partner"},
    {"full_name":"User 3","phone":"+1-555-0000","source":"internal"}
  ]'
```

---

## Demo Scenarios

### Scenario 1: Show Populated Frontend
```bash
./manual_tests/seed_database.sh
# Open http://localhost:5173/professionals
```

### Scenario 2: Show Empty State
```bash
./manual_tests/clear_database.sh  # Type "yes"
# Open http://localhost:5173/professionals
```

### Scenario 3: Show Filtering
```bash
# 1. Seed database first
./manual_tests/seed_database.sh

# 2. Open http://localhost:5173/professionals
# 3. Use the "Filter by source" dropdown
#    - Select "Direct" (11 results)
#    - Select "Partner" (9 results)
#    - Select "Internal" (5 results)
#    - Select "All" (25 results)
```

### Scenario 4: Show Form Validation
```bash
# Open http://localhost:5173/add
# Try to submit with:
#   - Empty name (error)
#   - Invalid email format (error)
#   - No email AND no phone (error)
#   - Missing source (error)
```

---

## Database Stats After Seeding

- Total: 25 professionals
- Direct: 11 (44%)
- Partner: 9 (36%)
- Internal: 5 (20%)

All records have:
- Full name
- Email
- Phone
- Company name
- Job title
- Source
- Timestamps
