import boto3
import os
from PIL import Image, UnidentifiedImageError
from io import BytesIO

s3 = boto3.client('s3')

DEST_BUCKET = 'bucket-refuge-img-trusted'

def lambda_handler(event, context):
    try:
        # Extrai informações do evento
        record = event['Records'][0]
        source_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        print(f"🔹 Iniciando processamento da imagem: {key} do bucket {source_bucket}")

        # Se for JPG ou JPEG, apenas copia para o bucket trusted (sem reconverter)
        if key.lower().endswith(('.jpg', '.jpeg')):
            print(f"📤 Arquivo {key} já é JPG. Enviando cópia direta para {DEST_BUCKET}...")
            s3.copy_object(
                Bucket=DEST_BUCKET,
                CopySource={'Bucket': source_bucket, 'Key': key},
                Key=key,
                ContentType='image/jpeg'
            )
            print(f"✅ Cópia concluída: {DEST_BUCKET}/{key}")
            return

        # Baixa a imagem original do bucket raw
        response = s3.get_object(Bucket=source_bucket, Key=key)
        image_data = response['Body'].read()

        # Converte para JPG
        with Image.open(BytesIO(image_data)) as img:
            # Corrige transparência e converte para RGB
            rgb_img = img.convert('RGB')

            buffer = BytesIO()
            rgb_img.save(buffer, format='JPEG', quality=90)
            buffer.seek(0)

            # Gera novo nome, substituindo extensão
            base_name = os.path.splitext(key)[0]
            new_key = f"{base_name}.jpg"

            # Faz upload pro bucket trusted
            s3.put_object(
                Bucket=DEST_BUCKET,
                Key=new_key,
                Body=buffer,
                ContentType='image/jpeg'
            )

            print(f"✅ Imagem convertida e salva em {DEST_BUCKET}/{new_key}")

    except UnidentifiedImageError:
        print(f"❌ Erro: o arquivo {key} não é uma imagem válida.")
    except Exception as e:
        print(f"❌ Erro inesperado ao processar {key}: {str(e)}")

