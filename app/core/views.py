from django.db import DatabaseError, connection
from django.http import JsonResponse
from django.views.decorators.http import require_safe


@require_safe
def health(request):
    """Utilisé par le healthcheck Docker : vérifie aussi que la base SQLite répond."""
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
    except DatabaseError:
        return JsonResponse(
            {"service": "project2-django", "status": "error", "project": "Telecommunication Security"},
            status=503,
        )
    return JsonResponse(
        {"service": "project2-django", "status": "ok", "project": "Telecommunication Security"}
    )
