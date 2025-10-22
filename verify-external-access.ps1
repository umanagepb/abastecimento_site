# Script de Verificação de Acesso Externo - Abastecimento API (PowerShell)
# Usage: .\verify-external-access.ps1 [-Host "localhost"] [-Port 5004]

param(
    [string]$Host = "localhost",
    [int]$Port = 5004
)

$BaseUrl = "http://${Host}:${Port}"

Write-Host "🔍 Verificando acesso externo para Abastecimento API..." -ForegroundColor Cyan
Write-Host "📍 URL Base: $BaseUrl" -ForegroundColor Yellow
Write-Host ""

# Função para testar endpoint
function Test-Endpoint {
    param(
        [string]$Endpoint,
        [int]$ExpectedStatus = 200
    )
    
    $url = "${BaseUrl}${Endpoint}"
    Write-Host "  Testing ${Endpoint}... " -NoNewline
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10 -ErrorAction Stop
        $statusCode = [int]$response.StatusCode
        
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "✅ OK ($statusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ UNEXPECTED ($statusCode)" -ForegroundColor Red
            return $false
        }
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq $ExpectedStatus) {
            Write-Host "✅ OK ($statusCode)" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ FAIL ($statusCode)" -ForegroundColor Red
            return $false
        }
    }
}

# Função para testar conectividade básica
function Test-Connectivity {
    Write-Host "🌐 Testando conectividade básica..." -ForegroundColor Cyan
    
    try {
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        $connect = $tcpClient.BeginConnect($Host, $Port, $null, $null)
        $wait = $connect.AsyncWaitHandle.WaitOne(3000, $false)
        
        if ($wait) {
            $tcpClient.EndConnect($connect)
            Write-Host "  ✅ Porta $Port está acessível em $Host" -ForegroundColor Green
            $tcpClient.Close()
            return $true
        } else {
            Write-Host "  ❌ Porta $Port não está acessível em $Host" -ForegroundColor Red
            $tcpClient.Close()
            return $false
        }
    }
    catch {
        Write-Host "  ❌ Erro ao testar conectividade: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Função para obter informações do sistema
function Get-SystemInfo {
    Write-Host "📊 Informações do Sistema:" -ForegroundColor Cyan
    Write-Host "  Host: $Host"
    Write-Host "  Port: $Port"
    Write-Host "  Date: $(Get-Date)"
    
    if ($Host -eq "localhost" -or $Host -eq "127.0.0.1") {
        try {
            $localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -First 1).IPAddress
            Write-Host "  Local IP: $localIP"
        }
        catch {
            Write-Host "  Local IP: N/A"
        }
    }
    Write-Host ""
}

# Função principal
function Main {
    Get-SystemInfo
    
    # Teste de conectividade
    if (-not (Test-Connectivity)) {
        Write-Host ""
        Write-Host "❌ Falha na conectividade básica. Verifique se:" -ForegroundColor Red
        Write-Host "   - O container está rodando: docker ps | grep abastecimento_api"
        Write-Host "   - A porta está mapeada: docker port abastecimento_api"
        Write-Host "   - O firewall não está bloqueando a porta $Port"
        return
    }
    
    Write-Host ""
    Write-Host "🧪 Testando endpoints da API..." -ForegroundColor Cyan
    
    # Testar endpoints comuns
    $failedTests = 0
    
    # Health check
    if (-not (Test-Endpoint "/health")) {
        $failedTests++
    }
    
    # API root
    Test-Endpoint "/" 200
    
    Write-Host ""
    
    # Resultado final
    if ($failedTests -eq 0) {
        Write-Host "🎉 Todos os testes essenciais passaram!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Próximos passos:" -ForegroundColor Yellow
        Write-Host "   - Acesse $BaseUrl no seu navegador"
        Write-Host "   - Teste endpoints específicos da sua aplicação"
        Write-Host "   - Configure CORS se necessário para acesso web"
    } else {
        Write-Host "⚠️  Alguns testes falharam. Verifique:" -ForegroundColor Yellow
        Write-Host "   - Logs do container: docker logs abastecimento_api"
        Write-Host "   - Configurações no appsettings.production.json"
        Write-Host "   - Variáveis de ambiente no docker-compose.yml"
    }
    
    Write-Host ""
    Write-Host "🔧 Comandos úteis:" -ForegroundColor Cyan
    Write-Host "   docker logs abastecimento_api --tail 50"
    Write-Host "   docker exec -it abastecimento_api env | grep ASPNET"
    Write-Host "   Invoke-WebRequest -Uri $BaseUrl/health -Method GET"
}

# Executar função principal
Main