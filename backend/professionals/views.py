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
