# Correções Aplicadas - DataProtection e SSL

## Problemas Identificados

1. **Warning DataProtection**: Keys sendo armazenadas em `/home/appuser/.aspnet/DataProtection-Keys` sem persistência
2. **Erro libssl**: "No usable version of libssl was found"

## Correções Implementadas

### 1. Arquivo `coolify-api.yml`

#### Adicionado volume para DataProtection:
```yaml
volumes:
  - dataprotection_keys:/home/appuser/.aspnet/DataProtection-Keys
```

#### Adicionadas variáveis de ambiente SSL:
```yaml
- DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
- DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
```

#### Criado volume persistente:
```yaml
dataprotection_keys:
  driver: local
  labels:
    - "coolify.managed=true"
```

### 2. Arquivo `Dockerfile`

#### Instaladas bibliotecas SSL adicionais:
```dockerfile
RUN apt-get update && apt-get install -y \
    libssl3 \
    libssl-dev \
    libicu-dev \
    # ... outras dependências
```

#### Criado diretório para DataProtection:
```dockerfile
RUN mkdir -p /home/appuser/.aspnet/DataProtection-Keys
```

#### Configuradas variáveis de ambiente SSL:
```dockerfile
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DOTNET_SYSTEM_NET_HTTP_USESOCKETSHTTPHANDLER=0
ENV DOTNET_SYSTEM_GLOBALIZATION_USEWEBTABLES=1
```

#### Configuradas permissões corretas:
```dockerfile
RUN chown -R appuser /home/appuser/.aspnet/DataProtection-Keys
```

### 3. Arquivo `appsettings.production.json`

#### Adicionada configuração do DataProtection:
```json
"DataProtection": {
  "ApplicationName": "AbastecimentoAPI",
  "KeyLifetime": "90.00:00:00",
  "ApplicationDiscriminator": "abastecimento-api"
}
```

## Como Aplicar as Correções

### No Coolify:

1. **Rebuild da Aplicação**:
   - Vá para sua aplicação no Coolify
   - Clique em "Deploy" → "Force Rebuild Without Cache"
   - Aguarde o rebuild completo

2. **Verificar Variáveis de Ambiente**:
   - Certifique-se que `DB_PASSWORD`, `JWT_AUDIENCE` e `JWT_SIGNING_KEY` estão configuradas

3. **Monitorar Logs**:
   - Após o rebuild, monitore os logs para verificar se os warnings desapareceram
   - Use o script `verify-dataprotection.ps1` para verificação automática

### Verificação Manual:

```powershell
# Executar o script de verificação
./verify-dataprotection.ps1

# Ou verificar logs manualmente:
docker logs abastecimento-api 2>&1 | grep -E "(DataProtection|libssl)"
```

## Resultados Esperados

Após aplicar as correções:

✅ **DataProtection**: 
- Não haverá mais warnings sobre armazenamento não persistente
- Keys serão armazenadas no volume `dataprotection_keys`
- Dados protegidos persistirão entre reinicializações do container

✅ **SSL/TLS**: 
- Não haverá mais erros "No usable version of libssl was found"
- Requisições HTTPS funcionarão corretamente
- Certificados SSL serão carregados sem problemas

## Observações Importantes

1. **Volume Persistente**: O volume `dataprotection_keys` garantirá que as chaves de proteção de dados sejam mantidas mesmo quando o container for recriado.

2. **Compatibilidade SSL**: As configurações adicionadas garantem compatibilidade com diferentes versões de SSL/TLS.

3. **Performance**: As configurações não afetam negativamente a performance da aplicação.

4. **Segurança**: As chaves de proteção de dados agora são adequadamente persistidas e protegidas.

## Troubleshooting

Se os problemas persistirem:

1. Verifique se o volume foi criado corretamente
2. Confirme que as permissões do diretório estão corretas
3. Execute um rebuild completo sem cache
4. Verifique os logs detalhados da aplicação