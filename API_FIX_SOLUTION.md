# Solução para API não Executando - Serviços Separados

## Problema Identificado
O serviço da API não está executando, enquanto PostgreSQL e Web funcionam corretamente.

## Solução: Separação em Serviços Independentes

### Arquivos Criados
1. **`coolify-postgres.yml`** - Serviço PostgreSQL isolado
2. **`coolify-api.yml`** - Serviço API isolado  
3. **`coolify-web.yml`** - Serviço Web/Blazor isolado
4. **`diagnose-api.ps1`** - Script de diagnóstico (Windows)
5. **`diagnose-api.sh`** - Script de diagnóstico (Linux/macOS)

### Vantagens da Separação
- ✅ **Diagnóstico Independente**: Cada serviço tem logs e métricas isolados
- ✅ **Deploy Seletivo**: Atualize apenas o serviço com problema
- ✅ **Escalabilidade**: Scale cada serviço conforme necessidade
- ✅ **Manutenção**: Falhas não propagam entre serviços
- ✅ **Debug**: Mais fácil identificar causa raiz dos problemas

## Passos para Implementação

### 1. Execute Diagnóstico Atual
```powershell
# Windows
.\diagnose-api.ps1

# Linux/macOS  
chmod +x diagnose-api.sh
./diagnose-api.sh
```

### 2. Deploy no Coolify (Ordem Importante)

#### A. PostgreSQL (Primeiro)
1. No Coolify, crie novo serviço "Docker Compose"
2. Use arquivo: `coolify-postgres.yml`
3. Configure variável: `DB_PASSWORD=senha_segura`
4. Deploy e aguarde ficar saudável

#### B. API (Segundo)  
1. Crie novo serviço "Docker Compose"
2. Use arquivo: `coolify-api.yml`
3. Configure variáveis:
   - `DB_PASSWORD=mesma_senha_postgres`
   - `JWT_SIGNING_KEY=chave_secreta_jwt`
   - `JWT_AUDIENCE=https://seu-dominio.com`
   - `DB_HOST=abastecimento-db`
   - `API_DOMAIN=api.seu-dominio.com`
4. **Importante**: Conecte à mesma rede do PostgreSQL
5. Deploy e aguarde ficar saudável

#### C. Web (Terceiro)
1. Crie novo serviço "Docker Compose"  
2. Use arquivo: `coolify-web.yml`
3. Configure variáveis:
   - `DB_PASSWORD=mesma_senha_postgres`
   - `JWT_SIGNING_KEY=mesma_chave_da_api`
   - `JWT_AUDIENCE=https://seu-dominio.com`
   - `WEB_DOMAIN=seu-dominio.com`
   - `API_URL=http://abastecimento-api:5004`
   - `DB_HOST=abastecimento-db`
4. **Importante**: Conecte à mesma rede dos outros serviços
5. Deploy

### 3. Configuração de Rede
Todos os serviços devem usar a rede: `abastecimento-network`

```bash
# Verificar rede criada
docker network ls | grep abastecimento

# Inspecionar conectividade
docker network inspect abastecimento-network
```

### 4. Testes de Validação

#### Conectividade Entre Serviços
```bash
# API -> PostgreSQL
docker exec abastecimento-api ping postgres

# Web -> API  
docker exec abastecimento-web ping api

# Web -> PostgreSQL
docker exec abastecimento-web ping postgres
```

#### Health Checks
```bash
# PostgreSQL
docker exec abastecimento-db pg_isready -U postgres

# API
curl http://localhost:5004/health
curl http://localhost:5004/

# Web
curl http://localhost:5003/health
curl http://localhost:5003/
```

## Possíveis Causas da Falha da API

### 1. Problemas de Conectividade BD
- **Causa**: API não consegue conectar ao PostgreSQL
- **Solução**: Verificar `DB_HOST` e conectividade de rede
- **Debug**: `docker exec abastecimento-api ping postgres`

### 2. Configuração JWT Incorreta
- **Causa**: Chaves JWT inválidas ou não definidas
- **Solução**: Verificar `JWT_SIGNING_KEY` e `JWT_AUDIENCE`
- **Debug**: Verificar logs da API para erros de JWT

### 3. Problemas de Build
- **Causa**: Dockerfile ou dependências com problemas
- **Solução**: Verificar logs de build do container
- **Debug**: `docker logs abastecimento-api`

### 4. Falta de Recursos  
- **Causa**: Memória/CPU insuficientes
- **Solução**: Aumentar limites no docker-compose
- **Debug**: `docker stats abastecimento-api`

### 5. Porta em Uso
- **Causa**: Porta 5004 já sendo usada
- **Solução**: Verificar conflitos de porta
- **Debug**: `netstat -tlnp | grep 5004`

## Monitoramento Contínuo

### Logs em Tempo Real
```bash
# API
docker logs -f abastecimento-api

# PostgreSQL  
docker logs -f abastecimento-db

# Web
docker logs -f abastecimento-web
```

### Status dos Serviços
```bash
# Ver todos os containers
docker ps -a --filter "name=abastecimento"

# Stats de recursos
docker stats abastecimento-api abastecimento-web abastecimento-db
```

## Rollback se Necessário

Se a separação causar problemas, você pode voltar ao `coolify-production.yml` original:

```bash
# Parar serviços separados
docker stop abastecimento-api abastecimento-web abastecimento-db

# Remover containers
docker rm abastecimento-api abastecimento-web abastecimento-db

# Deploy com arquivo original
# Use coolify-production.yml no Coolify
```

## Próximos Passos

1. ✅ Execute o diagnóstico atual
2. ✅ Faça backup dos dados importantes  
3. ✅ Deploy PostgreSQL primeiro
4. ✅ Deploy API em seguida
5. ✅ Deploy Web por último
6. ✅ Teste conectividade entre serviços
7. ✅ Configure monitoramento contínuo

## Suporte Adicional

- Consulte `DEPLOY_SEPARADO_GUIDE.md` para instruções detalhadas
- Use scripts de diagnóstico para identificar problemas específicos
- Logs detalhados estarão disponíveis para cada serviço individualmente