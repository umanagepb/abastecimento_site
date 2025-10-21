#!/bin/bash

# Script de verificação da aplicação Abastecimento
# Execute este script após o deploy para verificar se tudo está funcionando

echo "🔍 Verificando status da aplicação Abastecimento..."
echo "================================================"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar se um serviço está rodando
check_service() {
    local service_name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Verificando $service_name... "
    
    if command -v curl > /dev/null; then
        response_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
        if [ "$response_code" = "$expected_status" ]; then
            echo -e "${GREEN}✅ OK (HTTP $response_code)${NC}"
            return 0
        else
            echo -e "${RED}❌ FALHA (HTTP $response_code)${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️  curl não disponível${NC}"
        return 2
    fi
}

# Função para verificar container Docker
check_container() {
    local container_name=$1
    echo -n "Verificando container $container_name... "
    
    if docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-healthcheck")
        if [ "$status" = "healthy" ] || [ "$status" = "no-healthcheck" ]; then
            echo -e "${GREEN}✅ Rodando${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  Status: $status${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ Não encontrado${NC}"
        return 1
    fi
}

# Função para verificar conectividade do banco
check_database() {
    echo -n "Verificando banco de dados... "
    
    if docker exec abastecimento-db pg_isready -U postgres > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Conectado${NC}"
        
        # Verificar se o banco existe
        echo -n "Verificando banco 'abastecimento'... "
        if docker exec abastecimento-db psql -U postgres -lqt | cut -d \| -f 1 | grep -qw abastecimento; then
            echo -e "${GREEN}✅ Existe${NC}"
        else
            echo -e "${YELLOW}⚠️  Banco não encontrado${NC}"
        fi
    else
        echo -e "${RED}❌ Não conectado${NC}"
        return 1
    fi
}

# URLs para verificação (ajuste conforme seus domínios)
WEB_URL="${WEB_DOMAIN:-http://localhost:5003}"
API_URL="${API_DOMAIN:-http://localhost:5004}"

echo "🐳 Verificando containers Docker..."
echo "-----------------------------------"
check_container "abastecimento-db"
check_container "abastecimento-api"  
check_container "abastecimento-web"

echo ""
echo "🔗 Verificando conectividade..."
echo "-------------------------------"
check_database

echo ""
echo "🌐 Verificando endpoints HTTP..."
echo "-------------------------------"
check_service "API Health" "$API_URL/health"
check_service "Web Application" "$WEB_URL/health"
check_service "Web Home" "$WEB_URL" 200

echo ""
echo "📊 Status dos recursos..."
echo "------------------------"

# Verificar uso de CPU e memória dos containers
if command -v docker > /dev/null; then
    echo "Container Stats:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
        abastecimento-db abastecimento-api abastecimento-web 2>/dev/null || echo "Containers não encontrados"
fi

echo ""
echo "🔧 Verificando variáveis de ambiente..."
echo "--------------------------------------"

required_vars=("DB_PASSWORD" "JWT_AUDIENCE" "JWT_SIGNING_KEY")
for var in "${required_vars[@]}"; do
    if [ -n "${!var}" ]; then
        echo -e "$var: ${GREEN}✅ Configurada${NC}"
    else
        echo -e "$var: ${RED}❌ Não configurada${NC}"
    fi
done

echo ""
echo "📝 Verificando logs recentes..."
echo "------------------------------"

# Mostrar últimas linhas dos logs
echo "=== Logs da API (últimas 5 linhas) ==="
docker logs --tail 5 abastecimento-api 2>/dev/null || echo "Container não encontrado"

echo ""
echo "=== Logs da Web (últimas 5 linhas) ==="
docker logs --tail 5 abastecimento-web 2>/dev/null || echo "Container não encontrado"

echo ""
echo "✅ Verificação concluída!"
echo "========================"

# URLs úteis
echo ""
echo "🔗 URLs da aplicação:"
echo "Web Application: $WEB_URL"
echo "API Health Check: $API_URL/health" 
echo "API Swagger: $API_URL/swagger (se habilitado)"

echo ""
echo "💡 Dicas:"
echo "- Se algum serviço falhou, verifique os logs: docker logs <container_name>"
echo "- Para reiniciar um serviço: docker restart <container_name>"
echo "- Para ver todas as variáveis: docker exec <container_name> env"