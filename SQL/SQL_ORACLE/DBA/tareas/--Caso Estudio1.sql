--Caso Estudio1

SET SERVEROUTPUT ON;
SET FEEDBACK OFF;

DECLARE
    -- Parámetros configurables
    v_ts_name        VARCHAR2(30) := '&Nombre_Tablespace';
    v_max_failed_log INT          := &Intentos_Fallidos_Permitidos;
    v_role_name      VARCHAR2(30) := '&Nombre_Nuevo_Rol';
    
    -- Variables de control
    v_sql            VARCHAR2(1000);
    v_log_msg        VARCHAR2(4000);
BEGIN
    v_log_msg := '--- INICIO DE LOG DE OPTIMIZACIÓN DATALOGIX ---' || CHR(10);

    --  MONITOREO DE TABLESPACES (ALERTA SIMULADA)
    FOR ts IN (SELECT tablespace_name, used_percent FROM dba_tablespace_usage_metrics WHERE used_percent > 85) LOOP
        v_log_msg := v_log_msg || 'ALERTA: Tablespace ' || ts.tablespace_name || ' está al ' || ts.used_percent || '%' || CHR(10);
    END LOOP;

    -- Seleccionamos tablas con alto encadenamiento o fragmentación (simulado)
    FOR r IN (SELECT table_name FROM user_tables WHERE num_rows > 1000) LOOP
        BEGIN
            v_sql := 'ALTER TABLE ' || r.table_name || ' MOVE';
            EXECUTE IMMEDIATE v_sql;
            v_log_msg := v_log_msg || 'MANTENIMIENTO: Tabla ' || r.name || ' movida para reducir fragmentación.' || CHR(10);
        EXCEPTION WHEN OTHERS THEN 
            v_log_msg := v_log_msg || 'ERROR: No se pudo mover tabla ' || r.table_name || CHR(10);
        END;
    END LOOP;

    --  CONTROL DE ROLES (Limpieza de privilegios masivos)
    v_sql := 'CREATE ROLE ' || v_role_name;
    EXECUTE IMMEDIATE v_sql;
    v_log_msg := v_log_msg || 'SEGURIDAD: Rol ' || v_role_name || ' creado para control de acceso.' || CHR(10);

    --  POLÍTICAS DE CONTRASEÑAS (Profile de Seguridad)
    BEGIN
        v_sql := 'CREATE PROFILE DATALOGIX_SEC_PROFILE LIMIT ' ||
                 'FAILED_LOGIN_ATTEMPTS ' || v_max_failed_log || ' ' ||
                 'PASSWORD_LIFE_TIME 90 ' ||
                 'PASSWORD_LOCK_TIME 1/24'; -- Bloqueo por 1 hora
        EXECUTE IMMEDIATE v_sql;
        v_log_msg := v_log_msg || 'SEGURIDAD: Perfil de contraseñas aplicado.' || CHR(10);
    EXCEPTION WHEN OTHERS THEN
        v_log_msg := v_log_msg || 'INFO: El perfil ya existe o no se pudo crear.' || CHR(10);
    END;

    -- SALIDA FINAL DEL LOG
    DBMS_OUTPUT.PUT_LINE(v_log_msg);
    DBMS_OUTPUT.PUT_LINE('--- FIN DEL PROCESO ---');
END;
/