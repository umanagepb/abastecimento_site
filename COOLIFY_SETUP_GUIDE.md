# 🚀 Guia Completo: Configuração no Coolify

## 📋 Pré-requisitos

1. **Conta no Coolify** configurada
2. **Servidor** com Coolify instalado
3. **Domínios** configurados (opcional para teste)
4. **Repositório Git** com o código

## 🔧 Passo a Passo no Coolify

### 1. Criar Novo Projeto

1. Acesse seu painel do Coolify
2. Clique em **"New Project"**
3. Digite o nome: `abastecimento-system`
4. Clique em **"Create"**

### 2. Adicionar Repositório

1. No projeto criado, clique em **"New Resource"**
2. Selecione **"Git Repository"**
3. Configure:
   - **Repository URL**: `https://github.com/umanagepb/abastecimento_site.git`
   - **Branch**: `main`
   - **Build Pack**: `Docker Compose`
   - **Dockerfile**: Use o `docker-compose.yml` ou `coolify.yml`

### 3. Configurar Variáveis de Ambiente

Na seção **"Environment Variables"**, adicione:

```bash
# Banco de Dados
DB_PASSWORD=SuaSenhaPostgresSegura123!

# Autenticação JWT  
JWT_AUDIENCE=https://abastecimento.seudominio.com
JWT_SIGNING_KEY=sua-chave-jwt-super-secreta-aqui-128-bits

# Domínios (opcional para desenvolvimento)
API_DOMAIN=api-abastecimento.seudominio.com
WEB_DOMAIN=abastecimento.seudominio.com
```

### 4. Configurar Domínios (Opcional)

1. Vá para **"Domains"**
2. Adicione os domínios:
   - **Web App**: `abastecimento.seudominio.com`
   - **API**: `api-abastecimento.seudominio.com`
3. Configure **SSL automático** (Let's Encrypt)

### 5. Configurar Volumes Persistentes

1. Na seção **"Storages"**
2. Adicione volume para PostgreSQL:
   - **Name**: `postgres_data`
   - **Mount Path**: `/var/lib/postgresql/data`
   - **Host Path**: `/data/abastecimento/postgres`

### 6. Deploy da Aplicação

1. Clique em **"Deploy"**
2. Aguarde o build e deploy de todos os serviços
3. Monitore os logs para verificar se tudo está funcionando

## 📊 Monitoramento

### Verificar Status dos Serviços

1. **Database**: Deve estar "Healthy"
2. **API**: Deve responder em `/health`
3. **Web**: Deve responder em `/health`

### URLs de Teste

- **Aplicação Web**: `https://abastecimento.seudominio.com`
- **API Health**: `https://api-abastecimento.seudominio.com/health`
- **Logs**: Disponíveis no painel do Coolify

## 🛠️ Configuração Alternativa (Sem Docker Compose)

Se preferir configurar serviços individuais:

### 1. PostgreSQL Database

```yaml
Name: abastecimento-db
Image: postgres:15-alpine
Environment:
  POSTGRES_DB: abastecimento
  POSTGRES_USER: postgres
  POSTGRES_PASSWORD: ${DB_PASSWORD}
Volumes:
  postgres_data: /var/lib/postgresql/data
```

### 2. API Service

```yaml
Name: abastecimento-api
Build Path: ./abastecimento_api
Port: 5004
Environment:
  ASPNETCORE_ENVIRONMENT: Production
  ConnectionStrings__ConnectionString: XpoProvider=Postgres;User ID=postgres;Password=${DB_PASSWORD};Server=abastecimento-db;Port=5432;Database=abastecimento
  Authentication__Jwt__Audience: ${JWT_AUDIENCE}
  Authentication__Jwt__IssuerSigningKey: ${JWT_SIGNING_KEY}
```

### 3. Web Application

```yaml
Name: abastecimento-web
Build Path: ./abastecaonline
Port: 5003
Environment:
  ASPNETCORE_ENVIRONMENT: Production
  ConnectionStrings__ConnectionString: XpoProvider=Postgres;User ID=postgres;Password=${DB_PASSWORD};Server=abastecimento-db;Port=5432;Database=abastecimento
  Authentication__Jwt__Audience: ${JWT_AUDIENCE}
  Authentication__Jwt__IssuerSigningKey: ${JWT_SIGNING_KEY}
  ApiUrl: http://abastecimento-api:5004
Domain: abastecimento.seudominio.com
```

## 🔍 Troubleshooting

### Problemas Comuns

1. **Build falha**
   - Verifique se os Dockerfiles estão corretos
   - Confirme se as dependências .NET estão disponíveis

2. **Banco não conecta**
   - Verifique `DB_PASSWORD`
   - Confirme se o PostgreSQL iniciou primeiro

3. **SSL não funciona**
   - Aguarde alguns minutos para provisionamento
   - Verifique se o domínio está apontando para o servidor

### Comandos Úteis

```bash
# Ver logs do PostgreSQL
docker logs abastecimento-db

# Ver logs da API
docker logs abastecimento-api

# Ver logs da aplicação web
docker logs abastecimento-web

# Testar conectividade do banco
docker exec -it abastecimento-db psql -U postgres -d abastecimento -c "SELECT version();"
```

## 🔐 Segurança

### Variáveis Sensíveis

- ✅ Use senhas fortes para `DB_PASSWORD`
- ✅ Gere chave JWT única para `JWT_SIGNING_KEY`
- ✅ Configure HTTPS em produção
- ✅ Restrinja acesso ao banco de dados

### Backup

Configure backup automático do volume `postgres_data`:

```bash
# Backup manual
docker exec abastecimento-db pg_dump -U postgres abastecimento > backup.sql

# Restaurar backup
docker exec -i abastecimento-db psql -U postgres abastecimento < backup.sql
```

## 📈 Próximos Passos

1. **Configurar monitoramento** com alertas
2. **Implementar CI/CD** para deploy automático
3. **Configurar backup automático** do banco
4. **Adicionar load balancer** se necessário
5. **Configurar logs centralizados**

## 💡 Dicas Importantes

- **Teste local** primeiro com `docker-compose up`
- **Use domínios de teste** antes da produção
- **Monitore recursos** (CPU, RAM, disco)
- **Configure alertas** para falhas de serviço
- **Mantenha backups** regulares do banco