#!/bin/bash

echo "=== DEBUG SCRIPT PARA API ==="
echo "Data/Hora: $(date)"
echo ""

echo "1. Verificando status dos containers..."
docker-compose -f coolify-debug.yml ps
echo ""

echo "2. Verificando logs recentes da API (últimos 50 linhas)..."
docker-compose -f coolify-debug.yml logs --tail=50 api
echo ""

echo "3. Testando conectividade com PostgreSQL..."
if docker-compose -f coolify-debug.yml exec -T postgres pg_isready -U postgres; then
    echo "✅ PostgreSQL está respondendo"
else
    echo "❌ PostgreSQL não está respondendo"
fi
echo ""

echo "4. Verificando se API está respondendo..."
if curl -s -f http://localhost:5004/ > /dev/null; then
    echo "✅ API está respondendo na porta 5004"
else
    echo "❌ API não está respondendo na porta 5004"
fi
echo ""

echo "5. Testando endpoint de health (se existir)..."
if curl -s -f http://localhost:5004/health > /dev/null; then
    echo "✅ Health endpoint está funcionando"
    curl -s http://localhost:5004/health | jq . 2>/dev/null || curl -s http://localhost:5004/health
else
    echo "❌ Health endpoint não está disponível"
fi
echo ""

echo "6. Verificando variáveis de ambiente na API..."
echo "Variáveis de conexão:"
docker-compose -f coolify-debug.yml exec -T api env | grep -E "(DB_|Connection|ASPNET)" | head -10
echo ""

echo "7. Verificando processos dentro do container da API..."
docker-compose -f coolify-debug.yml exec -T api ps aux
echo ""

echo "8. Verificando uso de recursos..."
echo "Memória e CPU dos containers:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
echo ""

echo "9. Verificando últimos eventos do Docker..."
docker events --since="5m" --until="now" --filter container=abastecimento-api
echo ""

echo "=== FIM DO DEBUG ==="
echo "Para monitoramento contínuo dos logs: docker-compose -f coolify-debug.yml logs -f api"