# Setup Guide - NewtonX Professional Management System

##  Quick Setup (Recommended)

Anyone can clone this repo and start the project with **zero manual configuration**.

### Step 1: Clone the Repository
```bash
git clone <your-repo-url>
cd newtonx_takehome
```

### Step 2: Start Backend (Terminal 1)

**Mac/Linux:**
```bash
./start-backend.sh
```

**Windows:**
```cmd
start-backend.bat
```

You'll see:
```
 Starting NewtonX Backend...
 Creating virtual environment...
 Installing dependencies...
  Creating database...
 Database created successfully!
 Backend setup complete!
 Starting server at http://localhost:8000
```

### Step 3: Start Frontend (Terminal 2)

**Mac/Linux:**
```bash
./start-frontend.sh
```

**Windows:**
```cmd
start-frontend.bat
```

You'll see:
```
 Starting NewtonX Frontend...
 Installing dependencies...
 Frontend setup complete!
 Starting dev server at http://localhost:5173
```

### Step 4: Open Your Browser

Navigate to: **http://localhost:5173**

You're done! 

---

##  What the Scripts Do

### Backend Script (`start-backend.sh` / `.bat`)

1. **Creates Python virtual environment** (first run only)
   - Location: `backend/venv/`
   - Isolated from system Python

2. **Installs Python dependencies** (first run only)
   - Django 5.0.1
   - Django REST Framework 3.14.0
   - django-cors-headers 4.3.1
   - PyPDF2 3.0.1

3. **Creates SQLite database** (first run only)
   - Location: `backend/db.sqlite3`
   - Runs all migrations automatically
   - Creates `professionals_professional` table

4. **Starts Django development server**
   - Host: http://localhost:8000
   - API endpoints: http://localhost:8000/api/

### Frontend Script (`start-frontend.sh` / `.bat`)

1. **Installs Node.js dependencies** (first run only)
   - Uses pnpm if available, falls back to npm
   - Location: `frontend/newtonx_takehome/node_modules/`

2. **Starts Vite development server**
   - Host: http://localhost:5173
   - Hot module replacement enabled

---

##  Subsequent Runs

The scripts are smart! On subsequent runs:
- Skip virtual environment creation (already exists)
- Skip dependency installation (already installed)
- Skip database creation (already exists)
- Just start the servers immediately (~2 seconds)

Simply run the same commands:
```bash
./start-backend.sh   # Terminal 1
./start-frontend.sh  # Terminal 2
```

---

##  Database Details

### What Gets Created

The database is automatically created on first run at:
```
backend/db.sqlite3
```

### Schema

```sql
CREATE TABLE professionals_professional (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(254) UNIQUE,
    company_name VARCHAR(255),
    job_title VARCHAR(255),
    phone VARCHAR(50),
    source VARCHAR(20) NOT NULL,  -- 'direct', 'partner', or 'internal'
    resume VARCHAR(100),          -- File path to uploaded PDF
    created_at DATETIME NOT NULL,
    updated_at DATETIME NOT NULL
);
```

### Viewing the Database

**Option 1: Django Admin**
```bash
# In backend directory with venv activated
python manage.py createsuperuser

# Then visit: http://localhost:8000/admin/
```

**Option 2: SQLite Browser**
```bash
# Mac
brew install --cask db-browser-for-sqlite
open backend/db.sqlite3

# Windows
# Download from: https://sqlitebrowser.org/
```

**Option 3: Command Line**
```bash
sqlite3 backend/db.sqlite3
sqlite> .tables
sqlite> SELECT * FROM professionals_professional;
sqlite> .quit
```

---

##  Manual Setup (Optional)

If you prefer to run commands manually or need more control:

### Backend
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py makemigrations
python manage.py migrate
python manage.py runserver 8000
```

### Frontend
```bash
cd frontend/newtonx_takehome
pnpm install  # or: npm install
pnpm dev      # or: npm run dev
```

---

##  Troubleshooting

### Backend Issues

**"python3: command not found"**
- Install Python 3.8+ from https://python.org

**"No module named django"**
- Virtual environment not activated
- Run: `source venv/bin/activate` (Mac/Linux) or `venv\Scripts\activate` (Windows)

**Port 8000 already in use**
```bash
# Use different port
python manage.py runserver 8080

# Update frontend API URL in:
# frontend/newtonx_takehome/client/lib/api.ts
# Change: const API_BASE = "http://localhost:8080/api";
```

### Frontend Issues

**"pnpm: command not found"**
- The script will automatically use npm as fallback
- Or install pnpm: `npm install -g pnpm`

**"Cannot connect to backend"**
- Make sure backend is running on port 8000
- Check console for CORS errors
- Verify API_BASE in `client/lib/api.ts`

**Port 5173 already in use**
- Vite will automatically try 5174, 5175, etc.
- Or kill the existing process

### Database Issues

**"Database is locked"**
- Another process is accessing the database
- Stop all Django servers and try again

**Want to reset database**
```bash
cd backend
rm db.sqlite3
python manage.py migrate
```

---

##  What You'll See

### On First Run

**Backend Terminal:**
```
 Starting NewtonX Backend...
 Creating virtual environment...
 Activating virtual environment...
 Installing dependencies...
[pip installation output...]
  Creating database...
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, professionals, sessions
Running migrations:
  [Migration list...]
 Database created successfully!
 Backend setup complete!
 Starting server at http://localhost:8000

Django version 5.0.1, using settings 'newtonx_project.settings'
Starting development server at http://127.0.0.1:8000/
Quit the server with CONTROL-C.
```

**Frontend Terminal:**
```
 Starting NewtonX Frontend...
 Installing dependencies...
[pnpm/npm installation output...]
 Frontend setup complete!
 Starting dev server at http://localhost:5173

  VITE v7.1.2  ready in 1234 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

### On Subsequent Runs

**Backend:**
```
 Starting NewtonX Backend...
 Activating virtual environment...
 Dependencies already installed
 Database already exists
 Backend setup complete!
 Starting server at http://localhost:8000
```

**Frontend:**
```
 Starting NewtonX Frontend...
 Dependencies already installed
 Frontend setup complete!
 Starting dev server at http://localhost:5173
```

---

##  Summary

With the one-click setup scripts:
- No manual database setup needed
- No manual dependency installation
- No manual virtual environment creation
- Works on Mac, Linux, and Windows
- Idempotent (safe to run multiple times)
- Smart caching (only installs once)
- Clear status messages
- Automatic error checking

Just clone and run! 
