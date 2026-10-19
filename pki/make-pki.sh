#!/usr/bin/env bash
# PKI du laboratoire : Telecom Lab Root CA -> certificat serveur de Nginx (10.20.6.20).
# Sortie dans secrets/tls/ (ignoré par git) :
#   ca/ca.key       clé privée de la CA   -> reste sur l'hôte, jamais montée dans un conteneur
#   ca/ca.crt       certificat de la CA   -> monté en lecture seule dans l'UE (/etc/telecom-lab/ca.crt)
#   server/server.* clé + certificat serveur -> montés en lecture seule dans Nginx
# La CA existante est conservée ; seul le certificat serveur est réémis (--force-ca pour tout refaire).
set -euo pipefail

P2_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="$P2_DIR/secrets/tls"
CA_DIR="$OUT/ca"
SRV_DIR="$OUT/server"
CA_DAYS=1825      # 5 ans
SRV_DAYS=397      # durée maximale admise par les navigateurs pour un certificat serveur

umask 077
mkdir -p "$CA_DIR" "$SRV_DIR"

if [[ "${1:-}" == "--force-ca" ]]; then
  rm -f "$CA_DIR"/ca.key "$CA_DIR"/ca.crt
fi

# 1. Autorité de certification racine (auto-signée)
if [[ ! -f "$CA_DIR/ca.key" ]]; then
  openssl req -x509 -new -newkey rsa:4096 -nodes -sha256 -days "$CA_DAYS" \
    -keyout "$CA_DIR/ca.key" -out "$CA_DIR/ca.crt" \
    -subj "/C=LV/O=Esisar-RTU Telecom Lab/CN=Telecom Lab Root CA" \
    -addext "basicConstraints=critical,CA:TRUE,pathlen:0" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" \
    -addext "subjectKeyIdentifier=hash"
  echo "CA créée : $CA_DIR/ca.crt"
else
  echo "CA existante conservée : $CA_DIR/ca.crt"
fi

# 2. Clé + demande de certificat (CSR) du serveur
openssl req -new -newkey rsa:2048 -nodes -sha256 \
  -keyout "$SRV_DIR/server.key" -out "$SRV_DIR/server.csr" \
  -subj "/C=LV/O=Esisar-RTU Telecom Lab/CN=telecom-lab.local"

# 3. Signature par la CA. Le SAN est ce que le client vérifie (le CN est ignoré par les clients modernes).
cat > "$SRV_DIR/server.ext" <<'EOF'
basicConstraints=critical,CA:FALSE
keyUsage=critical,digitalSignature,keyEncipherment
extendedKeyUsage=serverAuth
subjectAltName=IP:10.20.6.20,DNS:telecom-lab.local,DNS:localhost
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid
EOF
openssl x509 -req -in "$SRV_DIR/server.csr" -sha256 -days "$SRV_DAYS" \
  -CA "$CA_DIR/ca.crt" -CAkey "$CA_DIR/ca.key" -CAcreateserial -CAserial "$CA_DIR/ca.srl" \
  -extfile "$SRV_DIR/server.ext" -out "$SRV_DIR/server.crt"
rm -f "$SRV_DIR/server.csr" "$SRV_DIR/server.ext"

# Les certificats sont publics ; les clés restent lisibles par le seul propriétaire
chmod 644 "$CA_DIR/ca.crt" "$SRV_DIR/server.crt"
chmod 600 "$CA_DIR/ca.key" "$SRV_DIR/server.key"

openssl verify -CAfile "$CA_DIR/ca.crt" "$SRV_DIR/server.crt"
