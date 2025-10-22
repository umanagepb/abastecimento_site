#!/usr/bin/env pwsh

# Script para rebuild da API com correções do libssl
Write-Host "=== Rebuild da API com Correções LibSSL ===" -ForegroundColor Green

Write-Host "`nOpções de rebuild:" -ForegroundColor Yellow
Write-Host "1. Rebuild usando Dockerfile original (recomendado)" -ForegroundColor Cyan
Write-Host "2. Rebuild usando Dockerfile.libssl-fix (alternativa)" -ForegroundColor Cyan
Write-Host "3. Apenas parar e iniciar containers existentes" -ForegroundColor Cyan

$choice = Read-Host "`nEscolha uma opção (1, 2 ou 3)"

switch ($choice) {
    "1" {
        Write-Host "`nFazendo rebuild com Dockerfile original..." -ForegroundColor Yellow
        
        # Parar containers
        Write-Host "Parando containers..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml down
        
        # Rebuild sem cache
        Write-Host "Fazendo rebuild sem cache..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml build --no-cache
        
        # Iniciar containers
        Write-Host "Iniciando containers..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml up -d
        
        Write-Host "✓ Rebuild concluído!" -ForegroundColor Green
    }
    
    "2" {
        Write-Host "`nFazendo rebuild com Dockerfile.libssl-fix..." -ForegroundColor Yellow
        
        # Fazer backup do Dockerfile original
        if (Test-Path "Dockerfile") {
            Copy-Item "Dockerfile" "Dockerfile.backup" -Force
            Write-Host "Backup do Dockerfile original criado" -ForegroundColor Cyan
        }
        
        # Usar o Dockerfile alternativo
        Copy-Item "Dockerfile.libssl-fix" "Dockerfile" -Force
        Write-Host "Usando Dockerfile.libssl-fix" -ForegroundColor Cyan
        
        # Parar containers
        Write-Host "Parando containers..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml down
        
        # Rebuild sem cache
        Write-Host "Fazendo rebuild sem cache..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml build --no-cache
        
        # Iniciar containers
        Write-Host "Iniciando containers..." -ForegroundColor Yellow
        docker-compose -f coolify-api.yml up -d
        
        Write-Host "✓ Rebuild concluído com Dockerfile alternativo!" -ForegroundColor Green
    }
    
    "3" {
        Write-Host "`nReiniciando containers existentes..." -ForegroundColor Yellow
        
        # Parar containers
        docker-compose -f coolify-api.yml down
        
        # Iniciar containers
        docker-compose -f coolify-api.yml up -d
        
        Write-Host "✓ Containers reiniciados!" -ForegroundColor Green
    }
    
    default {
        Write-Host "Opção inválida. Saindo..." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`nAguardando containers iniciarem..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Verificar status
Write-Host "`nVerificando status dos containers..." -ForegroundColor Yellow
docker-compose -f coolify-api.yml ps

Write-Host "`nPara verificar se as correções funcionaram, execute:" -ForegroundColor Cyan
Write-Host "./verify-dataprotection.ps1" -ForegroundColor White

Write-Host "`nPara ver os logs em tempo real:" -ForegroundColor Cyan
Write-Host "docker logs -f abastecimento-api" -ForegroundColor White