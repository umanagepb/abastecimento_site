#!/bin/bash
cd /app

# Wait for database to be ready
echo "Waiting for database connection..."
until pg_isready -h ${DB_HOST:-postgres} -p ${DB_PORT:-5432} -U postgres; do
  echo "Database is unavailable - sleeping"
  sleep 2
done

echo "Database is ready - starting application"

# Start the application
exec dotnet Abastecimento.WebApi.dll
