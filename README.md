# Sistema de Abastecimento - Configuração para Coolify

Este repositório contém uma aplicação .NET composta por:
- **abastecaonline**: Aplicação Blazor Server (Frontend)
- **abastecimento_api**: API Web (Backend)
- **PostgreSQL**: Banco de dados

## 🚀 Deploy no Coolify

### 1. Configuração de Variáveis de Ambiente

No Coolify, configure as seguintes variáveis de ambiente (secrets):

```bash
# Banco de dados
DB_PASSWORD=sua_senha_postgres_segura
DB_HOST=abastecimento-db
DB_PORT=5432
DB_NAME=abastecimento

# Autenticação JWT
JWT_AUDIENCE=https://seu-dominio.com
JWT_SIGNING_KEY=sua_chave_secreta_jwt_aqui

# URLs da aplicação
API_URL=https://api.seu-dominio.com
API_DOMAIN=api.seu-dominio.com
WEB_DOMAIN=seu-dominio.com
```

### 2. Estrutura dos Serviços

O sistema será implantado com 3 serviços:

1. **PostgreSQL Database** (`abastecimento-db`)
   - Imagem: `postgres:15-alpine`
   - Porto interno: 5432
   - Volume persistente para dados

2. **API Service** (`abastecimento-api`)
   - Build: `./abastecimento_api/Dockerfile`
   - Porto interno: 5004
   - Depende do banco de dados

3. **Web Application** (`abastecimento-web`)
   - Build: `./abastecaonline/Dockerfile`
   - Porto interno: 5003
   - Depende da API
   - Exposto publicamente via Traefik

### 3. Configuração no Coolify

1. **Criar novo projeto** no Coolify
2. **Importar repositório** Git
3. **Configurar variáveis de ambiente** conforme listado acima
4. **Deploy automático** será executado

### 4. Domínios e SSL

- Configure os domínios no Coolify
- SSL será automaticamente provisionado via Let's Encrypt
- Traefik fará o roteamento automático

## 🔧 Desenvolvimento Local

### Pré-requisitos
- Docker
- Docker Compose

### Executar localmente

1. Clone o repositório
2. Copie o arquivo de ambiente:
   ```bash
   cp .env.example .env
   ```
3. Ajuste as variáveis no arquivo `.env`
4. Execute com Docker Compose:
   ```bash
   docker-compose up -d
   ```

### URLs locais
- Web Application: http://localhost:5003
- API: http://localhost:5004
- PostgreSQL: localhost:5432

## 📝 Estrutura dos Arquivos

```
├── abastecaonline/                 # Aplicação Blazor
│   ├── Dockerfile
│   ├── .dockerignore
│   └── appsettings.production.json
├── abastecimento_api/              # API Web
│   ├── Dockerfile
│   ├── .dockerignore
│   └── appsettings.production.json
├── docker-compose.yml              # Para desenvolvimento local
├── coolify.yml                     # Configuração do Coolify
├── init-db.sh                      # Script de inicialização do BD
└── .env.example                    # Exemplo de variáveis
```

## 🛠️ Configurações Importantes

### Banco de Dados
- Utiliza PostgreSQL 15
- Connection string configurada via variáveis de ambiente
- Backup automático recomendado no Coolify

### Segurança
- JWT para autenticação
- HTTPS obrigatório em produção
- Variáveis sensíveis como secrets no Coolify

### Monitoramento
- Health checks configurados para todos os serviços
- Logs centralizados no Coolify
- Restart automático em caso de falha

## 🔍 Troubleshooting

### Problemas comuns:

1. **Erro de conexão com banco**
   - Verifique se `DB_PASSWORD` está correto
   - Confirme se o serviço do banco iniciou primeiro

2. **Erro de autenticação JWT**
   - Verifique `JWT_SIGNING_KEY` e `JWT_AUDIENCE`
   - Certifique-se que os domínios estão corretos

3. **Problemas de SSL**
   - Aguarde alguns minutos para provisionamento
   - Verifique configuração de domínio no Coolify

### Logs úteis:
```bash
# Ver logs dos containers
docker logs abastecimento-web
docker logs abastecimento-api
docker logs abastecimento-db
```

## 📞 Suporte

Para problemas específicos do deploy, verifique:
1. Logs do Coolify
2. Status dos health checks
3. Configuração das variáveis de ambiente
4. Conectividade entre serviços