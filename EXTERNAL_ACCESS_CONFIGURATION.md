# Configuração de Acesso Externo - Abastecimento API

## Alterações Implementadas

### 1. Dockerfile (`abastecimento_api/Dockerfile`)
- **ASPNETCORE_URLS**: Alterado de `http://+:5004` para `http://0.0.0.0:5004` para permitir conexões de qualquer IP
- **ASPNETCORE_FORWARDEDHEADERS_ENABLED**: Habilitado para suporte a proxy reverso
- **Health Check**: Adicionado health check automático
- **Script de Inicialização**: Implementado script `start.sh` melhorado com verificação de banco de dados

### 2. Configurações de Produção (`appsettings.production.json`)
- **Kestrel EndPoints**: Configurado para `http://0.0.0.0:5004`
- **Limites do Kestrel**: Configurações otimizadas para acesso externo
- **CORS**: Configurado para permitir acesso de qualquer origem (pode ser restringido conforme necessário)

### 3. Configurações Externas (`appsettings.External.json`)
- **CORS Policy**: Política específica para acesso externo
- **Forwarded Headers**: Configuração para proxies e load balancers
- **Headers Expostos**: Configuração para downloads e uploads

### 4. Docker Compose (`docker-compose.yml`)
- **Variáveis de Ambiente**: Adicionadas variáveis para configuração dinâmica
- **Restart Policy**: `unless-stopped` para alta disponibilidade
- **Network Configuration**: Configuração explícita de rede

### 5. Script de Inicialização (`start.sh`)
- **Verificação de Banco**: Aguarda o banco estar disponível antes de iniciar
- **Logging**: Melhor logging de inicialização
- **Error Handling**: Tratamento adequado de erros

## Como Acessar Externamente

### Localmente (Development)
```bash
# Acesso direto
http://localhost:5004

# Acesso via IP da máquina
http://[SEU_IP]:5004
```

### Produção (Docker)
```bash
# Subir os serviços
docker-compose up -d

# Verificar status
docker-compose ps

# Logs da API
docker-compose logs api
```

### Acesso via Rede Externa
1. **Firewall**: Certifique-se que a porta 5004 está aberta no firewall
2. **Router**: Configure port forwarding se necessário
3. **DNS**: Configure um domínio para apontar para seu servidor

## Endpoints Disponíveis

- **Health Check**: `/health`
- **API Documentation**: `/swagger` (se habilitado)
- **Authentication**: `/auth/login`

## Segurança

### Recomendações para Produção:
1. **CORS**: Restringir origens permitidas no `appsettings.production.json`
2. **HTTPS**: Implementar certificados SSL/TLS
3. **JWT**: Usar chaves de assinatura seguras
4. **Database**: Usar senhas fortes para o banco de dados
5. **Firewall**: Configurar regras específicas

### Variáveis de Ambiente Recomendadas:
```bash
# JWT Configuration
JWT_AUDIENCE=https://seu-dominio.com
JWT_SIGNING_KEY=sua-chave-secreta-muito-forte

# Database
DB_PASSWORD=senha-forte-do-banco
DB_HOST=seu-host-de-banco
DB_PORT=5432
DB_NAME=abastecimento

# API URL (para frontend)
API_URL=https://seu-dominio.com:5004
```

## Troubleshooting

### Verificar se a API está respondendo:
```bash
curl -f http://localhost:5004/health
```

### Verificar logs do container:
```bash
docker logs abastecimento_api
```

### Verificar conectividade de rede:
```bash
docker exec -it abastecimento_api netstat -tlnp
```

### Verificar configurações do Kestrel:
```bash
docker exec -it abastecimento_api env | grep ASPNET
```

## Monitoramento

A aplicação agora inclui:
- Health checks automáticos
- Restart automático em caso de falha
- Logs estruturados
- Métricas de performance básicas

Para monitoramento avançado, considere implementar:
- Prometheus/Grafana
- Application Insights
- ELK Stack (Elasticsearch, Logstash, Kibana)