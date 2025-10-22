# Runtime stage - usando arquivos pré-compilados
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install certificates, PostgreSQL client, graphics libraries for System.Drawing, and curl for health checks
RUN apt-get update && apt-get install -y \
    ca-certificates \
    postgresql-client \
    curl \
    libgdiplus \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy all pre-compiled files
COPY . .

# Create directory for certificates
RUN mkdir -p /etc/ssl/certs/app

# Set environment variables for external access
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://0.0.0.0:5004
ENV ASPNETCORE_HTTP_PORTS=5004
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true

# Expose port
EXPOSE 5004

# Make start script executable
RUN chmod +x start.sh

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:5004/health || exit 1

ENTRYPOINT ["./start.sh"]