#!/bin/bash

# reset shell colors
tput init

# Configure global variables
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$PROJECT_ROOT/$SOURCE"
done
PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

# required imports
source "${PROJECT_ROOT}"/variables/manifest.sh
source "${PROJECT_ROOT}"/utils/manifest.sh
source "${PROJECT_ROOT}"/lib/manifest.sh

# this file has passwords
sudo su - root <<EOF
chown root:root "${PROJECT_ROOT}"/.env
chmod 700 "${PROJECT_ROOT}"/.env
EOF
source "${PROJECT_ROOT}"/.env

# interactive CLI
#inquiry_options

link_git="https://axify-dev:${GITHUB_TOKEN}@github.com/weeblink/luminis.git"
frontend_url="clubedosfoguetes.com.br"
backend_url="api.clubedosfoguetes.com.br"
whatsappservice_url="waservice.clubedosfoguetes.com.br"
db_name="dbname"
db_user="dbuser"
db_password="dbpass"
postgresql_port=5432
plataform_name="luminis"
mail_host="smtp.hostinger.com"
mail_port="465"
mail_username="username@clubedosfoguetes.com.br"
mail_password="123456"
pandavideo_credential="panda-xxxxx"
checkoutapp_allowed_ip="15.229.103.46"

# Instalar dependências
system_install_dependences

# Github
system_github_config

sleep 5

# Docker
system_configure_docker_compose

# Network
system_config_nginx
system_request_ssl

# Run docker compose
print_banner
cd /var/www/"${plataform_name}" || exit
docker-compose down -v
docker-compose up --build

printf "\n\n${WHITE} ✅ Instalação finalizada com sucesso!"

