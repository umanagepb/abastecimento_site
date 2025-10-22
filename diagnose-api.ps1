# Script de diagnóstico para o serviço da API (PowerShell)
# Ajuda a identificar problemas no serviço da API que não está funcionando

Write-Host "=== DIAGNÓSTICO DO SERVIÇO API ===" -ForegroundColor Cyan
Write-Host "Data/Hora: $(Get-Date)" -ForegroundColor Gray
Write-Host ""

# Verificar se o container existe e está rodando
Write-Host "1. Status do container da API:" -ForegroundColor Yellow
try {
    $apiContainer = docker ps -a --filter "name=abastecimento-api" --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"
    if ($apiContainer -match "abastecimento-api") {
        Write-Host $apiContainer
    } else {
        Write-Host "❌ Container abastecimento-api não encontrado" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao verificar container: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar logs da API
Write-Host "2. Últimas 50 linhas dos logs da API:" -ForegroundColor Yellow
try {
    $runningApi = docker ps --filter "name=abastecimento-api" --format "{{.Names}}"
    if ($runningApi -match "abastecimento-api") {
        docker logs --tail 50 abastecimento-api
    } else {
        Write-Host "❌ Container não está rodando - tentando mostrar logs do container parado:" -ForegroundColor Red
        docker logs --tail 50 abastecimento-api 2>$null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Nenhum log disponível" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ Erro ao obter logs: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar conectividade com PostgreSQL
Write-Host "3. Teste de conectividade com PostgreSQL:" -ForegroundColor Yellow
try {
    $postgresContainer = docker ps --filter "name=abastecimento-db" --format "{{.Names}}"
    if ($postgresContainer -match "abastecimento-db") {
        Write-Host "✅ Container PostgreSQL está rodando" -ForegroundColor Green
        
        # Testar conexão do container da API com PostgreSQL
        $runningApi = docker ps --filter "name=abastecimento-api" --format "{{.Names}}"
        if ($runningApi -match "abastecimento-api") {
            Write-Host "Testando conexão API -> PostgreSQL:"
            $pgTest = docker exec abastecimento-api sh -c "command -v pg_isready" 2>$null
            if ($pgTest) {
                docker exec abastecimento-api pg_isready -h postgres -p 5432 -U postgres
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ Conexão com PostgreSQL OK" -ForegroundColor Green
                } else {
                    Write-Host "❌ API não consegue conectar ao PostgreSQL" -ForegroundColor Red
                }
            } else {
                Write-Host "⚠️  pg_isready não disponível no container da API" -ForegroundColor Yellow
            }
        } else {
            Write-Host "⚠️  Container API não está rodando para testar conexão" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Container PostgreSQL não está rodando" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao verificar PostgreSQL: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar portas
Write-Host "4. Verificação de portas:" -ForegroundColor Yellow
Write-Host "Porta 5004 (API):"
try {
    $port5004 = Get-NetTCPConnection -LocalPort 5004 -ErrorAction SilentlyContinue
    if ($port5004) {
        Write-Host "✅ Porta 5004 está sendo usada" -ForegroundColor Green
        $port5004 | Format-Table LocalAddress, LocalPort, State, OwningProcess
    } else {
        Write-Host "❌ Porta 5004 não está sendo usada" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao verificar porta: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar saúde da aplicação
Write-Host "5. Teste de saúde da API:" -ForegroundColor Yellow
try {
    $healthResponse = Invoke-WebRequest -Uri "http://localhost:5004/health" -TimeoutSec 10 -ErrorAction SilentlyContinue
    if ($healthResponse.StatusCode -eq 200) {
        Write-Host "✅ Health check passou" -ForegroundColor Green
        Write-Host $healthResponse.Content.Substring(0, [Math]::Min(200, $healthResponse.Content.Length))
    } else {
        # Tentar endpoint raiz
        $rootResponse = Invoke-WebRequest -Uri "http://localhost:5004/" -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($rootResponse.StatusCode -eq 200) {
            Write-Host "✅ API responde na raiz" -ForegroundColor Green
        } else {
            Write-Host "❌ API não responde nos endpoints de saúde" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "❌ API não responde: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar recursos do sistema
Write-Host "6. Uso de recursos:" -ForegroundColor Yellow
try {
    $stats = docker stats --no-stream --format "table {{.Container}}`t{{.CPUPerc}}`t{{.MemUsage}}`t{{.MemPerc}}" abastecimento-api
    if ($stats) {
        Write-Host $stats
    } else {
        Write-Host "❌ Não foi possível obter estatísticas de recursos" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao obter estatísticas: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Verificar variáveis de ambiente
Write-Host "7. Variáveis de ambiente importantes:" -ForegroundColor Yellow
try {
    $runningApi = docker ps --filter "name=abastecimento-api" --format "{{.Names}}"
    if ($runningApi -match "abastecimento-api") {
        Write-Host "ASPNETCORE_ENVIRONMENT:"
        $env1 = docker exec abastecimento-api printenv ASPNETCORE_ENVIRONMENT 2>$null
        Write-Host ($env1 ? $env1 : "Não definida")
        
        Write-Host "ASPNETCORE_URLS:"
        $env2 = docker exec abastecimento-api printenv ASPNETCORE_URLS 2>$null
        Write-Host ($env2 ? $env2 : "Não definida")
        
        Write-Host "DB_HOST:"
        $env3 = docker exec abastecimento-api printenv DB_HOST 2>$null
        Write-Host ($env3 ? $env3 : "Não definida")
    } else {
        Write-Host "❌ Container não está rodando" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erro ao verificar variáveis: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

Write-Host "=== FIM DO DIAGNÓSTICO ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUGESTÕES DE CORREÇÃO:" -ForegroundColor Yellow
Write-Host "1. Se o container não está rodando, verifique os logs de build"
Write-Host "2. Se há erros de conexão com BD, verifique se PostgreSQL está acessível"
Write-Host "3. Se a porta não está sendo usada, verifique se o Kestrel está configurado corretamente"
Write-Host "4. Verifique se todas as variáveis de ambiente necessárias estão definidas"