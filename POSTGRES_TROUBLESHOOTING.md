# Guia de Solução de Problemas - PostgreSQL Health Check

## Problema Identificado
O container PostgreSQL está falhando no health check, impedindo que os outros serviços iniciem.

## Mudanças Feitas no coolify.yml

### 1. PostgreSQL Service - Melhorias
- **Removido** `POSTGRES_INITDB_ARGS` que pode causar conflitos
- **Adicionado** `PGDATA: /var/lib/postgresql/data/pgdata` para separar dados
- **Aumentado** tempo de health check: start_period de 30s → 60s
- **Melhorado** comando de health check: especifica host e porta
- **Adicionado** `shm_size: 256mb` para memória compartilhada

### 2. API Service - Melhorias  
- **Mudado** de `curl` para `wget` (mais confiável em containers alpine)
- **Aumentado** start_period de 60s → 120s
- **Aumentado** timeout de 10s → 15s
- **Aumentado** retries de 5 → 8

### 3. Web Service - Melhorias
- **Mudado** de `curl` para `wget`
- **Aumentado** start_period de 90s → 150s
- **Aumentado** timeout de 10s → 15s
- **Aumentado** retries de 5 → 8

## Passos para Debugging

### Passo 1: Usar versão de debug (sem health checks)
```bash
# Renomeie o arquivo atual
mv coolify.yml coolify-production.yml

# Use a versão de debug
mv coolify-debug.yml coolify.yml
```

### Passo 2: Verificar logs do PostgreSQL
```bash
# No Coolify, acesse os logs do container postgres
# Ou via Docker CLI:
docker logs postgres-s880sswog8k444wg44os48gc-[ID]
```

### Passo 3: Testar conectividade do PostgreSQL
```bash
# Conectar ao container PostgreSQL
docker exec -it postgres-s880sswog8k444wg44os48gc-[ID] bash

# Dentro do container, testar:
pg_isready -U postgres -h localhost -p 5432
psql -U postgres -l
```

### Passo 4: Verificar variáveis de ambiente
Confirme que estas variáveis estão definidas no Coolify:
- `DB_PASSWORD` - senha do PostgreSQL
- `JWT_AUDIENCE` - domínio da aplicação  
- `JWT_SIGNING_KEY` - chave secreta JWT
- `API_DOMAIN` - domínio da API
- `WEB_DOMAIN` - domínio da web

### Passo 5: Verificar recursos do sistema
- Memória disponível (PostgreSQL precisa de pelo menos 256MB)
- Espaço em disco para volumes
- Permissões de arquivo no volume de dados

## Possíveis Causas do Problema

### 1. Recursos Insuficientes
- Pouca memória RAM disponível
- Pouco espaço em disco
- CPU sobrecarregada

### 2. Problemas de Permissão
- Volume PostgreSQL com permissões incorretas
- Container rodando com usuário sem privilégios

### 3. Conflitos de Porta
- Porta 5432 já em uso por outro processo

### 4. Problemas de Configuração
- Variável `DB_PASSWORD` não definida ou inválida
- Configurações de autenticação incorretas

### 5. Problemas de Rede
- Container não consegue resolver DNS interno
- Problemas com bridge network

## Comandos de Debug Úteis

```bash
# Verificar status dos containers
docker ps -a

# Logs detalhados do PostgreSQL
docker logs -f postgres-container-name

# Verificar uso de recursos
docker stats

# Inspecionar configuração do container
docker inspect postgres-container-name

# Testar conexão de rede entre containers
docker exec api-container-name ping postgres

# Verificar arquivos no volume
docker exec postgres-container-name ls -la /var/lib/postgresql/data/
```

## Solução Recomendada

1. **Use primeiro a versão debug** para identificar o problema específico
2. **Verifique os logs** do PostgreSQL para erros detalhados
3. **Confirme as variáveis de ambiente** estão corretas
4. **Teste conectividade** manualmente
5. **Volte para a versão com health checks** após corrigir o problema

## Após Resolver o Problema

Quando o PostgreSQL estiver funcionando na versão debug:
```bash
# Volte para a versão com health checks
mv coolify.yml coolify-debug-backup.yml
mv coolify-production.yml coolify.yml
```

## Contato para Suporte
Se o problema persistir, forneça:
- Logs completos do container PostgreSQL
- Saída do comando `docker inspect` do container
- Lista de variáveis de ambiente configuradas
- Informações sobre recursos disponíveis (RAM, disco, CPU)