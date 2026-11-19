-- Executada pelo Flyway conectado como WALLET_OWNER.

-- Sequences explicitas (uma por tabela). CACHE 20: lacunas na numeracao sao esperadas
-- (reinicio do banco, rollback). O ID identifica a linha; a ordem do extrato usa CRIADO_EM + ID.
CREATE SEQUENCE SEQ_CARTEIRA_ID   START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;
CREATE SEQUENCE SEQ_LANCAMENTO_ID START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;

CREATE TABLE CARTEIRA (
  ID         NUMBER(19)                    NOT NULL,
  TITULAR    VARCHAR2(120),
  SALDO      NUMBER(15,2)                  DEFAULT 0 NOT NULL,
  CRIADA_EM  TIMESTAMP(6) WITH TIME ZONE   DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT PK_CARTEIRA PRIMARY KEY (ID),
  -- Ultima barreira: mesmo que a procedure tenha um bug, o banco recusa saldo negativo.
  CONSTRAINT CK_CARTEIRA_SALDO_NAO_NEGATIVO CHECK (SALDO >= 0)
);

-- Extrato. A chave de idempotencia fica na propria linha: o lancamento aplicado "lembra"
-- a chave, o tipo e o valor, e o UNIQUE impede duas linhas com a mesma chave na carteira.
CREATE TABLE LANCAMENTO (
  ID                  NUMBER(19)                    NOT NULL,
  CARTEIRA_ID         NUMBER(19)                    NOT NULL,
  TIPO                VARCHAR2(7)                   NOT NULL,
  VALOR               NUMBER(15,2)                  NOT NULL,
  SALDO_APOS          NUMBER(15,2)                  NOT NULL,
  CHAVE_IDEMPOTENCIA  VARCHAR2(100)                 NOT NULL,
  CRIADO_EM           TIMESTAMP(6) WITH TIME ZONE   DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT PK_LANCAMENTO PRIMARY KEY (ID),
  CONSTRAINT FK_LANCAMENTO_CARTEIRA FOREIGN KEY (CARTEIRA_ID) REFERENCES CARTEIRA (ID),
  CONSTRAINT CK_LANCAMENTO_TIPO CHECK (TIPO IN ('CREDITO', 'DEBITO')),
  CONSTRAINT CK_LANCAMENTO_VALOR_POSITIVO CHECK (VALOR > 0),
  CONSTRAINT CK_LANCAMENTO_SALDO_APOS CHECK (SALDO_APOS >= 0),
  CONSTRAINT UQ_LANCAMENTO_CHAVE UNIQUE (CARTEIRA_ID, CHAVE_IDEMPOTENCIA)
);

-- Serve o extrato: filtro por carteira + periodo, ordenado, com paginacao.
-- (O UNIQUE acima ja indexa CARTEIRA_ID, entao a FK tambem fica coberta.)
CREATE INDEX IX_LANCAMENTO_EXTRATO ON LANCAMENTO (CARTEIRA_ID, CRIADO_EM, ID);
