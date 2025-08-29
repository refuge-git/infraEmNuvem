#!/bin/bash

# instalar o pacotes zip, necessário para instalar o sdkman
sudo apt-get update
sudo apt-get install zip -y
echo "Pacote zip instalado com sucesso!"

# Instala o SDKMAN como usuário 'ubuntu' (se não for esse seu usuário, troque no script) 
# e configura o ambiente na sessão atual
sudo su - ubuntu -c '
    echo "Iniciando a instalação do SDKMAN e Java 21 para o usuário ubuntu..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install java 21.0.8-amzn
    echo "Instalação do SDKMAN e Java 21 feita! Toma!"
'