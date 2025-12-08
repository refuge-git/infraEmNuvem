#!/bin/bash

# Configurações
DB_USER="root"
DB_PASS="rootpassword"
DB_NAME="refuge"
BACKUP_DIR="/home/ec2-user/bkp-banco"
S3_BUCKET="s3://bd-bkp-refuge"
EMAIL_ADMIN="refuge.relatorios@gmail.com"

# Criar diretório de backup, caso não exista
mkdir -p $BACKUP_DIR

# Nome do arquivo de backup com data ISO
DATE=$(date +%F)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

# Função para enviar email
send_email() {
    SUBJECT=$1
    BODY=$2
    echo "$BODY" | mail -s "$SUBJECT" $EMAIL_ADMIN
}

# Criar backup
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE
if [ $? -eq 0 ]; then
    echo "Backup do banco $DB_NAME criado com sucesso."
else
    send_email "Erro no backup do banco $DB_NAME" "Houve um erro ao criar o backup do banco $DB_NAME."
    exit 1
fi

# Enviar para S3
aws s3 cp $BACKUP_FILE $S3_BUCKET
if [ $? -eq 0 ]; then
    send_email "Backup do banco $DB_NAME realizado" "O backup do banco $DB_NAME foi enviado com sucesso para o S3: $S3_BUCKET/$BACKUP_FILE"
else
    send_email "Erro no envio do backup para S3" "O backup do banco $DB_NAME não pôde ser enviado para o S3."
    exit 1
fi
