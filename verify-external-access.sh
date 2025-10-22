#!/bin/bash

# Script de Verificação de Acesso Externo - Abastecimento API
# Usage: ./verify-external-access.sh [HOST] [PORT]

HOST=${1:-localhost}
PORT=${2:-5004}
BASE_URL="http://${HOST}:${PORT}"

echo "🔍 Verificando acesso externo para Abastecimento API..."
echo "📍 URL Base: ${BASE_URL}"
echo ""

# Função para testar endpoint
test_endpoint() {
    local endpoint=$1
    local expected_status=${2:-200}
    local url="${BASE_URL}${endpoint}"
    
    echo -n "  Testing ${endpoint}... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" "${url}" 2>/dev/null)
    
    if [ "$response" = "$expected_status" ]; then
        echo "✅ OK (${response})"
        return 0
    else
        echo "❌ FAIL (${response})"
        return 1
    fi
}

# Função para testar conectividade básica
test_connectivity() {
    echo "🌐 Testando conectividade básica..."
    
    if command -v nc >/dev/null 2>&1; then
        if nc -z "${HOST}" "${PORT}" 2>/dev/null; then
            echo "  ✅ Porta ${PORT} está acessível em ${HOST}"
        else
            echo "  ❌ Porta ${PORT} não está acessível em ${HOST}"
            return 1
        fi
    else
        echo "  ⚠️  netcat não disponível, pulando teste de conectividade"
    fi
}

# Função para obter informações do sistema
get_system_info() {
    echo "📊 Informações do Sistema:"
    echo "  Host: ${HOST}"
    echo "  Port: ${PORT}"
    echo "  Date: $(date)"
    
    if [ "${HOST}" = "localhost" ] || [ "${HOST}" = "127.0.0.1" ]; then
        echo "  Local IP: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    fi
    echo ""
}

# Executar testes
main() {
    get_system_info
    
    # Teste de conectividade
    if ! test_connectivity; then
        echo ""
        echo "❌ Falha na conectividade básica. Verifique se:"
        echo "   - O container está rodando: docker ps | grep abastecimento_api"
        echo "   - A porta está mapeada: docker port abastecimento_api"
        echo "   - O firewall não está bloqueando a porta ${PORT}"
        exit 1
    fi
    
    echo ""
    echo "🧪 Testando endpoints da API..."
    
    # Testar endpoints comuns
    failed_tests=0
    
    # Health check
    if ! test_endpoint "/health"; then
        ((failed_tests++))
    fi
    
    # Swagger (pode retornar 404 se não estiver habilitado)
    test_endpoint "/swagger" "200|404"
    
    # API root (pode retornar diferentes códigos)
    test_endpoint "/" "200|404|401"
    
    echo ""
    
    # Resultado final
    if [ $failed_tests -eq 0 ]; then
        echo "🎉 Todos os testes essenciais passaram!"
        echo ""
        echo "📋 Próximos passos:"
        echo "   - Acesse ${BASE_URL} no seu navegador"
        echo "   - Teste endpoints específicos da sua aplicação"
        echo "   - Configure CORS se necessário para acesso web"
    else
        echo "⚠️  Alguns testes falharam. Verifique:"
        echo "   - Logs do container: docker logs abastecimento_api"
        echo "   - Configurações no appsettings.production.json"
        echo "   - Variáveis de ambiente no docker-compose.yml"
    fi
    
    echo ""
    echo "🔧 Comandos úteis:"
    echo "   docker logs abastecimento_api --tail 50"
    echo "   docker exec -it abastecimento_api env | grep ASPNET"
    echo "   curl -v ${BASE_URL}/health"
}

# Verificar se curl está disponível
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ curl não está instalado. Por favor, instale curl para executar este script."
    exit 1
fi

# Executar função principal
main