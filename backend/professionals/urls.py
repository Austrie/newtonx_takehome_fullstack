from django.urls import path
from .views import ProfessionalListCreateView, ProfessionalBulkUpsertView

urlpatterns = [
    path('professionals/', ProfessionalListCreateView.as_view(), name='professional-list-create'),
    path('professionals/bulk', ProfessionalBulkUpsertView.as_view(), name='professional-bulk-upsert'),
]
