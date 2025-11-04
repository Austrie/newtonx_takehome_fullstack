"""
Utility functions for PDF resume processing.

This module provides basic PDF text extraction capabilities.
For production use, consider more robust solutions like:
- Apache Tika for comprehensive document parsing
- AWS Textract or Google Document AI for ML-based extraction
- LLM APIs (OpenAI, Anthropic) for intelligent field extraction
"""

import PyPDF2
import re
from typing import Dict, Optional


def extract_text_from_pdf(pdf_file) -> str:
    """
    Extract text content from a PDF file.

    Args:
        pdf_file: A file object or file-like object containing PDF data

    Returns:
        str: Extracted text content from all pages
    """
    try:
        pdf_reader = PyPDF2.PdfReader(pdf_file)
        text = ""

        for page in pdf_reader.pages:
            text += page.extract_text() + "\n"

        return text.strip()
    except Exception as e:
        raise ValueError(f"Failed to extract text from PDF: {str(e)}")


def extract_professional_info(pdf_text: str) -> Dict[str, Optional[str]]:
    """
    Extract professional information from PDF text using heuristics.

    This is a basic implementation using regex patterns.
    For production, consider using:
    - Named Entity Recognition (NER) models
    - LLM-based extraction (GPT-4, Claude, etc.)
    - Specialized resume parsing APIs

    Args:
        pdf_text: Text extracted from resume PDF

    Returns:
        dict: Dictionary containing extracted fields
    """
    info = {
        'full_name': None,
        'email': None,
        'phone': None,
        'company_name': None,
        'job_title': None,
    }

    # Extract email using regex
    email_pattern = r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'
    email_match = re.search(email_pattern, pdf_text)
    if email_match:
        info['email'] = email_match.group(0)

    # Extract phone number (multiple formats)
    phone_patterns = [
        r'\+?\d{1,3}[-.\s]?\(?\d{1,4}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,9}',
        r'\(\d{3}\)\s*\d{3}-\d{4}',
        r'\d{3}-\d{3}-\d{4}',
    ]
    for pattern in phone_patterns:
        phone_match = re.search(pattern, pdf_text)
        if phone_match:
            info['phone'] = phone_match.group(0)
            break

    # Extract name (first few words, heuristic - often resume starts with name)
    lines = [line.strip() for line in pdf_text.split('\n') if line.strip()]
    if lines:
        # Assume first non-empty line might be the name
        potential_name = lines[0]
        # Basic validation: name should be 2-4 words, mostly letters
        words = potential_name.split()
        if 2 <= len(words) <= 4 and all(word.replace('.', '').replace(',', '').isalpha() for word in words):
            info['full_name'] = potential_name

    # Note: Company name and job title extraction are more complex
    # and would require more sophisticated NLP or LLM-based approaches

    return info


def process_resume_upload(pdf_file) -> Dict[str, Optional[str]]:
    """
    Complete pipeline to process an uploaded resume PDF.

    Args:
        pdf_file: Uploaded PDF file object

    Returns:
        dict: Extracted professional information
    """
    try:
        # Extract text from PDF
        text = extract_text_from_pdf(pdf_file)

        # Extract structured information
        info = extract_professional_info(text)

        return info
    except Exception as e:
        raise ValueError(f"Resume processing failed: {str(e)}")
