-- Executada pelo Flyway conectado como WALLET_AUDIT.
-- Unica porta de entrada para gravar na trilha. O WALLET_OWNER recebe so EXECUTE aqui,
-- nunca INSERT na tabela (principio do menor privilegio).

CREATE OR REPLACE PACKAGE PKG_AUDIT AUTHID DEFINER AS
  PROCEDURE REGISTRAR_SALDO(
    p_carteira_id     IN NUMBER,
    p_saldo_anterior  IN NUMBER,
    p_saldo_novo      IN NUMBER,
    p_operacao_id     IN NUMBER
  );
END PKG_AUDIT;
/

CREATE OR REPLACE PACKAGE BODY PKG_AUDIT AS
  PROCEDURE REGISTRAR_SALDO(
    p_carteira_id     IN NUMBER,
    p_saldo_anterior  IN NUMBER,
    p_saldo_novo      IN NUMBER,
    p_operacao_id     IN NUMBER
  ) IS
  BEGIN
    -- O momento (SYSTIMESTAMP, default da coluna) e o usuario sao preenchidos aqui,
    -- nunca recebidos do chamador: quem chama nao escolhe nem forja esses dois campos.
    INSERT INTO SALDO_AUDITORIA (
      ID, CARTEIRA_ID, SALDO_ANTERIOR, SALDO_NOVO, OPERACAO_ID, USUARIO_BANCO
    ) VALUES (
      SEQ_SALDO_AUDITORIA_ID.NEXTVAL, p_carteira_id, p_saldo_anterior, p_saldo_novo,
      p_operacao_id, SYS_CONTEXT('USERENV', 'SESSION_USER')
    );
  END REGISTRAR_SALDO;
END PKG_AUDIT;
/

GRANT EXECUTE ON PKG_AUDIT TO WALLET_OWNER;
