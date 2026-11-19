-- Executada pelo Flyway conectado como WALLET_OWNER.
-- Requer que as migrations de audit (V1 e V2) ja tenham rodado: a trigger de auditoria
-- chama WALLET_AUDIT.PKG_AUDIT, para o qual o OWNER recebeu EXECUTE.

-- Imutabilidade do extrato: qualquer UPDATE ou DELETE em LANCAMENTO e barrado,
-- inclusive SQL executado direto no banco.
-- Limitacao conhecida: TRUNCATE e DDL e nao dispara trigger; o dono tambem pode desabilita-la.
CREATE OR REPLACE TRIGGER TRG_LANCAMENTO_IMUTAVEL
BEFORE UPDATE OR DELETE ON LANCAMENTO
FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20005, 'Lancamento e imutavel: nao pode ser alterado nem apagado.');
END;
/

-- Auditoria de saldo: toda mudanca real de SALDO gera uma linha na trilha, na mesma transacao.
-- OPERACAO_ID vem do contexto da sessao; fica NULL quando o saldo e alterado fora do package
-- (ex.: SQL direto), o que ja sinaliza uma alteracao suspeita.
CREATE OR REPLACE TRIGGER TRG_CARTEIRA_AUDITORIA
AFTER UPDATE OF SALDO ON CARTEIRA
FOR EACH ROW
WHEN (OLD.SALDO <> NEW.SALDO)
BEGIN
  WALLET_AUDIT.PKG_AUDIT.REGISTRAR_SALDO(
    :OLD.ID, :OLD.SALDO, :NEW.SALDO, PKG_WALLET_CTX.OBTER_OPERACAO
  );
END;
/
