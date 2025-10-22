# Runtime stage - usando arquivos pré-compilados
FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy
WORKDIR /app

# Install certificates, graphics libraries, SSL libraries, and curl for health checks
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    libgdiplus \
    libc6-dev \
    libssl3 \
    libssl-dev \
    openssl \
    libicu-dev \
    libkrb5-3 \
    zlib1g \
    && ln -sf /usr/lib/x86_64-linux-gnu/libssl.so.3 /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
    && ln -sf /usr/lib/x86_64-linux-gnu/libcrypto.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
    && ldconfig \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# Copy all pre-compiled files
COPY . .

# Create directories for certificates and data protection keys
RUN mkdir -p /etc/ssl/certs/app /app/keys /home/appuser/.aspnet/DataProtection-Keys

# Set environment variables for external access
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://0.0.0.0:5004
ENV ASPNETCORE_HTTP_PORTS=5004
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true

# SSL/TLS Configuration
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=1
ENV DOTNET_SYSTEM_GLOBALIZATION_USEWEBTABLES=1
ENV SSL_CERT_DIR=/etc/ssl/certs
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV DOTNET_SYSTEM_NET_HTTP_USEDEFAULTCREDENTIALS=false

# Expose port
EXPOSE 5004

# Make start script executable
RUN chmod +x start.sh

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser /app && \
    chown -R appuser /app/keys && \
    chown -R appuser /home/appuser/.aspnet/DataProtection-Keys

# Switch to root temporarily to install postgresql-client and fix SSL
USER root
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Switch back to appuser
USER appuser

# Health check - mais tolerante para Coolify
HEALTHCHECK --interval=45s --timeout=30s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:5004/health || curl -f http://localhost:5004/ || exit 1

ENTRYPOINT ["dotnet", "Abastecimento.WebApi.dll"]