#!/bin/bash

system_update(){
    print_banner
    printf "${WHITE} 💻 Vamos atualizar o servidor...${GRAY_LIGHT}"
    printf "\n\n"

    # Run commands directly with sudo instead of using heredoc
    sudo apt -y update
    sudo apt -y upgrade
    sudo apt-get install -y \
        libxshmfence-dev \
        libgbm-dev \
        wget \
        unzip \
        fontconfig \
        locales \
        gconf-service \
        libasound2 \
        libatk1.0-0 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libfontconfig1 \
        libgcc1 \
        libgconf-2-4 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libgtk-3-0 \
        libnspr4 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxi6 \
        libxrandr2 \
        libxrender1 \
        libxss1 \
        libxtst6 \
        ca-certificates \
        fonts-liberation \
        libappindicator1 \
        libnss3 \
        lsb-release \
        xdg-utils

    sleep 2
}

system_aapanel_install(){
    print_banner
    printf "${WHITE} 💻 Vamos instalar o sistema do Aapanel...${GRAY_LIGHT}"
    printf "\n\n"

    # Download the installer
    wget -O install.sh http://www.aapanel.com/script/install-ubuntu_6.0_en.sh &>/dev/null || {
        printf "${RED}Erro ao baixar o instalador do Aapanel${GRAY_LIGHT}"
        return 1
    }

    chmod +x install.sh

    # Run installer suppressing all errors
    yes "y" | bash install.sh aapanel &>/dev/null || {
        printf "${RED}🚨 Erro durante intalação do Aapanel${GRAY_LIGHT}\n"
        return 1
    }

    printf "${GREEN}✅ Aapanel instalado com sucesso!${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2
}

system_docker_install(){
    print_banner
    printf "${WHITE} 💻 Instalando docker...${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2

    # Update package list
    if ! apt-get update; then
        printf "${RED}❌ Falha ao atualizar os repositórios${GRAY_LIGHT}\n"
        return 1
    fi

    # Install prerequisites
    if ! apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        gnupg; then
        printf "${RED}Falha ao instalar os pré-requisitos${GRAY_LIGHT}\n"
        return 1
    fi

    # Add Docker's official GPG key
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg; then
        printf "${RED}❌ Falha ao adicionar a chave GPG do Docker${GRAY_LIGHT}\n"
        return 1
    fi

    # Add Docker repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update apt repository
    if ! apt-get update; then
        printf "${RED}❌ Falha ao atualizar os repositórios${GRAY_LIGHT}\n"
        return 1
    fi

    # Install Docker CE
    if ! apt-get install -y docker-ce docker-ce-cli containerd.io; then
        printf "${RED}❌ Falha ao instalar o Docker${GRAY_LIGHT}\n"
        return 1
    fi

    # Create docker group and add current user
    groupadd docker || true
    usermod -aG docker $USER || true

    # Start Docker daemon
    mkdir -p /etc/docker
    cat > /etc/docker/daemon.json <<EOL
{
  "default-ulimits": {
    "nofile": {
      "name": "nofile",
      "hard": 64000,
      "soft": 64000
    }
  }
}
EOL

    # Try different methods to start Docker
    if command -v systemctl >/dev/null 2>&1; then
        systemctl start docker || true
        systemctl enable docker || true
    else
        service docker start || true
        update-rc.d docker defaults || true
    fi

    printf "${GREEN}✅ Docker instalado com sucesso!${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2

    # Verify Docker installation
    if ! docker --version; then
        printf "${RED}⚠️ Docker instalado mas não foi possível verificar a versão${GRAY_LIGHT}\n"
    fi

    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v2.24.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    sleep 3

    # Verify Docker compose installation
    if ! docker-compose --version; then
        printf "${RED}⚠️ Docker-compose instalado mas não foi possível verificar a versão${GRAY_LIGHT}\n"
    fi

    # Wait for Docker to be ready
    sleep 5
    
    # Final check
    if ! docker info >/dev/null 2>&1; then
        printf "${RED}⚠️ Docker não está rodando. Tentando iniciar novamente...${GRAY_LIGHT}\n"
        kill -9 $(pidof -x dockerd) >/dev/null 2>&1 || true
        dockerd > /dev/null 2>&1 &
        sleep 5
    fi
}

system_nginx_install(){
    print_banner
    printf "${WHITE} 💻 Instalando nginx...${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2

    # Install nginx
    if ! apt-get install -y nginx; then
        printf "${RED}❌ Falha ao instalar o nginx${GRAY_LIGHT}\n"
        return 1
    fi

    # Remove default site configuration
    if [ -f /etc/nginx/sites-enabled/default ]; then
        rm /etc/nginx/sites-enabled/default
    fi

    # Start nginx service directly
    if ! service nginx start; then
        printf "${RED}❌ Falha ao iniciar o serviço nginx${GRAY_LIGHT}\n"
        return 1
    fi

    # Verify nginx installation
    if ! nginx -v; then
        printf "${RED}⚠️ Nginx instalado mas não foi possível verificar a versão${GRAY_LIGHT}\n"
    fi

    printf "${GREEN}✅ Nginx instalado com sucesso!${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2
}

system_certbot_install(){
    print_banner
    printf "${WHITE} 💻 Instalando certbot...${GRAY_LIGHT}"
    printf "\n\n"

    sleep 2

    # Clean up previous install script if exists
    rm -f install.sh

    # Redirect all output including stderr to /dev/null
    {
        apt-get update
        apt-get install -y python3-certbot python3-certbot-nginx
        certbot_version=$(certbot --version 2>/dev/null)
    } &>/dev/null

    if [ ! -z "$certbot_version" ]; then
        printf "${GREEN}✅ Certbot instalado com sucesso!${GRAY_LIGHT}\n\n"
    else
        printf "${RED}❌ Falha ao instalar Certbot${GRAY_LIGHT}\n"
        return 1
    fi

    sleep 2
}

system_install_dependences(  ){

    system_update
    sleep 2

    #system_aapanel_install
    #sleep 2

    #rm -f install.sh
    #killall -9 install.sh &>/dev/null || true

    system_docker_install
    sleep 10

    system_nginx_install
    sleep 2
    
    system_certbot_install
    sleep 2
}

system_github_config(){
    print_banner
    printf "${WHITE} 💻 Fazendo download do código da plataforma...${GRAY_LIGHT}"
    printf "\n\n"

    # Update and install git
    apt-get update
    sleep 2

    apt-get install -y git
    sleep 2

    if ! git clone "${link_git}" /var/www/${plataform_name}; then
        printf "${RED}❌ Falha ao clonar repositório${GRAY_LIGHT}\n"
        return 1
    fi

    printf "\n\n${WHITE} ✅ Código baixado com sucesso"

    sleep 2
}

system_configure_docker_compose(){
    print_banner
    printf "${WHITE} 💻 Configurando variáveis de ambiente...${GRAY_LIGHT}"
    printf "\n\n"

    cd /var/www/"${plataform_name}" || {
        printf "${RED}❌ Falha ao acessar diretório${GRAY_LIGHT}\n"
        return 1
    }

    cat > docker-compose.yml << EOL
# docker-compose.yml
version: "3.8"

services:
  backend:
    networks:
      - app-network
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/var/www/html
      - ./files:/var/www/html/storage/app/public
      - ./backend/logs/supervisor:/var/log/supervisor
    depends_on:
      pg:
        condition: service_healthy
    environment:
      - APP_NAME=${plataform_name}
      - APP_ENV=local
      - APP_DEBUG=true
      - APP_TIMEZONE=America/Sao_Paulo
      - APP_URL=https://${backend_url}
      - FRONTEND_URL=https://${frontend_url}
      - APP_LOCALE=pt_BR
      - APP_FALLBACK_LOCALE=en
      - APP_FAKER_LOCALE=pt_BR
      - L5_SWAGGER_CONST_HOST=https://${backend_url}
      - L5_SWAGGER_GENERATE_ALWAYS=true
      - APP_MAINTENANCE_DRIVER=file
      - BCRYPT_ROUNDS=12
      - LOG_CHANNEL=stack
      - LOG_STACK=single
      - LOG_DEPRECATIONS_CHANNEL=null
      - LOG_LEVEL=debug
      - DB_CONNECTION=pgsql
      - DB_HOST=pg
      - DB_PORT=${postgresql_port}
      - DB_DATABASE=${db_name}
      - DB_USERNAME=${db_user}
      - DB_PASSWORD=${db_password}
      - SESSION_DRIVER=database
      - SESSION_LIFETIME=120
      - SESSION_ENCRYPT=false
      - SESSION_PATH=/
      - BROADCAST_CONNECTION=log
      - FILESYSTEM_DISK=local
      - QUEUE_CONNECTION=database
      - CACHE_STORE=database
      - CACHE_PREFIX=""
      - SESSION_DOMAIN=${frontend_url},www.${frontend_url},localhost,127.0.0.1
      - SANCTUM_STATEFUL_DOMAINS=.${frontend_url},www.${frontend_url},localhost:5174,127.0.0.1:5174
      - MAIL_MAILER=smtp
      - MAIL_HOST=${mail_host}
      - MAIL_PORT=${mail_port}
      - MAIL_USERNAME=${mail_username}
      - MAIL_PASSWORD=${mail_password}
      - MAIL_ENCRYPTION=ssl
      - MAIL_FROM_ADDRESS=${mail_username}
      - VITE_APP_NAME="${APP_NAME}"
      - WS_WHATSAPP_TOKEN=7hK9mN2pQ5rS8vW3xZ1yA4dF6gH0jL2nP5tR8wB9cE4mJ7kU3vX6yA0bD4fG
      - WS_WHATSAPP_URL=https://${whatsappservice_url}/api/
      - CHECKOUTAPP_ALLOWED_IPS=${checkoutapp_allowed_ip},127.0.0.1
      - PANDAVIDEO_API_KEY="${pandavideo_credential}"
  frontend:
    networks:
      - app-network
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "5174:5174"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=${backend_url}
  pg:
    networks:
      - app-network
    image: bitnami/postgresql:latest
    ports:
      - "5432:5432"
    environment:
      - POSTGRESQL_USERNAME=${db_user}
      - POSTGRESQL_PASSWORD=${db_password}
      - POSTGRESQL_DATABASE=${db_name}
      - ALLOW_EMPTY_PASSWORD=no
    volumes:
      - postgres_data:/bitnami/postgresql
    healthcheck:
      test: [ "CMD", "pg_isready", "-U", "${db_user}" ]
      interval: 5s
      timeout: 5s
      retries: 5
  whatsapp:
    networks:
      - app-network
    build:
      context: ./whatsappWebService
      dockerfile: Dockerfile
    ports:
      - "4000:4000"
    volumes:
      - ./whatsappWebService:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - BACKEND_URL="https://${backend_url}"
      - FRONTEND_URL="https://${frontend_url}"
      - PORT=4000
      - MIDDLEWARE_TOKEN=7hK9mN2pQ5rS8vW3xZ1yA4dF6gH0jL2nP5tR8wB9cE4mJ7kU3vX6yA0bD4fG
      - DB_DIALECT=postgres
      - DB_HOST=pg
      - DB_PORT=5432
      - DB_USER=${db_user}
      - DB_PASS=${db_password}
      - DB_NAME=${db_name}
      - DB_TIMEZONE=-03:00
networks:
  app-network:
    driver: bridge
volumes:
  postgres_data:
EOL

    if [ $? -ne 0 ]; then
        printf "${RED}❌ Falha ao criar docker-compose.yml${GRAY_LIGHT}\n"
        return 1
    fi

    printf "${GREEN}✅ Docker Compose configurado com sucesso!${GRAY_LIGHT}\n"

    sleep 2

    printf "${WHITE} 📄 Conteúdo do arquivo docker-compose.yml:${GRAY_LIGHT}\n"
    cat docker-compose.yml
    printf "\n"
}

nginx_config_frontend(){
    print_banner
    printf "${WHITE} 💻 Configurando rede com nginx frontend...${GRAY_LIGHT}"
    printf "\n\n"

    cat > /etc/nginx/sites-available/${plataform_name}-frontend << 'EOL'
server {
    listen 80;
    server_name ${frontend_url} www.${frontend_url};

    location / {
        proxy_pass http://localhost:5174;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        proxy_read_timeout 120;
        proxy_connect_timeout 120;
        proxy_send_timeout 120;

        proxy_buffers 8 32k;
        proxy_buffer_size 64k;
    }

    location /@vite/ {
        proxy_pass http://localhost:5174;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    location /@vite/client {
        proxy_pass http://localhost:5174;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOL

    ln -s /etc/nginx/sites-available/${plataform_name}-frontend /etc/nginx/sites-enabled

    printf "\n\n${WHITE} ✅ Configuração de rede do frontend criada com sucesso!"
    sleep 5
}

nginx_config_backend(){
    print_banner
    printf "${WHITE} 💻 Configurando rede com nginx backend...${GRAY_LIGHT}"
    printf "\n\n"

    cat > /etc/nginx/sites-available/${plataform_name}-backend << 'EOL'
server {
    listen 80;
    server_name ${backend_url};
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }

    client_max_body_size 100M;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
}
EOL

    ln -s /etc/nginx/sites-available/${plataform_name}-backend /etc/nginx/sites-enabled

    printf "\n\n${WHITE} ✅ Configuração de rede do backend criada com sucesso!"

    sleep 5
}

nginx_config_waservice(){
   print_banner
   printf "${WHITE} 💻 Configurando rede com nginx WA Service...${GRAY_LIGHT}"
   printf "\n\n"

   cat > /etc/nginx/sites-available/${plataform_name}-waservice << 'EOL'
server {
   listen 80;
   server_name ${whatsappservice_url};
   
   error_log /var/log/nginx/waservice_error.log debug;
   access_log /var/log/nginx/waservice_access.log;

   location / {
       proxy_pass http://localhost:4000;
       proxy_http_version 1.1;
       proxy_set_header Host \$host;
       proxy_set_header X-Real-IP \$remote_addr;
       proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto \$scheme;
       
       proxy_set_header Upgrade \$http_upgrade;
       proxy_set_header Connection "upgrade";
       proxy_read_timeout 86400;
       proxy_send_timeout 86400;

       proxy_set_header Content-Type \$content_type;
       proxy_set_header Content-Length \$content_length;
   }

   client_max_body_size 50M;

   add_header X-Frame-Options "SAMEORIGIN";
   add_header X-XSS-Protection "1; mode=block";
   add_header X-Content-Type-Options "nosniff";
}
EOL

   ln -s /etc/nginx/sites-available/${plataform_name}-waservice /etc/nginx/sites-enabled

   printf "\n\n${WHITE} ✅ Configuração de rede do wa service criada com sucesso!"

   sleep 5
}

system_config_nginx(){
    
    nginx_config_frontend
    sleep 3

    nginx_config_backend
    sleep 3

    nginx_config_waservice
    sleep 3

    printf "\n\n"
    nginx -t
    sleep 5
}