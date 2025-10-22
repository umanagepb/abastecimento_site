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
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
ENV DOTNET_SYSTEM_GLOBALIZATION_USEWEBTABLES=1

# Expose port
EXPOSE 5004

# Make start script executable
RUN chmod +x start.sh

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser /app && \
    chown -R appuser /app/keys && \
    chown -R appuser /home/appuser/.aspnet/DataProtection-Keys
USER appuser

# Health check - mais tolerante para Coolify
HEALTHCHECK --interval=45s --timeout=30s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:5004/health || curl -f http://localhost:5004/ || exit 1

ENTRYPOINT ["dotnet", "Abastecimento.WebApi.dll"]