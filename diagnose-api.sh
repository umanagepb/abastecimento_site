#!/bin/bash
# Script de diagnóstico para o serviço da API
# Ajuda a identificar problemas no serviço da API que não está funcionando

echo "=== DIAGNÓSTICO DO SERVIÇO API ==="
echo "Data/Hora: $(date)"
echo ""

# Verificar se o container existe e está rodando
echo "1. Status do container da API:"
if docker ps -a --filter "name=abastecimento-api" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q abastecimento-api; then
    docker ps -a --filter "name=abastecimento-api" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "❌ Container abastecimento-api não encontrado"
fi
echo ""

# Verificar logs da API
echo "2. Últimas 50 linhas dos logs da API:"
if docker ps --filter "name=abastecimento-api" --format "{{.Names}}" | grep -q abastecimento-api; then
    docker logs --tail 50 abastecimento-api
else
    echo "❌ Container não está rodando - tentando mostrar logs do container parado:"
    docker logs --tail 50 abastecimento-api 2>/dev/null || echo "Nenhum log disponível"
fi
echo ""

# Verificar conectividade com PostgreSQL
echo "3. Teste de conectividade com PostgreSQL:"
if docker ps --filter "name=abastecimento-db" --format "{{.Names}}" | grep -q abastecimento-db; then
    echo "✅ Container PostgreSQL está rodando"
    # Testar conexão do container da API com PostgreSQL
    if docker ps --filter "name=abastecimento-api" --format "{{.Names}}" | grep -q abastecimento-api; then
        echo "Testando conexão API -> PostgreSQL:"
        docker exec abastecimento-api sh -c "apt-get update && apt-get install -y postgresql-client" 2>/dev/null
        docker exec abastecimento-api sh -c "pg_isready -h postgres -p 5432 -U postgres" 2>/dev/null || echo "❌ API não consegue conectar ao PostgreSQL"
    else
        echo "⚠️  Container API não está rodando para testar conexão"
    fi
else
    echo "❌ Container PostgreSQL não está rodando"
fi
echo ""

# Verificar portas
echo "4. Verificação de portas:"
echo "Porta 5004 (API):"
if netstat -tlnp 2>/dev/null | grep -q ":5004"; then
    echo "✅ Porta 5004 está sendo usada"
    netstat -tlnp 2>/dev/null | grep ":5004"
else
    echo "❌ Porta 5004 não está sendo usada"
fi
echo ""

# Verificar saúde da aplicação
echo "5. Teste de saúde da API:"
if curl -f -s -m 10 http://localhost:5004/health >/dev/null 2>&1; then
    echo "✅ Health check passou"
    curl -s http://localhost:5004/health | head -20
elif curl -f -s -m 10 http://localhost:5004/ >/dev/null 2>&1; then
    echo "✅ API responde na raiz"
else
    echo "❌ API não responde nos endpoints de saúde"
fi
echo ""

# Verificar recursos do sistema
echo "6. Uso de recursos:"
if docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" abastecimento-api 2>/dev/null; then
    echo "Recursos OK"
else
    echo "❌ Não foi possível obter estatísticas de recursos"
fi
echo ""

# Verificar variáveis de ambiente
echo "7. Variáveis de ambiente importantes:"
if docker ps --filter "name=abastecimento-api" --format "{{.Names}}" | grep -q abastecimento-api; then
    echo "ASPNETCORE_ENVIRONMENT:"
    docker exec abastecimento-api printenv ASPNETCORE_ENVIRONMENT 2>/dev/null || echo "Não definida"
    echo "ASPNETCORE_URLS:"
    docker exec abastecimento-api printenv ASPNETCORE_URLS 2>/dev/null || echo "Não definida"
    echo "DB_HOST:"
    docker exec abastecimento-api printenv DB_HOST 2>/dev/null || echo "Não definida"
else
    echo "❌ Container não está rodando"
fi
echo ""

echo "=== FIM DO DIAGNÓSTICO ==="
echo ""
echo "SUGESTÕES DE CORREÇÃO:"
echo "1. Se o container não está rodando, verifique os logs de build"
echo "2. Se há erros de conexão com BD, verifique se PostgreSQL está acessível"
echo "3. Se a porta não está sendo usada, verifique se o Kestrel está configurado corretamente"
echo "4. Verifique se todas as variáveis de ambiente necessárias estão definidas"