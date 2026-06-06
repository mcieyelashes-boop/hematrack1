#!/usr/bin/env python3
"""
Generate Android signing keystore untuk HemaTrack — jalankan SEKALI.

Cara pakai:
    pip install cryptography
    python3 scripts/gen_keystore.py

Output: keystore.p12 + instruksi set env var di Codemagic.
PENTING: Simpan keystore.p12 di tempat aman. JANGAN commit ke git.
"""
import base64
import datetime
import sys
from pathlib import Path

try:
    from cryptography.hazmat.primitives import hashes, serialization
    from cryptography.hazmat.primitives.asymmetric import rsa
    from cryptography.hazmat.primitives.serialization import pkcs12
    from cryptography import x509
    from cryptography.x509.oid import NameOID
except ImportError:
    sys.exit("Install dulu: pip install cryptography")

KEY_ALIAS    = "hematrack"
PASS         = b"HemaTrack2024!"

# Generate RSA private key
key = rsa.generate_private_key(public_exponent=65537, key_size=2048)

# Self-signed certificate valid 27 years
subject = issuer = x509.Name([
    x509.NameAttribute(NameOID.COMMON_NAME,        "HemaTrack"),
    x509.NameAttribute(NameOID.ORGANIZATION_NAME,  "HemaTrack"),
    x509.NameAttribute(NameOID.COUNTRY_NAME,       "ID"),
])
cert = (
    x509.CertificateBuilder()
    .subject_name(subject)
    .issuer_name(issuer)
    .public_key(key.public_key())
    .serial_number(x509.random_serial_number())
    .not_valid_before(datetime.datetime.utcnow())
    .not_valid_after(datetime.datetime.utcnow() + datetime.timedelta(days=10000))
    .sign(key, hashes.SHA256())
)

# Serialize as PKCS12
p12 = pkcs12.serialize_key_and_certificates(
    KEY_ALIAS.encode(),
    key,
    cert,
    None,
    serialization.BestAvailableEncryption(PASS),
)

out = Path("keystore.p12")
out.write_bytes(p12)
b64 = base64.b64encode(p12).decode()

sep = "=" * 64
print(sep)
print("KEYSTORE BERHASIL DIBUAT: keystore.p12")
print(sep)
print()
print("Set 4 environment variables berikut di Codemagic:")
print("  App Settings > Environment variables > Add variable")
print()
print(f"  CM_KEY_ALIAS     = {KEY_ALIAS}")
print(f"  CM_KEYSTORE_PASS = {PASS.decode()}")
print(f"  CM_KEY_PASS      = {PASS.decode()}")
print(f"  CM_KEYSTORE_B64  = <string panjang di bawah>")
print()
print("CM_KEYSTORE_B64 (copy semua, tidak ada spasi):")
print(b64)
print()
print(sep)
print("SIMPAN keystore.p12 di tempat aman (Google Drive / cloud).")
print("Kalau hilang, app tidak bisa di-update di Play Store.")
print(sep)
