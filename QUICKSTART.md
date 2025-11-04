# Quick Start Guide

## Prerequisites
- Python 3.8+
- Node.js 18+ (and npm or pnpm)

##  Get Started in 30 Seconds

### Option 1: One-Click Start (Recommended)

**Mac/Linux:**
```bash
# Terminal 1 - Backend
./start-backend.sh

# Terminal 2 - Frontend
./start-frontend.sh
```

**Windows:**
```cmd
# Terminal 1 - Backend
start-backend.bat

# Terminal 2 - Frontend
start-frontend.bat
```

 **Done!** The scripts handle everything:
- Virtual environment creation
- Dependency installation
- Database setup & migrations
- Server startup

### Option 2: Manual Setup

#### Backend (Terminal 1)
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8000
```

#### Frontend (Terminal 2)
```bash
cd frontend/newtonx_takehome
pnpm install  # or: npm install
pnpm dev      # or: npm run dev
```

---

Backend: **http://localhost:8000**
Frontend: **http://localhost:5173**

### 3. Test the Application

1. Open browser to http://localhost:5173
2. Click "Add Professional" to create a new professional
3. Fill out the form and submit
4. View the professional in the list
5. Use the source filter to filter by signup source

## API Testing

Test the API directly:

```bash
# List all professionals
curl http://localhost:8000/api/professionals/

# Create a professional
curl -X POST http://localhost:8000/api/professionals/ \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "email": "john@example.com",
    "phone": "+1 555 123 4567",
    "source": "direct"
  }'

# Filter by source
curl http://localhost:8000/api/professionals/?source=direct

# Bulk upsert
curl -X POST http://localhost:8000/api/professionals/bulk \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Alice Smith",
      "email": "alice@example.com",
      "source": "partner"
    },
    {
      "full_name": "Bob Johnson",
      "phone": "+1 555 999 8888",
      "source": "internal"
    }
  ]'
```

## Troubleshooting

### Backend Issues

**Error: "No module named django"**
```bash
# Make sure virtual environment is activated
source venv/bin/activate
pip install -r requirements.txt
```

**Error: Port 8000 already in use**
```bash
# Use a different port
python manage.py runserver 8080
# Update frontend API_BASE in frontend/newtonx_takehome/client/lib/api.ts
```

### Frontend Issues

**Error: "Command not found: pnpm"**
```bash
# Use npm instead
npm install
npm run dev
```

**Error: Connection refused**
- Make sure backend is running on port 8000
- Check that API_BASE in `client/lib/api.ts` points to `http://localhost:8000/api`

## Next Steps

- Check out the full [README.md](./README.md) for detailed documentation
- Access Django admin at http://localhost:8000/admin/ (create superuser first)
- Explore the API endpoints and features
