#!/bin/bash
set -e # faz o script parar no primeiro comando que falhar

# Tudo entre <<EOF e EOF é enviado ao sqlplus como SQL.
# As senhas vêm das variáveis de ambiente (definidas no .env pelo docker-compose).
sqlplus -s / as sysdba <<EOF
-- Faz o sqlplus sair com erro se algum SQL falhar (senão o set -e não percebe)
WHENEVER SQLERROR EXIT SQL.SQLCODE

-- Troca da raiz (CDB) para o banco da aplicação (PDB)
ALTER SESSION SET CONTAINER = FREEPDB1;

-- WALLET_OWNER: dono das tabelas, sequences, package e triggers. Usado só pelo Flyway.
CREATE USER WALLET_OWNER IDENTIFIED BY "${WALLET_OWNER_PASSWORD}"
  DEFAULT TABLESPACE USERS
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE,
      CREATE PROCEDURE, CREATE TRIGGER, CREATE VIEW
  TO WALLET_OWNER;

-- WALLET_APP: usuário da aplicação Spring. Só conecta (sem quota, sem criar objetos).
-- Os grants de EXECUTE no package e SELECT nas views vêm depois, pelo Flyway.
CREATE USER WALLET_APP IDENTIFIED BY "${WALLET_APP_PASSWORD}";

GRANT CREATE SESSION TO WALLET_APP;

-- WALLET_AUDIT: dono da trilha de auditoria. A aplicação nunca acessa este schema.
CREATE USER WALLET_AUDIT IDENTIFIED BY "${WALLET_AUDIT_PASSWORD}"
  DEFAULT TABLESPACE USERS
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE PROCEDURE
  TO WALLET_AUDIT;
EOF
