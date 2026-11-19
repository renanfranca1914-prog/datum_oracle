-- Executada pelo Flyway conectado como WALLET_OWNER.
-- Guarda, na sessao, o ID da operacao em andamento para a trigger de auditoria saber
-- "qual operacao causou esta mudanca de saldo". Estado de package e por sessao (isolado entre conexoes).
-- O WALLET_APP nao recebe EXECUTE aqui; so o PKG_WALLET (mesmo schema) vai usar.

CREATE OR REPLACE PACKAGE PKG_WALLET_CTX AUTHID DEFINER AS
  PROCEDURE DEFINIR_OPERACAO(p_operacao_id IN NUMBER);
  PROCEDURE LIMPAR_OPERACAO;
  FUNCTION  OBTER_OPERACAO RETURN NUMBER;
END PKG_WALLET_CTX;
/

CREATE OR REPLACE PACKAGE BODY PKG_WALLET_CTX AS
  g_operacao_id NUMBER := NULL;

  PROCEDURE DEFINIR_OPERACAO(p_operacao_id IN NUMBER) IS
  BEGIN
    g_operacao_id := p_operacao_id;
  END DEFINIR_OPERACAO;

  PROCEDURE LIMPAR_OPERACAO IS
  BEGIN
    g_operacao_id := NULL;
  END LIMPAR_OPERACAO;

  FUNCTION OBTER_OPERACAO RETURN NUMBER IS
  BEGIN
    RETURN g_operacao_id;
  END OBTER_OPERACAO;
END PKG_WALLET_CTX;
/
