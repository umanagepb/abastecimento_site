# Arquitetura dos Serviços - Abastecimento

## 🏗️ Estrutura dos Serviços

### 📊 PostgreSQL Database
- **Função**: Banco de dados principal
- **Porta**: 5432
- **Dependências**: Nenhuma
- **Usado por**: Web Application e API

### 🌐 Web Application (Blazor Server)
- **Função**: Interface principal do usuário
- **Porta**: 5003
- **Dependências**: PostgreSQL Database
- **Tecnologia**: ASP.NET Core Blazor Server
- **Acesso**: Usuários finais via browser

### 🔌 API (WebApi)
- **Função**: Integração com sistemas externos
- **Porta**: 5004  
- **Dependências**: PostgreSQL Database
- **Tecnologia**: ASP.NET Core WebAPI
- **Acesso**: Sistemas externos via HTTP/REST

## 🔄 Fluxo de Dependências

```
┌─────────────────┐
│   PostgreSQL    │
│   Database      │
│   (port 5432)   │
└─────────┬───────┘
          │
    ┌─────┴─────┐
    │           │
    ▼           ▼
┌─────────┐ ┌─────────┐
│   Web   │ │   API   │
│  App    │ │ (Ext)   │
│ (5003)  │ │ (5004)  │
└─────────┘ └─────────┘
```

## ⚡ Inicialização Otimizada

### Ordem de Inicialização:
1. **PostgreSQL** - Primeiro (base de dados)
2. **Web App** - Assim que PostgreSQL estiver pronto
3. **API** - Independente, pode iniciar em paralelo

### Benefícios:
- ✅ **Inicialização Mais Rápida**: Web não espera API
- ✅ **Maior Disponibilidade**: Web funciona mesmo se API falhar
- ✅ **Isolamento**: Problemas na API não afetam usuários
- ✅ **Escalabilidade**: Serviços podem escalar independentemente

## 🚀 Deploy Strategies

### Produção Normal:
```bash
docker-compose -f coolify-production.yml up -d
```

### Deploy Apenas Web (manutenção da API):
```bash
docker-compose -f coolify-production.yml up -d postgres web
```

### Deploy Apenas API (manutenção da Web):
```bash
docker-compose -f coolify-production.yml up -d postgres api
```

## 📋 Configurações Específicas

### Web Application:
- **Foco**: Interface do usuário
- **Conexão**: Direta com PostgreSQL
- **Health Check**: Endpoint da aplicação web
- **Recursos**: 1GB RAM limit

### API:
- **Foco**: Integrações externas
- **Conexão**: Direta com PostgreSQL  
- **Health Check**: Endpoint da API
- **Recursos**: 1GB RAM limit
- **Uso**: Sistemas externos, webhooks, integrações

## 🔧 Troubleshooting

### Se Web não iniciar:
1. Verificar PostgreSQL está rodando
2. Verificar conexão de rede
3. Verificar logs: `docker-compose logs web`

### Se API não iniciar:
1. Verificar PostgreSQL está rodando
2. Não afeta funcionamento da Web
3. Verificar logs: `docker-compose logs api`

### Se PostgreSQL não iniciar:
1. Ambos Web e API falharão
2. Verificar volumes e permissões
3. Verificar senha do banco

## 💡 Vantagens da Arquitetura

- **Modularidade**: Cada serviço tem responsabilidade específica
- **Confiabilidade**: Falha em um serviço não derruba o sistema todo
- **Performance**: Web App não carrega recursos da API desnecessariamente
- **Manutenção**: Atualizações independentes
- **Monitoramento**: Métricas específicas por serviço