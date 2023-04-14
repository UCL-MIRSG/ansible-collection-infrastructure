#!/usr/bin/env bash

# This script generates a self-signed SSL certificate for a local XNAT test
# server running on a vagrant XNAT testing environment.
# This allows you to test out the https configuration.
#
# Note that your browser will show security warnings when using a self-signed
# certificate


# Stop on error
set -e

# Generate self-signed certificate
CERT_DIR="/etc/ssl/certs"
KEY_FILE="/etc/ssl/certs/${WEB_CERTIFICATE_HOST}.key"
CERT_FILE="/etc/ssl/certs/${WEB_CERTIFICATE_HOST}.cert"

if [ -z "${WEB_CERTIFICATE_HOST}" ]
then
      echo "Skipping certificate generation"
else
  if [ -f "${CERT_FILE}" ]; then
      echo "Certificate for ${WEB_CERTIFICATE_HOST} already exists"
  else
      echo "Generating new certificate for ${WEB_CERTIFICATE_HOST}"
      mkdir -p "${CERT_DIR}"
      openssl genrsa -out "${KEY_FILE}" 2048
      openssl req -new -x509 -key "${KEY_FILE}" -out "${CERT_FILE}" -days 3650 -subj /CN="${WEB_CERTIFICATE_HOST}"
      chmod 700 "${CERT_DIR}"
      chmod 600 "${KEY_FILE}"
      chmod 600 "${CERT_FILE}"
  fi
fi
