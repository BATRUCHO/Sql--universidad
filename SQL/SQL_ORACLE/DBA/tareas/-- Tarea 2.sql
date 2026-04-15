--Tarea


CREATE PROFILE perfil_seguridad_hr LIMIT
    FAILED_LOGIN_ATTEMPTS 3         -- Bloqueo tras 3 intentos fallidos 
    PASSWORD_LOCK_TIME 1/1440       -- Bloqueo por 1 minuto para pruebas 
    PASSWORD_LIFE_TIME 90;          -- Cambio de clave cada 90 días 

-- 1. Creación de usuarios con su perfil 
CREATE USER Empleado1 IDENTIFIED BY "Clave123*@@23" PROFILE perfil_seguridad_hr;
CREATE USER Empleado2 IDENTIFIED BY "Clave456*@@@a" PROFILE perfil_seguridad_hr;
CREATE USER GestorDB IDENTIFIED BY "Admin789*@@@4" PROFILE perfil_seguridad_hr;


-- 3. Creación de roles 
CREATE ROLE rol_consulta;  
CREATE ROLE rol_edicion;  
CREATE ROLE rol_admin_estructuras; 

-- 4. Asignación de privilegios a los roles 
GRANT CREATE SESSION, SELECT ANY TABLE TO rol_consulta; 
GRANT CREATE SESSION, SELECT ANY TABLE, UPDATE ANY TABLE TO rol_edicion; 


GRANT CREATE ANY TABLE, ALTER ANY TABLE, DROP ANY TABLE TO rol_admin_estructuras;
GRANT CREATE ANY INDEX, DROP ANY INDEX TO rol_admin_estructuras;
GRANT CREATE VIEW, CREATE PROCEDURE TO rol_admin_estructuras;


-- 5. Asignación de roles a los usuarios 
GRANT rol_consulta TO Empleado1;
GRANT rol_edicion TO Empleado2;
GRANT rol_admin_estructuras TO GestorDB;



-- 1. Borrar por si quedaron mal creadas (opcional)
DROP TABLE detalle_pago;
DROP TABLE pagos;
DROP TABLE estudiantes;

-- 2. Crear las tablas correctamente
CREATE TABLE estudiantes (
    id_estudiante NUMBER PRIMARY KEY,
    nombre VARCHAR2(50),
    saldo NUMBER
);

CREATE TABLE pagos (
    id_pago NUMBER PRIMARY KEY,
    id_estudiante NUMBER,
    fecha DATE,
    monto NUMBER,
    CONSTRAINT fk_estudiante_pago FOREIGN KEY (id_estudiante) REFERENCES estudiantes (id_estudiante)
);

CREATE TABLE detalle_pago (
    id_pago NUMBER,
    descripcion VARCHAR2(100),
    CONSTRAINT fk_pago_detalle FOREIGN KEY (id_pago) REFERENCES pagos(id_pago)
);

-- 3. Insertar un estudiante de prueba para que el script no falle
INSERT INTO estudiantes (id_estudiante, nombre, saldo) VALUES (101, 'Brayan Batres', 100000);
COMMIT;



------------------------------------------------------------------------------------------------------

DECLARE
    v_id_estudiante NUMBER := 101; -- ID de prueba
    v_monto_pago NUMBER := 50000;  -- Monto de prueba
    v_id_pago NUMBER := 1;
    v_existe_estudiante NUMBER;
BEGIN
    -- Verificamos si el estudiante 
    SELECT COUNT(*) INTO v_existe_estudiante FROM estudiantes WHERE id_estudiante = v_id_estudiante;

    IF v_existe_estudiante = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: El estudiante no existe.');
        ROLLBACK; 
    ELSIF v_monto_pago < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Error: Monto negativo.');
        ROLLBACK; 
    ELSE
        -- 1. Insertar el pago 
        INSERT INTO pagos (id_pago, id_estudiante, fecha, monto)
        VALUES (v_id_pago, v_id_estudiante, SYSDATE, v_monto_pago);
        
        SAVEPOINT registro_inicial; -- Punto de control 

        -- 2. Actualizar el saldo del estudiante
        UPDATE estudiantes SET saldo = saldo - v_monto_pago 
        WHERE id_estudiante = v_id_estudiante;

        -- 3. Insertar el detalle del pago 
        INSERT INTO detalle_pago (id_pago, descripcion)
        VALUES (v_id_pago, 'Pago de matrícula primer cuatrimestre');

        COMMIT; -- 6. Todo exitoso, confirmar cambios 
        DBMS_OUTPUT.PUT_LINE('Pago registrado con éxito.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- En caso de error inesperado, asegurar atomicidad 
        DBMS_OUTPUT.PUT_LINE('Error en la transacción. Se aplicó ROLLBACK.');
END;