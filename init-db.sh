#!/bin/bash
# Database initialization script for PostgreSQL

# Wait for PostgreSQL to be ready
until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U postgres; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

echo "PostgreSQL is ready!"

# Create database if it doesn't exist
psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -c "CREATE DATABASE $DB_NAME"

echo "Database $DB_NAME is ready!"

# Run any additional initialization scripts here
# For example, you could run Entity Framework migrations:
# dotnet ef database update --connection "$ConnectionStrings__ConnectionString"