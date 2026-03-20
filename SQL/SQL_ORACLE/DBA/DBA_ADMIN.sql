DROP USER HR_ADM CASCADE;

--Creacio  de usuario

CREATE USER HR_ADM IDENTIFIED BY Unlock_2026#;

GRANT CREATE SESSION
    , CREATE TABLE  
    , CREATE VIEW
    , CREATE SEQUENCE
    , CREATE PROCEDURE
    , CREATE TRIGGER
    , CREATE TYPE
    , CREATE SYNONYM 
    , CREATE INDEXTYPE
    , CREATE MATERIALIZED VIEW
    , CREATE ROLE
    , UNLIMITED TABLESPACE
TO HR_ADM;

ALTER USER HR_ADM QUOTA UNLIMITED ON DATA;


-------------------------------------------------------------------------

-- . Creacion del Usuario HR_CLOUD
CREATE USER HR_CLOUD IDENTIFIED BY "IngSistema_2026_*";

-- .Asignacion de cuotas y permisos
ALTER USER HR_CLOUD QUOTA 50M ON DATA;
ALTER USER HR_CLOUD QUOTA 50M ON DBFS_DATA;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE TO HR_CLOUD;

---------------------------------------------------------------------------

