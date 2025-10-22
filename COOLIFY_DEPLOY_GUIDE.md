# Guia de Deploy no Coolify - Correções Aplicadas

## 🔧 Correções Implementadas

### ✅ 1. Problema SSL Resolvido
- **Adicionado**: `libssl3` e `openssl` nos Dockerfiles
- **Comando**: `update-ca-certificates` para atualizar certificados
- **Resultado**: Elimina o erro "No usable version of libssl was found"

### ✅ 2. DataProtection Keys Persistentes
- **Adicionado**: Volume `api_keys` e `web_keys` no docker-compose
- **Diretório**: `/app/keys` para armazenar chaves de proteção de dados
- **Resultado**: Sessões não serão perdidas em restarts

### ✅ 3. Health Checks Otimizados
- **Intervalo**: 45s (mais tolerante)
- **Timeout**: 30s (mais tempo para resposta)
- **Start Period**: 120-180s (mais tempo para inicialização)
- **Retries**: 5 tentativas antes de considerar falha
- **Fallback**: Testa `/health` primeiro, depois `/` como backup

### ✅ 4. Configurações para Coolify
- **Labels**: Configurados para proxy reverso
- **Resources**: Limites de memória definidos
- **Dependencies**: Web depende apenas do PostgreSQL (API é para integrações externas)
- **Networks**: Isolamento adequado

## 🚀 Deploy no Coolify

### Opção 1: Usar Configuração de Produção (Recomendado)
```bash
# Use o arquivo otimizado para produção
docker-compose -f coolify-production.yml up -d
```

### Opção 2: Usar Configuração de Debug (Temporário)
```bash
# Para troubleshooting sem health checks
docker-compose -f coolify-debug.yml up -d
```

## 📋 Variáveis de Ambiente Necessárias

No Coolify, configure estas variáveis:

```bash
# Database
DB_PASSWORD=sua_senha_segura

# JWT
JWT_AUDIENCE=https://seu-dominio.com
JWT_SIGNING_KEY=sua_chave_jwt_segura

# Domain
WEB_DOMAIN=seu-dominio.com
```

## 🔍 Monitoramento

### Comandos para Verificar Status:
```bash
# Status dos containers
docker-compose -f coolify-production.yml ps

# Logs em tempo real
docker-compose -f coolify-production.yml logs -f

# Health check manual
curl http://localhost:5004/health
curl http://localhost:5003/health
```

### Sinais de Sucesso:
- ✅ Sem mensagens "No usable version of libssl was found"
- ✅ Sem reinicializações constantes
- ✅ DataProtection keys persistindo em `/app/keys`
- ✅ Health checks passando
- ✅ Aplicação estável por mais de 10 minutos

## 🔄 Rollback (Se Necessário)

Se houver problemas, use a configuração de debug:
```bash
docker-compose -f coolify-production.yml down
docker-compose -f coolify-debug.yml up -d
```

## 💡 Próximos Passos

1. **Deploy**: Use `coolify-production.yml`
2. **Monitore**: Logs por 15-20 minutos
3. **Teste**: Acesse a aplicação e verifique funcionalidade
4. **Health Checks**: Implemente endpoints `/health` se ainda não existirem
5. **Performance**: Monitore uso de CPU/memória

## 🔧 Health Check Endpoints (Para Implementar)

Se os endpoints `/health` não existirem, adicione ao código das aplicações:

```csharp
// Program.cs - API
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }));

// Program.cs - Web
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }));
```