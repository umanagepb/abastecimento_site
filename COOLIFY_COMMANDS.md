# 🛠️ Comandos Úteis para Coolify - Sistema Abastecimento

## 📋 Comandos de Deploy

### Deploy Inicial
```bash
# No painel do Coolify, clique em "Deploy"
# Ou use a API (se configurada):
curl -X POST "https://seu-coolify.com/api/deploy" \
  -H "Authorization: Bearer SEU_TOKEN" \
  -d '{"project": "abastecimento-system"}'
```

### Redeploy após Mudanças
```bash
# Após fazer commit no Git, o Coolify pode fazer redeploy automático
# Ou manualmente no painel: Projects > abastecimento-system > Deploy
```

## 🔍 Monitoramento e Logs

### Ver Logs em Tempo Real
```bash
# No painel do Coolify:
# Projects > abastecimento-system > Services > [Service] > Logs

# Via SSH no servidor (se tiver acesso):
docker logs -f abastecimento-web
docker logs -f abastecimento-api
docker logs -f abastecimento-db
```

### Verificar Status dos Containers
```bash
# No servidor Coolify:
docker ps --filter "label=coolify.managed=true"
docker stats abastecimento-web abastecimento-api abastecimento-db
```

## 🔧 Gerenciamento de Variáveis

### Adicionar/Editar Variáveis
```bash
# No painel Coolify:
# Projects > abastecimento-system > Environment Variables

# Variáveis importantes:
DB_PASSWORD=nova_senha_segura
JWT_SIGNING_KEY=nova_chave_jwt
JWT_AUDIENCE=https://novo-dominio.com
```

### Aplicar Mudanças de Variáveis
```bash
# Após alterar variáveis, é necessário redeploy:
# Projects > abastecimento-system > Deploy
```

## 🗄️ Gerenciamento de Banco de Dados

### Backup do Banco
```bash
# Via SSH no servidor:
docker exec abastecimento-db pg_dump -U postgres abastecimento > backup_$(date +%Y%m%d_%H%M%S).sql

# Ou configurar backup automático no Coolify:
# Projects > abastecimento-system > Storages > postgres_data > Backup
```

### Restaurar Backup
```bash
# Via SSH no servidor:
docker exec -i abastecimento-db psql -U postgres abastecimento < backup.sql
```

### Conectar ao Banco
```bash
# Via SSH no servidor:
docker exec -it abastecimento-db psql -U postgres -d abastecimento
```

## 🌐 Gerenciamento de Domínios

### Configurar Novo Domínio
```bash
# No painel Coolify:
# Projects > abastecimento-system > Services > abastecimento-web > Domains
# Adicionar: novo-dominio.com
# SSL será configurado automaticamente
```

### Verificar SSL
```bash
# Teste SSL:
curl -I https://seu-dominio.com
openssl s_client -connect seu-dominio.com:443 -servername seu-dominio.com
```

## 🚨 Troubleshooting

### Reiniciar Serviços
```bash
# No painel Coolify:
# Projects > abastecimento-system > Services > [Service] > Restart

# Via SSH:
docker restart abastecimento-web
docker restart abastecimento-api
docker restart abastecimento-db
```

### Verificar Saúde dos Serviços
```bash
# Health checks:
curl https://seu-dominio.com/health
curl https://api.seu-dominio.com/health

# Status dos containers:
docker inspect abastecimento-web --format='{{.State.Health.Status}}'
```

### Limpar e Rebuild
```bash
# No painel Coolify, forçar rebuild:
# Projects > abastecimento-system > Services > [Service] > Force Rebuild

# Via SSH (cuidado - remove tudo):
docker system prune -a
```

## 📊 Monitoramento de Performance

### Ver Uso de Recursos
```bash
# CPU e Memória:
docker stats --no-stream

# Espaço em disco:
df -h
docker system df
```

### Logs de Error
```bash
# Filtrar apenas erros:
docker logs abastecimento-api 2>&1 | grep -i error
docker logs abastecimento-web 2>&1 | grep -i error
```

## 🔄 Atualizações

### Processo de Atualização
1. **Faça backup** do banco de dados
2. **Teste localmente** as mudanças
3. **Commit** no repositório Git
4. **Deploy** no Coolify
5. **Verificar** se tudo está funcionando

### Rollback em Caso de Problema
```bash
# No painel Coolify:
# Projects > abastecimento-system > Deployments > [Deployment anterior] > Redeploy
```

## 🔐 Segurança

### Rotacionar Senhas
```bash
# 1. Alterar DB_PASSWORD no Coolify
# 2. Redeploy todos os serviços
# 3. Verificar conectividade
```

### Verificar Logs de Segurança
```bash
# Verificar tentativas de login:
docker logs abastecimento-api | grep -i "authentication\|login\|unauthorized"
```

## 📈 Escalabilidade

### Monitorar Performance
```bash
# No painel Coolify, verificar métricas:
# Projects > abastecimento-system > Metrics

# Ou via comando:
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
```

### Configurar Alertas
```bash
# No painel Coolify:
# Settings > Notifications
# Configurar webhook/email para alertas de CPU/Memory/Disk
```

## 🔧 Comandos de Manutenção

### Limpeza Periódica
```bash
# Limpar logs antigos:
docker logs abastecimento-api --since="24h" > /dev/null

# Limpar imagens não utilizadas:
docker image prune -a

# Limpar volumes órfãos:
docker volume prune
```

### Verificação Completa
```bash
# Execute o script de verificação:
chmod +x check-health.sh
./check-health.sh
```

## 📞 Suporte

### Informações para Debug
Ao reportar problemas, inclua:

```bash
# Versão do Docker:
docker --version

# Status dos containers:
docker ps -a

# Logs recentes:
docker logs --tail 50 abastecimento-web
docker logs --tail 50 abastecimento-api

# Variáveis de ambiente (sem valores sensíveis):
docker exec abastecimento-web env | grep -v PASSWORD | grep -v KEY
```