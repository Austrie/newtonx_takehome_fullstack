from django.db import models


class Professional(models.Model):
    """
    Model representing a professional profile from various sources.
    """
    SOURCE_CHOICES = [
        ('direct', 'Direct'),
        ('partner', 'Partner'),
        ('internal', 'Internal'),
    ]

    full_name = models.CharField(max_length=255)
    email = models.EmailField(unique=True, null=True, blank=True)
    company_name = models.CharField(max_length=255, null=True, blank=True)
    job_title = models.CharField(max_length=255, null=True, blank=True)
    phone = models.CharField(max_length=50, unique=True, null=True, blank=True)
    source = models.CharField(max_length=20, choices=SOURCE_CHOICES)
    resume = models.FileField(upload_to='resumes/', null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['email']),
            models.Index(fields=['phone']),
            models.Index(fields=['source']),
        ]

    def __str__(self):
        return f"{self.full_name} ({self.source})"
