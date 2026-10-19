# Application Django du Projet 2 (scenario-b-django).
# Code dans app/, fourni comme contexte de build nommé "app" (voir compose).
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Utilisateur non-root ; seul /app/data (volume SQLite) lui appartient
RUN useradd --system --uid 10001 --home-dir /app --shell /usr/sbin/nologin django \
 && mkdir -p /app/data \
 && chown django:django /app/data

COPY --from=app . /app/
COPY entrypoint.sh /usr/local/bin/django-entrypoint.sh
RUN chmod 0755 /usr/local/bin/django-entrypoint.sh

USER django
EXPOSE 8000
ENTRYPOINT ["django-entrypoint.sh"]
