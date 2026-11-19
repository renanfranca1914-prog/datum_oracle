-- Executada pelo Flyway conectado como WALLET_AUDIT.
-- Trilha de auditoria de saldo. A aplicacao (WALLET_APP) nao tem nenhum acesso a este schema.

-- Sequence explicita para o identificador da trilha.
-- CACHE 20: o Oracle reserva 20 numeros em memoria por vez (menos idas ao dicionario).
-- Consequencia: ao reiniciar o banco, os numeros ainda nao usados do cache se perdem (lacunas).
-- Lacuna e aceitavel: o ID identifica a linha, nao conta eventos.
CREATE SEQUENCE SEQ_SALDO_AUDITORIA_ID START WITH 1 INCREMENT BY 1 CACHE 20 NOCYCLE;

-- Sem FOREIGN KEY para WALLET_OWNER.CARTEIRA de proposito: a trilha e independente
-- e nao deve depender (nem dar privilegio) ao schema que ela audita.
CREATE TABLE SALDO_AUDITORIA (
  ID              NUMBER(19)                      NOT NULL,
  CARTEIRA_ID     NUMBER(19)                      NOT NULL,
  SALDO_ANTERIOR  NUMBER(15,2)                    NOT NULL,
  SALDO_NOVO      NUMBER(15,2)                    NOT NULL,
  OPERACAO_ID     NUMBER(19),
  USUARIO_BANCO   VARCHAR2(128)                   NOT NULL,
  REGISTRADO_EM   TIMESTAMP(6) WITH TIME ZONE     DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT PK_SALDO_AUDITORIA PRIMARY KEY (ID)
);

CREATE INDEX IX_SALDO_AUD_CARTEIRA ON SALDO_AUDITORIA (CARTEIRA_ID, REGISTRADO_EM);

COMMENT ON COLUMN SALDO_AUDITORIA.OPERACAO_ID IS 'ID do lancamento que causou a mudanca. NULL = saldo alterado fora do package (ex.: SQL direto).';
