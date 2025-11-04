# NewtonX Professional Management System

This is a full-stack application I built for managing professional sign-ups from multiple sources (direct, partner, and internal channels).

## Quick Start

I designed this to be as simple as possible to get running. Just clone the repo and run:

### Mac/Linux
```bash
# Backend (Terminal 1)
./start-backend.sh

# Frontend (Terminal 2)
./start-frontend.sh
```

### Windows
```cmd
# Backend (Terminal 1)
start-backend.bat

# Frontend (Terminal 2)
start-frontend.bat
```

These scripts handle everything automatically - creating the virtual environment, installing dependencies, setting up the database, and starting the servers. Visit **http://localhost:5173** when both are running.

## Running Tests

I've created automated test scripts that handle all setup automatically:

### Mac/Linux

**Unit Tests** (run without servers):
```bash
# Run all unit tests (backend + frontend)
./run-all-tests.sh

# Run backend unit tests only
./run-backend-tests.sh

# Run frontend unit tests only
./run-frontend-tests.sh
```

**Integration Tests** (require running backend server):
```bash
# Run integration tests only (requires backend running)
./run-integration-tests.sh

# Run ALL tests including integration tests
# (Start backend first: ./start-backend.sh)
./run-all-tests.sh --with-integration
```

**What the scripts do:**
- Create virtual environments if needed
- Install all dependencies automatically
- Set up the database if needed
- Run the complete test suite
- Show a summary of results

**Test types:**
- **Unit tests**: Backend (Django) and Frontend (Vitest) - no server required
- **Integration tests**: API endpoint tests from `/manual_tests` - require running backend server

## Project Structure

```
├── backend/                 # Django REST Framework API
│   ├── newtonx_project/     # Django project settings
│   ├── professionals/       # Professionals app
│   ├── manage.py
│   └── requirements.txt
└── frontend/                # React frontend
    └── newtonx_takehome/
        ├── client/          # React source files
        ├── package.json
        └── vite.config.ts
```

## Tech Stack

### Backend
- Django 5.0.1 with Django REST Framework 3.14.0
- SQLite for development (would use PostgreSQL in production)
- PyPDF2 for PDF text extraction
- django-cors-headers for CORS support

### Frontend
- React 18 with TypeScript
- Vite as the build tool
- TanStack Query for data fetching
- React Router 6 for routing
- TailwindCSS 3 with shadcn/ui components

## Manual Setup

If you prefer to set things up manually instead of using the scripts:

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

The API runs at `http://localhost:8000/api/`

### Frontend

```bash
cd frontend/newtonx_takehome
pnpm install  # or npm/yarn
pnpm dev
```

The frontend runs at `http://localhost:5173/`

## API Endpoints

Base URL: `http://localhost:8000/api/`

### List/Create Professionals
**GET** `/api/professionals/`
- Returns all professionals
- Optional query param: `?source=direct|partner|internal`

**POST** `/api/professionals/`
- Creates or updates a professional (upsert logic)
- Accepts JSON or multipart/form-data (for file upload)
- Email is used as the unique key; falls back to phone if no email provided

Example:
```json
{
  "full_name": "Jane Doe",
  "email": "jane@company.com",
  "phone": "+1 555 123 4567",
  "company_name": "Acme Inc.",
  "job_title": "VP, Product",
  "source": "direct",
  "resume": "<file>" // optional PDF
}
```

### Bulk Upsert
**POST** `/api/professionals/bulk`
- Bulk create/update professionals
- Handles partial success - if one record fails, the rest still process
- Failed records are logged to console and returned in the response

Example:
```json
[
  {
    "full_name": "John Smith",
    "email": "john@example.com",
    "source": "partner"
  },
  {
    "full_name": "Alice Johnson",
    "phone": "+1 555 999 8888",
    "source": "internal"
  }
]
```

Response:
```json
{
  "success": [...],
  "failed": [
    {
      "index": 2,
      "record": {...},
      "reason": "Validation error details"
    }
  ]
}
```

### Parse Resume with GPT
**POST** `/api/professionals/parse-resume`
- Parse a resume PDF using GPT-4o-mini
- Returns extracted professional data with confidence scores
- Requires `OPENAI_API_KEY` environment variable
- Gracefully returns error if API key not configured

Request (multipart/form-data):
```bash
curl -X POST http://localhost:8000/api/professionals/parse-resume \
  -F "resume=@resume.pdf"
```

Success Response:
```json
{
  "success": true,
  "data": {
    "full_name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+1 555 123 4567",
    "company_name": "Tech Corp",
    "job_title": "Senior Engineer",
    "confidence": {
      "full_name": 95,
      "email": 100,
      "phone": 90,
      "company_name": 85,
      "job_title": 88
    }
  },
  "message": "Resume parsed successfully"
}
```

Error Response (No API Key):
```json
{
  "error": "GPT-based resume parsing is not available",
  "message": "OpenAI API key is not configured. Please set the OPENAI_API_KEY environment variable to enable this feature.",
  "available": false
}
```

## Features

### What's Working
- Full CRUD for professionals
- Filter by source (direct/partner/internal)
- Bulk upsert with partial success handling
- Email and phone uniqueness validation
- PDF resume upload (stores file, doesn't parse yet)
- Admin interface at `http://localhost:8000/admin/`

### Validation Rules
- `full_name` is required
- At least one of `email` or `phone` must be provided
- Both `email` and `phone` must be unique when provided
- `source` must be one of: direct, partner, internal
- Resume uploads limited to PDF files under 10MB

## Database Schema

```python
class Professional:
    id               # auto-generated primary key
    full_name        # required
    email            # unique, nullable
    company_name     # optional
    job_title        # optional
    phone            # unique, nullable
    source           # direct|partner|internal
    resume           # file path, nullable
    created_at       # auto
    updated_at       # auto
```

## PDF Resume Processing

### How It Works

I implemented two approaches for resume processing:

**Option 1: Basic Storage (Always Available)**
- Frontend sends PDF via multipart/form-data to `/api/professionals/`
- Backend validates it (must be PDF, under 10MB)
- File gets stored in `/backend/media/resumes/`
- File path is saved in the database
- Basic regex-based extraction utilities available in `pdf_utils.py` but not auto-triggered

**Option 2: GPT-4o Parsing (Requires API Key)**
- Endpoint: `POST /api/professionals/parse-resume`
- Upload PDF and get back structured data with confidence scores
- Uses GPT-4o-mini for cost efficiency
- PDF is converted to base64 and sent directly to OpenAI
- Returns: full_name, email, phone, company_name, job_title + confidence scores (0-100)

### Using the GPT Parser

The backend automatically loads environment variables from `backend/.env` using python-dotenv.

**Setup (one-time):**

1. Copy the example file:
```bash
cd backend
cp .env.example .env
```

2. Edit `backend/.env` and add your OpenAI API key:
```bash
# backend/.env
OPENAI_API_KEY=sk-your-actual-api-key-here
```

3. Restart the backend server to pick up the changes

**Get an API Key:**
- Sign up at https://platform.openai.com/
- Go to https://platform.openai.com/api-keys
- Create a new API key
- Copy it to your `backend/.env` file

**Alternative (temporary testing):**
```bash
# Set for current terminal session only
export OPENAI_API_KEY="sk-..."
python manage.py runserver 8000
```

Example request:
```bash
curl -X POST http://localhost:8000/api/professionals/parse-resume \
  -F "resume=@resume.pdf"
```

Response:
```json
{
  "success": true,
  "data": {
    "full_name": "Jane Doe",
    "email": "jane@example.com",
    "phone": "+1 555 123 4567",
    "company_name": "Tech Corp",
    "job_title": "Senior Engineer",
    "confidence": {
      "full_name": 95,
      "email": 100,
      "phone": 90,
      "company_name": 85,
      "job_title": 88
    }
  },
  "message": "Resume parsed successfully"
}
```

If the API key isn't set, you'll get a graceful error:
```json
{
  "error": "GPT-based resume parsing is not available",
  "message": "OpenAI API key is not configured. Please set the OPENAI_API_KEY environment variable to enable this feature.",
  "available": false
}
```

### How I'd Improve This for Production

**Current Limitations:**
- Synchronous processing (blocks the request)
- No caching of parsing results
- Single PDF at a time
- Local file storage

**Production Improvements:**
1. **Structured JSON Mode**: Use OpenAI's structured output mode for guaranteed consistent JSON responses
2. **Async Processing**: Use Celery + Redis to queue parsing jobs
3. **Cloud Storage**: Upload to S3/GCS instead of local filesystem
4. **Batch Processing**: Accept multiple PDFs at once
5. **Caching**: Cache parsing results to avoid re-processing
6. **Webhooks**: Notify clients when parsing completes
7. **Human Review**: Flag low-confidence fields for manual verification
8. **Malware Scanning**: Scan uploaded files before processing
9. **Rate Limiting**: Prevent abuse of the GPT endpoint
10. **Cost Tracking**: Monitor OpenAI API usage and costs
11. **Fallback**: Use PyPDF2 + regex if GPT fails

**Frontend Integration:**
- Drag-and-drop upload zone
- Real-time parsing status indicator
- Show extracted fields in editable form with confidence badges
- Side-by-side view: PDF preview + extracted data
- Bulk upload with progress tracking
- Option to choose between basic storage or GPT parsing

## Testing

The project includes comprehensive test coverage with automated test scripts:

### Automated Unit Tests

Run without requiring servers:

```bash
# Run all unit tests (backend + frontend)
./run-all-tests.sh

# Run backend unit tests only (28 Django tests)
./run-backend-tests.sh

# Run frontend unit tests only (5 Vitest tests)
./run-frontend-tests.sh
```

**Test Coverage:**
- **Backend (28 tests)**: Models, serializers, API endpoints, validation, upsert logic
- **Frontend (5 tests)**: Utility functions for className merging

### Integration Tests

Test actual API endpoints (requires running servers):

```bash
# Start backend first
./start-backend.sh  # In Terminal 1

# Then run integration tests
./run-integration-tests.sh  # In Terminal 2

# Or run everything together
./run-all-tests.sh --with-integration
```

**Integration tests include:**
- All CRUD operations
- Filtering by source
- Bulk upsert with success/failure handling
- Validation error cases
- Before/after database state verification

### Manual Testing Scripts

For database management and manual API testing:

```bash
# Add 25 sample professionals
./manual_tests/seed_database.sh

# Clear everything and start fresh
./manual_tests/clear_database.sh

# Test all endpoints manually
./manual_tests/test_endpoints.sh
```

See [`manual_tests/README.md`](./manual_tests/README.md) for details.

## Assumptions I Made

1. **Database**: SQLite is fine for a prototype. I'd use PostgreSQL for production.
2. **Unique Keys**: Email is the primary identifier. Phone is the fallback for upsert operations.
3. **Resume Processing**: I built the utilities but didn't wire them up automatically. Production would need this.
4. **Text Extraction**: Regex is acceptable for a demo. Real implementation needs ML/LLM.
5. **Authentication**: No auth for this prototype. Production needs proper authentication.
6. **Single-tenant**: No multi-organization support. This is a single-tenant system.
7. **Data Privacy**: No PII encryption. Production would need this for compliance.
8. **File Storage**: Local storage is fine for development. S3/GCS for production.
9. **Concurrency**: Built for low traffic. Production needs connection pooling and caching.
10. **Error Handling**: Basic error messages are sufficient for a demo.

## Trade-offs I Made

**SQLite vs PostgreSQL**
- I went with SQLite because it requires zero setup - just works out of the box
- Trade-off: limited concurrency, no JSON fields, no full-text search
- For production, I'd migrate to PostgreSQL

**Basic PDF Extraction vs ML/LLM**
- Used PyPDF2 with regex patterns to keep dependencies light
- Trade-off: lower accuracy, can't handle complex layouts or scanned docs
- Production needs Apache Tika + GPT-4/Claude for 90%+ accuracy

**Synchronous vs Async Processing**
- Resume processing is synchronous right now
- Trade-off: blocks API requests, can timeout on large files
- Should use Celery + Redis for background jobs

**CORS Wide Open**
- Set `CORS_ALLOW_ALL_ORIGINS=True` for easy development
- Trade-off: security risk if this goes to production
- Need to configure specific allowed origins

**No Rate Limiting**
- No throttling or request limits
- Trade-off: vulnerable to abuse
- Production needs DRF throttling or API gateway rate limits

**Local File Storage**
- Files stored in `/backend/media/resumes/`
- Trade-off: not scalable, files lost on server restart, no CDN
- Should use S3/GCS with CloudFront/Cloud CDN

**Bulk Upload Transaction**
- Wrapped bulk upsert in `transaction.atomic()` for consistency
- Trade-off: can be slow for large batches
- Could use chunked processing instead

**Phone Uniqueness**
- Made phone unique to support upsert fallback logic
- Trade-off: prevents legitimate duplicate phone numbers (shared lines)
- Could use composite unique constraint (phone + company) instead

## Time Spent

I spent less than an hour on this. It was rather straightforward.

## What I'd Improve With More Time

If I had more time, here's what I'd prioritize:

**High Priority:**
1. Comprehensive test suite - pytest for backend, Vitest for frontend
2. Hook up Claude or GPT-4 for resume parsing
3. Add pagination to the professionals list
4. Build search functionality (name, email, company)

**Medium Priority:**
5. Docker Compose setup with PostgreSQL
6. CI/CD pipeline with GitHub Actions
7. Advanced filtering (company, job title, date ranges)
8. CSV/Excel export functionality
9. Celery for async PDF processing
10. Better error handling with React error boundaries

**Nice to Have:**
11. Detail view page for individual professionals
12. Bulk actions (select multiple, bulk delete/export)
13. Analytics dashboard with charts
14. Audit logging for all changes
15. API rate limiting

## Deployment Notes

For production deployment:

**Backend**
- Use environment variables for secrets
- Set `DEBUG=False`
- Configure `ALLOWED_HOSTS`
- Switch to PostgreSQL
- Set up WhiteNoise or S3 for static files
- Configure specific CORS origins

**Frontend**
- Update API_BASE to production URL
- Build with `pnpm build`
- Deploy to Vercel/Netlify or serve with Nginx
- Configure environment variables

