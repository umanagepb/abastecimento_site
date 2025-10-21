# Runtime stage - usando arquivos pré-compilados
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app

# Install certificates, PostgreSQL client and curl for health checks
RUN apt-get update && apt-get install -y ca-certificates postgresql-client curl && rm -rf /var/lib/apt/lists/*

# Copy all pre-compiled files
COPY . .

# Create directory for certificates
RUN mkdir -p /etc/ssl/certs/app

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5004

# Expose port
EXPOSE 5004

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "Abastecimento.WebApi.dll"]