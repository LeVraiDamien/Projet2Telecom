# Project 2 — Telecommunication Security, DevSecOps and Traffic Intelligence

Damien Guffon — Esisar

Extends the [Project 1](https://github.com/LeVraiDamien/Projet1Telecom) 5G Standalone network (Open5GS + UERANSIM) with a secure application service reached over the 5G user plane (Scenario A), then a Jenkins security CI/CD pipeline (Scenario B).

**Full report and evidence: [REPORT.md](REPORT.md).**

## Layout

```
p2-compose.sh        docker compose wrapper: Project 1 core + Project 2 additions
compose/             p2-core.yaml (dn-net, app-net, UPF/UE overrides), p2-scenario-a.yaml (Nginx, Django)
images/              Dockerfiles: ueransim-p2, nginx, django
app/                 Django project
nginx/conf.d/        Nginx configuration (TLS, 80 → 301)
pki/                 lab PKI script (keys and certificates go to secrets/tls/, never committed)
evidence/            raw evidence per phase (command output, pcaps)
.env.example         template for the Django secret (.env is never committed)
```

## Quick start

See [REPORT.md § Reproduce](REPORT.md#reproduce).
