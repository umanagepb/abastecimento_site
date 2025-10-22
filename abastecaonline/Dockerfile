# Runtime stage - usando arquivos pré-compilados
FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy
WORKDIR /app

# Install certificates, graphics libraries for System.Drawing, and curl for health checks
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    libgdiplus \
    libc6-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy all pre-compiled files
COPY . .

# Create directory for certificates
RUN mkdir -p /etc/ssl/certs/app

# Set environment variables
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_URLS=http://+:5003
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

# Expose port
EXPOSE 5003

# Create non-root user and set permissions
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser /app
USER appuser

ENTRYPOINT ["dotnet", "Abastecimento.Blazor.Server.dll"]