import os
import subprocess
import boto3
import smtplib
from datetime import datetime
from email.mime.text import MIMEText
from dotenv import load_dotenv


load_dotenv()


DB_CONTAINER = os.getenv("DB_CONTAINER")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")
AWS_BUCKET = os.getenv("AWS_BUCKET")
AWS_REGION = os.getenv("AWS_REGION")
ADMIN_EMAIL = os.getenv("ADMIN_EMAIL")
SENDER_EMAIL = os.getenv("SENDER_EMAIL")
SENDER_PASSWORD = os.getenv("SENDER_PASSWORD")

def send_email(subject, message):
    try:
        msg = MIMEText(message)
        msg["Subject"] = subject
        msg["From"] = SENDER_EMAIL
        msg["To"] = ADMIN_EMAIL

        with smtplib.SMTP("smtp.gmail.com", 587) as server:
            server.starttls()
            server.login(SENDER_EMAIL, SENDER_PASSWORD)
            server.send_message(msg)
    except Exception as e:
        print(f"❌ Erro ao enviar e-mail: {e}")

def main():
    today = datetime.now().strftime("%Y-%m-%d")
    backup_file = f"/tmp/{DB_NAME}_backup_{today}.sql"

    try:

        dump_cmd = [
            "docker", "exec", DB_CONTAINER,
            "mysqldump",
            f"-u{DB_USER}",
            f"-p{DB_PASSWORD}",
            DB_NAME
        ]

        with open(backup_file, "w") as f:
            subprocess.run(dump_cmd, stdout=f, check=True)

        print(f"✅ Backup gerado: {backup_file}")

        
        s3 = boto3.client("s3", region_name=AWS_REGION)
        s3.upload_file(backup_file, AWS_BUCKET, os.path.basename(backup_file))

        print(f"📦 Enviado ao S3: {AWS_BUCKET}/{os.path.basename(backup_file)}")

        send_email(
            subject=f"[Backup SUCESSO] {DB_NAME}",
            message=f"O backup do banco {DB_NAME} foi gerado e enviado ao S3 com sucesso em {today}."
        )

    except subprocess.CalledProcessError as e:
        error_msg = f"❌ Erro ao gerar backup: {e}"
        print(error_msg)
        send_email(f"[Backup ERRO] {DB_NAME}", error_msg)
    except Exception as e:
        error_msg = f"❌ Falha geral no backup: {e}"
        print(error_msg)
        send_email(f"[Backup ERRO] {DB_NAME}", error_msg)
    finally:
        if os.path.exists(backup_file):
            os.remove(backup_file)

if __name__ == "__main__":
    main()
