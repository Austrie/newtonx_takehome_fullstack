from django.contrib import admin
from .models import Professional


@admin.register(Professional)
class ProfessionalAdmin(admin.ModelAdmin):
    list_display = ['full_name', 'email', 'phone', 'company_name', 'job_title', 'source', 'created_at']
    list_filter = ['source', 'created_at']
    search_fields = ['full_name', 'email', 'phone', 'company_name', 'job_title']
    readonly_fields = ['created_at', 'updated_at']
