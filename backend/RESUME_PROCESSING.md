# PDF Resume Processing - Design & Implementation

## Overview

This document outlines the approach for handling PDF resume uploads in the Professional Management System.

## Current Implementation

### Basic PDF Text Extraction

Located in: `professionals/pdf_utils.py`

```python
# Three main functions:
1. extract_text_from_pdf(pdf_file) - Extracts raw text from PDF
2. extract_professional_info(pdf_text) - Extracts structured data using regex
3. process_resume_upload(pdf_file) - Complete pipeline
```

### How It Works

1. **File Upload**: User uploads PDF via multipart/form-data
2. **Validation**: Check file type (.pdf) and size (max 10MB)
3. **Storage**: File saved to `/media/resumes/` directory
4. **Text Extraction**: PyPDF2 extracts text from all pages
5. **Field Extraction**: Regex patterns identify email, phone, name

### Limitations

-  Can't handle scanned PDFs (no OCR)
-  Limited name detection (assumes first line)
-  Can't extract company name or job title reliably
-  No context understanding
-  Fails on complex layouts or multi-column resumes

## Production-Ready Approaches

### Approach 1: LLM-Based Extraction (Recommended)

**Best for**: Highest accuracy, handles various formats

```python
# Using OpenAI GPT-4 or Anthropic Claude
import openai

def extract_with_llm(pdf_text: str) -> dict:
    prompt = f"""
    Extract the following information from this resume:
    - Full Name
    - Email
    - Phone Number
    - Current Company
    - Current Job Title

    Resume text:
    {pdf_text}

    Return JSON format with these fields.
    """

    response = openai.ChatCompletion.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        response_format={"type": "json_object"}
    )

    return json.loads(response.choices[0].message.content)
```

**Pros**:
- High accuracy (~95%+)
- Handles various resume formats
- Understands context and synonyms
- Can extract complex information

**Cons**:
- Cost per API call ($0.01-0.03 per resume)
- Requires API key management
- Latency (2-5 seconds per resume)
- Needs proper prompt engineering

**Cost Estimate**: ~$10-30 per 1,000 resumes

### Approach 2: Cloud Document AI Services

**AWS Textract**:
```python
import boto3

textract = boto3.client('textract')

def extract_with_textract(pdf_bytes):
    response = textract.analyze_document(
        Document={'Bytes': pdf_bytes},
        FeatureTypes=['FORMS', 'TABLES']
    )
    # Post-process response to extract fields
    return parse_textract_response(response)
```

**Google Document AI**:
```python
from google.cloud import documentai_v1

def extract_with_documentai(pdf_bytes):
    client = documentai_v1.DocumentProcessorServiceClient()
    # Use pre-trained resume parser
    processor_name = "projects/.../processors/resume-parser"

    document = {"content": pdf_bytes, "mime_type": "application/pdf"}
    request = {"name": processor_name, "raw_document": document}

    result = client.process_document(request=request)
    return parse_documentai_response(result.document)
```

**Pros**:
- Very high accuracy
- Pre-trained on millions of documents
- Handles OCR for scanned PDFs
- Scalable infrastructure

**Cons**:
- Vendor lock-in
- Cost per page
- Requires cloud credentials
- More complex setup

**Cost Estimate**:
- AWS Textract: $1.50 per 1,000 pages
- Google Document AI: $1.00-3.00 per 1,000 pages

### Approach 3: Named Entity Recognition (NER)

**Using spaCy**:
```python
import spacy

nlp = spacy.load("en_core_web_lg")

def extract_with_ner(pdf_text: str) -> dict:
    doc = nlp(pdf_text)

    info = {
        'full_name': None,
        'company_name': None,
        'email': None,
        'phone': None
    }

    # Extract named entities
    for ent in doc.ents:
        if ent.label_ == "PERSON" and not info['full_name']:
            info['full_name'] = ent.text
        elif ent.label_ == "ORG":
            info['company_name'] = ent.text

    # Use regex for email/phone
    info['email'] = extract_email(pdf_text)
    info['phone'] = extract_phone(pdf_text)

    return info
```

**Pros**:
- No external API costs
- Fast processing (<1 second)
- Works offline
- Open source

**Cons**:
- Lower accuracy than LLM (~70-80%)
- Requires training for domain-specific fields
- May need custom entity types
- Still struggles with complex layouts

**Cost Estimate**: Free (open source)

### Approach 4: Specialized Resume Parsing APIs

**Commercial services**:
- Sovren
- DaXtra
- HireAbility
- RChilli

```python
# Example with Sovren
import requests

def extract_with_sovren(pdf_bytes):
    response = requests.post(
        "https://api.sovren.com/parse",
        headers={
            "Sovren-AccountId": "YOUR_ACCOUNT_ID",
            "Sovren-ServiceKey": "YOUR_SERVICE_KEY"
        },
        json={
            "DocumentAsBase64String": base64.b64encode(pdf_bytes).decode(),
            "OutputHtml": False
        }
    )

    data = response.json()
    return {
        'full_name': data['Value']['ResumeData']['ContactInformation']['CandidateName']['FormattedName'],
        'email': data['Value']['ResumeData']['ContactInformation']['EmailAddresses'][0],
        'phone': data['Value']['ResumeData']['ContactInformation']['Telephones'][0],
        # ... more fields
    }
```

**Pros**:
- Highest accuracy (90-95%)
- Purpose-built for resumes
- Extracts rich data (skills, education, etc.)
- Battle-tested at scale

**Cons**:
- Most expensive option
- Vendor lock-in
- Monthly minimums
- API integration complexity

**Cost Estimate**: $500-2,000/month base + per-parse fees

## Recommended Implementation

### For This Prototype

Keep the basic PyPDF2 implementation as a starting point. It demonstrates the concept without external dependencies.

### For MVP (First Version)

Use **LLM-based extraction (Approach 1)** with OpenAI GPT-4 or Anthropic Claude:

1. Cost-effective for moderate volume
2. High accuracy without training
3. Easy to implement
4. Can improve prompts iteratively

**Implementation Steps**:
```python
# 1. Add to requirements.txt
openai==1.12.0

# 2. Update views.py
from .pdf_utils import extract_text_from_pdf
from .llm_extraction import extract_with_llm

def perform_create(self, serializer):
    if 'resume' in self.request.FILES:
        pdf_file = self.request.FILES['resume']
        text = extract_text_from_pdf(pdf_file)
        extracted_data = extract_with_llm(text)

        # Merge with user-provided data (user data takes precedence)
        for field in ['full_name', 'email', 'phone', 'company_name', 'job_title']:
            if not serializer.validated_data.get(field) and extracted_data.get(field):
                serializer.validated_data[field] = extracted_data[field]

    serializer.save()
```

### For Production

Combine multiple approaches:

1. **Primary**: LLM extraction (high accuracy)
2. **Fallback**: Regex patterns (fast, no cost)
3. **Validation**: Confidence scoring
4. **Human-in-loop**: Show extracted data for confirmation

```python
def extract_professional_info_hybrid(pdf_file):
    # Step 1: Extract text
    text = extract_text_from_pdf(pdf_file)

    # Step 2: Try regex first (fast, free)
    basic_info = extract_with_regex(text)

    # Step 3: If critical fields missing, use LLM
    if not basic_info.get('full_name') or not basic_info.get('email'):
        llm_info = extract_with_llm(text)
        basic_info.update(llm_info)

    # Step 4: Calculate confidence scores
    confidence = calculate_confidence(basic_info)

    # Step 5: Return data with confidence
    return {
        'data': basic_info,
        'confidence': confidence,
        'needs_review': confidence < 0.8
    }
```

## User Experience Considerations

### Option 1: Automatic Extraction
- Extract data automatically
- Pre-fill form fields
- Let user review/edit before saving

**Pros**: Fastest UX, minimal clicks
**Cons**: User may not notice errors

### Option 2: Review Before Save (Recommended)
- Show extracted data in a review modal
- User confirms or edits each field
- Clear "Auto-extracted" indicators

**Pros**: Ensures accuracy, builds trust
**Cons**: Extra step

### Option 3: Background Processing
- Accept upload, save immediately
- Process asynchronously
- Update record when done
- Notify user of completion

**Pros**: No waiting, scalable
**Cons**: More complex, needs queue system

## Frontend Integration

```typescript
// In AddProfessional.tsx
const onSubmit = async (values: FormValues) => {
  if (values.resume) {
    // Show processing indicator
    setProcessing(true);

    try {
      // Upload with auto-extraction
      const result = await ProfessionalsAPI.createWithExtraction(values);

      if (result.needs_review) {
        // Show review modal
        setExtractedData(result.extracted_data);
        setShowReviewModal(true);
      } else {
        // Success - redirect
        navigate('/professionals');
      }
    } catch (error) {
      toast.error("Extraction failed. Please fill manually.");
    } finally {
      setProcessing(false);
    }
  } else {
    // Standard submission without resume
    await ProfessionalsAPI.create(values);
  }
};
```

## Testing Strategy

1. **Unit Tests**: Test each extraction method independently
2. **Integration Tests**: Test end-to-end upload flow
3. **Sample Resumes**: Create test suite with various formats
4. **Accuracy Metrics**: Track extraction accuracy over time
5. **Error Handling**: Test invalid PDFs, corrupted files

## Monitoring & Analytics

Track in production:
- Extraction success rate
- Average confidence scores
- Processing time
- API costs
- User corrections (to improve prompts)

## Conclusion

Start with basic regex extraction for the prototype, plan to upgrade to LLM-based extraction (GPT-4/Claude) for MVP, and consider hybrid approaches for production scale.

The key is to balance accuracy, cost, and user experience based on your volume and budget constraints.
