from rest_framework import serializers
from .models import Professional


class ProfessionalSerializer(serializers.ModelSerializer):
    """
    Serializer for Professional model with validation.
    """
    class Meta:
        model = Professional
        fields = ['id', 'full_name', 'email', 'company_name', 'job_title',
                  'phone', 'source', 'resume', 'created_at']
        read_only_fields = ['id', 'created_at']

    def validate(self, data):
        """
        Ensure at least email or phone is provided.
        """
        email = data.get('email')
        phone = data.get('phone')

        if not email and not phone:
            raise serializers.ValidationError(
                "At least one of email or phone must be provided."
            )

        return data

    def validate_source(self, value):
        """
        Validate source field.
        """
        valid_sources = ['direct', 'partner', 'internal']
        if value not in valid_sources:
            raise serializers.ValidationError(
                f"Invalid source. Must be one of: {', '.join(valid_sources)}"
            )
        return value

    def validate_resume(self, value):
        """
        Validate that the uploaded file is a PDF.
        """
        if value:
            if not value.name.lower().endswith('.pdf'):
                raise serializers.ValidationError(
                    "Only PDF files are allowed for resume uploads."
                )
            # Check file size (limit to 10MB)
            if value.size > 10 * 1024 * 1024:
                raise serializers.ValidationError(
                    "Resume file size must not exceed 10MB."
                )
        return value


class BulkProfessionalSerializer(serializers.Serializer):
    """
    Serializer for bulk upsert operations.
    """
    full_name = serializers.CharField(max_length=255)
    email = serializers.EmailField(required=False, allow_blank=True, allow_null=True)
    company_name = serializers.CharField(max_length=255, required=False, allow_blank=True, allow_null=True)
    job_title = serializers.CharField(max_length=255, required=False, allow_blank=True, allow_null=True)
    phone = serializers.CharField(max_length=50, required=False, allow_blank=True, allow_null=True)
    source = serializers.ChoiceField(choices=['direct', 'partner', 'internal'])

    def validate(self, data):
        """
        Ensure at least email or phone is provided.
        """
        email = data.get('email')
        phone = data.get('phone')

        # Convert empty strings to None
        if email == '':
            data['email'] = None
        if phone == '':
            data['phone'] = None

        if not data.get('email') and not data.get('phone'):
            raise serializers.ValidationError(
                "At least one of email or phone must be provided."
            )

        return data
