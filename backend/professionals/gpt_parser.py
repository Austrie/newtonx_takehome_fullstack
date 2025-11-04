"""
GPT-based resume parsing utilities using OpenAI API.
"""

import os
import json
import base64
from typing import Dict, Optional
from openai import OpenAI, OpenAIError


def parse_resume_with_gpt(pdf_file) -> Dict[str, any]:
    """
    Parse a resume PDF using GPT-4o with base64 encoding.

    Args:
        pdf_file: A file object containing PDF data

    Returns:
        dict: Parsed professional information with confidence scores

    Raises:
        ValueError: If OpenAI API key is not configured
        OpenAIError: If API request fails
    """
    # Check if API key is configured
    api_key = os.environ.get('OPENAI_API_KEY')
    if not api_key:
        raise ValueError(
            "OpenAI API key not configured. "
            "Please set OPENAI_API_KEY environment variable to use GPT-based resume parsing."
        )

    try:
        client = OpenAI(api_key=api_key)

        # Read and encode the PDF file to base64
        pdf_file.seek(0)  # Reset file pointer to beginning
        pdf_data = pdf_file.read()
        base64_string = base64.b64encode(pdf_data).decode("utf-8")

        # Create a prompt for extracting professional information
        prompt = """
        Please analyze this resume PDF and extract the following information in JSON format:

        {
          "full_name": "string",
          "email": "string",
          "phone": "string",
          "company_name": "string (most recent company)",
          "job_title": "string (most recent job title)",
          "confidence": {
            "full_name": 0-100,
            "email": 0-100,
            "phone": 0-100,
            "company_name": 0-100,
            "job_title": 0-100
          }
        }

        For each field:
        - If the information is clearly present, extract it and set confidence to 90-100
        - If the information is implied or uncertain, extract your best guess and set confidence to 50-89
        - If the information is not found, set the field to null and confidence to 0

        Return ONLY the JSON object, no additional text.
        """

        # Call GPT-4o with the base64-encoded PDF
        response = client.chat.completions.create(
            model="gpt-4o-mini",  # Using GPT-4o mini for cost efficiency and PDF support
            messages=[
                {
                    "role": "system",
                    "content": "You are a professional resume parser. Extract information accurately and provide confidence scores."
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": prompt
                        },
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:application/pdf;base64,{base64_string}"
                            }
                        }
                    ]
                }
            ],
            response_format={"type": "json_object"},
            temperature=0.1  # Low temperature for consistent extraction
        )

        # Parse the JSON response
        result = json.loads(response.choices[0].message.content)

        return result

    except OpenAIError as e:
        raise OpenAIError(f"OpenAI API error: {str(e)}")
    except json.JSONDecodeError as e:
        raise ValueError(f"Failed to parse GPT response as JSON: {str(e)}")
    except Exception as e:
        raise Exception(f"Unexpected error during resume parsing: {str(e)}")


def is_gpt_parsing_available() -> bool:
    """
    Check if GPT-based parsing is available (API key configured).

    Returns:
        bool: True if OpenAI API key is set, False otherwise
    """
    return bool(os.environ.get('OPENAI_API_KEY'))
