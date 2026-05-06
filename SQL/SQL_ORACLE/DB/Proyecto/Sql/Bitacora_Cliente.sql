
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE bitacora_clientes CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE bitacora_clientes (
  idBitacora NUMBER PRIMARY KEY,
  idCliente  NUMBER,
  usuario_bd VARCHAR2(50),
  accion     VARCHAR2(20),
  fecha      DATE DEFAULT SYSDATE
);

-- 2. Secuencia que genera los IDs de la bitacora
CREATE SEQUENCE seq_bitacora_clientes
START WITH 1
INCREMENT BY 1;

-- 3. Trigger BEFORE INSERT: asigna el siguiente numero de secuencia
--    al idBitacora antes de que la fila se guarde. Asi la aplicacion
--    no tiene que preocuparse por generar IDs.
CREATE OR REPLACE TRIGGER trg_id_bitacora
BEFORE INSERT ON bitacora_clientes
FOR EACH ROW
BEGIN
  :NEW.idBitacora := seq_bitacora_clientes.NEXTVAL;
END;
/

-- 4. Trigger AFTER sobre CLIENTE: detecta cada operacion y la registra
--    con su accion ('INSERT', 'UPDATE' o 'DELETE'). El DELETE usa :OLD
--    porque la fila nueva (:NEW) no existe en un DELETE.
CREATE OR REPLACE TRIGGER trg_bitacora_clientes
AFTER INSERT OR UPDATE OR DELETE ON cliente
FOR EACH ROW
BEGIN
  IF INSERTING THEN
    INSERT INTO bitacora_clientes (idCliente, usuario_bd, accion)
    VALUES (
      :NEW.idCliente,
      NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER),
      'INSERT'
    );

  ELSIF UPDATING THEN
    INSERT INTO bitacora_clientes (idCliente, usuario_bd, accion)
    VALUES (
      :NEW.idCliente,
      NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER),
      'UPDATE'
    );

  ELSIF DELETING THEN
    INSERT INTO bitacora_clientes (idCliente, usuario_bd, accion)
    VALUES (
      :OLD.idCliente,
      NVL(SYS_CONTEXT('USERENV','CLIENT_IDENTIFIER'), USER),
      'DELETE'
    );
  END IF;
END;
/


-- Verificamos que los dos triggers quedaron ENABLED
SELECT trigger_name, table_name, status
FROM user_triggers
WHERE trigger_name IN ('TRG_ID_BITACORA', 'TRG_BITACORA_CLIENTES');