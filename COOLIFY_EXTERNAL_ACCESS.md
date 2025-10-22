# 🚀 Configurações Coolify - Acesso Externo

Este documento detalha as configurações aplicadas nos arquivos Coolify para garantir acesso externo às aplicações.

## 📋 Arquivos Atualizados

### 1. `coolify.yml` - Configuração Principal
- Versão completa com health checks HTTP
- Recomendado para produção quando os endpoints `/health` estão implementados

### 2. `coolify-debug.yml` - Versão para Debug
- Health checks desabilitados
- Porta do PostgreSQL exposta (5432) para debug
- Ideal para troubleshooting e desenvolvimento

### 3. `coolify-alternative.yml` - Versão Alternativa
- Health checks usando `netstat` em vez de HTTP
- Para casos onde endpoints `/health` não estão disponíveis

## 🔧 Configurações Aplicadas

### **API (abastecimento-api)**
```yaml
environment:
  - ASPNETCORE_URLS=http://0.0.0.0:5004          # ✅ Acesso de qualquer IP
  - ASPNETCORE_FORWARDEDHEADERS_ENABLED=true     # ✅ Suporte a proxy reverso
  - DB_HOST=postgres                              # ✅ Configuração dinâmica
  - DB_PORT=5432                                  # ✅ Porta do banco
  - DB_NAME=abastecimento                         # ✅ Nome do banco
  - DB_PASSWORD=${DB_PASSWORD}                    # ✅ Senha via variável
```

### **Web (abastecimento-web)**  
```yaml
environment:
  - ASPNETCORE_URLS=http://0.0.0.0:5003          # ✅ Acesso de qualquer IP
  - ASPNETCORE_FORWARDEDHEADERS_ENABLED=true     # ✅ Suporte a proxy reverso
  - ApiUrl=http://api:5004                        # ✅ URL interna da API
  - DB_HOST=postgres                              # ✅ Configuração dinâmica
```

## 🌐 Configuração no Coolify

### Variáveis de Ambiente Obrigatórias:
```bash
# Database
DB_PASSWORD=sua_senha_postgres_muito_segura

# JWT Configuration  
JWT_AUDIENCE=https://seu-dominio.com
JWT_SIGNING_KEY=sua_chave_jwt_super_secreta_de_pelo_menos_32_caracteres

# Domains (para labels do Coolify)
WEB_DOMAIN=app.seu-dominio.com
API_DOMAIN=api.seu-dominio.com
```

### Variáveis Opcionais:
```bash
# Customização adicional
POSTGRES_DB=abastecimento
POSTGRES_USER=postgres
```

## 🚀 Deploy no Coolify

### 1. **Criar Novo Projeto**
1. Acesse o painel do Coolify
2. Clique em "New Project"
3. Configure o repositório Git

### 2. **Configurar Variáveis**
```bash
# No painel do Coolify, adicione as variáveis:
DB_PASSWORD=MinhaPasswordSegura123!
JWT_AUDIENCE=https://meuapp.exemplo.com
JWT_SIGNING_KEY=minha-chave-jwt-super-secreta-aqui-123456789
WEB_DOMAIN=meuapp.exemplo.com
```

### 3. **Escolher Arquivo de Configuração**
- **Produção**: Use `coolify.yml`
- **Debug**: Use `coolify-debug.yml` 
- **Sem /health**: Use `coolify-alternative.yml`

### 4. **Executar Deploy**
```bash
# O Coolify irá automaticamente:
# 1. Fazer build das imagens Docker
# 2. Configurar proxy reverso
# 3. Gerenciar certificados SSL
# 4. Aplicar health checks
```

## 🔍 Verificação e Troubleshooting

### **Verificar Status dos Serviços**
No painel do Coolify:
1. Verifique se todos os containers estão "Running"
2. Analise os logs de cada serviço
3. Teste os health checks

### **Testar Acesso Externo**
```bash
# Health check da API
curl https://api.seu-dominio.com/health

# Página principal
curl https://seu-dominio.com

# Verificar headers de proxy
curl -I https://seu-dominio.com
```

### **Debug de Problemas Comuns**

#### **Problema**: Aplicação não inicia
**Solução**:
1. Use `coolify-debug.yml` temporariamente
2. Verifique logs no painel do Coolify
3. Confirme variáveis de ambiente

#### **Problema**: Erro de conexão com banco
**Solução**:
1. Verifique a variável `DB_PASSWORD`
2. Analise logs do PostgreSQL
3. Confirme se o banco está inicializando

#### **Problema**: CORS ou proxy reverso
**Solução**:
1. Confirme `ASPNETCORE_FORWARDEDHEADERS_ENABLED=true`
2. Verifique configurações do domínio
3. Analise logs do proxy reverso do Coolify

## 📊 Monitoramento

### **Logs em Tempo Real**
No painel do Coolify:
- Acesse a seção "Logs" de cada serviço
- Configure alertas para erros críticos
- Monitore métricas de performance

### **Health Checks**
```yaml
# API Health Check (coolify.yml)
healthcheck:
  test: ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:5004/health || exit 1"]
  interval: 30s
  timeout: 15s
  retries: 8
  start_period: 120s
```

### **Métricas Importantes**
- **Tempo de resposta** dos health checks
- **Uso de CPU/Memória** dos containers
- **Conectividade** com o banco de dados
- **Certificados SSL** (renovação automática)

## 🛡️ Segurança

### **Configurações Recomendadas**
1. **Senhas Fortes**: Use geradores de senha para `DB_PASSWORD`
2. **JWT Keys**: Chaves de pelo menos 32 caracteres aleatórios
3. **HTTPS**: Coolify gerencia automaticamente via Let's Encrypt
4. **Firewall**: Configure regras específicas no servidor

### **Variáveis Sensíveis**
```bash
# ❌ NÃO faça isso (senhas fracas):
DB_PASSWORD=123456
JWT_SIGNING_KEY=secret

# ✅ Faça assim (senhas fortes):
DB_PASSWORD=Minha@SenhaComplexa#2024$PostgreSQL
JWT_SIGNING_KEY=A1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P6Q7R8S9T0
```

## 🔄 Atualizações e Manutenção

### **Deploy de Novas Versões**
1. Commit das alterações no repositório
2. Coolify detecta automaticamente via webhook
3. Build e deploy automático
4. Rollback disponível se necessário

### **Backup e Recuperação**
- **Banco de dados**: Coolify pode configurar backups automáticos
- **Configurações**: Mantenha as variáveis documentadas
- **Volumes**: Dados persistentes em `postgres_data`

---

**💡 Dica**: Use `coolify-debug.yml` durante desenvolvimento e `coolify.yml` em produção para obter a melhor experiência.