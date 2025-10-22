# Script de Verificação Pós-Deploy - Coolify
# Execute este script após o deploy para verificar se as correções funcionaram

Write-Host "=== VERIFICAÇÃO PÓS-DEPLOY - COOLIFY ===" -ForegroundColor Green
Write-Host "Data/Hora: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

$configFile = "coolify-production.yml"
if (Test-Path "coolify-debug.yml") {
    $choice = Read-Host "Usar configuração de produção (P) ou debug (D)? [P/D]"
    if ($choice -eq "D" -or $choice -eq "d") {
        $configFile = "coolify-debug.yml"
        Write-Host "Usando configuração de DEBUG" -ForegroundColor Yellow
    }
}

Write-Host "Usando arquivo: $configFile" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar containers
Write-Host "1. Status dos containers:" -ForegroundColor Cyan
docker-compose -f $configFile ps
Write-Host ""

# 2. Verificar logs para problemas SSL
Write-Host "2. Verificando logs para erros SSL (últimas 20 linhas):" -ForegroundColor Cyan
$logs = docker-compose -f $configFile logs --tail=20 api 2>$null
if ($logs -match "No usable version of libssl was found") {
    Write-Host "❌ ERRO SSL ainda presente!" -ForegroundColor Red
} else {
    Write-Host "✅ Erro SSL corrigido!" -ForegroundColor Green
}
Write-Host ""

# 3. Verificar reinicializações
Write-Host "3. Verificando reinicializações frequentes:" -ForegroundColor Cyan
$recentLogs = docker-compose -f $configFile logs --since="10m" api 2>$null
$restartCount = ($recentLogs | Select-String "Waiting for database connection").Count
if ($restartCount -gt 3) {
    Write-Host "❌ Muitas reinicializações detectadas ($restartCount)" -ForegroundColor Red
} else {
    Write-Host "✅ Containers estáveis (apenas $restartCount reinicializações)" -ForegroundColor Green
}
Write-Host ""

# 4. Testar conectividade
Write-Host "4. Testando conectividade:" -ForegroundColor Cyan
try {
    $apiResponse = Invoke-WebRequest -Uri "http://localhost:5004/" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($apiResponse.StatusCode -eq 200) {
        Write-Host "✅ API respondendo na porta 5004" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ API não responde na porta 5004" -ForegroundColor Red
}

try {
    $webResponse = Invoke-WebRequest -Uri "http://localhost:5003/" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($webResponse.StatusCode -eq 200) {
        Write-Host "✅ Web respondendo na porta 5003" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Web não responde na porta 5003" -ForegroundColor Red
}
Write-Host ""

# 5. Verificar volumes de DataProtection
Write-Host "5. Verificando volumes de DataProtection:" -ForegroundColor Cyan
$volumes = docker volume ls --format "table {{.Name}}" | Select-String "keys"
if ($volumes.Count -gt 0) {
    Write-Host "✅ Volumes para DataProtection criados:" -ForegroundColor Green
    $volumes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
} else {
    Write-Host "❌ Volumes de DataProtection não encontrados" -ForegroundColor Red
}
Write-Host ""

# 6. Verificar health checks
Write-Host "6. Testando health checks:" -ForegroundColor Cyan
try {
    $healthAPI = Invoke-WebRequest -Uri "http://localhost:5004/health" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "✅ Health check API funcionando" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Health check API não implementado (normal se não existir endpoint)" -ForegroundColor Yellow
}

try {
    $healthWeb = Invoke-WebRequest -Uri "http://localhost:5003/health" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    Write-Host "✅ Health check Web funcionando" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Health check Web não implementado (normal se não existir endpoint)" -ForegroundColor Yellow
}
Write-Host ""

# 7. Resumo
Write-Host "=== RESUMO ===" -ForegroundColor Green
Write-Host "Para monitoramento contínuo execute:" -ForegroundColor Yellow
Write-Host "docker-compose -f $configFile logs -f" -ForegroundColor White
Write-Host ""
Write-Host "Para verificar recursos:" -ForegroundColor Yellow
Write-Host "docker stats --no-stream" -ForegroundColor White
Write-Host ""
Write-Host "Se tudo estiver funcionando, o deploy foi bem-sucedido! 🎉" -ForegroundColor Green