def lambda_handler(event, context):
    return f"Uma coisa é certa: {event['texto']}"

# Altere o código acima para que ele use um texto simples que chegará
# na requisição e retorne esse mesmo texto no corpo da resposta.
# Exemplo: Uma coisa é certa: "<texto que chegou na requisição>"
# Não pe mais para retornar um JSON e sim um texto simples.