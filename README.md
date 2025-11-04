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

### How It Works Right Now

I built in basic PDF processing capabilities, though they're not automatically invoked yet. Here's the flow:

**File Upload**
- Frontend sends the PDF via multipart/form-data
- Backend validates it (must be PDF, under 10MB)
- File gets stored in `/backend/media/resumes/`
- File path is saved in the database

**Text Extraction** (available but not auto-triggered)
- I wrote utilities in `pdf_utils.py` using PyPDF2
- `extract_text_from_pdf()` pulls raw text from all pages
- `extract_professional_info()` uses regex to find email, phone, and name

Right now the PDF is just stored. To enable auto-parsing, I'd need to hook up the extraction utilities in the view's `perform_create()` method.

### How I'd Build This in Production

If I were building this for real, here's what I'd do:

**File Upload Pipeline:**
1. Client uploads PDF through the React form
2. POST to `/api/professionals/` with multipart/form-data
3. Validate file type and size, scan for malware
4. Upload to S3/GCS with a UUID filename
5. Store the cloud URL in the database
6. Trigger a background Celery job for parsing

**PDF Parsing Pipeline:**
1. Queue the parsing job (don't block the API request)
2. Use Apache Tika or AWS Textract for robust text extraction
3. Send the extracted text to GPT-4 or Claude with a prompt like:
   ```
   Extract these fields from this resume: full_name, email, phone, company_name, job_title
   ```
4. The LLM returns structured data with confidence scores
5. Auto-fill fields with >80% confidence
6. Flag low-confidence fields for human review
7. Notify the user when parsing completes

**Frontend Enhancements I'd Add:**
- Drag-and-drop upload zone
- Real-time upload progress bar
- PDF preview after upload
- Show extracted fields in editable form
- Highlight low-confidence fields
- Side-by-side view: PDF on left, extracted data on right
- Bulk resume upload with batch processing
- Download/replace/delete resume options

The basic implementation uses PyPDF2 + regex which is fine for a prototype, but production would need either ML models (spaCy NER) or LLM-based extraction for 90%+ accuracy. Apache Tika handles complex PDFs better, and Tesseract OCR is needed for scanned documents.

## Testing

I wrote some manual testing scripts to make it easy to populate and clear the database:

```bash
# Add 25 sample professionals
./manual_tests/seed_database.sh

# Clear everything and start fresh
./manual_tests/clear_database.sh

# Test all endpoints
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

