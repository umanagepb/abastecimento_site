#!/bin/bash
cd /app

# SSL Libraries verification and setup
echo "Checking SSL libraries..."

# Verify SSL libraries are available
if [ ! -f "/usr/lib/x86_64-linux-gnu/libssl.so.3" ]; then
    echo "ERROR: libssl.so.3 not found!"
    exit 1
fi

# Create symbolic links for compatibility if they don't exist
if [ ! -L "/usr/lib/x86_64-linux-gnu/libssl.so.1.1" ]; then
    echo "Creating libssl.so.1.1 symbolic link..."
    ln -sf /usr/lib/x86_64-linux-gnu/libssl.so.3 /usr/lib/x86_64-linux-gnu/libssl.so.1.1
fi

if [ ! -L "/usr/lib/x86_64-linux-gnu/libcrypto.so.1.1" ]; then
    echo "Creating libcrypto.so.1.1 symbolic link..."
    ln -sf /usr/lib/x86_64-linux-gnu/libcrypto.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1
fi

# Update library cache
echo "Updating library cache..."
ldconfig

# Set SSL environment variables
export SSL_CERT_DIR=/etc/ssl/certs
export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
export DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=1

echo "SSL libraries configured successfully"

# Wait for database to be ready
# echo "Waiting for database connection..."
# until pg_isready -h ${DB_HOST:-abastecimento-db} -p ${DB_PORT:-5432} -U postgres; do
#   echo "Database is unavailable - sleeping - ${DB_HOST:-abastecimento-db}"
#   sleep 2
# done

# echo "Database is ready - starting application"

# Start the application
exec dotnet Abastecimento.WebApi.dll
