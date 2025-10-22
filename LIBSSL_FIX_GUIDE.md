# Solução Definitiva para Erro LibSSL

## Problema
```
No usable version of libssl was found
```

Este erro ocorre quando o .NET 8.0 não consegue encontrar as bibliotecas SSL compatíveis no container Linux.

## Soluções Implementadas

### 1. **Correção Principal - Dockerfile Atualizado**

#### Bibliotecas SSL Instaladas:
```dockerfile
libssl3 \
libssl-dev \
libkrb5-3 \
zlib1g \
```

#### Links Simbólicos Criados:
```dockerfile
ln -sf /usr/lib/x86_64-linux-gnu/libssl.so.3 /usr/lib/x86_64-linux-gnu/libssl.so.1.1 \
ln -sf /usr/lib/x86_64-linux-gnu/libcrypto.so.3 /usr/lib/x86_64-linux-gnu/libcrypto.so.1.1 \
```

#### Variáveis de Ambiente SSL:
```dockerfile
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=1
ENV SSL_CERT_DIR=/etc/ssl/certs
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib
```

### 2. **Script de Inicialização Melhorado**

O `start.sh` agora inclui:
- Verificação das bibliotecas SSL
- Criação automática de links simbólicos
- Atualização do cache de bibliotecas
- Configuração de variáveis de ambiente SSL

### 3. **Dockerfile Alternativo**

Criado `Dockerfile.libssl-fix` com configurações ainda mais robustas para casos extremos.

## Como Aplicar as Correções

### Opção 1: No Coolify (Recomendado)

1. **Force Rebuild Without Cache**:
   ```
   Coolify → Sua Aplicação → Deploy → Force Rebuild Without Cache
   ```

2. **Verificar Variáveis de Ambiente**:
   - Certifique-se que todas as variáveis SSL estão configuradas
   - `LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/usr/lib`

### Opção 2: Localmente com Docker Compose

```powershell
# Executar script de rebuild
./rebuild-api.ps1

# Ou manualmente:
docker-compose -f coolify-api.yml down
docker-compose -f coolify-api.yml build --no-cache
docker-compose -f coolify-api.yml up -d
```

### Opção 3: Usar Dockerfile Alternativo

Se o problema persistir:

```powershell
# Backup do Dockerfile original
cp Dockerfile Dockerfile.backup

# Usar versão alternativa
cp Dockerfile.libssl-fix Dockerfile

# Rebuild
./rebuild-api.ps1
```

## Verificação das Correções

### 1. Script Automático:
```powershell
./verify-dataprotection.ps1
```

### 2. Verificação Manual:
```powershell
# Verificar logs de erro
docker logs abastecimento-api 2>&1 | findstr "libssl"

# Verificar bibliotecas no container
docker exec abastecimento-api ls -la /usr/lib/x86_64-linux-gnu/libssl*

# Verificar links simbólicos
docker exec abastecimento-api ls -la /usr/lib/x86_64-linux-gnu/libssl.so.1.1
```

### 3. Teste de Conectividade:
```powershell
# Testar API
curl http://localhost:5004

# Verificar health check
curl http://localhost:5004/health
```

## Resultados Esperados

✅ **Após as correções**:
- Não haverá mensagens "No usable version of libssl was found"
- Bibliotecas SSL serão carregadas corretamente
- Requisições HTTPS funcionarão sem problemas
- Aplicação iniciará sem erros SSL

## Troubleshooting Avançado

### Se o problema persistir:

1. **Verificar versão do .NET**:
   ```bash
   docker exec abastecimento-api dotnet --version
   ```

2. **Verificar variáveis de ambiente**:
   ```bash
   docker exec abastecimento-api env | grep -E "(SSL|DOTNET|LD_LIBRARY)"
   ```

3. **Verificar cache de bibliotecas**:
   ```bash
   docker exec abastecimento-api ldconfig -p | grep ssl
   ```

4. **Logs detalhados**:
   ```bash
   docker logs abastecimento-api --details
   ```

### Solução Alternativa - Base Image Diferente

Se nada funcionar, considere usar uma base image diferente:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine
# ou
FROM mcr.microsoft.com/dotnet/aspnet:8.0-bookworm-slim
```

## Notas Importantes

- **Compatibilidade**: As correções mantêm compatibilidade com todas as funcionalidades existentes
- **Performance**: Não há impacto negativo na performance
- **Segurança**: Certificados SSL são atualizados e configurados corretamente
- **Persistência**: Volumes do DataProtection continuam funcionando

## Monitoramento Contínuo

Após aplicar as correções, monitore os logs da aplicação:

```powershell
# Logs em tempo real
docker logs -f abastecimento-api

# Filtrar apenas erros SSL
docker logs abastecimento-api 2>&1 | findstr -i "ssl\|crypto\|libssl"
```