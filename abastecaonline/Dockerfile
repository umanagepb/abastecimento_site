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
    openssl \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates

# Copy all pre-compiled files
COPY . .

# Create directories for certificates and data protection keys
RUN mkdir -p /etc/ssl/certs/app /app/keys

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5003

# Expose port
EXPOSE 5003

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && \
    chown -R appuser /app && \
    chown -R appuser /app/keys
USER appuser

# Health check
HEALTHCHECK --interval=45s --timeout=30s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:5003/health || curl -f http://localhost:5003/ || exit 1

ENTRYPOINT ["dotnet", "Abastecimento.Blazor.Server.dll"]