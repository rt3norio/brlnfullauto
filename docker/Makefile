.PHONY: help all up down restart status logs clean prune bitcoin lnd thunderhub tor i2pd shell-bitcoin shell-lnd shell-thunderhub shell-tor shell-i2pd backup restore health

# Definir cores para output
RED := \033[31m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
MAGENTA := \033[35m
CYAN := \033[36m
RESET := \033[0m

# Diretórios dos serviços
BITCOIN_DIR := "bitcoin core"
LND_DIR := lnd
THUNDERHUB_DIR := thunderhub
TOR_DIR := tor
I2PD_DIR := i2pd

# Data de backup
BACKUP_DATE := $(shell date +%Y%m%d_%H%M%S)

help: ## Mostrar esta ajuda
	@echo "$(CYAN)BR-LN Docker Management$(RESET)"
	@echo "============================"
	@echo ""
	@echo "$(GREEN)Comandos Principais:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: up ## Subir todos os containers

up: ## Subir todos os containers Docker
	@echo "$(GREEN)🚀 Iniciando todos os serviços...$(RESET)"
	@echo "$(BLUE)📡 Iniciando Tor...$(RESET)"
	@cd $(TOR_DIR) && docker-compose up -d
	@sleep 5
	@echo "$(BLUE)🌐 Iniciando i2pd...$(RESET)"
	@cd $(I2PD_DIR) && docker-compose up -d
	@sleep 5
	@echo "$(BLUE)₿ Iniciando Bitcoin Core...$(RESET)"
	@cd $(BITCOIN_DIR) && docker-compose up -d
	@sleep 30
	@echo "$(BLUE)⚡ Iniciando LND...$(RESET)"
	@cd $(LND_DIR) && docker-compose up -d
	@sleep 15
	@echo "$(BLUE)🌩️ Iniciando Thunderhub...$(RESET)"
	@cd $(THUNDERHUB_DIR) && docker-compose up -d
	@echo "$(GREEN)✅ Todos os serviços foram iniciados!$(RESET)"
	@make status

down: ## Parar todos os containers
	@echo "$(RED)🛑 Parando todos os serviços...$(RESET)"
	@cd $(THUNDERHUB_DIR) && docker-compose down
	@cd $(LND_DIR) && docker-compose down
	@cd $(BITCOIN_DIR) && docker-compose down
	@cd $(TOR_DIR) && docker-compose down
	@cd $(I2PD_DIR) && docker-compose down
	@echo "$(RED)✅ Todos os serviços foram parados!$(RESET)"

restart: down up ## Reiniciar todos os containers

# Comandos individuais por serviço
bitcoin-up: ## Subir apenas Bitcoin Core
	@echo "$(BLUE)₿ Iniciando Bitcoin Core...$(RESET)"
	@cd $(BITCOIN_DIR) && docker-compose up -d

bitcoin-down: ## Parar Bitcoin Core
	@echo "$(RED)₿ Parando Bitcoin Core...$(RESET)"
	@cd $(BITCOIN_DIR) && docker-compose down

bitcoin-restart: bitcoin-down bitcoin-up ## Reiniciar Bitcoin Core

lnd-up: ## Subir apenas LND
	@echo "$(BLUE)⚡ Iniciando LND...$(RESET)"
	@cd $(LND_DIR) && docker-compose up -d

lnd-down: ## Parar LND
	@echo "$(RED)⚡ Parando LND...$(RESET)"
	@cd $(LND_DIR) && docker-compose down

lnd-restart: lnd-down lnd-up ## Reiniciar LND

thunderhub-up: ## Subir apenas Thunderhub
	@echo "$(BLUE)🌩️ Iniciando Thunderhub...$(RESET)"
	@cd $(THUNDERHUB_DIR) && docker-compose up -d

thunderhub-down: ## Parar Thunderhub
	@echo "$(RED)🌩️ Parando Thunderhub...$(RESET)"
	@cd $(THUNDERHUB_DIR) && docker-compose down

thunderhub-restart: thunderhub-down thunderhub-up ## Reiniciar Thunderhub

tor-up: ## Subir apenas Tor
	@echo "$(BLUE)📡 Iniciando Tor...$(RESET)"
	@cd $(TOR_DIR) && docker-compose up -d

tor-down: ## Parar Tor
	@echo "$(RED)📡 Parando Tor...$(RESET)"
	@cd $(TOR_DIR) && docker-compose down

tor-restart: tor-down tor-up ## Reiniciar Tor

i2pd-up: ## Subir apenas i2pd
	@echo "$(BLUE)🌐 Iniciando i2pd...$(RESET)"
	@cd $(I2PD_DIR) && docker-compose up -d

i2pd-down: ## Parar i2pd
	@echo "$(RED)🌐 Parando i2pd...$(RESET)"
	@cd $(I2PD_DIR) && docker-compose down

i2pd-restart: i2pd-down i2pd-up ## Reiniciar i2pd

status: ## Mostrar status de todos os containers
	@echo "$(CYAN)📊 Status dos Containers:$(RESET)"
	@echo ""
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(NAMES|bitcoin-node|lnd|thunderhub|tor_service|i2pd)" || echo "$(RED)Nenhum container encontrado$(RESET)"

logs: ## Mostrar logs de todos os containers
	@echo "$(CYAN)📋 Logs dos Containers:$(RESET)"
	@echo ""
	@echo "$(YELLOW)Bitcoin Core:$(RESET)"
	@docker logs bitcoin-node --tail=10 2>/dev/null || echo "$(RED)Container bitcoin-node não encontrado$(RESET)"
	@echo ""
	@echo "$(YELLOW)LND:$(RESET)"
	@docker logs lnd --tail=10 2>/dev/null || echo "$(RED)Container lnd não encontrado$(RESET)"
	@echo ""
	@echo "$(YELLOW)Thunderhub:$(RESET)"
	@docker logs thunderhub --tail=10 2>/dev/null || echo "$(RED)Container thunderhub não encontrado$(RESET)"
	@echo ""
	@echo "$(YELLOW)Tor:$(RESET)"
	@docker logs tor_service --tail=10 2>/dev/null || echo "$(RED)Container tor_service não encontrado$(RESET)"
	@echo ""
	@echo "$(YELLOW)i2pd:$(RESET)"
	@docker logs i2pd --tail=10 2>/dev/null || echo "$(RED)Container i2pd não encontrado$(RESET)"

logs-follow: ## Seguir logs de todos os containers em tempo real
	@echo "$(CYAN)📋 Seguindo logs em tempo real (Ctrl+C para sair):$(RESET)"
	@docker logs --follow bitcoin-node lnd thunderhub tor_service i2pd 2>/dev/null

# Comandos de acesso aos containers
shell-bitcoin: ## Acessar shell do Bitcoin Core
	@echo "$(CYAN)🐚 Acessando shell do Bitcoin Core...$(RESET)"
	@docker exec -it bitcoin-node bash

shell-lnd: ## Acessar shell do LND
	@echo "$(CYAN)🐚 Acessando shell do LND...$(RESET)"
	@docker exec -it lnd sh

shell-thunderhub: ## Acessar shell do Thunderhub
	@echo "$(CYAN)🐚 Acessando shell do Thunderhub...$(RESET)"
	@docker exec -it thunderhub sh

shell-tor: ## Acessar shell do Tor
	@echo "$(CYAN)🐚 Acessando shell do Tor...$(RESET)"
	@docker exec -it tor_service bash

shell-i2pd: ## Acessar shell do i2pd
	@echo "$(CYAN)🐚 Acessando shell do i2pd...$(RESET)"
	@docker exec -it i2pd sh

# Comandos específicos do Bitcoin
bitcoin-cli: ## Executar bitcoin-cli
	@echo "$(CYAN)₿ Executando bitcoin-cli getblockchaininfo...$(RESET)"
	@docker exec bitcoin-node bitcoin-cli -rpcuser=bitcoinrpc -rpcpassword=secure_password getblockchaininfo

bitcoin-getinfo: ## Obter informações do Bitcoin Core
	@echo "$(CYAN)₿ Informações do Bitcoin Core:$(RESET)"
	@docker exec bitcoin-node bitcoin-cli -rpcuser=bitcoinrpc -rpcpassword=secure_password getblockchaininfo
	@echo ""
	@docker exec bitcoin-node bitcoin-cli -rpcuser=bitcoinrpc -rpcpassword=secure_password getnetworkinfo

# Comandos específicos do LND
lnd-getinfo: ## Obter informações do LND
	@echo "$(CYAN)⚡ Informações do LND:$(RESET)"
	@docker exec lnd lncli getinfo

lnd-wallet-balance: ## Ver saldo da carteira LND
	@echo "$(CYAN)⚡ Saldo da carteira LND:$(RESET)"
	@docker exec lnd lncli walletbalance

lnd-channel-balance: ## Ver saldo dos canais LND
	@echo "$(CYAN)⚡ Saldo dos canais LND:$(RESET)"
	@docker exec lnd lncli channelbalance

lnd-create-wallet: ## Criar uma nova carteira LND
	@echo "$(CYAN)⚡ Criando uma nova carteira LND...$(RESET)"
	@docker exec lnd lncli create

lnd-unlock-wallet: ## Desbloquear uma carteira LND
	@echo "$(CYAN)⚡ Desbloquear uma carteira LND...$(RESET)"
	@if [ -n "$(password)" ]; then \
		echo "$(password)" | docker exec -i lnd lncli unlock; \
	else \
		stty -echo; \
		printf "Enter wallet password: "; \
		read password; \
		stty echo; \
		echo ""; \
		echo "$$password" | docker exec -i lnd lncli unlock; \
	fi

# Comandos de backup
backup: ## Fazer backup dos dados
	@echo "$(YELLOW)💾 Fazendo backup dos dados...$(RESET)"
	@mkdir -p backups/$(BACKUP_DATE)
	@echo "$(BLUE)📦 Backup Bitcoin Core...$(RESET)"
	@sudo tar -czf backups/$(BACKUP_DATE)/bitcoin-data.tar.gz $(BITCOIN_DIR)/bitcoin-data/ 2>/dev/null || echo "$(RED)Erro no backup do Bitcoin Core$(RESET)"
	@echo "$(BLUE)📦 Backup LND...$(RESET)"
	@sudo tar -czf backups/$(BACKUP_DATE)/lnd-data.tar.gz $(LND_DIR)/lnd_data/ 2>/dev/null || echo "$(RED)Erro no backup do LND$(RESET)"
	@echo "$(BLUE)📦 Backup Tor...$(RESET)"
	@sudo tar -czf backups/$(BACKUP_DATE)/tor-data.tar.gz $(TOR_DIR)/tor_data/ 2>/dev/null || echo "$(RED)Erro no backup do Tor$(RESET)"
	@echo "$(BLUE)📦 Backup i2pd...$(RESET)"
	@sudo tar -czf backups/$(BACKUP_DATE)/i2pd-data.tar.gz $(I2PD_DIR)/i2pd_data/ 2>/dev/null || echo "$(RED)Erro no backup do i2pd$(RESET)"
	@echo "$(GREEN)✅ Backup concluído em backups/$(BACKUP_DATE)/$(RESET)"

# Comandos de limpeza
clean: ## Remover containers parados e imagens órfãs
	@echo "$(YELLOW)🧹 Limpando containers parados...$(RESET)"
	@docker container prune -f
	@echo "$(YELLOW)🧹 Limpando imagens órfãs...$(RESET)"
	@docker image prune -f

prune: ## Limpeza completa do Docker (CUIDADO!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso removerá TODOS os dados não utilizados do Docker!$(RESET)"
	@read -p "Tem certeza? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@docker system prune -a --volumes -f

# Comandos de monitoramento
health: ## Verificar saúde dos containers
	@echo "$(CYAN)🏥 Verificando saúde dos containers:$(RESET)"
	@echo ""
	@for container in bitcoin-node lnd thunderhub tor_service i2pd; do \
		if docker ps --format '{{.Names}}' | grep -q "$$container"; then \
			echo "$(GREEN)✅ $$container: Rodando$(RESET)"; \
		else \
			echo "$(RED)❌ $$container: Parado$(RESET)"; \
		fi; \
	done

monitor: ## Monitorar recursos dos containers
	@echo "$(CYAN)📊 Monitoramento de recursos (Ctrl+C para sair):$(RESET)"
	@docker stats bitcoin-node lnd thunderhub tor_service i2pd

# Comandos de informação
ports: ## Mostrar portas utilizadas
	@echo "$(CYAN)🔌 Portas dos serviços:$(RESET)"
	@echo ""
	@echo "$(YELLOW)Bitcoin Core:$(RESET)"
	@echo "  - RPC: 8332"
	@echo "  - P2P: 8333"
	@echo "  - ZMQ Block: 28332"
	@echo "  - ZMQ TX: 28333"
	@echo ""
	@echo "$(YELLOW)LND:$(RESET)"
	@echo "  - RPC: 10009"
	@echo "  - REST: 8080"
	@echo "  - P2P: 9735"
	@echo ""
	@echo "$(YELLOW)Thunderhub:$(RESET)"
	@echo "  - Web UI: 3000"
	@echo ""
	@echo "$(YELLOW)Tor:$(RESET)"
	@echo "  - SOCKS: 9050"
	@echo "  - Control: 9051"
	@echo ""
	@echo "$(YELLOW)i2pd:$(RESET)"
	@echo "  - HTTP Proxy: 4444"
	@echo "  - SAM: 4447"
	@echo "  - Control: 7656"

urls: ## Mostrar URLs de acesso
	@echo "$(CYAN)🌐 URLs de acesso:$(RESET)"
	@echo ""
	@echo "$(GREEN)Thunderhub Web Interface:$(RESET) http://localhost:3000"
	@echo "$(GREEN)LND REST API:$(RESET) http://localhost:8080"
	@echo "$(GREEN)Bitcoin Core RPC:$(RESET) http://localhost:8332"
	@echo "$(GREEN)Tor SOCKS Proxy:$(RESET) socks5://localhost:9050"
	@echo "$(GREEN)i2pd HTTP Proxy:$(RESET) http://localhost:4444"

# Comandos avançados
update: ## Atualizar todas as imagens Docker
	@echo "$(YELLOW)🔄 Atualizando imagens Docker...$(RESET)"
	@cd $(BITCOIN_DIR) && docker-compose pull
	@cd $(LND_DIR) && docker-compose pull
	@cd $(THUNDERHUB_DIR) && docker-compose pull
	@cd $(TOR_DIR) && docker-compose pull
	@cd $(I2PD_DIR) && docker-compose pull
	@echo "$(GREEN)✅ Imagens atualizadas!$(RESET)"

rebuild: ## Reconstruir todas as imagens
	@echo "$(YELLOW)🔨 Reconstruindo imagens...$(RESET)"
	@cd $(BITCOIN_DIR) && docker-compose build --no-cache
	@cd $(TOR_DIR) && docker-compose build --no-cache
	@echo "$(GREEN)✅ Imagens reconstruídas!$(RESET)"

# Comandos de desenvolvimento
dev-up: ## Subir em modo desenvolvimento com logs
	@echo "$(CYAN)🔧 Iniciando em modo desenvolvimento...$(RESET)"
	@make up
	@make logs-follow

network-info: ## Mostrar informações das redes Docker
	@echo "$(CYAN)🌐 Informações das redes Docker:$(RESET)"
	@docker network ls | grep -E "(bitcoin|lnd|tor|i2pd)"

# Default target
.DEFAULT_GOAL := help 