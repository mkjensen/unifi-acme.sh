#!/bin/bash

# Copyright 2016 Martin Kamp Jensen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# USER CONFIGURATION BEGIN

# The domain for which acme.sh generated/generates a certificate
DOMAIN="$1"

# The path to the acme.sh installation
ACME_SH="$2"

# USER CONFIGURATION END

uname -a | grep CloudKey > /dev/null
CLOUD_KEY="$?"

echo "Updating UniFi Controller certificate"

WORKDIR="${ACME_SH}/${DOMAIN}"

if [ $CLOUD_KEY -eq 0 ]; then
	echo "* Stopping nginx..."
	systemctl stop nginx

	if [ ! -f /usr/lib/unifi/data/keystore.backup ]; then
		echo "* Moving controller keystore for initial setup..."
		mv /usr/lib/unifi/data/keystore /usr/lib/unifi/data/keystore.backup
		cp /etc/ssl/private/unifi.keystore.jks /usr/lib/unifi/data/keystore

		echo "* Modifying controller config for initial setup..."
		sed -i /etc/default/unifi -e '/UNIFI_SSL_KEYSTORE/s/^/# /'
	fi
fi

echo "* Stopping UniFi controller..."
systemctl stop unifi

echo "* Creating PKCS12 keystore..."
openssl pkcs12 -export -passout pass:aircontrolenterprise \
 -in ${WORKDIR}/${DOMAIN}.cer \
 -inkey ${WORKDIR}/${DOMAIN}.key \
 -out ${WORKDIR}/keystore.pkcs12 -name unifi \
 -CAfile ${WORKDIR}/fullchain.cer -caname root

echo "* Importing certificate into Unifi Controller keystore..."
keytool -noprompt -trustcacerts -importkeystore -deststorepass aircontrolenterprise \
 -destkeypass aircontrolenterprise -destkeystore /usr/lib/unifi/data/keystore \
 -srckeystore ${WORKDIR}/keystore.pkcs12 -srcstoretype PKCS12 -srcstorepass aircontrolenterprise -alias unifi

cat > ${WORKDIR}/identrust.cer << EOF
-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----
EOF

echo "* Importing certificate via ace.jar..."
java -jar /usr/lib/unifi/lib/ace.jar import_cert \
 ${WORKDIR}/${DOMAIN}.cer \
 ${WORKDIR}/ca.cer \
 ${WORKDIR}/identrust.cer

if [ $CLOUD_KEY -eq 0 ]; then
	if [ ! -f /etc/ssl/private/cloudkey.key.backup ]; then
		echo "* Setting permissions on certificate and key for initial setup..."
		chown root:ssl-cert ${WORKDIR}/fullchain.cer
		chown root:ssl-cert ${WORKDIR}/${DOMAIN}.key

		chmod 640 ${WORKDIR}/fullchain.cer
		chmod 640 ${WORKDIR}/${DOMAIN}.key

		echo "* Moving nginx certificates for initial setup..."
		mv /etc/ssl/private/cloudkey.crt /etc/ssl/private/cloudkey.crt.backup
		mv /etc/ssl/private/cloudkey.key /etc/ssl/private/cloudkey.key.backup

		ln -s ${WORKDIR}/fullchain.cer /etc/ssl/private/cloudkey.crt
		ln -s ${WORKDIR}/${DOMAIN}.key /etc/ssl/private/cloudkey.key
	fi
fi

echo "* Starting UniFi Controller..."
systemctl start unifi

if [ $CLOUD_KEY -eq 0 ]; then
	echo "* Starting nginx..."
	systemctl start nginx
fi