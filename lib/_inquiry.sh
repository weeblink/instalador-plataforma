#!/bin/bash

get_db_name(){
    print_banner
    printf "${WHITE} 🗓️ Insira o nome do Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " db_name
    db_name="teste"
}

get_db_user(){
    print_banner
    printf "${WHITE} 🗓️ Insira o usuário do Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " db_user
    db_user="teste_user"
}

get_db_password(){
    print_banner
    printf "${WHITE} 🗓️ Insira a senha do usuário ${db_user} do Banco de Dados (Não utilizar caracteres especiais):${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " db_password
    db_password="123456"
}

get_db_info(){

    # Configure DB name
    get_db_name    

    # Configure DB User
    get_db_user

    # Configure DB User
    get_db_password
}

get_link_git(){
    print_banner
    printf "${WHITE} 💻 Insira o link do GITHUB do repositório desejado: ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " link_git
    link_git="https://github.com/weeblink/plataforma_paidoecommerce.git"
}

get_frontend_domain(){
    print_banner
    printf "${WHITE} 💻 Digite o domínio do FRONTEND/PAINEL para a ${plataform_name}:${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " frontend_url
    frontend_url="app.paidoecommerce.com"
}

get_backend_domain(){
    print_banner
    printf "${WHITE} 💻 Digite o domínio do BACKEND/API para a ${plataform_name}:${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " backend_url
    backend_url="api.paidoecommerce.com"
}

get_whatsapp_service_domain(){
    print_banner
    printf "${WHITE} 💻 Digite o domínio do WHATSAPP SERVICE para a ${plataform_name}:${GRAY_LIGHT}"
    printf "\n\n"
    #read -p "> " whatsappservice_url
    whatsappservice_url="ws.paidoecommerce.com"
}

get_domains(){
    get_frontend_domain
    get_backend_domain
    get_whatsapp_service_domain
}

get_plataform_name(){
    print_banner
    printf "${WHITE} 📊 Digite o nome da plataforma que será instalada: ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " plataform_name
    plataform_name="paidoecommerce"
}

get_frontend_port(){
    print_banner
    printf "${WHITE} 🧵 Digite a porta do FRONTEND ( 3000 a 3999 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " frontend_port
    frontend_port="3000"
}

get_backend_port(){
    print_banner
    printf "${WHITE} 🧵 Digite a porta do BACKEND ( 4000 a 4999 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " backend_port
    backend_port="4000"
}

get_wsservice_port(){
    print_banner
    printf "${WHITE} 🧵 Digite a porta do WHATSAPP SERVICE ( 6000 a 6999 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " wsservice_port
    wsservice_port="6000"
}

get_database_port(){
    print_banner
    printf "${WHITE} 🧵 Digite a porta do POSTGRESQL ( 5432 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " postgresql_port
    postgresql_port="5432"
}

get_ports(){
    get_frontend_port
    get_backend_port
    get_wsservice_port
    get_database_port
}

get_mail_host(){
    print_banner
    printf "${WHITE} 🧵 Digite o host do email ( smtp.hostinger.com ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " mail_host
    mail_host="smtp.hostinger.com"
}

get_mail_port(){
    print_banner
    printf "${WHITE} 🧵 Digite a porta do servidor do email ( 465 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " mail_port
    mail_port="465"
}

get_mail_username(){
    print_banner
    printf "${WHITE} 🧵 Digite o username do email ( username@${frontend_url} ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " mail_username
    mail_username="naoresponda@paidoecommerce.com"
}

get_mail_password(){
    print_banner
    printf "${WHITE} 🧵 Digite a senha do email ( ******* ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " mail_password
    mail_password="7R|];hScT="
}

get_mail_info(){
    get_mail_host
    get_mail_port
    get_mail_username
    get_mail_password
}

get_pandavideo_info(){
    print_banner
    printf "${WHITE} 🧵 Digite a credencial do PandaVideo ( panda-xxxxxxxxx ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " pandavideo_credential
    pandavideo_credential="panda-fcfdcbb5f5ce4f0805311b5ecf99f0543b9696e4a2c369cf17d80f85548e057d"
}

get_checkout_info(){
    print_banner
    printf "${WHITE} 🧵 Digite o IP permitido para receber comunicações do checkout de pagamento ( 15.229.103.46 ): ${GRAY_LIGHT}"
    printf "\n\n";
    #read -p "> " checkoutapp_allowed_ip
    checkoutapp_allowed_ip="15.229.103.46"
}

create_plataform(){
    get_db_info
    get_link_git
    get_plataform_name
    get_domains
    get_ports
    get_mail_info
    get_pandavideo_info
    get_checkout_info
}

inquiry_options(){

    print_banner

    print_banner
    printf "${WHITE} 💻 Bem vindo(a) ao Gerenciador Axify, Selecione abaixo a proxima ação!${GRAY_LIGHT}"
    printf "\n\n"
    printf "   [1] Instalar Plataforma\n"
    printf "   [2] Atualizar Plataforma\n"
    printf "\n"
    read -p "> " option

    case "${option}" in
        1) create_plataform;;
        # 1) update_plataform
        *) exit ;;
    esac
}