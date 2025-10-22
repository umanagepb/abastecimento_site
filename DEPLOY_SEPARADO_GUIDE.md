# Guia de Deploy com Serviços Separados no Coolify

Este guia explica como fazer o deploy dos serviços separadamente no Coolify para facilitar o diagnóstico e gerenciamento.

## Vantagens dos Serviços Separados

- **Diagnóstico independente**: Cada serviço pode ser analisado separadamente
- **Escalabilidade**: Cada serviço pode ser escalado independentemente
- **Manutenção**: Atualizações podem ser feitas em serviços específicos
- **Monitoramento**: Logs e métricas são isolados por serviço
- **Recuperação**: Falhas em um serviço não afetam os outros

## Ordem de Deploy

### 1. PostgreSQL (Primeiro)
```bash
# Arquivo: coolify-postgres.yml
# Este deve ser o primeiro serviço a ser criado
```

**Variáveis de ambiente obrigatórias:**
- `DB_PASSWORD`: Senha do PostgreSQL (use uma senha forte)

**Configurações no Coolify:**
1. Crie um novo serviço do tipo "Docker Compose"
2. Use o arquivo `coolify-postgres.yml`
3. Configure a variável `DB_PASSWORD`
4. **Importante**: Anote o nome da rede criada (será `abastecimento-network`)

### 2. API (Segundo)
```bash
# Arquivo: coolify-api.yml
# Aguarde o PostgreSQL estar saudável antes de iniciar
```

**Variáveis de ambiente obrigatórias:**
- `DB_PASSWORD`: Mesma senha do PostgreSQL
- `JWT_AUDIENCE`: URL do seu domínio (ex: https://meusite.com.br)
- `JWT_SIGNING_KEY`: Chave secreta para JWT (gere uma UUID)
- `DB_HOST`: Nome do container PostgreSQL (ex: abastecimento-db)
- `API_DOMAIN`: Domínio da API (ex: api.meusite.com.br)

**Configurações no Coolify:**
1. Crie um novo serviço do tipo "Docker Compose"
2. Use o arquivo `coolify-api.yml`
3. Configure todas as variáveis de ambiente
4. **Importante**: Use a mesma rede do PostgreSQL (`abastecimento-network`)

### 3. Web/Blazor (Terceiro)
```bash
# Arquivo: coolify-web.yml
# Aguarde API e PostgreSQL estarem saudáveis
```

**Variáveis de ambiente obrigatórias:**
- `DB_PASSWORD`: Mesma senha do PostgreSQL
- `JWT_AUDIENCE`: Mesma do serviço API
- `JWT_SIGNING_KEY`: Mesma chave do serviço API
- `WEB_DOMAIN`: Domínio principal (ex: meusite.com.br)
- `API_URL`: URL da API (ex: http://abastecimento-api:5004 ou https://api.meusite.com.br)
- `DB_HOST`: Nome do container PostgreSQL

**Configurações no Coolify:**
1. Crie um novo serviço do tipo "Docker Compose"
2. Use o arquivo `coolify-web.yml`
3. Configure todas as variáveis de ambiente
4. **Importante**: Use a mesma rede dos outros serviços

## Scripts de Diagnóstico

### Para Windows (PowerShell):
```powershell
.\diagnose-api.ps1
```

### Para Linux/macOS:
```bash
chmod +x diagnose-api.sh
./diagnose-api.sh
```

## Configuração de Rede no Coolify

### Opção 1: Rede Automática
O Coolify criará automaticamente a rede `abastecimento-network` quando você fizer o deploy do PostgreSQL primeiro.

### Opção 2: Rede Manual
Se necessário, você pode criar a rede manualmente:

```bash
docker network create abastecimento-network
```

## Verificação de Conectividade

### Entre Serviços
```bash
# Do container da API para PostgreSQL
docker exec abastecimento-api ping postgres

# Do container Web para API
docker exec abastecimento-web ping api
```

### Saúde dos Serviços
```bash
# PostgreSQL
docker exec abastecimento-db pg_isready -U postgres

# API
curl http://localhost:5004/health

# Web
curl http://localhost:5003/health
```

## Logs Específicos

### PostgreSQL
```bash
docker logs -f abastecimento-db
```

### API
```bash
docker logs -f abastecimento-api
```

### Web
```bash
docker logs -f abastecimento-web
```

## Troubleshooting Comum

### 1. API não conecta ao PostgreSQL
- Verifique se ambos estão na mesma rede
- Confirme se `DB_HOST` aponta para o nome correto do container PostgreSQL
- Teste conectividade: `docker exec abastecimento-api ping postgres`

### 2. Web não conecta à API
- Verifique se `API_URL` está correto
- Confirme se a API está respondendo: `curl http://api:5004/health`
- Verifique logs da API para erros

### 3. Problemas de JWT
- Confirme se `JWT_SIGNING_KEY` é a mesma em API e Web
- Verifique se `JWT_AUDIENCE` corresponde ao domínio correto

### 4. Container não inicia
- Verifique logs de build: `docker logs nome-do-container`
- Confirme se todas as variáveis de ambiente estão definidas
- Teste health checks individualmente

## Comandos Úteis

### Verificar todos os containers
```bash
docker ps -a --filter "name=abastecimento"
```

### Verificar rede
```bash
docker network inspect abastecimento-network
```

### Reiniciar serviço específico
```bash
docker restart abastecimento-api    # Apenas API
docker restart abastecimento-web    # Apenas Web
docker restart abastecimento-db     # Apenas PostgreSQL
```

### Verificar recursos
```bash
docker stats abastecimento-api abastecimento-web abastecimento-db
```

## Backup e Restore

### Backup PostgreSQL
```bash
docker exec abastecimento-db pg_dump -U postgres abastecimento > backup.sql
```

### Restore PostgreSQL
```bash
docker exec -i abastecimento-db psql -U postgres abastecimento < backup.sql
```