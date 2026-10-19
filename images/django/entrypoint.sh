#!/bin/sh
# check -> migrations -> Gunicorn. Les migrations créent/mettent à jour la base
# SQLite du volume avant que le compte de laboratoire ne soit créé (phase 1D).
set -e

python manage.py check
python manage.py migrate --noinput

# --forwarded-allow-ips : seul Nginx (app-net) est autorisé à fournir les en-têtes X-Forwarded-*
# --no-control-socket : interface d'administration de Gunicorn inutile ici (et /app non inscriptible)
# Log d'accès : on ajoute X-Forwarded-Proto et X-Forwarded-For (protocole et IP d'origine de l'UE vus par Nginx)
exec gunicorn project2.wsgi:application \
  --bind 0.0.0.0:8000 \
  --no-control-socket \
  --workers "${GUNICORN_WORKERS:-2}" \
  --forwarded-allow-ips "${GUNICORN_FORWARDED_ALLOW_IPS:-10.20.8.10}" \
  --access-logfile - \
  --access-logformat '%(h)s %(t)s "%(r)s" %(s)s %(b)s "%(a)s" xfp=%({x-forwarded-proto}i)s xff=%({x-forwarded-for}i)s'
