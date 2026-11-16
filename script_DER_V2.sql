CREATE DATABASE IF NOT EXISTS HexaDevs;
USE HexaDevs;

CREATE TABLE Usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(45) NOT NULL,
    sobrenome VARCHAR(45) NOT NULL,
    email VARCHAR(45) NOT NULL UNIQUE,
    telefone VARCHAR(11),
    senha VARCHAR(45) NOT NULL,
    ativo TINYINT(1) DEFAULT 1,
    dataCadastro DATETIME,
    dt_nascimento DATE,
    tipo_usuario TINYINT(1)
);

CREATE TABLE Dependentes (
    idDependentes INT AUTO_INCREMENT,
    nome VARCHAR(45) NOT NULL,
    parentesco VARCHAR(45) NOT NULL,
    Usuario_idUsuario INT NOT NULL,
    PRIMARY KEY (idDependentes, Usuario_idUsuario),
    FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE Servico (
    idServico INT AUTO_INCREMENT PRIMARY KEY,
    tipoServico VARCHAR(45) NOT NULL,
    valor DECIMAL(10,2) NOT NULL
);

CREATE TABLE Servico_func (
    Usuario_idUsuario INT NOT NULL,
    Servico_idServico INT NOT NULL,
    tempo_duracao TIME,
    PRIMARY KEY (Usuario_idUsuario, Servico_idServico),
    FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario(idUsuario),
    FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
);

CREATE TABLE Agendamento (
    idAgendamento INT AUTO_INCREMENT PRIMARY KEY,
    data DATE NOT NULL,
    horario TIME NOT NULL,
    status ENUM('Pendente', 'Confirmado', 'Cancelado', 'Concluido') DEFAULT 'Pendente',
    Dependentes_idDependentes INT,
    Dependentes_Usuario_idUsuario INT,
    Usuario_idUsuario INT NOT NULL,
    FOREIGN KEY (Dependentes_idDependentes, Dependentes_Usuario_idUsuario) 
        REFERENCES Dependentes(idDependentes, Usuario_idUsuario),
    FOREIGN KEY (Usuario_idUsuario) REFERENCES Usuario(idUsuario)
);

CREATE TABLE itemServico (
    Agendamento_idAgendamento INT NOT NULL,
    Servico_idServico INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (Agendamento_idAgendamento, Servico_idServico),
    FOREIGN KEY (Agendamento_idAgendamento) REFERENCES Agendamento(idAgendamento),
    FOREIGN KEY (Servico_idServico) REFERENCES Servico(idServico)
);
-- tipo_usuario: 0 = Cliente, 1 = Funcionário, 2 = Administrador
INSERT INTO Usuario (idUsuario, nome, sobrenome, email, telefone, senha, ativo, dataCadastro, dt_nascimento, tipo_usuario) VALUES
(1, 'Ana', 'Silva', 'ana.silva@email.com', '11988887777', 'senha123', 1, '2026-01-10 10:00:00', '1990-05-15', 0), 
(2, 'Carlos', 'Oliveira', 'carlos.oli@email.com', '11977776666', 'senha456', 1, '2026-01-12 11:30:00', '1985-08-20', 1), 
(3, 'Mariana', 'Souza', 'mariana.souza@email.com', '11966665555', 'senha789', 1, '2026-01-15 14:20:00', '1992-12-01', 0), 
(4, 'Fred', 'Admin', 'fred.admin@email.com', '11955554444', 'admin123', 1, '2026-01-01 08:00:00', '1980-03-10', 2),
(5, 'Juliana', 'Lima', 'juliana.lima@email.com', '11944443333', 'senha999', 1, '2026-02-01 09:00:00', '1988-04-12', 1),
(6, 'Marcos', 'Santos', 'marcos.santos@email.com', '11933332222', 'senha333', 1, '2026-02-10 14:00:00', '1995-11-25', 0);

INSERT INTO Dependentes (idDependentes, nome, parentesco, Usuario_idUsuario) VALUES
(1, 'Lucas Silva', 'Filho', 1),
(2, 'Beatriz Souza', 'Filha', 3);

INSERT INTO Servico (idServico, tipoServico, valor) VALUES
(1, 'Corte de Cabelo', 50.00),
(2, 'Manicure', 30.00),
(3, 'Massagem Relaxante', 120.00);

INSERT INTO Servico_func (Usuario_idUsuario, Servico_idServico, tempo_duracao) VALUES
(2, 1, '00:45:00'), 
(2, 3, '01:00:00'),
(5, 2, '00:30:00');


INSERT INTO Agendamento (idAgendamento, data, horario, status, Dependentes_idDependentes, Dependentes_Usuario_idUsuario, Usuario_idUsuario) VALUES
(1, '2026-03-20', '14:00:00', 'Confirmado', NULL, NULL, 1),
(2, '2026-03-20', '10:30:00', 'Pendente', 1, 1, 1),      
(3, '2026-03-20', '15:30:00', 'Confirmado', NULL, NULL, 6),
(4, '2026-03-20', '17:00:00', 'Confirmado', 2, 3, 3);

INSERT INTO itemServico (Agendamento_idAgendamento, Servico_idServico, preco_unitario) VALUES
(1, 1, 50.00), 
(2, 2, 30.00),
(3, 1, 50.00), 
(4, 3, 120.00);


-- quais são todos os agendamentos realizados, quem foi o cliente que marcou, qual serviço foi escolhido e qual funcionário está associado a esse serviço?
SELECT Agendamento.idAgendamento,
    Agendamento.data,
    Agendamento.horario,
    cliente.nome AS cliente_nome,
    Servico.tipoServico,
    funcionario.nome AS funcionario_nome,
    funcionario.sobrenome AS funcionario_sobrenome 
FROM Agendamento
JOIN Usuario AS cliente ON Agendamento.Usuario_idUsuario = cliente.idUsuario
JOIN itemServico ON Agendamento.idAgendamento = itemServico.Agendamento_idAgendamento
JOIN Servico ON itemServico.Servico_idServico = Servico.idServico
JOIN Servico_func ON Servico.idServico = Servico_func.Servico_idServico
JOIN Usuario AS funcionario ON Servico_func.Usuario_idUsuario = funcionario.idUsuario;

-- lista Dependentes
SELECT idDependentes,
    nome,
    parentesco,
    Usuario_idUsuario FROM Dependentes;

-- lista especificamente todos os agendamentos que foram feitos para os dependentes
SELECT Agendamento.idAgendamento,
    Agendamento.data,
    Agendamento.horario,
    Agendamento.status,
    dependente.nome AS dependente_nome,
    dependente.parentesco,
    titular.nome AS titular_nome
FROM Agendamento
JOIN Dependentes AS dependente 
    ON Agendamento.Dependentes_idDependentes = dependente.idDependentes 
    AND Agendamento.Dependentes_Usuario_idUsuario = dependente.Usuario_idUsuario
JOIN Usuario AS titular 
    ON dependente.Usuario_idUsuario = titular.idUsuario
WHERE Agendamento.Dependentes_idDependentes IS NOT NULL;

-- esse mostra todos os atendimentos marcados para um dia específico (nesse caso é o dia 2026-03-20),
-- mostrando tanto os agendamentos feitos pelos próprios titulares quanto os feitos para os dependentes
SELECT agendamento.idAgendamento,
    agendamento.data,
    agendamento.horario,
    COALESCE(dependente.nome, titular.nome) AS pessoa_atendida,
    CASE 
        WHEN agendamento.Dependentes_idDependentes IS NOT NULL THEN 'Dependente'
        ELSE 'Titular'
    END AS tipo_cliente,
    servico.tipoServico,
    itemServico.preco_unitario 
FROM Agendamento AS agendamento 
JOIN Usuario AS titular 
    ON agendamento.Usuario_idUsuario = titular.idUsuario 
LEFT JOIN Dependentes AS dependente 
    ON agendamento.Dependentes_idDependentes = dependente.idDependentes 
    AND agendamento.Dependentes_Usuario_idUsuario = dependente.Usuario_idUsuario 
JOIN itemServico 
    ON agendamento.idAgendamento = itemServico.Agendamento_idAgendamento 
JOIN Servico AS servico 
    ON itemServico.Servico_idServico = servico.idServico 
WHERE agendamento.data = '2026-03-20';

-- esse select mostra todos os agendamentos que o funcionario tem naquele dia, tanto de titulares, tanto de dependentes 
SELECT agendamento.idAgendamento,
    agendamento.data,
    agendamento.horario,
    agendamento.status,
    COALESCE(dependente.nome, titular.nome) AS cliente_atendido,
    CASE 
        WHEN agendamento.Dependentes_idDependentes IS NOT NULL THEN 'Dependente'
        ELSE 'Titular'
    END AS tipo_cliente,
    servico.tipoServico
FROM Agendamento AS agendamento
JOIN Usuario AS titular 
    ON agendamento.Usuario_idUsuario = titular.idUsuario
LEFT JOIN Dependentes AS dependente 
    ON agendamento.Dependentes_idDependentes = dependente.idDependentes 
    AND agendamento.Dependentes_Usuario_idUsuario = dependente.Usuario_idUsuario
JOIN itemServico 
    ON agendamento.idAgendamento = itemServico.Agendamento_idAgendamento
JOIN Servico AS servico 
    ON itemServico.Servico_idServico = servico.idServico
JOIN Servico_func 
    ON servico.idServico = Servico_func.Servico_idServico
WHERE Servico_func.Usuario_idUsuario = 2
  AND agendamento.data = '2026-03-20';