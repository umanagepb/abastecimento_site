#!/usr/bin/env pwsh

# Script para verificar se as correções do DataProtection e SSL estão funcionando
Write-Host "=== Verificação das Correções DataProtection e SSL ===" -ForegroundColor Green

# Função para verificar se um container está rodando
function Test-ContainerRunning {
    param([string]$ContainerName)
    
    $container = docker ps --filter "name=$ContainerName" --format "table {{.Names}}" | Select-String $ContainerName
    return $null -ne $container
}

# Verificar se o container da API está rodando
$apiContainer = "abastecimento-api"
Write-Host "Verificando se o container '$apiContainer' está rodando..." -ForegroundColor Yellow

if (Test-ContainerRunning $apiContainer) {
    Write-Host "✓ Container '$apiContainer' está rodando" -ForegroundColor Green
    
    # Verificar logs para warnings do DataProtection
    Write-Host "`nVerificando logs do DataProtection..." -ForegroundColor Yellow
    $dataProtectionLogs = docker logs $apiContainer 2>&1 | Select-String "DataProtection-Keys"
    
    if ($dataProtectionLogs.Count -eq 0) {
        Write-Host "✓ Não há warnings do DataProtection nos logs!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Ainda há warnings do DataProtection:" -ForegroundColor Red
        $dataProtectionLogs | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
    
    # Verificar logs para erros do libssl
    Write-Host "`nVerificando logs do libssl..." -ForegroundColor Yellow
    $libsslLogs = docker logs $apiContainer 2>&1 | Select-String "libssl"
    
    if ($libsslLogs.Count -eq 0) {
        Write-Host "✓ Não há erros do libssl nos logs!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Ainda há erros do libssl:" -ForegroundColor Red
        $libsslLogs | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
    
    # Verificar se as bibliotecas SSL estão disponíveis no container
    Write-Host "`nVerificando bibliotecas SSL no container..." -ForegroundColor Yellow
    try {
        $sslCheck = docker exec $apiContainer ls -la /usr/lib/x86_64-linux-gnu/libssl* 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Bibliotecas SSL encontradas no container:" -ForegroundColor Green
            $sslCheck | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
        } else {
            Write-Host "⚠ Erro ao verificar bibliotecas SSL no container" -ForegroundColor Red
        }
    } catch {
        Write-Host "⚠ Não foi possível verificar bibliotecas SSL: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Verificar se os volumes estão montados
    Write-Host "`nVerificando volumes montados..." -ForegroundColor Yellow
    $volumes = docker inspect $apiContainer | ConvertFrom-Json | Select-Object -ExpandProperty Mounts
    
    $dataProtectionVolume = $volumes | Where-Object { $_.Destination -eq "/home/appuser/.aspnet/DataProtection-Keys" }
    if ($dataProtectionVolume) {
        Write-Host "✓ Volume do DataProtection está montado corretamente" -ForegroundColor Green
        Write-Host "  Origem: $($dataProtectionVolume.Source)" -ForegroundColor Cyan
    } else {
        Write-Host "⚠ Volume do DataProtection não encontrado" -ForegroundColor Red
    }
    
    # Testar conectividade HTTP
    Write-Host "`nTestando conectividade HTTP..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5004" -Method GET -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✓ API respondendo corretamente (Status: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Erro ao conectar com a API: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Verificar health check se disponível
    Write-Host "`nTestando health check..." -ForegroundColor Yellow
    try {
        $healthResponse = Invoke-WebRequest -Uri "http://localhost:5004/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
        Write-Host "✓ Health check respondendo (Status: $($healthResponse.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "ℹ Health check endpoint não disponível ou com erro: $($_.Exception.Message)" -ForegroundColor Blue
    }
    
} else {
    Write-Host "✗ Container '$apiContainer' não está rodando" -ForegroundColor Red
    Write-Host "Execute 'docker-compose up -d' ou rebuild no Coolify para iniciar" -ForegroundColor Yellow
}

Write-Host "`n=== Verificação Concluída ===" -ForegroundColor Green
Write-Host "Se ainda houver problemas, execute um rebuild completo no Coolify." -ForegroundColor Yellow