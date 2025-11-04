from django.test import TestCase
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from rest_framework.test import APITestCase
from rest_framework import status
from django.core.files.uploadedfile import SimpleUploadedFile
from .models import Professional
from .serializers import ProfessionalSerializer, BulkProfessionalSerializer
import io


class ProfessionalModelTest(TestCase):
    """Test cases for the Professional model"""

    def test_create_professional_with_email(self):
        """Test creating a professional with email"""
        professional = Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            company_name="Tech Corp",
            job_title="Engineer",
            source="direct"
        )
        self.assertEqual(professional.full_name, "John Doe")
        self.assertEqual(professional.email, "john@example.com")
        self.assertEqual(professional.source, "direct")

    def test_create_professional_with_phone_only(self):
        """Test creating a professional with only phone number"""
        professional = Professional.objects.create(
            full_name="Jane Smith",
            phone="+1234567890",
            source="partner"
        )
        self.assertEqual(professional.full_name, "Jane Smith")
        self.assertEqual(professional.phone, "+1234567890")
        self.assertIsNone(professional.email)

    def test_email_uniqueness(self):
        """Test that email must be unique"""
        Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            source="direct"
        )
        with self.assertRaises(IntegrityError):
            Professional.objects.create(
                full_name="Jane Doe",
                email="john@example.com",
                source="partner"
            )

    def test_phone_uniqueness(self):
        """Test that phone must be unique"""
        Professional.objects.create(
            full_name="John Doe",
            phone="+1234567890",
            source="direct"
        )
        with self.assertRaises(IntegrityError):
            Professional.objects.create(
                full_name="Jane Doe",
                phone="+1234567890",
                source="partner"
            )

    def test_professional_str_representation(self):
        """Test the string representation of Professional"""
        professional = Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            source="direct"
        )
        self.assertEqual(str(professional), "John Doe (direct)")

    def test_ordering_by_created_at(self):
        """Test that professionals are ordered by created_at descending"""
        prof1 = Professional.objects.create(
            full_name="First",
            email="first@example.com",
            source="direct"
        )
        prof2 = Professional.objects.create(
            full_name="Second",
            email="second@example.com",
            source="partner"
        )
        professionals = Professional.objects.all()
        self.assertEqual(professionals[0].id, prof2.id)
        self.assertEqual(professionals[1].id, prof1.id)


class ProfessionalSerializerTest(TestCase):
    """Test cases for the ProfessionalSerializer"""

    def test_valid_serializer_with_email(self):
        """Test serializer with valid email data"""
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "company_name": "Tech Corp",
            "job_title": "Engineer",
            "source": "direct"
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_valid_serializer_with_phone_only(self):
        """Test serializer with only phone number"""
        data = {
            "full_name": "Jane Smith",
            "phone": "+1234567890",
            "source": "partner"
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_invalid_serializer_no_email_or_phone(self):
        """Test serializer fails when neither email nor phone provided"""
        data = {
            "full_name": "John Doe",
            "source": "direct"
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("At least one of email or phone must be provided", str(serializer.errors))

    def test_invalid_source(self):
        """Test serializer fails with invalid source"""
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "source": "invalid_source"
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("source", serializer.errors)

    def test_resume_validation_pdf_only(self):
        """Test that only PDF files are accepted for resume"""
        # Create a fake non-PDF file
        non_pdf_file = SimpleUploadedFile(
            "resume.txt",
            b"file content",
            content_type="text/plain"
        )
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "source": "direct",
            "resume": non_pdf_file
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("resume", serializer.errors)

    def test_resume_validation_size_limit(self):
        """Test that resume file size is limited to 10MB"""
        # Create a fake PDF file larger than 10MB
        large_file = SimpleUploadedFile(
            "resume.pdf",
            b"x" * (11 * 1024 * 1024),  # 11MB
            content_type="application/pdf"
        )
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "source": "direct",
            "resume": large_file
        }
        serializer = ProfessionalSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("resume", serializer.errors)


class BulkProfessionalSerializerTest(TestCase):
    """Test cases for the BulkProfessionalSerializer"""

    def test_valid_bulk_serializer(self):
        """Test bulk serializer with valid data"""
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "source": "direct"
        }
        serializer = BulkProfessionalSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_bulk_serializer_converts_empty_strings(self):
        """Test that empty strings are converted to None"""
        data = {
            "full_name": "John Doe",
            "email": "",
            "phone": "+1234567890",
            "source": "direct"
        }
        serializer = BulkProfessionalSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        self.assertIsNone(serializer.validated_data.get('email'))

    def test_bulk_serializer_invalid_no_contact(self):
        """Test bulk serializer fails with no email or phone"""
        data = {
            "full_name": "John Doe",
            "email": "",
            "phone": "",
            "source": "direct"
        }
        serializer = BulkProfessionalSerializer(data=data)
        self.assertFalse(serializer.is_valid())


class ProfessionalAPITest(APITestCase):
    """Test cases for Professional API endpoints"""

    def test_list_professionals_empty(self):
        """Test listing professionals when database is empty"""
        response = self.client.get('/api/professionals/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)

    def test_list_professionals_with_data(self):
        """Test listing professionals with data"""
        Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            source="direct"
        )
        Professional.objects.create(
            full_name="Jane Smith",
            email="jane@example.com",
            source="partner"
        )
        response = self.client.get('/api/professionals/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)

    def test_filter_professionals_by_source(self):
        """Test filtering professionals by source"""
        Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            source="direct"
        )
        Professional.objects.create(
            full_name="Jane Smith",
            email="jane@example.com",
            source="partner"
        )
        response = self.client.get('/api/professionals/?source=direct')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]['source'], 'direct')

    def test_create_professional(self):
        """Test creating a new professional"""
        data = {
            "full_name": "John Doe",
            "email": "john@example.com",
            "company_name": "Tech Corp",
            "job_title": "Engineer",
            "source": "direct"
        }
        response = self.client.post('/api/professionals/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(response.data['full_name'], "John Doe")
        self.assertEqual(response.data['email'], "john@example.com")
        self.assertEqual(Professional.objects.count(), 1)

    def test_upsert_professional_by_email(self):
        """Test updating an existing professional by email via bulk endpoint"""
        # Create initial professional
        Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            company_name="Old Corp",
            source="direct"
        )
        # Update via bulk upsert (the single POST endpoint doesn't support clean upserts)
        data = [
            {
                "full_name": "John Doe Updated",
                "email": "john@example.com",
                "company_name": "New Corp",
                "job_title": "Senior Engineer",
                "source": "direct"
            }
        ]
        response = self.client.post('/api/professionals/bulk', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['success']), 1)
        self.assertEqual(response.data['success'][0]['company_name'], "New Corp")
        self.assertEqual(Professional.objects.count(), 1)  # Still only one record

    def test_create_professional_invalid_no_contact(self):
        """Test creating professional fails without email or phone"""
        data = {
            "full_name": "John Doe",
            "source": "direct"
        }
        response = self.client.post('/api/professionals/', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_bulk_upsert_success(self):
        """Test bulk upsert with all valid records"""
        data = [
            {
                "full_name": "John Doe",
                "email": "john@example.com",
                "source": "direct"
            },
            {
                "full_name": "Jane Smith",
                "phone": "+1234567890",
                "source": "partner"
            }
        ]
        response = self.client.post('/api/professionals/bulk', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['success']), 2)
        self.assertEqual(len(response.data['failed']), 0)
        self.assertEqual(Professional.objects.count(), 2)

    def test_bulk_upsert_partial_failure(self):
        """Test bulk upsert with some invalid records"""
        data = [
            {
                "full_name": "John Doe",
                "email": "john@example.com",
                "source": "direct"
            },
            {
                "full_name": "Invalid User",
                "source": "direct"  # Missing email and phone
            }
        ]
        response = self.client.post('/api/professionals/bulk', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['success']), 1)
        self.assertEqual(len(response.data['failed']), 1)
        self.assertEqual(Professional.objects.count(), 1)

    def test_bulk_upsert_invalid_format(self):
        """Test bulk upsert with non-list data"""
        data = {"not": "a list"}
        response = self.client.post('/api/professionals/bulk', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Expected a list", response.data['error'])

    def test_bulk_upsert_updates_existing(self):
        """Test bulk upsert updates existing records"""
        # Create initial professional
        Professional.objects.create(
            full_name="John Doe",
            email="john@example.com",
            company_name="Old Corp",
            source="direct"
        )
        # Bulk upsert with update
        data = [
            {
                "full_name": "John Doe Updated",
                "email": "john@example.com",
                "company_name": "New Corp",
                "source": "direct"
            }
        ]
        response = self.client.post('/api/professionals/bulk', data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data['success']), 1)
        self.assertEqual(Professional.objects.count(), 1)
        updated = Professional.objects.get(email="john@example.com")
        self.assertEqual(updated.company_name, "New Corp")

    def test_parse_resume_no_file(self):
        """Test parse resume endpoint with no file"""
        response = self.client.post('/api/professionals/parse-resume')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("No resume file provided", response.data['error'])

    def test_parse_resume_invalid_file_type(self):
        """Test parse resume endpoint with non-PDF file"""
        file = SimpleUploadedFile(
            "resume.txt",
            b"file content",
            content_type="text/plain"
        )
        response = self.client.post('/api/professionals/parse-resume', {'resume': file})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Invalid file type", response.data['error'])

    def test_parse_resume_file_too_large(self):
        """Test parse resume endpoint with file exceeding size limit"""
        large_file = SimpleUploadedFile(
            "resume.pdf",
            b"x" * (11 * 1024 * 1024),  # 11MB
            content_type="application/pdf"
        )
        response = self.client.post('/api/professionals/parse-resume', {'resume': large_file})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("File too large", response.data['error'])
