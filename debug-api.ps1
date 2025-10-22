# Debug Script para API - Versão PowerShell
Write-Host "=== DEBUG SCRIPT PARA API ===" -ForegroundColor Green
Write-Host "Data/Hora: $(Get-Date)" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. Verificando status dos containers..." -ForegroundColor Cyan
docker-compose -f coolify-debug.yml ps
Write-Host ""

Write-Host "2. Verificando logs recentes da API (últimos 50 linhas)..." -ForegroundColor Cyan
docker-compose -f coolify-debug.yml logs --tail=50 api
Write-Host ""

Write-Host "3. Testando conectividade com PostgreSQL..." -ForegroundColor Cyan
try {
    $pgResult = docker-compose -f coolify-debug.yml exec -T postgres pg_isready -U postgres 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ PostgreSQL está respondendo" -ForegroundColor Green
    } else {
        Write-Host "❌ PostgreSQL não está respondendo" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao verificar PostgreSQL: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "4. Verificando se API está respondendo..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:5004/" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ API está respondendo na porta 5004" -ForegroundColor Green
    } else {
        Write-Host "❌ API retornou status: $($response.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ API não está respondendo na porta 5004" -ForegroundColor Red
}
Write-Host ""

Write-Host "5. Testando endpoint de health (se existir)..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:5004/health" -TimeoutSec 10 -UseBasicParsing -ErrorAction SilentlyContinue
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✅ Health endpoint está funcionando" -ForegroundColor Green
        Write-Host "Resposta: $($healthResponse.Content)" -ForegroundColor Gray
    } else {
        Write-Host "❌ Health endpoint retornou status: $($healthResponse.StatusCode)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Health endpoint não está disponível" -ForegroundColor Red
}
Write-Host ""

Write-Host "6. Verificando variáveis de ambiente na API..." -ForegroundColor Cyan
Write-Host "Variáveis de conexão:" -ForegroundColor Yellow
docker-compose -f coolify-debug.yml exec -T api env | Select-String -Pattern "(DB_|Connection|ASPNET)" | Select-Object -First 10
Write-Host ""

Write-Host "7. Verificando processos dentro do container da API..." -ForegroundColor Cyan
docker-compose -f coolify-debug.yml exec -T api ps aux
Write-Host ""

Write-Host "8. Verificando uso de recursos..." -ForegroundColor Cyan
Write-Host "Memória e CPU dos containers:" -ForegroundColor Yellow
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
Write-Host ""

Write-Host "9. Verificando informações do Docker..." -ForegroundColor Cyan
Write-Host "Versão do Docker:" -ForegroundColor Yellow
docker --version
Write-Host ""

Write-Host "=== FIM DO DEBUG ===" -ForegroundColor Green
Write-Host "Para monitoramento contínuo dos logs execute:" -ForegroundColor Yellow
Write-Host "docker-compose -f coolify-debug.yml logs -f api" -ForegroundColor White