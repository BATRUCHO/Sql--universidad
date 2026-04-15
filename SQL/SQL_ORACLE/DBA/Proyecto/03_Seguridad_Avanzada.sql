-- Seccion con la que se tiene que iniciar es: DW_BANCO_NOVA



/*========================================================
1. VISTA SEGURA
========================================================*/

CREATE OR REPLACE VIEW VW_CLIENTE_SEGURA AS
SELECT
    c.id_cliente,
    c.nombre,
    c.apellido,
    t.direccion,
    t.ciudad,
    t.codigoPostal,
    c.telefono,
    c.email,
    RPAD('****', LENGTH(c.dni) - 4, '*') || SUBSTR(c.dni, -4) AS dni,
    '************' || SUBSTR(TO_CHAR(c.numero_tarjeta_credito), -4) AS numero_tarjeta_credito,
    '********' || SUBSTR(TO_CHAR(c.cuenta_bancaria), -4) AS cuenta_bancaria,
    c.fecha_nacimiento
FROM dim_cliente c
INNER JOIN dim_sucursal s ON c.dim_sucursal_id_sucursal = s.id_sucursal
INNER JOIN dim_territorio t ON s.dim_territorio_id_zona = t.id_zona;

-- GRANT después de crear la vista
GRANT SELECT ON VW_CLIENTE_SEGURA TO USRCONSULTA;

/*========================================================
2. AUDITORÍA FGA
========================================================*/

BEGIN
    DBMS_FGA.ADD_POLICY(
        OBJECT_SCHEMA   => 'DW_BANCO_NOVA',
        OBJECT_NAME     => 'DIM_CLIENTE',
        POLICY_NAME     => 'AUDIT_ACCESO_SENSIBLE',
        AUDIT_COLUMN    => 'DNI, NUMERO_TARJETA_CREDITO, CUENTA_BANCARIA',
        ENABLE          => TRUE,
        STATEMENT_TYPES => 'SELECT'
    );
END;
/

BEGIN
    DBMS_FGA.DROP_POLICY(
        OBJECT_SCHEMA => 'DW_BANCO_NOVA',
        OBJECT_NAME   => 'DIM_CLIENTE',
        POLICY_NAME   => 'AUDIT_ACCESO_SENSIBLE'
    );
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

/*========================================================
3. PACKAGE
========================================================*/

CREATE OR REPLACE PACKAGE PKG_AUDITORIA_PRIVS AS

    PROCEDURE RPT_PRIVS_SISTEMA   (p_usuario IN VARCHAR2);
    PROCEDURE RPT_PRIVS_OBJETOS   (p_usuario IN VARCHAR2);
    PROCEDURE RPT_ROLES           (p_usuario IN VARCHAR2);
    PROCEDURE RPT_PRIVS_HEREDADOS (p_usuario IN VARCHAR2);
    PROCEDURE RPT_COMPLETO        (p_usuario IN VARCHAR2);

END PKG_AUDITORIA_PRIVS;
/

/*========================================================
4. PACKAGE BODY (CORRECTO)
========================================================*/

CREATE OR REPLACE PACKAGE BODY PKG_AUDITORIA_PRIVS AS

    -- 1. PRIVILEGIOS DE SISTEMA
    PROCEDURE RPT_PRIVS_SISTEMA (p_usuario IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PRIVILEGIOS DE SISTEMA ===');

        FOR r IN (
            SELECT PRIVILEGE, ADMIN_OPTION
            FROM DBA_SYS_PRIVS
            WHERE GRANTEE = UPPER(p_usuario)
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(r.PRIVILEGE, 30) ||
                ' | ADMIN: ' || r.ADMIN_OPTION
            );
        END LOOP;
    END RPT_PRIVS_SISTEMA;

    -- 2. PRIVILEGIOS DE OBJETOS
    PROCEDURE RPT_PRIVS_OBJETOS (p_usuario IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PRIVILEGIOS DE OBJETOS ===');

        FOR r IN (
            SELECT OWNER, TABLE_NAME, PRIVILEGE
            FROM DBA_TAB_PRIVS
            WHERE GRANTEE = UPPER(p_usuario)
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                r.OWNER || '.' || r.TABLE_NAME || ' - ' || r.PRIVILEGE
            );
        END LOOP;
    END RPT_PRIVS_OBJETOS;

    -- 3. ROLES
    PROCEDURE RPT_ROLES (p_usuario IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ROLES ===');

        FOR r IN (
            SELECT GRANTED_ROLE
            FROM DBA_ROLE_PRIVS
            WHERE GRANTEE = UPPER(p_usuario)
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(r.GRANTED_ROLE);
        END LOOP;
    END RPT_ROLES;

    -- 4. PRIVILEGIOS HEREDADOS
    PROCEDURE RPT_PRIVS_HEREDADOS (p_usuario IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PRIVILEGIOS HEREDADOS ===');

        FOR r IN (
            SELECT RP.GRANTED_ROLE, SP.PRIVILEGE
            FROM DBA_ROLE_PRIVS RP
            JOIN DBA_SYS_PRIVS SP 
              ON SP.GRANTEE = RP.GRANTED_ROLE
            WHERE RP.GRANTEE = UPPER(p_usuario)
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(
                r.GRANTED_ROLE || ' -> ' || r.PRIVILEGE
            );
        END LOOP;
    END RPT_PRIVS_HEREDADOS;

    -- 5. REPORTE COMPLETO
    PROCEDURE RPT_COMPLETO (p_usuario IN VARCHAR2) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('==============================');
        DBMS_OUTPUT.PUT_LINE('REPORTE COMPLETO: ' || UPPER(p_usuario));
        DBMS_OUTPUT.PUT_LINE('==============================');

        RPT_PRIVS_SISTEMA(p_usuario);
        RPT_PRIVS_OBJETOS(p_usuario);
        RPT_ROLES(p_usuario);
        RPT_PRIVS_HEREDADOS(p_usuario);

    END RPT_COMPLETO;

END PKG_AUDITORIA_PRIVS;
/

/*========================================================
5. PRUEBAS
========================================================*/

SET SERVEROUTPUT ON;

EXEC PKG_AUDITORIA_PRIVS.RPT_COMPLETO('USRCONSULTA');


-- Activar salida
SET SERVEROUTPUT ON SIZE UNLIMITED;

-- Reporte completo de USRCLASE
EXEC PKG_AUDITORIA_PRIVS.RPT_COMPLETO('USRCLASE');

-- O ejecutar cada secci�n por separado
EXEC PKG_AUDITORIA_PRIVS.RPT_PRIVS_SISTEMA('USRCLASE');
EXEC PKG_AUDITORIA_PRIVS.RPT_PRIVS_OBJETOS('USRCLASE');
EXEC PKG_AUDITORIA_PRIVS.RPT_ROLES('USRCLASE');
EXEC PKG_AUDITORIA_PRIVS.RPT_PRIVS_HEREDADOS('USRCLASE');

-- Funciona con cualquier usuario, solo cambia el par�metro
EXEC PKG_AUDITORIA_PRIVS.RPT_COMPLETO('EMPLEADO1');


/*
PRUEBAS DE EJECUCION DE STORED PRODEDURE Y TRIGGER
*/

-- PRUEBA 1: inserciOn correcta en insertar contracto

-- Corremos el Stored prodecure de insertar 
BEGIN
    insertar_contracto(
        p_id_contrato            => 2304,
        p_id_cliente             => 1,
        p_id_producto_financiero => 1,
        p_id_canal               => 1,
        p_id_fecha_contratacion  => 1,
        p_id_moneda              => 1,
        p_monto_contrato         => 25000,
        p_plazos_meses           => 36,
        p_tasa_aplicada          => 8.5,
        p_saldo_inicial          => 25000,
        p_id_estado_contrato     => 1
    );
END;
/


-- Select para ver si se ingreso bien el ID de contrato nuevo
SELECT *
FROM fact_producto_contrato
WHERE id_contrato = 2008;

-- PRUEBA 2: Error por cliente con ID no existente
BEGIN
    insertar_contracto(
        p_id_contrato            => 2002,
        p_id_cliente             => 9999,
        p_id_producto_financiero => 1,
        p_id_canal               => 1,
        p_id_fecha_contratacion  => 1,
        p_id_moneda              => 1,
        p_monto_contrato         => 30000,
        p_plazos_meses           => 24,
        p_tasa_aplicada          => 7.9,
        p_saldo_inicial          => 30000,
        p_id_estado_contrato     => 1
    );
END;
/

-- PRUEBA 3 Error por producto que no existe
BEGIN
    insertar_contracto(
        p_id_contrato            => 1003,
        p_id_cliente             => 1,
        p_id_producto_financiero => 9999,
        p_id_canal               => 1,
        p_id_fecha_contratacion  => 1,
        p_id_moneda              => 1,
        p_monto_contrato         => 15000,
        p_plazos_meses           => 12,
        p_tasa_aplicada          => 6.5,
        p_saldo_inicial          => 15000,
        p_id_estado_contrato     => 1
    );
END;
/


-- PRUEBA 4 : Acutalizar monto para activar el trigger creado 
UPDATE fact_producto_contrato
   SET monto_contrato = 28000
 WHERE id_contrato = 2008;

COMMIT;
 

-- Ver si el trg de auditar si funciono correctamente
SELECT *
FROM log_auditoria_sistema
ORDER BY id_auditoria DESC;
