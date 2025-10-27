#!/bin/bash
# Espera o MySQL ficar pronto antes de iniciar a aplicação Spring Boot

set -e

host="$1"         # Host passado como argumento
shift
cmd="$@"          # Comando para iniciar o Spring Boot

# Loop até o MySQL aceitar conexões
until mysql -h "$host" -u"$SPRING_DATASOURCE_USERNAME" -p"$SPRING_DATASOURCE_PASSWORD" -e "SELECT 1;" &> /dev/null; do
  echo "Aguardando MySQL em $host..."
  sleep 2
done

echo "MySQL está pronto! Iniciando aplicação..."
exec $cmd