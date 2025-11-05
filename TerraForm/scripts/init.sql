-- ====================================
-- SCRIPT SQL COM SUPORTE UTF-8
-- ====================================

DROP DATABASE IF EXISTS refuge;
CREATE DATABASE refuge CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE refuge;

-- TABELA DE FUNCIONÁRIO
CREATE TABLE funcionario (
    id_funcionario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    telefone VARCHAR(20),
    email VARCHAR(100) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO funcionario (nome, cpf, telefone, email, senha) VALUES
('João Silva', '123.456.789-00', '(11) 91234-5678', 'joao.silva@email.com', '1234'),
('Maria Oliveira', '987.654.321-00', '(11) 99876-5432', 'maria.oliveira@email.com', 'senha123'),
('Carlos Souza', '111.222.333-44', '(11) 97777-8888', 'carlos.souza@email.com', 'admin');

-- TABELA DE ENDEREÇO
CREATE TABLE endereco (
    id_endereco INT AUTO_INCREMENT PRIMARY KEY,
    tipo_logradouro VARCHAR(50),
    nome_logradouro VARCHAR(100) NOT NULL,
    numero INT,
    complemento VARCHAR(100),
    bairro VARCHAR(80),
    cep VARCHAR(9) NOT NULL,
    nome_localidade VARCHAR(100),
    sigla_cidade VARCHAR(2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO endereco (tipo_logradouro, nome_logradouro, numero, complemento, bairro, cep, nome_localidade, sigla_cidade) VALUES
('Rua', 'Praça da Árvore', 314, 'Apto 1', 'Jardim Silveira', '04241064', 'São Paulo', 'SP'),
('Avenida', 'Paulista', 1000, 'Bloco B', 'Bela Vista', '01311000', 'São Paulo', 'SP'),
('Travessa', 'Monte Alegre', 57, 'Casa 3', 'Perdizes', '05014000', 'São Paulo', 'SP');

-- TABELA DE TIPO DE GÊNERO
CREATE TABLE tipo_genero (
    id_genero INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tipo_genero (nome, descricao) VALUES
('Cisgênero', 'Pessoa cuja identidade de gênero corresponde ao sexo atribuído no nascimento'),
('Transgênero', 'Pessoa cuja identidade de gênero é diferente do sexo atribuído no nascimento'),
('Agênero', 'Pessoa que não se identifica com nenhum gênero'),
('Não declarado', 'Pessoa que optou por não declarar sua identidade de gênero');

-- TABELA DE TIPO DE SEXUALIDADE
CREATE TABLE tipo_sexualidade (
    id_sexualidade INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(50) UNIQUE NOT NULL,
    descricao VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tipo_sexualidade (nome, descricao) VALUES
('Heterossexual', 'Pessoa que sente atração por pessoas do gênero oposto'),
('Homossexual', 'Pessoa que sente atração por pessoas do mesmo gênero'),
('Bissexual', 'Pessoa que sente atração por mais de um gênero'),
('Assexual', 'Pessoa que não sente atração sexual'),
('Pansexual', 'Pessoa que sente atração independente de gênero'),
('Queer', 'Pessoa cuja identidade de gênero e/ou sexualidade não se encaixa em normas tradicionais'),
('Não declarado', 'Pessoa que preferiu não declarar sua sexualidade');

-- TABELA DE BENEFICIÁRIO
CREATE TABLE beneficiario (
    id_beneficiario INT AUTO_INCREMENT PRIMARY KEY,
    nome_registro VARCHAR(100) NOT NULL,
    nome_social VARCHAR(100),
    dt_nasc DATE,
    cpf VARCHAR(14) UNIQUE,
    estrangeiro BOOLEAN,
    raca ENUM('BRANCO', 'PRETO', 'PARDO', 'AMARELA', 'INDIGENA', 'NAO_DECLARADO'), 
    sexo ENUM('FEMININO', 'MASCULINO', 'NAO_DECLARADO'),
    nome_mae VARCHAR(100),
    egresso_prisional BOOLEAN,
    local_dorme ENUM('CASA', 'RUA', 'CENTRO_ACOLHIDA', 'PENSAO', 'PASSAGEM_PELA_CIDADE'),
    foto_perfil VARCHAR(255),
    sisa VARCHAR(50) UNIQUE,
    `status` ENUM('ATIVO', 'INATIVO', 'BANIDO', 'SUSPENSO'),
    data_ativacao DATETIME,
    fk_funcionario INT,
    fk_endereco INT,
    fk_genero INT,
    fk_sexualidade INT,
    observacao VARCHAR(250),
    FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario),
    FOREIGN KEY (fk_endereco) REFERENCES endereco(id_endereco),
    FOREIGN KEY (fk_genero) REFERENCES tipo_genero(id_genero),
    FOREIGN KEY (fk_sexualidade) REFERENCES tipo_sexualidade(id_sexualidade)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO beneficiario (
    nome_registro, nome_social, dt_nasc, cpf, estrangeiro, raca, sexo,
    nome_mae, egresso_prisional, local_dorme, foto_perfil, sisa, `status`,
    data_ativacao, fk_funcionario, fk_endereco, fk_genero, fk_sexualidade, observacao
) VALUES 
('Lucas Andrade', 'Luk', '1992-01-15', '123.456.789-00', false, 'PARDO', 'MASCULINO',
    'Sandra Andrade', false, 'CASA', NULL, 'SISA101', 'ATIVO',
    NOW(), 1, 1, 2, 3, 'Perfil completo e ativo'),
('Marta Silva', NULL, '1987-07-20', '234.567.890-11', false, 'BRANCO', 'FEMININO',
    'Claudia Silva', true, 'CENTRO_ACOLHIDA', NULL, 'SISA102', 'SUSPENSO',
    NOW(), 2, 2, 1, 6, 'Em reabilitação social'),
('Diego Santos', NULL, '2001-11-03', '345.678.901-22', false, 'PRETO', 'MASCULINO',
    'Juliana Santos', false, 'RUA', NULL, 'SISA103', 'ATIVO',
    NOW(), 3, 3, 3, 1, 'Necessita acompanhamento psicológico'),
('Ana Beatriz Lima', 'Bia', '1999-04-09', '456.789.012-33', true, 'AMARELA', 'FEMININO',
    'Márcia Lima', false, 'PENSAO', NULL, 'SISA104', 'INATIVO',
    NOW(), 2, 1, 4, 2, 'Documentação pendente'),
('José Carlos Ferreira', NULL, '1975-09-29', '567.890.123-44', false, 'INDIGENA', 'NAO_DECLARADO',
    'Marinalva Ferreira', true, 'PASSAGEM_PELA_CIDADE', NULL, 'SISA105', 'BANIDO',
    NOW(), 1, 3, 1, 5, 'Histórico de comportamento inadequado');

-- TABELA DE TIPO DE ATENDIMENTO
CREATE TABLE tipo_atendimento (
    id_tipo_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(250),
    data_criacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    fk_funcionario INT,
    FOREIGN KEY (fk_funcionario) REFERENCES funcionario(id_funcionario)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO tipo_atendimento (nome, descricao, fk_funcionario)
VALUES 
('Refeição', 'Distribuição de refeições aos assistidos.', 1),
('Banho', 'Oferecimento de banho e cuidados de higiene pessoal.', 2),
('Lavagem de Roupa', 'Serviço de lavanderia para roupas pessoais.', 3);

-- TABELA DE REGISTRO DO ATENDIMENTO
CREATE TABLE registro_atendimento (
    id_registro_atendimento INT AUTO_INCREMENT PRIMARY KEY,
    fk_beneficiario INT NOT NULL,
    fk_tipo INT NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (fk_beneficiario) REFERENCES beneficiario(id_beneficiario),
    FOREIGN KEY (fk_tipo) REFERENCES tipo_atendimento(id_tipo_atendimento)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO registro_atendimento (fk_beneficiario, fk_tipo, data_hora)
VALUES 
(1, 3, '2025-05-22 08:00:00');

-- TABELA DE CATEGORIA DE CONDIÇÃO DE SAÚDE
CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categoria (nome) VALUES 
('Deficiência'),
('Doença'),
('Transtorno');

-- TABELA DE CONDIÇÃO DE SAÚDE 
CREATE TABLE condicao_saude (
    id_condicao_saude INT AUTO_INCREMENT PRIMARY KEY,
    diagnostico VARCHAR(100),
    descricao VARCHAR(250),
    data_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    tratamento VARCHAR(250),
    observacoes VARCHAR(250),
    fk_beneficiario INT NOT NULL,
    fk_categoria INT NOT NULL,
    FOREIGN KEY (fk_beneficiario) REFERENCES beneficiario(id_beneficiario),
    FOREIGN KEY (fk_categoria) REFERENCES categoria(id_categoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO condicao_saude (diagnostico, descricao, tratamento, observacoes, fk_beneficiario, fk_categoria)
VALUES
('Deficiência visual parcial', 'Dificuldade de enxergar claramente a longa distância', 'Uso de óculos e acompanhamento oftalmológico', 'Paciente adaptado ao uso de lentes corretivas', 1, 1),
('Diabetes tipo 2', 'Alteração metabólica caracterizada por resistência à insulina', 'Uso diário de metformina e dieta controlada', 'Necessita acompanhamento mensal', 2, 2),
('Transtorno de ansiedade generalizada', 'Estado persistente de preocupação e tensão excessiva', 'Psicoterapia e uso de ansiolíticos', 'Crises controladas com terapia', 3, 3),
('Hipertensão arterial', 'Pressão arterial elevada de forma persistente', 'Uso contínuo de losartana', 'Monitoramento de pressão diário', 4, 2),
('Transtorno depressivo maior', 'Quadros de tristeza profunda e perda de interesse', 'Uso de antidepressivos e apoio psicológico', 'Melhora nos últimos dois meses', 5, 3);

-- INSERÇÃO DE REGISTROS DE ATENDIMENTO - SETEMBRO 2025
INSERT INTO registro_atendimento (fk_beneficiario, fk_tipo, data_hora) VALUES
(1, 1, '2025-09-01 09:10:00'), (2, 2, '2025-09-01 10:15:00'), (3, 3, '2025-09-01 11:20:00'),
(4, 1, '2025-09-02 08:30:00'), (5, 2, '2025-09-02 09:40:00'), (1, 3, '2025-09-02 14:10:00'),
(2, 1, '2025-09-03 09:00:00'), (3, 2, '2025-09-03 10:15:00'), (4, 3, '2025-09-03 11:30:00'),
(5, 1, '2025-09-03 12:00:00'), (1, 2, '2025-09-04 08:45:00'), (2, 3, '2025-09-04 09:50:00'),
(3, 1, '2025-09-04 10:30:00'), (4, 2, '2025-09-04 13:15:00'), (5, 3, '2025-09-04 15:20:00'),
(1, 1, '2025-09-05 08:00:00'), (2, 2, '2025-09-05 09:00:00'), (3, 3, '2025-09-05 10:00:00'),
(4, 1, '2025-09-05 11:00:00'), (5, 2, '2025-09-05 12:00:00'), (1, 3, '2025-09-06 08:00:00'),
(2, 1, '2025-09-06 09:00:00'), (3, 2, '2025-09-06 10:00:00'), (4, 3, '2025-09-06 11:00:00'),
(5, 1, '2025-09-06 12:00:00'), (1, 2, '2025-09-07 08:00:00'), (2, 3, '2025-09-07 09:00:00'),
(3, 1, '2025-09-07 10:00:00'), (4, 2, '2025-09-07 11:00:00'), (5, 3, '2025-09-07 12:00:00'),
(1, 1, '2025-09-08 08:10:00'), (2, 2, '2025-09-08 09:15:00'), (3, 3, '2025-09-08 10:20:00'),
(4, 1, '2025-09-08 11:25:00'), (5, 2, '2025-09-08 12:30:00'), (1, 3, '2025-09-08 13:35:00'),
(2, 1, '2025-09-09 08:00:00'), (3, 2, '2025-09-09 09:10:00'), (4, 3, '2025-09-09 10:20:00'),
(5, 1, '2025-09-09 11:30:00'), (1, 2, '2025-09-10 08:40:00'), (2, 3, '2025-09-10 09:50:00'),
(3, 1, '2025-09-10 11:00:00'), (4, 2, '2025-09-10 12:10:00'), (5, 3, '2025-09-10 13:20:00'),
(1, 1, '2025-09-11 08:00:00'), (2, 2, '2025-09-11 09:00:00'), (3, 3, '2025-09-11 10:00:00'),
(4, 1, '2025-09-11 11:00:00'), (5, 2, '2025-09-11 12:00:00'), (1, 3, '2025-09-12 08:00:00'),
(2, 1, '2025-09-12 09:00:00'), (3, 2, '2025-09-12 10:00:00'), (4, 3, '2025-09-12 11:00:00'),
(5, 1, '2025-09-12 12:00:00'), (1, 2, '2025-09-13 08:00:00'), (2, 3, '2025-09-13 09:00:00'),
(3, 1, '2025-09-13 10:00:00'), (4, 2, '2025-09-13 11:00:00'), (5, 3, '2025-09-13 12:00:00'),
(1, 1, '2025-09-14 08:10:00'), (2, 2, '2025-09-14 09:20:00'), (3, 3, '2025-09-14 10:30:00'),
(4, 1, '2025-09-14 11:40:00'), (5, 2, '2025-09-14 12:50:00'), (1, 3, '2025-09-15 08:00:00'),
(2, 1, '2025-09-15 09:10:00'), (3, 2, '2025-09-15 10:20:00'), (4, 3, '2025-09-15 11:30:00'),
(5, 1, '2025-09-15 12:40:00'), (1, 2, '2025-09-16 08:00:00'), (2, 3, '2025-09-16 09:00:00'),
(3, 1, '2025-09-16 10:00:00'), (4, 2, '2025-09-16 11:00:00'), (5, 3, '2025-09-16 12:00:00'),
(1, 1, '2025-09-17 08:00:00'), (2, 2, '2025-09-17 09:00:00'), (3, 3, '2025-09-17 10:00:00'),
(4, 1, '2025-09-17 11:00:00'), (5, 2, '2025-09-17 12:00:00'), (1, 3, '2025-09-18 08:00:00'),
(2, 1, '2025-09-18 09:00:00'), (3, 2, '2025-09-18 10:00:00'), (4, 3, '2025-09-18 11:00:00'),
(5, 1, '2025-09-18 12:00:00'), (1, 2, '2025-09-19 08:00:00'), (2, 3, '2025-09-19 09:00:00'),
(3, 1, '2025-09-19 10:00:00'), (4, 2, '2025-09-19 11:00:00'), (5, 3, '2025-09-19 12:00:00');

-- INSERÇÃO DE REGISTROS DE ATENDIMENTO - OUTUBRO 2025
INSERT INTO registro_atendimento (fk_beneficiario, fk_tipo, data_hora) VALUES
(1,1,'2025-10-01 08:00:00'), (2,2,'2025-10-01 09:00:00'), (3,3,'2025-10-01 10:00:00'),
(4,1,'2025-10-01 11:00:00'), (5,2,'2025-10-01 12:00:00'), (1,2,'2025-10-02 08:10:00'),
(2,3,'2025-10-02 09:15:00'), (3,1,'2025-10-02 10:20:00'), (4,2,'2025-10-02 11:25:00'),
(1,3,'2025-10-03 08:05:00'), (2,1,'2025-10-03 09:10:00'), (5,2,'2025-10-03 10:15:00'),
(1,1,'2025-10-04 08:00:00'), (2,2,'2025-10-04 09:00:00'), (3,3,'2025-10-04 10:00:00'),
(4,1,'2025-10-04 11:00:00'), (5,3,'2025-10-04 12:00:00'), (1,2,'2025-10-05 08:00:00'),
(2,3,'2025-10-05 09:00:00'), (3,1,'2025-10-05 10:00:00'), (1,1,'2025-10-06 08:00:00'),
(2,2,'2025-10-06 09:00:00'), (3,3,'2025-10-06 10:00:00'), (4,1,'2025-10-06 11:00:00'),
(1,3,'2025-10-07 08:00:00'), (5,1,'2025-10-07 09:00:00'), (3,2,'2025-10-07 10:00:00'),
(4,3,'2025-10-07 11:00:00'), (2,1,'2025-10-08 08:00:00'), (1,2,'2025-10-08 09:00:00'),
(5,3,'2025-10-08 10:00:00'), (3,1,'2025-10-09 08:00:00'), (4,2,'2025-10-09 09:00:00'),
(1,3,'2025-10-09 10:00:00'), (2,1,'2025-10-09 11:00:00'), (1,1,'2025-10-10 08:00:00'),
(3,2,'2025-10-10 09:00:00'), (4,3,'2025-10-10 10:00:00'), (5,1,'2025-10-10 11:00:00'),
(2,2,'2025-10-10 12:00:00'), (1,2,'2025-10-11 08:00:00'), (2,3,'2025-10-11 09:00:00'),
(3,1,'2025-10-11 10:00:00'), (1,1,'2025-10-12 08:00:00'), (4,2,'2025-10-12 09:00:00'),
(5,3,'2025-10-12 10:00:00'), (2,1,'2025-10-12 11:00:00'), (1,3,'2025-10-13 08:00:00'),
(3,2,'2025-10-13 09:00:00'), (4,1,'2025-10-13 10:00:00'), (2,2,'2025-10-14 08:00:00'),
(3,3,'2025-10-14 09:00:00'), (1,1,'2025-10-14 10:00:00'), (5,2,'2025-10-14 11:00:00'),
(1,2,'2025-10-15 08:00:00'), (4,3,'2025-10-15 09:00:00'), (5,1,'2025-10-15 10:00:00'),
(2,1,'2025-10-16 08:00:00'), (3,2,'2025-10-16 09:00:00'), (1,3,'2025-10-16 10:00:00'),
(1,1,'2025-10-17 08:00:00'), (2,2,'2025-10-17 09:00:00'), (3,3,'2025-10-17 10:00:00'),
(4,1,'2025-10-17 11:00:00'), (5,2,'2025-10-18 08:00:00'), (1,3,'2025-10-18 09:00:00'),
(2,1,'2025-10-18 10:00:00'), (1,1,'2025-10-19 08:00:00'), (2,2,'2025-10-19 09:00:00'),
(3,3,'2025-10-19 10:00:00'), (4,1,'2025-10-19 11:00:00'), (1,2,'2025-10-20 08:00:00'),
(3,1,'2025-10-20 09:00:00'), (5,3,'2025-10-20 10:00:00'), (1,1,'2025-10-21 08:00:00'),
(2,2,'2025-10-21 09:00:00'), (3,3,'2025-10-21 10:00:00'), (4,1,'2025-10-22 08:00:00'),
(5,2,'2025-10-22 09:00:00'), (1,3,'2025-10-22 10:00:00'), (2,1,'2025-10-23 08:00:00'),
(3,2,'2025-10-23 09:00:00'), (1,1,'2025-10-24 08:00:00'), (2,3,'2025-10-24 09:00:00'),
(3,2,'2025-10-24 10:00:00'), (1,3,'2025-10-25 08:00:00'), (4,1,'2025-10-25 09:00:00'),
(5,2,'2025-10-25 10:00:00'), (2,2,'2025-10-26 08:00:00'), (3,3,'2025-10-26 09:00:00'),
(1,1,'2025-10-27 08:00:00'), (4,2,'2025-10-27 09:00:00'), (5,3,'2025-10-27 10:00:00'),
(2,1,'2025-10-28 08:00:00'), (3,2,'2025-10-28 09:00:00'), (1,3,'2025-10-28 10:00:00'),
(4,1,'2025-10-29 08:00:00'), (5,2,'2025-10-29 09:00:00'), (1,1,'2025-10-30 08:00:00'),
(2,3,'2025-10-30 09:00:00'), (3,2,'2025-10-30 10:00:00'), (1,3,'2025-10-31 08:00:00'),
(2,1,'2025-10-31 09:00:00'), (4,2,'2025-10-31 10:00:00');


INSERT INTO condicao_saude (diagnostico, descricao, tratamento, observacoes, fk_beneficiario, fk_categoria)
VALUES
('Deficiência visual parcial', 'Dificuldade de enxergar claramente a longa distância', 'Uso de óculos e acompanhamento oftalmológico', 'Paciente adaptado ao uso de lentes corretivas', 1, 1),
('Diabetes tipo 2', 'Alteração metabólica caracterizada por resistência à insulina', 'Uso diário de metformina e dieta controlada', 'Necessita acompanhamento mensal', 2, 2),
('Transtorno de ansiedade generalizada', 'Estado persistente de preocupação e tensão excessiva', 'Psicoterapia e uso de ansiolíticos', 'Crises controladas com terapia', 3, 3),
('Hipertensão arterial', 'Pressão arterial elevada de forma persistente', 'Uso contínuo de losartana', 'Monitoramento de pressão diário', 4, 2),
('Transtorno depressivo maior', 'Quadros de tristeza profunda e perda de interesse', 'Uso de antidepressivos e apoio psicológico', 'Melhora nos últimos dois meses', 5, 3);

SELECT * FROM condicao_saude;
    
    
    
INSERT INTO registro_atendimento (fk_beneficiario, fk_tipo, data_hora)
VALUES
(1, 1, '2025-09-01 09:10:00'),
(2, 2, '2025-09-01 10:15:00'),
(3, 3, '2025-09-01 11:20:00'),
(4, 1, '2025-09-02 08:30:00'),
(5, 2, '2025-09-02 09:40:00'),
(1, 3, '2025-09-02 14:10:00'),
(2, 1, '2025-09-03 09:00:00'),
(3, 2, '2025-09-03 10:15:00'),
(4, 3, '2025-09-03 11:30:00'),
(5, 1, '2025-09-03 12:00:00'),

(1, 2, '2025-09-04 08:45:00'),
(2, 3, '2025-09-04 09:50:00'),
(3, 1, '2025-09-04 10:30:00'),
(4, 2, '2025-09-04 13:15:00'),
(5, 3, '2025-09-04 15:20:00'),
(1, 1, '2025-09-05 08:00:00'),
(2, 2, '2025-09-05 09:00:00'),
(3, 3, '2025-09-05 10:00:00'),
(4, 1, '2025-09-05 11:00:00'),
(5, 2, '2025-09-05 12:00:00'),

(1, 3, '2025-09-06 08:00:00'),
(2, 1, '2025-09-06 09:00:00'),
(3, 2, '2025-09-06 10:00:00'),
(4, 3, '2025-09-06 11:00:00'),
(5, 1, '2025-09-06 12:00:00'),
(1, 2, '2025-09-07 08:00:00'),
(2, 3, '2025-09-07 09:00:00'),
(3, 1, '2025-09-07 10:00:00'),
(4, 2, '2025-09-07 11:00:00'),
(5, 3, '2025-09-07 12:00:00'),

(1, 1, '2025-09-08 08:10:00'),
(2, 2, '2025-09-08 09:15:00'),
(3, 3, '2025-09-08 10:20:00'),
(4, 1, '2025-09-08 11:25:00'),
(5, 2, '2025-09-08 12:30:00'),
(1, 3, '2025-09-08 13:35:00'),
(2, 1, '2025-09-09 08:00:00'),
(3, 2, '2025-09-09 09:10:00'),
(4, 3, '2025-09-09 10:20:00'),
(5, 1, '2025-09-09 11:30:00'),

(1, 2, '2025-09-10 08:40:00'),
(2, 3, '2025-09-10 09:50:00'),
(3, 1, '2025-09-10 11:00:00'),
(4, 2, '2025-09-10 12:10:00'),
(5, 3, '2025-09-10 13:20:00'),
(1, 1, '2025-09-11 08:00:00'),
(2, 2, '2025-09-11 09:00:00'),
(3, 3, '2025-09-11 10:00:00'),
(4, 1, '2025-09-11 11:00:00'),
(5, 2, '2025-09-11 12:00:00'),

(1, 3, '2025-09-12 08:00:00'),
(2, 1, '2025-09-12 09:00:00'),
(3, 2, '2025-09-12 10:00:00'),
(4, 3, '2025-09-12 11:00:00'),
(5, 1, '2025-09-12 12:00:00'),
(1, 2, '2025-09-13 08:00:00'),
(2, 3, '2025-09-13 09:00:00'),
(3, 1, '2025-09-13 10:00:00'),
(4, 2, '2025-09-13 11:00:00'),
(5, 3, '2025-09-13 12:00:00'),

(1, 1, '2025-09-14 08:10:00'),
(2, 2, '2025-09-14 09:20:00'),
(3, 3, '2025-09-14 10:30:00'),
(4, 1, '2025-09-14 11:40:00'),
(5, 2, '2025-09-14 12:50:00'),
(1, 3, '2025-09-15 08:00:00'),
(2, 1, '2025-09-15 09:10:00'),
(3, 2, '2025-09-15 10:20:00'),
(4, 3, '2025-09-15 11:30:00'),
(5, 1, '2025-09-15 12:40:00'),

(1, 2, '2025-09-16 08:00:00'),
(2, 3, '2025-09-16 09:00:00'),
(3, 1, '2025-09-16 10:00:00'),
(4, 2, '2025-09-16 11:00:00'),
(5, 3, '2025-09-16 12:00:00'),
(1, 1, '2025-09-17 08:00:00'),
(2, 2, '2025-09-17 09:00:00'),
(3, 3, '2025-09-17 10:00:00'),
(4, 1, '2025-09-17 11:00:00'),
(5, 2, '2025-09-17 12:00:00'),

(1, 3, '2025-09-18 08:00:00'),
(2, 1, '2025-09-18 09:00:00'),
(3, 2, '2025-09-18 10:00:00'),
(4, 3, '2025-09-18 11:00:00'),
(5, 1, '2025-09-18 12:00:00'),
(1, 2, '2025-09-19 08:00:00'),
(2, 3, '2025-09-19 09:00:00'),
(3, 1, '2025-09-19 10:00:00'),
(4, 2, '2025-09-19 11:00:00'),
(5, 3, '2025-09-19 12:00:00');


select * from registro_atendimento;



-- Inserção de registros de atendimento para todo o mês de outubro de 2025
INSERT INTO registro_atendimento (fk_beneficiario, fk_tipo, data_hora) VALUES
-- 1 de outubro
(1,1,'2025-10-01 08:00:00'),
(2,2,'2025-10-01 09:00:00'),
(3,3,'2025-10-01 10:00:00'),
(4,1,'2025-10-01 11:00:00'),
(5,2,'2025-10-01 12:00:00'),

-- 2 de outubro
(1,2,'2025-10-02 08:10:00'),
(2,3,'2025-10-02 09:15:00'),
(3,1,'2025-10-02 10:20:00'),
(4,2,'2025-10-02 11:25:00'),

-- 3 de outubro
(1,3,'2025-10-03 08:05:00'),
(2,1,'2025-10-03 09:10:00'),
(5,2,'2025-10-03 10:15:00'),

-- 4 de outubro
(1,1,'2025-10-04 08:00:00'),
(2,2,'2025-10-04 09:00:00'),
(3,3,'2025-10-04 10:00:00'),
(4,1,'2025-10-04 11:00:00'),
(5,3,'2025-10-04 12:00:00'),

-- 5 de outubro
(1,2,'2025-10-05 08:00:00'),
(2,3,'2025-10-05 09:00:00'),
(3,1,'2025-10-05 10:00:00'),

-- 6 de outubro
(1,1,'2025-10-06 08:00:00'),
(2,2,'2025-10-06 09:00:00'),
(3,3,'2025-10-06 10:00:00'),
(4,1,'2025-10-06 11:00:00'),

-- 7 de outubro
(1,3,'2025-10-07 08:00:00'),
(5,1,'2025-10-07 09:00:00'),
(3,2,'2025-10-07 10:00:00'),
(4,3,'2025-10-07 11:00:00'),

-- 8 de outubro
(2,1,'2025-10-08 08:00:00'),
(1,2,'2025-10-08 09:00:00'),
(5,3,'2025-10-08 10:00:00'),

-- 9 de outubro
(3,1,'2025-10-09 08:00:00'),
(4,2,'2025-10-09 09:00:00'),
(1,3,'2025-10-09 10:00:00'),
(2,1,'2025-10-09 11:00:00'),

-- 10 de outubro
(1,1,'2025-10-10 08:00:00'),
(3,2,'2025-10-10 09:00:00'),
(4,3,'2025-10-10 10:00:00'),
(5,1,'2025-10-10 11:00:00'),
(2,2,'2025-10-10 12:00:00'),

-- 11 de outubro
(1,2,'2025-10-11 08:00:00'),
(2,3,'2025-10-11 09:00:00'),
(3,1,'2025-10-11 10:00:00'),

-- 12 de outubro
(1,1,'2025-10-12 08:00:00'),
(4,2,'2025-10-12 09:00:00'),
(5,3,'2025-10-12 10:00:00'),
(2,1,'2025-10-12 11:00:00'),

-- 13 de outubro
(1,3,'2025-10-13 08:00:00'),
(3,2,'2025-10-13 09:00:00'),
(4,1,'2025-10-13 10:00:00'),

-- 14 de outubro
(2,2,'2025-10-14 08:00:00'),
(3,3,'2025-10-14 09:00:00'),
(1,1,'2025-10-14 10:00:00'),
(5,2,'2025-10-14 11:00:00'),

-- 15 de outubro
(1,2,'2025-10-15 08:00:00'),
(4,3,'2025-10-15 09:00:00'),
(5,1,'2025-10-15 10:00:00'),

-- 16 de outubro
(2,1,'2025-10-16 08:00:00'),
(3,2,'2025-10-16 09:00:00'),
(1,3,'2025-10-16 10:00:00'),

-- 17 de outubro
(1,1,'2025-10-17 08:00:00'),
(2,2,'2025-10-17 09:00:00'),
(3,3,'2025-10-17 10:00:00'),
(4,1,'2025-10-17 11:00:00'),

-- 18 de outubro
(5,2,'2025-10-18 08:00:00'),
(1,3,'2025-10-18 09:00:00'),
(2,1,'2025-10-18 10:00:00'),

-- 19 de outubro
(1,1,'2025-10-19 08:00:00'),
(2,2,'2025-10-19 09:00:00'),
(3,3,'2025-10-19 10:00:00'),
(4,1,'2025-10-19 11:00:00'),

-- 20 de outubro
(1,2,'2025-10-20 08:00:00'),
(3,1,'2025-10-20 09:00:00'),
(5,3,'2025-10-20 10:00:00'),

-- 21 de outubro
(1,1,'2025-10-21 08:00:00'),
(2,2,'2025-10-21 09:00:00'),
(3,3,'2025-10-21 10:00:00'),

-- 22 de outubro
(4,1,'2025-10-22 08:00:00'),
(5,2,'2025-10-22 09:00:00'),
(1,3,'2025-10-22 10:00:00'),

-- 23 de outubro
(2,1,'2025-10-23 08:00:00'),
(3,2,'2025-10-23 09:00:00'),

-- 24 de outubro
(1,1,'2025-10-24 08:00:00'),
(2,3,'2025-10-24 09:00:00'),
(3,2,'2025-10-24 10:00:00'),

-- 25 de outubro
(1,3,'2025-10-25 08:00:00'),
(4,1,'2025-10-25 09:00:00'),
(5,2,'2025-10-25 10:00:00'),

-- 26 de outubro
(2,2,'2025-10-26 08:00:00'),
(3,3,'2025-10-26 09:00:00'),

-- 27 de outubro
(1,1,'2025-10-27 08:00:00'),
(4,2,'2025-10-27 09:00:00'),
(5,3,'2025-10-27 10:00:00'),

-- 28 de outubro
(2,1,'2025-10-28 08:00:00'),
(3,2,'2025-10-28 09:00:00'),
(1,3,'2025-10-28 10:00:00'),

-- 29 de outubro
(4,1,'2025-10-29 08:00:00'),
(5,2,'2025-10-29 09:00:00'),

-- 30 de outubro
(1,1,'2025-10-30 08:00:00'),
(2,3,'2025-10-30 09:00:00'),
(3,2,'2025-10-30 10:00:00'),

-- 31 de outubro
(1,3,'2025-10-31 08:00:00'),
(2,1,'2025-10-31 09:00:00'),
(4,2,'2025-10-31 10:00:00');
