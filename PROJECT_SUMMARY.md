# NewtonX Take-Home Project Summary

## What Was Built

A full-stack professional management system with:
- **Django REST Framework backend** with 3 API endpoints
- **React + TypeScript frontend** with professional list and form
- **PDF resume upload** with basic text extraction
- **Bulk upsert functionality** with partial success handling
- **Source-based filtering** (direct, partner, internal)
- **One-click setup scripts** for Mac/Linux/Windows - no manual database setup needed!

## Project Structure

```
newtonx_takehome/
├── backend/                          # Django Backend
│   ├── newtonx_project/              # Django project settings
│   │   ├── settings.py               # Configuration (CORS, DB, etc.)
│   │   └── urls.py                   # Root URL routing
│   ├── professionals/                # Main Django app
│   │   ├── models.py                 # Professional model
│   │   ├── serializers.py            # DRF serializers + validation
│   │   ├── views.py                  # API views (list, create, bulk)
│   │   ├── urls.py                   # App URL routing
│   │   ├── admin.py                  # Django admin configuration
│   │   └── pdf_utils.py              # PDF text extraction utilities
│   ├── requirements.txt              # Python dependencies
│   ├── manage.py                     # Django CLI
│   └── setup.sh                      # Backend setup script
│
├── frontend/newtonx_takehome/        # React Frontend
│   ├── client/
│   │   ├── pages/
│   │   │   ├── Professionals.tsx     # Professional list page
│   │   │   ├── AddProfessional.tsx   # Add professional form
│   │   │   └── Index.tsx             # Home page
│   │   ├── components/ui/            # shadcn/ui components
│   │   ├── lib/
│   │   │   └── api.ts                # API client (typed)
│   │   └── App.tsx                   # React Router setup
│   ├── package.json                  # Dependencies
│   └── vite.config.ts                # Vite configuration
│
├── start-backend.sh / .bat           # One-click backend setup
├── start-frontend.sh / .bat          # One-click frontend setup
├── start.sh                          # Interactive startup script
├── README.md                         # Full documentation
├── QUICKSTART.md                     # Quick setup guide
├── SETUP_GUIDE.md                    # Detailed setup documentation
└── .gitignore                        # Git ignore rules
```

## Key Features Implemented

### Backend (Django)
- Professional model with all required fields
- POST `/api/professionals/` - Create professional
- GET `/api/professionals/` - List with optional source filter
- POST `/api/professionals/bulk` - Bulk upsert with partial success
- Email/phone uniqueness validation
- Resume (PDF) upload support with file validation
- Basic PDF text extraction utilities
- CORS configuration for frontend
- Django admin interface

### Frontend (React)
- Professional listing table with all fields
- Source filter dropdown (direct/partner/internal)
- Add professional form with validation (Zod + React Hook Form)
- PDF resume upload field
- API integration with TypeScript types
- Error handling and toast notifications
- Responsive design with TailwindCSS
- React Query for data fetching and caching

### Cleanup Completed
- Removed Express server code (`/server`, `/netlify`)
- Removed unnecessary dependencies (express, cors, serverless-http)
- Removed AGENTS.md and other AI-generated artifacts
- Removed `/shared` directory and server-related configs
- Updated package.json with correct scripts
- Updated API base URL to point to Django backend

## API Endpoints

### 1. List/Create Professionals
**GET** `/api/professionals/`
- Optional query param: `?source=direct|partner|internal`
- Returns: Array of professional objects

**POST** `/api/professionals/`
- Body: JSON or multipart/form-data (for file upload)
- Fields: full_name, email, phone, company_name, job_title, source, resume
- Validation: At least email OR phone required, unique email, valid source
- Returns: Created professional object

### 2. Bulk Upsert
**POST** `/api/professionals/bulk`
- Body: JSON array of professional objects
- Upserts using email as primary key, phone as fallback
- Returns: `{ success: [...], failed: [...] }`
- Handles partial success (some records succeed, others fail)

## Technologies Used

### Backend Stack
- Django 5.0.1
- Django REST Framework 3.14.0
- django-cors-headers 4.3.1
- PyPDF2 3.0.1 (PDF parsing)
- SQLite (database)

### Frontend Stack
- React 18.3.1
- TypeScript 5.9.2
- Vite 7.1.2 (build tool)
- TanStack Query 5.84.2 (data fetching)
- React Router 6.30.1
- React Hook Form 7.62.0 + Zod 3.25.76 (forms)
- TailwindCSS 3.4.17
- shadcn/ui (component library)

## How to Run

###  One-Click Setup (Recommended)

**Mac/Linux:**
```bash
./start-backend.sh   # Terminal 1
./start-frontend.sh  # Terminal 2
```

**Windows:**
```cmd
start-backend.bat   # Terminal 1
start-frontend.bat  # Terminal 2
```

The scripts automatically:
- Create virtual environment (if needed)
- Install dependencies (if needed)
- Create and migrate SQLite database (if needed)
- Start the development servers

**Database is automatically created at:** `backend/db.sqlite3`

### Manual Setup (Alternative)

**Backend:**
```bash
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 8000
```

**Frontend:**
```bash
cd frontend/newtonx_takehome
pnpm install  # or: npm install
pnpm dev      # or: npm run dev
```

---

**Access:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api/
- Django Admin: http://localhost:8000/admin/ (create superuser first)

## Design Decisions

### 1. Database Schema
- Used email as primary unique field (most common identifier)
- Made email and phone both optional but at least one required
- Added company_name and job_title as optional fields
- Included resume file field for PDF uploads
- Added source field with choices (direct, partner, internal)

### 2. Bulk Upsert Logic
- Email is primary unique key for upserts
- Falls back to phone if email not provided
- Returns both successful and failed records
- Uses Django transaction for data consistency

### 3. PDF Processing
- Implemented basic text extraction with PyPDF2
- Included detailed documentation on production approaches
- Validates file type (.pdf) and size (10MB max)
- Stores files in /media/resumes/ directory

### 4. Frontend Architecture
- Used existing UI component library (shadcn/ui)
- TypeScript for type safety across API calls
- React Query for caching and automatic refetching
- Form validation with Zod schemas
- Responsive design with TailwindCSS

### 5. CORS Configuration
- Set CORS_ALLOW_ALL_ORIGINS for development
- Production should restrict to specific origins

## What Could Be Improved

See full list in README.md, key items:

**Backend:**
- Add comprehensive test suite
- Implement async resume processing (Celery)
- Upgrade to LLM-based resume parsing
- Add API documentation (Swagger)
- Use PostgreSQL instead of SQLite
- Implement rate limiting

**Frontend:**
- Add unit/integration tests
- Implement pagination for large datasets
- Add CSV bulk upload
- Improve loading states
- Add search functionality

**DevOps:**
- Dockerize applications
- Add CI/CD pipeline
- Implement proper secrets management
- Add monitoring and logging

## Time Breakdown

Total: ~3 hours

1. **Backend Setup** (45 min)
   - Django project structure
   - Professional model
   - Database migrations

2. **API Implementation** (45 min)
   - Serializers with validation
   - List/Create view
   - Bulk upsert view
   - URL routing and CORS

3. **Frontend Cleanup & Integration** (30 min)
   - Remove Express/server code
   - Update API configuration
   - Clean package.json
   - Test integration

4. **PDF Processing** (30 min)
   - Basic PyPDF2 implementation
   - Utility functions
   - Documentation

5. **Documentation** (30 min)
   - README.md
   - QUICKSTART.md
   - RESUME_PROCESSING.md
   - Code comments

## Files Created/Modified

### New Files (Backend)
- backend/manage.py
- backend/requirements.txt
- backend/setup.sh
- backend/newtonx_project/{__init__,settings,urls,asgi,wsgi}.py
- backend/professionals/{__init__,models,views,serializers,urls,admin,pdf_utils,apps}.py
- backend/.gitignore
- backend/RESUME_PROCESSING.md

### New Files (Root)
- start-backend.sh / .bat (one-click backend setup)
- start-frontend.sh / .bat (one-click frontend setup)
- start.sh (interactive startup)
- README.md
- QUICKSTART.md
- SETUP_GUIDE.md
- PROJECT_SUMMARY.md
- .gitignore

### Modified Files (Frontend)
- frontend/newtonx_takehome/package.json (removed Express deps)
- frontend/newtonx_takehome/client/lib/api.ts (updated API_BASE)

### Deleted Files (Frontend)
- frontend/newtonx_takehome/server/ (entire directory)
- frontend/newtonx_takehome/netlify/ (entire directory)
- frontend/newtonx_takehome/shared/ (entire directory)
- frontend/newtonx_takehome/AGENTS.md
- frontend/newtonx_takehome/netlify.toml
- frontend/newtonx_takehome/vite.config.server.ts

## Testing Recommendations

### Backend Tests
```python
# tests/test_models.py
- Test Professional model creation
- Test unique constraints (email)
- Test validation (source choices)

# tests/test_serializers.py
- Test required field validation
- Test email/phone "at least one" validation
- Test PDF file validation

# tests/test_views.py
- Test professional list endpoint
- Test source filtering
- Test professional creation
- Test bulk upsert with partial success
```

### Frontend Tests
```typescript
// tests/Professionals.test.tsx
- Test professional list rendering
- Test source filter
- Test empty state

// tests/AddProfessional.test.tsx
- Test form validation
- Test form submission
- Test resume upload
```

## Production Checklist

Before deploying to production:

- [ ] Change Django SECRET_KEY
- [ ] Set DEBUG=False
- [ ] Configure ALLOWED_HOSTS
- [ ] Switch to PostgreSQL
- [ ] Set up proper CORS origins
- [ ] Add rate limiting
- [ ] Implement proper logging
- [ ] Set up error monitoring (Sentry)
- [ ] Configure static/media file serving
- [ ] Add SSL/HTTPS
- [ ] Set up database backups
- [ ] Add environment variable management
- [ ] Implement authentication if needed
- [ ] Add API documentation
- [ ] Set up CI/CD pipeline

## Contact & Questions

This project was completed as a take-home challenge for NewtonX.

For questions about implementation decisions or to discuss improvements, please reach out.
