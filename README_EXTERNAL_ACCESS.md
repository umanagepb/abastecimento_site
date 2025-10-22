# 🌐 Acesso Externo - Abastecimento API

Este documento descreve as configurações implementadas para permitir acesso externo à aplicação `abastecimento_api`.

## ✅ Configurações Implementadas

### 1. **Dockerfile Otimizado**
- Configuração do Kestrel para aceitar conexões de qualquer IP (`0.0.0.0:5004`)
- Habilitação de Forwarded Headers para proxy reverso
- Health check automático integrado
- Script de inicialização com verificação de dependências

### 2. **Configurações de Rede**
- **ASPNETCORE_URLS**: `http://0.0.0.0:5004`
- **ASPNETCORE_FORWARDEDHEADERS_ENABLED**: Habilitado
- **Porta Exposta**: 5004 (mapeada no Docker Compose)

### 3. **Configurações CORS**
- Política configurada para permitir acesso de qualquer origem
- Headers customizados permitidos
- Métodos HTTP completos (GET, POST, PUT, DELETE, OPTIONS, PATCH)

### 4. **Docker Compose Atualizado**
- Variáveis de ambiente para configuração dinâmica
- Política de restart automático
- Configuração de rede explícita

## 🚀 Como Usar

### Subir a Aplicação
```bash
# Navegar para o diretório do projeto
cd e:\abastecimento_site

# Subir todos os serviços
docker-compose up -d

# Verificar status
docker-compose ps
```

### Verificar Acesso Externo

**Windows (PowerShell):**
```powershell
.\verify-external-access.ps1
```

**Linux/macOS (Bash):**
```bash
chmod +x verify-external-access.sh
./verify-external-access.sh
```

### Teste Manual
```bash
# Health check
curl http://localhost:5004/health

# Ou via IP da máquina
curl http://[SEU_IP]:5004/health
```

## 🔧 Endpoints Disponíveis

| Endpoint | Descrição | Status Esperado |
|----------|-----------|-----------------|
| `/health` | Health check da aplicação | 200 OK |
| `/` | Root da API | 200/404 |
| `/swagger` | Documentação da API | 200/404 |

## 🛡️ Configurações de Segurança

### Para Desenvolvimento
As configurações atuais permitem acesso amplo para facilitar o desenvolvimento.

### Para Produção (Recomendações)
1. **Restringir CORS** no `appsettings.production.json`:
```json
{
  "Cors": {
    "AllowedOrigins": ["https://seu-dominio.com", "https://app.exemplo.com"],
    "AllowCredentials": true
  }
}
```

2. **Configurar HTTPS**:
```json
{
  "Kestrel": {
    "EndPoints": {
      "Https": {
        "Url": "https://0.0.0.0:5005",
        "Certificate": {
          "Path": "/app/cert/certificate.pfx",
          "Password": "${CERT_PASSWORD}"
        }
      }
    }
  }
}
```

3. **Variáveis de Ambiente Seguras**:
```bash
JWT_SIGNING_KEY=sua-chave-super-secreta-de-pelo-menos-32-caracteres
DB_PASSWORD=senha-forte-do-banco-de-dados
CERT_PASSWORD=senha-do-certificado-ssl
```

## 🔍 Troubleshooting

### Problema: API não responde externamente
**Solução:**
1. Verificar se o container está rodando:
   ```bash
   docker ps | grep abastecimento_api
   ```

2. Verificar logs:
   ```bash
   docker logs abastecimento_api --tail 50
   ```

3. Verificar mapeamento de porta:
   ```bash
   docker port abastecimento_api
   ```

### Problema: CORS bloqueando requisições
**Solução:**
1. Verificar configurações de CORS no `appsettings.production.json`
2. Adicionar o domínio/IP na lista de origens permitidas
3. Reiniciar o container após alterações

### Problema: Timeout de conexão
**Solução:**
1. Verificar firewall do sistema operacional
2. Verificar configurações de rede do Docker
3. Testar conectividade com `telnet localhost 5004`

## 📝 Logs e Monitoramento

### Visualizar Logs em Tempo Real
```bash
docker logs -f abastecimento_api
```

### Verificar Métricas de Health
```bash
curl -v http://localhost:5004/health
```

### Monitorar Recursos do Container
```bash
docker stats abastecimento_api
```

## 🔄 Atualizações Futuras

Para melhorar ainda mais o acesso externo, considere implementar:

1. **Load Balancer** (nginx, HAProxy)
2. **SSL/TLS Termination**
3. **Rate Limiting**
4. **API Gateway**
5. **Monitoramento Avançado** (Prometheus, Grafana)
6. **Logging Centralizado** (ELK Stack)

## 📞 Suporte

Em caso de problemas:
1. Execute o script de verificação primeiro
2. Consulte os logs do container
3. Verifique as configurações de rede
4. Teste a conectividade básica com ferramentas como `curl` ou `telnet`

---

**Última atualização:** 21 de Outubro de 2024
**Versão:** 1.0