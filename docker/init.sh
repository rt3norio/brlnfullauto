#!/bin/bash

# BR-LN Docker Node - Script de Inicialização
# Este script verifica pré-requisitos e configura o ambiente

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║          BR-LN Docker Node Setup             ║"
    echo "║     Bitcoin Lightning Network Stack          ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Função para verificar se um comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para verificar versão do Docker
check_docker_version() {
    local version=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    
    if [ "$major" -gt 20 ] || ([ "$major" -eq 20 ] && [ "$minor" -ge 10 ]); then
        return 0
    else
        return 1
    fi
}

# Função para verificar versão do Docker Compose
check_docker_compose_version() {
    local version=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    local major=$(echo $version | cut -d. -f1)
    
    if [ "$major" -ge 2 ]; then
        return 0
    else
        return 1
    fi
}

# Função para verificar espaço em disco
check_disk_space() {
    local available=$(df . | tail -1 | awk '{print $4}')
    local required=$((10 * 1024 * 1024)) # 10GB em KB
    
    if [ "$available" -gt "$required" ]; then
        return 0
    else
        return 1
    fi
}

# Função para verificar RAM disponível
check_memory() {
    local available=$(free -m | awk 'NR==2{printf "%.0f", $7}')
    local required=2048 # 2GB
    
    if [ "$available" -gt "$required" ]; then
        return 0
    else
        return 1
    fi
}

# Função principal de verificação
check_prerequisites() {
    print_status "Verificando pré-requisitos..."
    
    local all_good=true
    
    # Verificar Docker
    if command_exists docker; then
        if check_docker_version; then
            print_success "Docker $(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) encontrado"
        else
            print_error "Docker versão muito antiga. Requer 20.10 ou superior"
            all_good=false
        fi
    else
        print_error "Docker não encontrado. Instale o Docker primeiro"
        all_good=false
    fi
    
    # Verificar Docker Compose
    if command_exists docker-compose; then
        if check_docker_compose_version; then
            print_success "Docker Compose $(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1) encontrado"
        else
            print_error "Docker Compose versão muito antiga. Requer 2.0 ou superior"
            all_good=false
        fi
    else
        print_error "Docker Compose não encontrado"
        all_good=false
    fi
    
    # Verificar Make
    if command_exists make; then
        print_success "Make encontrado"
    else
        print_error "Make não encontrado. Instale: sudo apt install make"
        all_good=false
    fi
    
    # Verificar espaço em disco
    if check_disk_space; then
        local available_gb=$(df . | tail -1 | awk '{printf "%.1f", $4/1024/1024}')
        print_success "Espaço em disco suficiente (${available_gb}GB disponível)"
    else
        print_error "Espaço em disco insuficiente. Requer pelo menos 10GB"
        all_good=false
    fi
    
    # Verificar RAM
    if check_memory; then
        local available_gb=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')
        print_success "Memória suficiente (${available_gb}GB disponível)"
    else
        print_warning "Pouca RAM disponível. Recomendado pelo menos 2GB livres"
    fi
    
    # Verificar se o usuário está no grupo docker
    if groups $USER | grep -q docker; then
        print_success "Usuário no grupo docker"
    else
        print_warning "Usuário não está no grupo docker. Execute: sudo usermod -aG docker $USER"
        print_warning "Depois faça logout/login ou execute: newgrp docker"
    fi
    
    if [ "$all_good" = false ]; then
        print_error "Alguns pré-requisitos não foram atendidos"
        exit 1
    fi
}

# Função para criar diretórios necessários
create_directories() {
    print_status "Criando diretórios necessários..."
    
    local dirs=(
        "bitcoin core/bitcoin-data"
        "lnd/lnd_data"
        "tor/tor_data"
        "i2pd/i2pd_data"
        "backups"
    )
    
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            print_success "Criado: $dir"
        else
            print_status "Já existe: $dir"
        fi
    done
}

# Função para configurar permissões
setup_permissions() {
    print_status "Configurando permissões..."
    
    # Definir o UID/GID do usuário atual
    local uid=$(id -u)
    local gid=$(id -g)
    
    # Configurar permissões para os diretórios de dados
    local dirs=(
        "bitcoin core/bitcoin-data"
        "lnd/lnd_data"
        "tor/tor_data"
        "i2pd/i2pd_data"
    )
    
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            chown -R $uid:$gid "$dir" 2>/dev/null || {
                print_warning "Não foi possível alterar permissões de $dir. Talvez seja necessário sudo"
            }
            chmod -R 755 "$dir"
            print_success "Permissões configuradas para: $dir"
        fi
    done
}

# Função para verificar portas disponíveis
check_ports() {
    print_status "Verificando disponibilidade de portas..."
    
    local ports=(8332 8333 10009 8080 9735 3000 9050 9051 4444 4447 7656 28332 28333)
    local busy_ports=()
    
    for port in "${ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            busy_ports+=($port)
        fi
    done
    
    if [ ${#busy_ports[@]} -eq 0 ]; then
        print_success "Todas as portas estão disponíveis"
    else
        print_warning "Portas ocupadas: ${busy_ports[*]}"
        print_warning "Verifique se outros serviços estão usando essas portas"
    fi
}

# Função para exibir informações do sistema
show_system_info() {
    print_status "Informações do sistema:"
    echo "  OS: $(uname -s) $(uname -r)"
    echo "  Arquitetura: $(uname -m)"
    echo "  RAM Total: $(free -h | awk 'NR==2{print $2}')"
    echo "  RAM Disponível: $(free -h | awk 'NR==2{print $7}')"
    echo "  Espaço em Disco: $(df -h . | tail -1 | awk '{print $4}') disponível"
    echo "  Docker: $(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo 'Não instalado')"
    echo "  Docker Compose: $(docker-compose --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo 'Não instalado')"
}

# Função para exibir próximos passos
show_next_steps() {
    echo
    print_success "Configuração inicial concluída!"
    echo
    echo -e "${CYAN}Próximos passos:${NC}"
    echo
    echo "1. Ver todos os comandos disponíveis:"
    echo "   ${YELLOW}make help${NC}"
    echo
    echo "2. Iniciar todos os serviços:"
    echo "   ${YELLOW}make up${NC}"
    echo
    echo "3. Verificar status dos containers:"
    echo "   ${YELLOW}make status${NC}"
    echo
    echo "4. Ver logs dos serviços:"
    echo "   ${YELLOW}make logs${NC}"
    echo
    echo "5. Acessar Thunderhub (após inicialização completa):"
    echo "   ${YELLOW}http://localhost:3000${NC}"
    echo
    echo -e "${BLUE}Documentação completa disponível em README.md${NC}"
    echo
}

# Função principal
main() {
    print_header
    
    echo "Este script irá verificar os pré-requisitos e configurar"
    echo "o ambiente para executar o BR-LN Docker Node."
    echo
    
    read -p "Deseja continuar? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Configuração cancelada."
        exit 0
    fi
    
    echo
    show_system_info
    echo
    
    check_prerequisites
    echo
    
    create_directories
    echo
    
    setup_permissions
    echo
    
    check_ports
    echo
    
    show_next_steps
}

# Executar função principal
main "$@" 