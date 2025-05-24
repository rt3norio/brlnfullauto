# BR-LN Docker Management 🚀

Este projeto oferece uma infraestrutura completa para executar um nó Bitcoin Lightning Network usando Docker, incluindo Bitcoin Core, LND, Thunderhub, Tor e i2pd.

## 📋 Índice

- [Componentes](#-componentes)
- [Pré-requisitos](#-pré-requisitos)
- [Instalação Rápida](#-instalação-rápida)
- [Comandos Principais](#-comandos-principais)
- [Gerenciamento Individual](#-gerenciamento-individual)
- [Monitoramento](#-monitoramento)
- [Backup e Restauração](#-backup-e-restauração)
- [Solução de Problemas](#-solução-de-problemas)
- [Portas e URLs](#-portas-e-urls)

## 🔧 Componentes

### Bitcoin Core
- **Função**: Nó completo da rede Bitcoin
- **Portas**: 8332 (RPC), 8333 (P2P), 28332/28333 (ZMQ)
- **Configuração**: Modo prune ativado (550MB)

### LND (Lightning Network Daemon)
- **Função**: Implementação do Lightning Network
- **Portas**: 10009 (RPC), 8080 (REST), 9735 (P2P)
- **Conectado**: Bitcoin Core via RPC/ZMQ

### Thunderhub
- **Função**: Interface web para gerenciar LND
- **Porta**: 3000
- **URL**: http://localhost:3000

### Tor
- **Função**: Proxy para privacidade
- **Portas**: 9050 (SOCKS), 9051 (Control)
- **Configuração**: Proxy SOCKS5

### i2pd
- **Função**: Router I2P para anonimato
- **Portas**: 4444 (HTTP Proxy), 4447 (SAM), 7656 (Control)

## 🛠️ Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Make
- Pelo menos 2GB de RAM disponível
- 10GB de espaço em disco livre

## ⚡ Instalação Rápida

1. **Clone o repositório** (se necessário):
   ```bash
   cd /caminho/para/BR-LN_docker_node
   ```

2. **Ver todos os comandos disponíveis**:
   ```bash
   make help
   ```

3. **Iniciar todos os serviços**:
   ```bash
   make up
   ```

4. **Verificar status**:
   ```bash
   make status
   ```

## 📚 Comandos Principais

### Gerenciamento Geral

```bash
# Subir todos os containers
make up

# Parar todos os containers  
make down

# Reiniciar todos os containers
make restart

# Ver status dos containers
make status

# Ver logs dos containers
make logs

# Seguir logs em tempo real
make logs-follow
```

### Comandos de Acesso

```bash
# Acessar shell do Bitcoin Core
make shell-bitcoin

# Acessar shell do LND
make shell-lnd

# Acessar shell do Thunderhub
make shell-thunderhub

# Acessar shell do Tor
make shell-tor

# Acessar shell do i2pd
make shell-i2pd
```

## 🎛️ Gerenciamento Individual

### Bitcoin Core
```bash
make bitcoin-up        # Iniciar apenas Bitcoin Core
make bitcoin-down      # Parar Bitcoin Core
make bitcoin-restart   # Reiniciar Bitcoin Core
make bitcoin-cli       # Executar bitcoin-cli
make bitcoin-getinfo   # Ver informações do nó
```

### LND
```bash
make lnd-up              # Iniciar apenas LND
make lnd-down            # Parar LND
make lnd-restart         # Reiniciar LND
make lnd-getinfo         # Ver informações do LND
make lnd-wallet-balance  # Ver saldo da carteira
make lnd-channel-balance # Ver saldo dos canais
```

### Thunderhub
```bash
make thunderhub-up       # Iniciar Thunderhub
make thunderhub-down     # Parar Thunderhub
make thunderhub-restart  # Reiniciar Thunderhub
```

### Tor
```bash
make tor-up       # Iniciar Tor
make tor-down     # Parar Tor
make tor-restart  # Reiniciar Tor
```

### i2pd
```bash
make i2pd-up       # Iniciar i2pd
make i2pd-down     # Parar i2pd
make i2pd-restart  # Reiniciar i2pd
```

## 📊 Monitoramento

```bash
# Verificar saúde dos containers
make health

# Monitorar recursos em tempo real
make monitor

# Ver informações das redes Docker
make network-info

# Ver portas utilizadas
make ports

# Ver URLs de acesso
make urls
```

## 💾 Backup e Restauração

```bash
# Fazer backup completo
make backup

# Os backups são salvos em: backups/YYYYMMDD_HHMMSS/
```

## 🧹 Limpeza e Manutenção

```bash
# Limpar containers parados e imagens órfãs
make clean

# Atualizar todas as imagens Docker
make update

# Reconstruir imagens personalizadas
make rebuild

# Limpeza completa (CUIDADO!)
make prune
```

## 🔧 Desenvolvimento

```bash
# Iniciar em modo desenvolvimento (com logs)
make dev-up
```

## 📡 Portas e URLs

### Portas Principais
| Serviço | Porta | Descrição |
|---------|-------|-----------|
| Bitcoin Core | 8332 | RPC API |
| Bitcoin Core | 8333 | P2P Network |
| LND | 10009 | gRPC API |
| LND | 8080 | REST API |
| LND | 9735 | P2P Lightning |
| Thunderhub | 3000 | Web Interface |
| Tor | 9050 | SOCKS Proxy |
| Tor | 9051 | Control Port |
| i2pd | 4444 | HTTP Proxy |
| i2pd | 4447 | SAM Interface |
| i2pd | 7656 | Control Port |

### URLs de Acesso
- **Thunderhub**: http://localhost:3000
- **LND REST API**: http://localhost:8080
- **Bitcoin RPC**: http://localhost:8332
- **Tor SOCKS**: socks5://localhost:9050
- **i2pd HTTP Proxy**: http://localhost:4444

## 🔧 Solução de Problemas

### Bitcoin Core não inicia
```bash
# Verificar logs
make logs | grep bitcoin

# Verificar configuração
make shell-bitcoin
cat /home/bitcoin/.bitcoin/bitcoin.conf
```

### LND não conecta ao Bitcoin Core
```bash
# Verificar se Bitcoin Core está rodando
make status

# Verificar logs do LND
docker logs lnd --tail=50

# Testar conexão RPC
make bitcoin-cli
```

### Thunderhub não acessa LND
```bash
# Verificar se LND está rodando e sincronizado
make lnd-getinfo

# Verificar logs do Thunderhub
docker logs thunderhub --tail=50
```

### Problemas de permissão
```bash
# Verificar proprietário dos diretórios de dados
ls -la */

# Se necessário, corrigir permissões
sudo chown -R 1000:1000 "./bitcoin core/bitcoin-data"
sudo chown -R 1000:1000 "lnd/lnd_data"
```

### Containers não iniciam
```bash
# Verificar se as portas estão livres
netstat -tulpn | grep -E "(8332|8333|10009|3000|9050)"

# Verificar logs do Docker
docker system events &
make up
```

## 📝 Configurações Importantes

### Bitcoin Core
- **Modo Prune**: Ativado (550MB)
- **RPC**: Habilitado com autenticação
- **ZMQ**: Configurado para notificações em tempo real
- **Network**: Mainnet (pode ser alterado para testnet)

### LND
- **Network**: Mainnet (configurado via docker-compose)
- **Backend**: Bitcoin Core
- **Conexão**: RPC + ZMQ para notificações rápidas

### Segurança
- Containers executam com usuários não-root
- Redes Docker isoladas
- Credenciais RPC configuradas
- Volumes persistentes para dados importantes

## 🚨 Avisos Importantes

1. **Mainnet**: Este setup usa a rede principal do Bitcoin. Certifique-se de entender os riscos.

2. **Backup**: Sempre faça backup das chaves e dados importantes antes de atualizações.

3. **Recursos**: O Bitcoin Core em modo prune usa menos espaço, mas pode precisar redownload de blocos para operações específicas.

4. **Rede**: As configurações assumem que você tem uma conexão de internet estável.

5. **Segurança**: As configurações padrão são para desenvolvimento/teste. Para produção, revise as configurações de segurança.

## 🆘 Suporte

Para problemas ou dúvidas:

1. Verificar logs: `make logs`
2. Verificar status: `make health`
3. Verificar configurações dos containers individuais
4. Consultar documentação oficial de cada componente

---

**Desenvolvido para facilitar o gerenciamento de nós Bitcoin Lightning Network** ⚡ 