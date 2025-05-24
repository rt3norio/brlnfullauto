# 🛠️ Guia de Solução de Problemas - BR-LN Docker Node

Este guia ajuda a resolver problemas comuns encontrados ao executar o BR-LN Docker Node.

## 📋 Índice

- [Problemas Gerais](#problemas-gerais)
- [Bitcoin Core](#bitcoin-core)
- [LND](#lnd)
- [Thunderhub](#thunderhub)
- [Tor](#tor)
- [i2pd](#i2pd)
- [Docker](#docker)
- [Rede](#rede)
- [Performance](#performance)

## 🔍 Diagnóstico Rápido

Antes de investigar problemas específicos, execute estes comandos para um diagnóstico geral:

```bash
# Verificar status de todos os containers
make status

# Verificar saúde dos containers
make health

# Ver logs recentes
make logs

# Verificar portas ocupadas
netstat -tulpn | grep -E "(8332|8333|10009|3000|9050)"

# Verificar espaço em disco
df -h

# Verificar memória
free -h
```

## ⚠️ Problemas Gerais

### Containers não iniciam

**Sintomas:**
- `make up` falha
- Containers param imediatamente após iniciar

**Soluções:**

1. **Verificar se as portas estão livres:**
   ```bash
   # Verificar portas ocupadas
   netstat -tulpn | grep -E "(8332|8333|10009|3000|9050)"
   
   # Parar serviços que usam as portas
   sudo systemctl stop bitcoin
   sudo systemctl stop lnd
   ```

2. **Verificar permissões dos diretórios:**
   ```bash
   # Verificar proprietário
   ls -la */
   
   # Corrigir permissões se necessário
   sudo chown -R $USER:$USER "bitcoin core/bitcoin-data"
   sudo chown -R $USER:$USER "lnd/lnd_data"
   sudo chown -R $USER:$USER "tor/tor_data"
   sudo chown -R $USER:$USER "i2pd/i2pd_data"
   ```

3. **Verificar espaço em disco:**
   ```bash
   df -h
   # Se necessário, limpar espaço ou mover para outro disco
   ```

### Erro "Permission denied"

**Solução:**
```bash
# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Reiniciar sessão ou executar
newgrp docker

# Verificar se funcionou
groups $USER | grep docker
```

### Containers param com "Out of Memory"

**Solução:**
```bash
# Verificar memória disponível
free -h

# Parar alguns containers temporariamente
make thunderhub-down
make i2pd-down

# Ou aumentar swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

## ₿ Bitcoin Core

### Bitcoin Core não sincroniza

**Sintomas:**
- Logs mostram "No block source available"
- `getblockchaininfo` mostra blocks=0

**Soluções:**

1. **Verificar conectividade de rede:**
   ```bash
   # Testar conectividade
   make shell-bitcoin
   ping 8.8.8.8
   
   # Verificar peers
   bitcoin-cli -rpcuser=bitcoinrpc -rpcpassword=secure_password getpeerinfo
   ```

2. **Reiniciar Bitcoin Core:**
   ```bash
   make bitcoin-restart
   
   # Aguardar alguns minutos e verificar
   make bitcoin-getinfo
   ```

3. **Verificar configuração:**
   ```bash
   make shell-bitcoin
   cat /home/bitcoin/.bitcoin/bitcoin.conf
   ```

### Erro RPC "Connection refused"

**Soluções:**

1. **Aguardar inicialização completa:**
   ```bash
   # Bitcoin Core pode demorar para inicializar
   docker logs bitcoin-node -f
   ```

2. **Verificar credenciais RPC:**
   ```bash
   # Testar manualmente
   docker exec bitcoin-node bitcoin-cli -rpcuser=bitcoinrpc -rpcpassword=secure_password getblockchaininfo
   ```

### Espaço em disco insuficiente

**Soluções:**

1. **Verificar configuração de prune:**
   ```bash
   make shell-bitcoin
   grep prune /home/bitcoin/.bitcoin/bitcoin.conf
   ```

2. **Limpar dados antigos (CUIDADO!):**
   ```bash
   make bitcoin-down
   # Backup antes de deletar
   sudo rm -rf "bitcoin core/bitcoin-data/blocks"
   sudo rm -rf "bitcoin core/bitcoin-data/chainstate"
   make bitcoin-up
   ```

## ⚡ LND

### LND não conecta ao Bitcoin Core

**Sintomas:**
- Logs mostram "unable to connect to bitcoind"
- `lncli getinfo` falha

**Soluções:**

1. **Verificar se Bitcoin Core está rodando:**
   ```bash
   make status
   make bitcoin-getinfo
   ```

2. **Verificar conectividade de rede:**
   ```bash
   # Testar conexão RPC
   docker exec lnd curl -u bitcoinrpc:secure_password \
     --data-binary '{"jsonrpc":"1.0","id":"test","method":"getblockchaininfo","params":[]}' \
     -H 'content-type: text/plain;' \
     http://172.21.0.1:8332/
   ```

3. **Verificar configuração do LND:**
   ```bash
   make shell-lnd
   cat /root/.lnd/lnd.conf
   ```

### LND não sincroniza

**Soluções:**

1. **Aguardar sincronização do Bitcoin Core:**
   ```bash
   make bitcoin-getinfo
   # Verificar se blocks está atualizado
   ```

2. **Reiniciar LND:**
   ```bash
   make lnd-restart
   ```

3. **Verificar logs:**
   ```bash
   docker logs lnd --tail=50
   ```

### Wallet não encontrada

**Soluções:**

1. **Criar nova carteira:**
   ```bash
   make shell-lnd
   lncli create
   ```

2. **Desbloquear carteira existente:**
   ```bash
   make shell-lnd
   lncli unlock
   ```

## 🌩️ Thunderhub

### Thunderhub não carrega

**Sintomas:**
- Página em branco ou erro 500
- Não consegue acessar http://localhost:3000

**Soluções:**

1. **Verificar se LND está rodando:**
   ```bash
   make lnd-getinfo
   ```

2. **Verificar logs do Thunderhub:**
   ```bash
   docker logs thunderhub --tail=50
   ```

3. **Verificar configuração:**
   ```bash
   make shell-thunderhub
   env | grep -E "(LND|THUB)"
   ```

### Erro de autenticação

**Soluções:**

1. **Verificar macaroon:**
   ```bash
   make shell-lnd
   ls -la /root/.lnd/*.macaroon
   ```

2. **Regenerar macaroon:**
   ```bash
   make shell-lnd
   lncli bakemacaroon info:read info:write invoices:read invoices:write
   ```

## 📡 Tor

### Tor não inicia

**Soluções:**

1. **Verificar logs:**
   ```bash
   docker logs tor_service --tail=50
   ```

2. **Verificar portas:**
   ```bash
   netstat -tulpn | grep 9050
   ```

3. **Reconstruir imagem:**
   ```bash
   make tor-down
   cd tor && docker-compose build --no-cache
   make tor-up
   ```

### Conexão Tor lenta

**Soluções:**

1. **Reiniciar Tor:**
   ```bash
   make tor-restart
   ```

2. **Verificar conectividade:**
   ```bash
   curl --socks5 localhost:9050 http://httpbin.org/ip
   ```

## 🌐 i2pd

### i2pd não conecta

**Soluções:**

1. **Aguardar inicialização:**
   ```bash
   # i2pd pode demorar para conectar à rede
   docker logs i2pd -f
   ```

2. **Verificar portas:**
   ```bash
   netstat -tulpn | grep 4444
   ```

## 🐳 Docker

### Erro "No space left on device"

**Soluções:**

1. **Limpar containers e imagens:**
   ```bash
   make clean
   
   # Limpeza mais agressiva (CUIDADO!)
   docker system prune -a
   ```

2. **Mover dados para outro disco:**
   ```bash
   # Parar containers
   make down
   
   # Mover dados
   sudo mv "bitcoin core/bitcoin-data" /novo/disco/
   ln -s /novo/disco/bitcoin-data "bitcoin core/"
   ```

### Docker Compose não encontrado

**Soluções:**

1. **Instalar Docker Compose:**
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install docker-compose-plugin
   
   # Ou versão standalone
   sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

### Containers ficam reiniciando

**Soluções:**

1. **Verificar logs:**
   ```bash
   docker logs CONTAINER_NAME --tail=100
   ```

2. **Remover política de restart temporariamente:**
   ```bash
   # Editar docker-compose.yml e comentar "restart: unless-stopped"
   ```

## 🌐 Rede

### Containers não se comunicam

**Soluções:**

1. **Verificar redes Docker:**
   ```bash
   docker network ls
   make network-info
   ```

2. **Recriar redes:**
   ```bash
   make down
   docker network prune
   make up
   ```

### Problemas de DNS

**Soluções:**

1. **Verificar resolução:**
   ```bash
   make shell-bitcoin
   nslookup google.com
   ```

2. **Usar IPs fixos:**
   ```bash
   # Editar docker-compose.yml para usar IPs específicos
   ```

## 🚀 Performance

### Sistema lento

**Soluções:**

1. **Verificar recursos:**
   ```bash
   make monitor
   ```

2. **Limitar recursos dos containers:**
   ```bash
   # Editar docker-compose.yml adicionar:
   # deploy:
   #   resources:
   #     limits:
   #       memory: 1G
   #       cpus: '1.0'
   ```

3. **Parar containers desnecessários:**
   ```bash
   make thunderhub-down  # Se não usar interface web
   make i2pd-down        # Se não usar I2P
   ```

## 🆘 Comandos de Emergência

### Reset Completo (CUIDADO!)

```bash
# Parar tudo
make down

# Backup (se necessário)
make backup

# Limpar tudo
docker system prune -a --volumes

# Remover dados (PERDA DE DADOS!)
sudo rm -rf "bitcoin core/bitcoin-data"
sudo rm -rf "lnd/lnd_data"
sudo rm -rf "tor/tor_data"
sudo rm -rf "i2pd/i2pd_data"

# Recriar
make up
```

### Logs Detalhados

```bash
# Logs de todos os containers
docker-compose -f "bitcoin core/docker-compose.yml" logs -f &
docker-compose -f "lnd/docker-compose.yml" logs -f &
docker-compose -f "thunderhub/docker-compose.yml" logs -f &
docker-compose -f "tor/docker-compose.yml" logs -f &
docker-compose -f "i2pd/docker-compose.yml" logs -f &
```

### Informações do Sistema

```bash
# Informações completas
echo "=== SISTEMA ==="
uname -a
free -h
df -h

echo "=== DOCKER ==="
docker version
docker-compose version
docker system df

echo "=== CONTAINERS ==="
make status

echo "=== PORTAS ==="
netstat -tulpn | grep -E "(8332|8333|10009|3000|9050)"

echo "=== LOGS RECENTES ==="
make logs
```

## 📞 Obtendo Ajuda

1. **Verificar documentação oficial:**
   - [Bitcoin Core](https://bitcoincore.org/en/doc/)
   - [LND](https://docs.lightning.engineering/)
   - [Thunderhub](https://thunderhub.io/)

2. **Comunidade:**
   - Bitcoin Stack Exchange
   - Lightning Network community
   - Docker community forums

3. **Logs para suporte:**
   ```bash
   # Coletar informações para suporte
   make health > debug.log
   make logs >> debug.log
   docker system info >> debug.log
   ```

---

**Lembre-se:** Sempre faça backup dos dados importantes antes de aplicar soluções que possam causar perda de dados! 