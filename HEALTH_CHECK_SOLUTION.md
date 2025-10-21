# Solução para Problemas de Health Check

## Problema Identificado

O erro principal é que o container PostgreSQL está falhando no health check, causando falha em toda a stack de dependências:

```
Container postgres-s880sswog8k444wg44os48gc-224533510779 is unhealthy
dependency failed to start: container postgres-s880sswog8k444wg44os48gc-224533510779 is unhealthy
```

## Correções Implementadas

### 1. **Melhorias no Health Check do PostgreSQL**

- **Adicionado `start_period`**: 30s para dar tempo ao PostgreSQL inicializar
- **Melhorado o comando de test**: `pg_isready -U postgres -d abastecimento || exit 1`
- **Aumentado retries**: de 5 para 10
- **Reduzido interval**: de 30s para 10s para detecção mais rápida
- **Adicionado configuração de autenticação**: `POSTGRES_INITDB_ARGS`

### 2. **Melhorias nos Health Checks das Aplicações**

- **Adicionado `start_period`**: 60s para API e 90s para Web
- **Melhorado formato do comando**: usando `CMD-SHELL` com `|| exit 1`
- **Aumentado retries**: de 3 para 5

### 3. **Configuração PostgreSQL Robusta**

```yaml
postgres:
  image: postgres:15-alpine
  environment:
    POSTGRES_DB: abastecimento
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: ${DB_PASSWORD}
    POSTGRES_INITDB_ARGS: "--auth-host=scram-sha-256 --auth-local=scram-sha-256"
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U postgres -d abastecimento || exit 1"]
    interval: 10s
    timeout: 5s
    retries: 10
    start_period: 30s
```

## Como Implementar a Correção

### 1. **No Coolify:**

1. Faça commit das mudanças no `coolify.yml`
2. Execute um novo deploy
3. As novas configurações de health check serão aplicadas

### 2. **Verificação Manual (se necessário):**

```bash
# Verificar se o PostgreSQL está saudável
docker exec <postgres-container> pg_isready -U postgres -d abastecimento

# Verificar logs do PostgreSQL
docker logs <postgres-container>

# Verificar health status
docker inspect <postgres-container> --format='{{.State.Health.Status}}'
```

### 3. **Variáveis de Ambiente Obrigatórias:**

Certifique-se de que estas variáveis estão configuradas no Coolify:

- `DB_PASSWORD`: Senha forte para PostgreSQL
- `JWT_AUDIENCE`: URL do seu domínio
- `JWT_SIGNING_KEY`: Chave secreta para JWT
- `API_DOMAIN`: api.seu-dominio.com
- `WEB_DOMAIN`: seu-dominio.com

## Sequência de Inicialização Corrigida

1. **PostgreSQL** (30s start_period) → Health check a cada 10s
2. **API** (60s start_period) → Aguarda PostgreSQL healthy
3. **Web** (90s start_period) → Aguarda API healthy

## Troubleshooting Adicional

Se o problema persistir:

1. **Verificar logs detalhados:**
   ```bash
   docker logs <container-name> --tail 50
   ```

2. **Testar conectividade do banco manualmente:**
   ```bash
   docker exec <postgres-container> psql -U postgres -d abastecimento -c "SELECT 1;"
   ```

3. **Verificar se os endpoints /health existem:**
   - API: `http://localhost:5004/health`
   - Web: `http://localhost:5003/health`

4. **Se os endpoints /health não existirem**, você pode removê-los temporariamente e usar verificações de porta:
   ```yaml
   healthcheck:
     test: ["CMD-SHELL", "netstat -an | grep :5004 || exit 1"]
   ```

## Próximos Passos

1. Commit das mudanças
2. Novo deploy no Coolify
3. Monitorar logs durante a inicialização
4. Verificar se todos os containers ficam healthy
5. Testar acesso às aplicações

As correções implementadas devem resolver o problema de health check do PostgreSQL e permitir que toda a stack inicialize corretamente.