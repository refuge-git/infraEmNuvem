import pika
import json 
import threading
import smtplib
import traceback
from flask import Flask, jsonify
from email.mime.text import MIMEText

app = Flask(__name__)

relatorios_presencas = []

# RabbitMQ
RABBITMQ_HOST = "localhost"
RABBITMQ_USER = "myuser"
RABBITMQ_PASS = "secret"
QUEUE_NAME = "refuge.direct.queue"

# E-mail
EMAIL_SENDER = "refuge.relatorios@gmail.com"
EMAIL_PASSWORD = "xjul lknf ezsy nxve"
SMTP_SERVER = "smtp.gmail.com"
SMTP_PORT = 587

def send_email(to_email, report_json, atendimentos_por_faixa=None, 
               atendimentos_por_raca_sexo=None, atendimentos_por_genero=None, 
               atendimentos_com_deficiencia=None, 
               atendimentos_de_imigrantes=None, 
               atendimentos_egresso_prisional=None,
               atendimentos_endereco_referencia=None,
               atendimentos_de_lgbtqia=None,
               atendimentos_por_local_dorme=None,
               atendimentos_de_banho=None,
               atendimentos_de_lavagem_roupa=None,
               atendimentos_de_alimentacao=None):
    """Envia um e-mail com os dados recebidos em formato legível"""
    try:
        linhas = ["Relatório de Serviços do Espaço Social D'Achiropita\n"]

        # Presenças por dia (mantendo comportamento original)
        if isinstance(report_json, list):
            total = sum(int(item.get('quantidadePessoas', 0)) for item in report_json)
            dias_funcionamento = len(report_json)
            media_diaria = round(total / dias_funcionamento, 2) if dias_funcionamento else 0

            linhas.append(f"Informe o número de pessoas que frequentaram o serviço por dia. Total no mês:  Dias de funcionamento:{dias_funcionamento}  Média Diária: {media_diaria} Pessoas atendidas no mês: {total}\n")
            

            for item in report_json:
                dia = item.get('dia', '?')
                q = item.get('quantidadePessoas', 0)
                linhas.append(
                    f"Informe o número de pessoas que frequentaram o serviço por dia. "
                    f"Total no mês: Dias de funcionamento: Média Diária:  "
                    f"Pessoas atendidas no mês: [{dia}][Qtd pessoas]\t{q}"
                )
        else:
            linhas.append(f"Dados do relatório:\n{json.dumps(report_json, indent=2, ensure_ascii=False)}")

        if atendimentos_por_faixa:
            mapa = {}
            for entry in atendimentos_por_faixa:
                faixa = (entry.get('faixaEtaria') or '').strip()
                sexo_raw = (entry.get('sexo') or '').upper()
                sexo = 'M' if 'MASC' in sexo_raw else ('F' if 'FEM' in sexo_raw else sexo_raw)
                numero = entry.get('numeroPessoasAtendidas', 0)
                mapa.setdefault(faixa, {})[sexo] = numero

            linhas.append("\nNúmero de pessoas atendidas no mês de referência")
            faixa_order = [
                "0 a 5 anos",
                "6 a 11 anos",
                "12 a 14 anos",
                "15 a 17 anos",
                "18 a 29 anos",
                "30 a 59 anos",
                "60 anos ou mais"
            ]
            for faixa in faixa_order:
                valores = mapa.get(faixa, {})
                m_val = valores.get('M', 0)
                f_val = valores.get('F', 0)
                linhas.append(f"Número de pessoas atendidas no mês de referência [Nº de pessoas atendidas][{faixa} (M)]\t{m_val}")
                linhas.append(f"Número de pessoas atendidas no mês de referência [Nº de pessoas atendidas][{faixa} (F)]\t{f_val}")

        
        if atendimentos_por_raca_sexo:
            mapa_raca = {}
            for entry in atendimentos_por_raca_sexo:
                sexo_raw = (entry.get('sexo') or '').upper()
                raca_raw = (entry.get('raca') or '').upper()
                numero = entry.get('numeroPessoasAtendidas', 0) or 0
                mapa_raca.setdefault(sexo_raw, {})[raca_raw] = numero

            linhas.append("\nPERFIL DOS USUÁRIOS")
            linhas.append("Número de pessoas atendidas por sexo e raça/cor no mês de referência")

            ordem_racas = [
                ("BRANCO", "Branca"),
                ("PRETO", "Preta"),
                ("PARDO", "Parda"),
                ("AMARELO", "Amarela"),
                ("INDÍGENA", "Indígena"),
                ("NAO_DECLARADO", "Não informada")
            ]
            sexo_order = [("FEMININO", "Feminino"), ("MASCULINO", "Masculino")]

            for sexo_key, sexo_label in sexo_order:
                for raca_key, raca_label in ordem_racas:
                    valor = mapa_raca.get(sexo_key, {}).get(raca_key, 0)
                    linhas.append(f"Número de pessoas atendidas por sexo e raça/cor no mês de referência [Nº de pessoas atendidas][{sexo_label}][{raca_label}]\t{valor}")
            

        
        if atendimentos_por_genero:
            mapa_genero = {}
            for entry in atendimentos_por_genero:
                genero_raw = (entry.get('genero') or '').upper()
                numero = entry.get('numeroPessoasAtendidas', 0) or 0
                mapa_genero[genero_raw] = numero

            linhas.append("\nNúmero de pessoas atendidas por identidade de gênero no mês de referência")

            ordem_generos = [
                ("Cisgênero"),   
                ("Transgênero"),   
                ("Agênero"),   
                ("Não declarado")
            ]

            for genero in ordem_generos:
                valor = mapa_genero.get(genero.upper(), 0)
                linhas.append(f"Número de pessoas atendidas no mês de referência, por identidade de gênero [{genero}] [Quantidade]\t{valor}")

        if atendimentos_com_deficiencia:
            qtd_deficiencia = atendimentos_com_deficiencia.get('pessoasComDeficiencia', 0)

            linhas.append("\nQuantifique as situações abaixo com os dados do mês de referência:")
            linhas.append(f"Quantifique as situações abaixo com os dados do mês de referência: [Nº de pessoas com deficiência atendidas pelo serviço] \t{qtd_deficiencia}")


        if atendimentos_de_imigrantes:
            qtd_imigrantes = atendimentos_de_imigrantes.get('numeroImigrantesAtendidos', 0)

            linhas.append(f"Quantifique as situações abaixo com os dados do mês de referência: [N° de pessoas que vieram de outros países (refugiados/imigrantes)] \t{qtd_imigrantes}")


        if atendimentos_egresso_prisional:
            qtd_egresso = atendimentos_egresso_prisional.get('numeroEgressosAtendidos', 0)

            linhas.append(f"Quantifique as situações abaixo com os dados do mês de referência: [N° de pessoas egressas do sistema prisional] \t{qtd_egresso}")


        if atendimentos_endereco_referencia:
            qtd_endereco_ref = atendimentos_endereco_referencia.get('numeroAtendimentosEnderecoReferencia', 0)

            linhas.append(f"Quantifique as situações abaixo com os dados do mês de referência: [Nº de pessoas que utilizam o endereço do serviço como endereço de referência] \t{qtd_endereco_ref}")


        if atendimentos_de_lgbtqia:
            qtd_lgbtqia = atendimentos_de_lgbtqia.get('numeroPessoasLgbtAtendidas', 0)

            linhas.append(f"Quantifique as situações abaixo com os dados do mês de referência: [N° de pessoas LGBTQIA+ atendidas] \t{qtd_lgbtqia}")


        if atendimentos_por_local_dorme:
            mapa_local_dorme = {}
            locais = [
                ("CASA", "dormem em casa"),
                ("RUA", "dormem na rua"),
                ("CENTRO_ACOLHIDA", "dormem em centros de acolhida"),
                ("PENSAO", "dormem em pensão"),
                ("PASSAGEM_PELA_CIDADE", "estão de passagem pela cidade"),
            ]
            for entry in atendimentos_por_local_dorme:
                local_raw = (entry.get('localDorme') or '').upper()
                numero = entry.get('numeroAtendimentosLocalDorme', 0) or 0
                mapa_local_dorme[local_raw] = numero

            linhas.append("\nOnde o usuário dorme:")
            for chave, frase in locais:
                numero = mapa_local_dorme.get(chave, 0)
                linhas.append(f"Onde o usuário dorme: [Nº de usuários que {frase}]\t{numero}")

        if atendimentos_de_banho:
            linhas.append("\nIndique as ofertas descritas abaixo às pessoas atendidas pelo serviço no mês de referência.")

            qtd_banho = atendimentos_de_banho.get('numeroAtendimentosDeBanho', 0)
            linhas.append(f"Indique as ofertas descritas abaixo às pessoas atendidas pelo serviço no mês de referência. [Banho][Número de pessoas atendidas] \t{qtd_banho}")


        if atendimentos_de_lavagem_roupa:
            qtd_lavagem = atendimentos_de_lavagem_roupa.get('numeroAtendimentosLavagemRoupa', 0)
            linhas.append(f"Indique as ofertas descritas abaixo às pessoas atendidas pelo serviço no mês de referência. [Lavagem de roupa][Número de pessoas atendidas] \t{qtd_lavagem}")


        if atendimentos_de_alimentacao:
            qtd_alimentacao = atendimentos_de_alimentacao.get('numeroAtendimentosRefeicao', 0)
            linhas.append(f"Indique as ofertas descritas abaixo às pessoas atendidas pelo serviço no mês de referência. [Alimentação][Número de pessoas atendidas] \t{qtd_alimentacao}")

        linhas.append("\n---\nEste é um e-mail automático gerado pelo sistema.")

        email_body = "\n".join(linhas)

        msg = MIMEText(email_body, 'plain', 'utf-8')
        msg['Subject'] = 'Relatório de Serviços Espaço Social Achiropita'
        msg['From'] = EMAIL_SENDER
        msg['To'] = to_email

        with smtplib.SMTP(SMTP_SERVER, SMTP_PORT) as server:
            server.starttls()
            server.login(EMAIL_SENDER, EMAIL_PASSWORD)
            server.send_message(msg)
            print(f"[SUCCESS] E-mail enviado para {to_email}")
    except Exception as e:
        print(f"[ERRO] Falha ao enviar e-mail: {e}")
        traceback.print_exc()

def conectar_rabbitmq():
    """Conecta ao RabbitMQ e retorna conexão e canal."""
    print(f"[DEBUG] Conectando ao RabbitMQ em {RABBITMQ_HOST} com usuário '{RABBITMQ_USER}'...")
    credentials = pika.PlainCredentials(RABBITMQ_USER, RABBITMQ_PASS)
    try:
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(host=RABBITMQ_HOST, credentials=credentials)
        )
        channel = connection.channel()
        print("[DEBUG] Conexão estabelecida com sucesso.")
        channel.queue_declare(queue=QUEUE_NAME, durable=True)
        print(f"[DEBUG] Fila '{QUEUE_NAME}' declarada.")
        return connection, channel
    except Exception as e:
        print(f"[ERRO] Falha ao conectar no RabbitMQ: {e}")
        raise

def callback(ch, method, properties, body):
    """Função chamada quando chega uma mensagem na fila."""
    print(f"[DEBUG] Mensagem recebida! Body: {body}")
    try:
        mensagem = json.loads(body)  # decodifica JSON
        print(f"[DEBUG] Mensagem decodificada como JSON: {type(mensagem)}")
    except json.JSONDecodeError as e:
        print(f"[DEBUG] Erro ao decodificar JSON: {e}")
        mensagem = body.decode()
        print(f"[DEBUG] Mensagem decodificada como string: {mensagem}")

    relatorios_presencas.append(mensagem)
    print(f"[DEBUG] Total de relatórios armazenados: {len(relatorios_presencas)}")

    destinatario = None
    presencas = None
    atendimentos = None
    atendimentos_raca_sexo = None
    atendimentos_genero = None
    atendimentos_deficiencia = None
    atendimentos_imigrantes = None
    atendimentos_egresso_prisional = None
    atendimentos_endereco_referencia = None
    atendimentos_de_lgbtqia = None
    atendimentos_por_local_dorme = None
    atendimentos_de_banho = None
    atendimentos_de_lavagem_roupa = None
    atendimentos_de_alimentacao = None

    if isinstance(mensagem, dict) and 'presencaDiaResponses' in mensagem:
        presenca_resp = mensagem.get('presencaDiaResponses') or {}
        destinatario = presenca_resp.get('email')
        presencas = presenca_resp.get('presencas', [])
        atendimentos = mensagem.get('atendimentosPorFaixaEtarias')
        atendimentos_raca_sexo = mensagem.get('atendimentosPorRacaSexos') or mensagem.get('atendimentosPorRacaSexo')
        atendimentos_genero = mensagem.get('atendimentosPorIdentidadeGeneros')
        atendimentos_deficiencia = mensagem.get('atendimentosComDeficiencia')
        atendimentos_imigrantes = mensagem.get('atendimentosDeImigrantes')
        atendimentos_egresso_prisional = mensagem.get('atendimentosEgressoPrisional')
        atendimentos_endereco_referencia = mensagem.get('atendimentosEnderecoReferencia')
        atendimentos_de_lgbtqia = mensagem.get('atendimentosDeLgbt')
        atendimentos_por_local_dorme = mensagem.get('atendimentosPorLocalDorme')
        atendimentos_de_banho = mensagem.get('atendimentosDeBanho')
        atendimentos_de_lavagem_roupa = mensagem.get('atendimentosDeLavagemRoupa')
        atendimentos_de_alimentacao = mensagem.get('atendimentosDeRefeicao')
 
    elif isinstance(mensagem, dict) and 'email' in mensagem and 'presencas' in mensagem:
        destinatario = mensagem.get('email')
        presencas = mensagem.get('presencas')
        atendimentos = mensagem.get('atendimentosPorFaixaEtarias')
        atendimentos_raca_sexo = mensagem.get('atendimentosPorRacaSexos') or mensagem.get('atendimentosPorRacaSexo')
        atendimentos_genero = mensagem.get('atendimentosPorIdentidadeGeneros')
        atendimentos_deficiencia = mensagem.get('atendimentosComDeficiencia')
        atendimentos_imigrantes = mensagem.get('atendimentosDeImigrantes')
        atendimentos_egresso_prisional = mensagem.get('atendimentosEgressoPrisional')
        atendimentos_endereco_referencia = mensagem.get('atendimentosEnderecoReferencia')
        atendimentos_de_lgbtqia = mensagem.get('atendimentosDeLgbt')
        atendimentos_por_local_dorme = mensagem.get('atendimentosPorLocalDorme')
        atendimentos_de_banho = mensagem.get('atendimentosDeBanho')
        atendimentos_de_lavagem_roupa = mensagem.get('atendimentosDeLavagemRoupa')
        atendimentos_de_alimentacao = mensagem.get('atendimentosDeRefeicao')

    if destinatario and presencas is not None:
        print(f"[DEBUG] Destinatário do e-mail: {destinatario}")
        print(f"✅ Relatório recebido ({len(presencas)} registros):")
        print(json.dumps(mensagem, indent=2, ensure_ascii=False))

        if destinatario and '@' in destinatario:
            print(f"[DEBUG] Enviando e-mail para: {destinatario}")
            send_email(destinatario, presencas, atendimentos_por_faixa=atendimentos, 
                       atendimentos_por_raca_sexo=atendimentos_raca_sexo, atendimentos_por_genero=atendimentos_genero, 
                       atendimentos_com_deficiencia=atendimentos_deficiencia, 
                       atendimentos_de_imigrantes=atendimentos_imigrantes, 
                       atendimentos_egresso_prisional=atendimentos_egresso_prisional,
                       atendimentos_endereco_referencia=atendimentos_endereco_referencia,
                       atendimentos_de_lgbtqia=atendimentos_de_lgbtqia,
                       atendimentos_por_local_dorme=atendimentos_por_local_dorme,
                       atendimentos_de_banho=atendimentos_de_banho,
                       atendimentos_de_lavagem_roupa=atendimentos_de_lavagem_roupa,
                       atendimentos_de_alimentacao=atendimentos_de_alimentacao)
        else:
            print(f"[ERRO] Destinatário inválido: {destinatario}. E-mail não enviado.")
    else:
        print("[ERRO] Mensagem recebida não tem os campos esperados. E-mail não enviado.")

# Conecta ao RabbitMQ
connection, channel = conectar_rabbitmq()

def iniciar_consumidor():
    print("🎧 Consumidor de relatórios iniciado. Aguardando mensagens...")
    try:
        print(f"[DEBUG] Consumindo da fila '{QUEUE_NAME}'...")
        channel.basic_consume(queue=QUEUE_NAME, on_message_callback=callback, auto_ack=True)
        channel.start_consuming()
    except Exception as e:
        print(f"[ERRO] Falha ao consumir mensagens: {e}")

# Executa o consumidor em uma thread separada
threading.Thread(target=iniciar_consumidor, daemon=True).start()

# Endpoint para visualizar relatórios recebidos
@app.route("/relatorios/recebidos", methods=["GET"])
def obter_relatorios():
    print(f"[DEBUG] Endpoint /relatorios/recebidos chamado. Total de relatórios: {len(relatorios_presencas)}")
    return jsonify(relatorios_presencas), 200

# Endpoint para verificar o status da conexão
@app.route("/status", methods=["GET"])
def status():
    return jsonify({
        "status": "running",
        "relatorios_count": len(relatorios_presencas),
        "queue": QUEUE_NAME,
        "host": RABBITMQ_HOST
    }), 200

if __name__ == "__main__":
    print("Consumidor Flask rodando na porta 5000")
    app.run(port=5000)