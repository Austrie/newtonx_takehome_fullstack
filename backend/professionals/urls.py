from django.urls import path
from .views import (
    ProfessionalListCreateView,
    ProfessionalBulkUpsertView,
    ParseResumeWithGPTView
)

urlpatterns = [
    path('professionals/', ProfessionalListCreateView.as_view(), name='professional-list-create'),
    path('professionals/bulk', ProfessionalBulkUpsertView.as_view(), name='professional-bulk-upsert'),
    path('professionals/parse-resume', ParseResumeWithGPTView.as_view(), name='parse-resume-gpt'),
]
