from rest_framework import generics, status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from django.db import transaction
from django.db.models import Q
from .models import Professional
from .serializers import ProfessionalSerializer, BulkProfessionalSerializer


class ProfessionalListCreateView(APIView):
    """
    GET /api/professionals/ - List all professionals (with optional source filter)
    POST /api/professionals/ - Upsert a professional using email or phone as unique key
    """
    parser_classes = [JSONParser, MultiPartParser, FormParser]

    def get(self, request):
        """
        List all professionals, optionally filtered by source.
        """
        queryset = Professional.objects.all()
        source = request.query_params.get('source', None)

        if source:
            queryset = queryset.filter(source=source)

        serializer = ProfessionalSerializer(queryset, many=True)
        return Response(serializer.data)

    def post(self, request):
        """
        Upsert a professional using email as primary key, phone as fallback.
        """
        serializer = ProfessionalSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        validated_data = serializer.validated_data
        email = validated_data.get('email')
        phone = validated_data.get('phone')

        try:
            # Upsert logic: use email as primary unique key, fallback to phone
            if email:
                professional, created = Professional.objects.update_or_create(
                    email=email,
                    defaults=validated_data
                )
            elif phone:
                professional, created = Professional.objects.update_or_create(
                    phone=phone,
                    defaults=validated_data
                )
            else:
                return Response(
                    {"error": "Either email or phone must be provided."},
                    status=status.HTTP_400_BAD_REQUEST
                )

            response_serializer = ProfessionalSerializer(professional)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED if created else status.HTTP_200_OK
            )

        except Exception as e:
            return Response(
                {"error": str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )


class ProfessionalBulkUpsertView(APIView):
    """
    POST /api/professionals/bulk - Bulk create or update professionals

    Accepts a list of professional records.
    Upserts using email as unique key (if provided), otherwise phone.
    Returns success and failed records.
    """

    def post(self, request):
        if not isinstance(request.data, list):
            return Response(
                {"error": "Expected a list of professional records."},
                status=status.HTTP_400_BAD_REQUEST
            )

        success = []
        failed = []

        with transaction.atomic():
            for index, record in enumerate(request.data):
                serializer = BulkProfessionalSerializer(data=record)

                if not serializer.is_valid():
                    error_msg = {
                        "index": index,
                        "record": record,
                        "reason": serializer.errors
                    }
                    failed.append(error_msg)
                    print(f"[BULK UPLOAD] Failed row {index}: {error_msg}")
                    continue

                validated_data = serializer.validated_data
                email = validated_data.get('email')
                phone = validated_data.get('phone')

                try:
                    # Upsert logic: use email as primary unique key, fallback to phone
                    if email:
                        professional, created = Professional.objects.update_or_create(
                            email=email,
                            defaults=validated_data
                        )
                    elif phone:
                        professional, created = Professional.objects.update_or_create(
                            phone=phone,
                            defaults=validated_data
                        )
                    else:
                        error_msg = {
                            "index": index,
                            "record": record,
                            "reason": "Either email or phone must be provided."
                        }
                        failed.append(error_msg)
                        print(f"[BULK UPLOAD] Failed row {index}: {error_msg}")
                        continue

                    success.append(ProfessionalSerializer(professional).data)

                except Exception as e:
                    error_msg = {
                        "index": index,
                        "record": record,
                        "reason": str(e)
                    }
                    failed.append(error_msg)
                    print(f"[BULK UPLOAD] Failed row {index}: {error_msg}")

        return Response({
            "success": success,
            "failed": failed
        }, status=status.HTTP_200_OK)


class ParseResumeWithGPTView(APIView):
    """
    POST /api/professionals/parse-resume - Parse a resume PDF using GPT-4

    Accepts a PDF file upload and returns extracted professional information.
    Requires OPENAI_API_KEY environment variable to be set.
    """
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        """
        Parse resume using GPT-4 and return extracted fields with confidence scores.
        """
        from .gpt_parser import parse_resume_with_gpt, is_gpt_parsing_available

        # Check if GPT parsing is available
        if not is_gpt_parsing_available():
            return Response({
                "error": "GPT-based resume parsing is not available",
                "message": "OpenAI API key is not configured. Please set the OPENAI_API_KEY environment variable to enable this feature.",
                "available": False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        # Check if resume file was provided
        resume_file = request.FILES.get('resume')
        if not resume_file:
            return Response({
                "error": "No resume file provided",
                "message": "Please upload a PDF file with the field name 'resume'"
            }, status=status.HTTP_400_BAD_REQUEST)

        # Validate file type
        if not resume_file.name.lower().endswith('.pdf'):
            return Response({
                "error": "Invalid file type",
                "message": "Only PDF files are supported"
            }, status=status.HTTP_400_BAD_REQUEST)

        # Validate file size (10MB limit)
        if resume_file.size > 10 * 1024 * 1024:
            return Response({
                "error": "File too large",
                "message": "Resume file must be under 10MB"
            }, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Parse the resume with GPT
            result = parse_resume_with_gpt(resume_file)

            return Response({
                "success": True,
                "data": result,
                "message": "Resume parsed successfully"
            }, status=status.HTTP_200_OK)

        except ValueError as e:
            # API key not configured or parsing error
            return Response({
                "error": "Configuration error",
                "message": str(e),
                "available": False
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

        except Exception as e:
            # Other errors (API errors, network issues, etc.)
            print(f"[GPT PARSING ERROR] {str(e)}")
            return Response({
                "error": "Parsing failed",
                "message": f"Failed to parse resume: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
