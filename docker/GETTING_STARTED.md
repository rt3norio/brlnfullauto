# 🚀 Guia de Início Rápido - BR-LN Docker Node

Bem-vindo ao BR-LN Docker Node! Este guia irá te ajudar a configurar e executar rapidamente um nó completo Bitcoin Lightning Network.

## 📦 O que foi criado para você

O sistema inclui um **Makefile completo** com gerenciamento para todos os containers Docker:

### 🏗️ Arquivos Principais Criados:

1. **`Makefile`** - Script principal de gerenciamento (289 linhas)
   - 50+ comandos para gerenciar containers
   - Cores e formatação bonita
   - Sequenciamento automático de inicialização
   - Comandos individuais e em grupo

2. **`README.md`** - Documentação completa (328 linhas)
   - Guia detalhado de uso
   - Explicação de todos os componentes
   - Tabela de portas e URLs
   - Solução de problemas básicos

3. **`TROUBLESHOOTING.md`** - Guia de solução de problemas (538 linhas)
   - Diagnósticos por serviço
   - Comandos de emergência
   - Problemas comuns e soluções

4. **`init.sh`** - Script de configuração inicial (311 linhas)
   - Verificação de pré-requisitos
   - Configuração automática de permissões
   - Verificação de portas e recursos

5. **`config.env.example`** - Arquivo de configuração (139 linhas)
   - Variáveis de ambiente personalizáveis
   - Configurações de todos os serviços

## ⚡ Início Ultra-Rápido (3 comandos)

```bash
# 1. Verificar e configurar ambiente
./init.sh

# 2. Subir todos os serviços
make up

# 3. Verificar status
make status
```

## 🎯 Comandos Mais Usados

```bash
# Ver ajuda completa
make help

# Subir tudo
make up

# Parar tudo  
make down

# Ver status
make status

# Ver logs
make logs

# Acessar Thunderhub
# http://localhost:3000
```

## 🔧 Gerenciamento Individual

### Bitcoin Core
```bash
make bitcoin-up         # Iniciar
make bitcoin-down       # Parar
make bitcoin-getinfo    # Ver informações
make bitcoin-cli        # Executar comandos
make shell-bitcoin      # Acessar shell
```

### LND (Lightning Network)
```bash
make lnd-up             # Iniciar
make lnd-down           # Parar
make lnd-getinfo        # Ver informações
make lnd-wallet-balance # Ver saldo
make shell-lnd          # Acessar shell
```

### Thunderhub (Interface Web)
```bash
make thunderhub-up      # Iniciar
make thunderhub-down    # Parar
# Acesso: http://localhost:3000
```

### Tor (Privacidade)
```bash
make tor-up             # Iniciar
make tor-down           # Parar
# SOCKS: localhost:9050
```

### i2pd (Anonimato)
```bash
make i2pd-up            # Iniciar
make i2pd-down          # Parar
# HTTP Proxy: localhost:4444
```

## 🛠️ Ferramentas de Administração

### Monitoramento
```bash
make health      # Verificar saúde dos containers
make monitor     # Monitorar recursos em tempo real
make logs-follow # Seguir logs em tempo real
make ports       # Ver todas as portas
make urls        # Ver URLs de acesso
```

### Backup e Manutenção
```bash
make backup      # Backup completo dos dados
make clean       # Limpar containers órfãos
make update      # Atualizar imagens Docker
make rebuild     # Reconstruir imagens
```

### Desenvolvimento
```bash
make dev-up      # Modo desenvolvimento (com logs)
make network-info # Info das redes Docker
```

## 🔍 Verificação Rápida

Execute este comando para verificar se tudo está funcionando:

```bash
# Diagnóstico completo
make health && echo "---" && make status && echo "---" && make ports
```

## 📋 Sequência de Inicialização Automática

O comando `make up` inicia os serviços na ordem correta:

1. **Tor** (5s delay) - Proxy para privacidade
2. **i2pd** (5s delay) - Router I2P
3. **Bitcoin Core** (30s delay) - Nó Bitcoin
4. **LND** (15s delay) - Lightning Network
5. **Thunderhub** - Interface web

## 🌐 URLs de Acesso Após Inicialização

- **Thunderhub**: http://localhost:3000
- **LND REST API**: http://localhost:8080
- **Bitcoin RPC**: http://localhost:8332
- **Tor SOCKS**: socks5://localhost:9050
- **i2pd HTTP**: http://localhost:4444

## 🚨 Primeira Execução

### Se é a primeira vez:

```bash
# 1. Executar script de configuração
./init.sh

# 2. Aguardar: "Configuração inicial concluída!"

# 3. Iniciar serviços
make up

# 4. Aguardar sincronização (pode demorar)
make logs-follow

# 5. Verificar quando estiver pronto
make bitcoin-getinfo
make lnd-getinfo
```

### Tempos Esperados:
- **Tor/i2pd**: 1-2 minutos
- **Bitcoin Core**: 15-30 minutos (primeira sync)
- **LND**: 5-10 minutos após Bitcoin
- **Thunderhub**: Imediato após LND

## 🎛️ Customização

### Configuração Personalizada:
```bash
# Copiar arquivo de exemplo
cp config.env.example config.env

# Editar configurações
nano config.env

# Aplicar (reiniciar containers)
make restart
```

### Portas Personalizadas:
Edite os arquivos `docker-compose.yml` em cada pasta de serviço.

## 🆘 Problemas?

1. **Script não executa**: `chmod +x init.sh`
2. **Erro de permissão Docker**: `sudo usermod -aG docker $USER`
3. **Portas ocupadas**: `make health` e verificar conflitos
4. **Pouca memória**: Parar alguns serviços temporariamente
5. **Consulte**: `TROUBLESHOOTING.md` para problemas específicos

## 📚 Documentação Completa

- **`README.md`** - Documentação principal
- **`TROUBLESHOOTING.md`** - Solução de problemas
- **`config.env.example`** - Configurações disponíveis

## 🎉 Conclusão

Agora você tem um sistema completo de gerenciamento Docker para Bitcoin Lightning Network com:

✅ **50+ comandos** no Makefile  
✅ **Cores e formatação** bonita  
✅ **Sequenciamento automático** de inicialização  
✅ **Backup automático** com timestamp  
✅ **Monitoramento em tempo real**  
✅ **Scripts de configuração** automática  
✅ **Documentação completa** e troubleshooting  
✅ **Suporte individual** para cada serviço  

---

**🚀 Comece agora:** `./init.sh && make up`

**💡 Dica:** Use `make help` para ver todos os comandos disponíveis!

---

*Desenvolvido para facilitar o gerenciamento de nós Bitcoin Lightning Network* ⚡ 