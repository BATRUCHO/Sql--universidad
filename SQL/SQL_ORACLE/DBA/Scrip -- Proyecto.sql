/********************************************************************************************************************************************************************/

-- 1. Crear el Tablespace
CREATE TABLESPACE TS_Banco_Financiero_Nova
DATAFILE 'C:\ORADATA\TS_Banco_Financiero_Nova.DBF'
SIZE 100M
AUTOEXTEND ON NEXT 10M MAXSIZE 500M
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO;

/********************************************************************************************************************************************************************/
-- 2. Crear Usuarios y Asignar Cuotas y Perfiles

/*
CREACION DE PERFIL 
Con límite de sesiones, tiempo de inactividad, uso de recursos, entre otros.
*/

CREATE PROFILE PERFIL_USUARIOS 
LIMIT
     FAILED_LOGIN_ATTEMPTS 3
     PASSWORD_LIFE_TIME 30
     PASSWORD_LOCK_TIME 7
     PASSWORD_REUSE_TIME 10
     SESSIONS_PER_USER 2
     IDLE_TIME 15
     CONNECT_TIME 480
     CPU_PER_SESSION 10000;
     
 -- Creación de usuarios con el perfil asignado    
CREATE USER DW_BANCO_NOVA IDENTIFIED BY "NoVa2026!" PROFILE PERFIL_USUARIOS;
CREATE USER USRCONSULTA IDENTIFIED BY "PwUsrNova24$" PROFILE PERFIL_USUARIOS;
CREATE USER USRDESARROLADOR IDENTIFIED BY "PwUsrNova24$" PROFILE PERFIL_USUARIOS;
CREATE USER USRDBA IDENTIFIED BY "PwUsrNova24$" PROFILE PERFIL_USUARIOS;

-- Asignar cuotas de espacio en el tablespace para cada usuario
ALTER USER DW_BANCO_NOVA QUOTA UNLIMITED ON TS_Banco_Financiero_Nova;
ALTER USER USRCONSULTA QUOTA UNLIMITED ON TS_Banco_Financiero_Nova;
ALTER USER USRDESARROLADOR QUOTA UNLIMITED ON TS_Banco_Financiero_Nova;
ALTER USER USRDBA QUOTA UNLIMITED ON TS_Banco_Financiero_Nova;


/********************************************************************************************************************************************************************/
-- 4. Crear y Asignar Roles

CREATE ROLE ROL_CONSULTA_APP;

GRANT CREATE SESSION TO ROL_CONSULTA_APP;
GRANT SELECT ANY TABLE TO ROL_CONSULTA_APP;

-- Grant al usuario de consulta
GRANT ROL_CONSULTA_APP TO USRCONSULTA;


-- Rol Desarrollador
CREATE ROLE ROL_DESARROLLADOR_APP;

GRANT CREATE SESSION TO ROL_DESARROLLADOR_APP;
GRANT CREATE TABLE TO ROL_DESARROLLADOR_APP;
GRANT CREATE VIEW TO ROL_DESARROLLADOR_APP;
GRANT CREATE PROCEDURE TO ROL_DESARROLLADOR_APP;
GRANT CREATE SEQUENCE TO ROL_DESARROLLADOR_APP;
GRANT CREATE TRIGGER TO ROL_DESARROLLADOR_APP;

-- Grant al usuario de desarrollador
GRANT ROL_DESARROLLADOR_APP TO USRDESARROLADOR;


-- Rol DBA (Nota en Oracle Autonomous no puede hacer un DBA DBA como se conoce, se puede decir que es un Administrador de aplicacion)
CREATE ROLE ROL_DBA_APP;

GRANT CREATE SESSION TO ROL_DBA_APP;

-- Privilegios de administracion de objetos
GRANT CREATE TABLE TO ROL_DBA_APP;
GRANT CREATE VIEW TO ROL_DBA_APP;
GRANT CREATE PROCEDURE TO ROL_DBA_APP;
GRANT CREATE TRIGGER TO ROL_DBA_APP;
GRANT CREATE SEQUENCE TO ROL_DBA_APP;

-- Administracion sobre objetos
GRANT ALTER ANY TABLE TO ROL_DBA_APP;
GRANT DROP ANY TABLE TO ROL_DBA_APP;
GRANT ALTER ANY PROCEDURE TO ROL_DBA_APP;
GRANT DROP ANY PROCEDURE TO ROL_DBA_APP;
GRANT SELECT ANY TABLE TO ROL_DBA_APP;

-- Grant para usuario de DBA
GRANT ROL_DBA_APP TO USRDBA;

/********************************************************************************************************************************************************************/
-- 5. Crear Tablas

-- Script pruebas tablas de proyecto
CREATE TABLE dim_moneda (
    id_moneda NUMBER PRIMARY KEY,
    codigo_moneda NUMBER NOT NULL,
    nombre_moneda VARCHAR2(50) NOT NULL,
    simbolo VARCHAR2(10) NOT NULL
);

CREATE TABLE dim_estadoContrato (
    id_estadoContrato NUMBER PRIMARY KEY,
    codigo_estado VARCHAR2(20) NOT NULL,
    nombre_estado VARCHAR2(50) NOT NULL,
    activo NUMBER(1) DEFAULT 1,
    descripcion VARCHAR2(200)
);

CREATE TABLE dim_territorio (
    id_zona NUMBER PRIMARY KEY,
    provincia VARCHAR2(50) NOT NULL,
    ciudad VARCHAR2(50) NOT NULL,
    direccion VARCHAR2(150),
    codigoPostal VARCHAR2(20)
);

CREATE TABLE dim_sucursal (
    id_sucursal NUMBER PRIMARY KEY,
    nombreSucursal VARCHAR2(100) NOT NULL,
    telefono VARCHAR2(20),
    dim_territorio_id_zona NUMBER NOT NULL,
    CONSTRAINT fk_sucursal_territorio
        FOREIGN KEY (dim_territorio_id_zona)
        REFERENCES dim_territorio(id_zona)
);


CREATE TABLE dim_producto_financiero (
    id_producto_financiero NUMBER PRIMARY KEY,
    codigo_producto VARCHAR2(20) NOT NULL,
    subcategoria_producto VARCHAR2(100),
    plazo_min_meses NUMBER,
    plazo_max_meses NUMBER,
    devenga_interes NUMBER(1),
    tasa_referencia NUMBER(5,2),
    permite_movimiento NUMBER(1),
    estado_producto NUMBER(1),
    fecha_creacion_producto DATE,
    dim_moneda_id_moneda NUMBER NOT NULL,
    CONSTRAINT fk_producto_moneda
        FOREIGN KEY (dim_moneda_id_moneda)
        REFERENCES dim_moneda(id_moneda)
);


CREATE TABLE dim_cliente (
    id_cliente NUMBER PRIMARY KEY,
    nombre VARCHAR2(50) NOT NULL,
    apellido VARCHAR2(50) NOT NULL,
    telefono VARCHAR2(20),
    email VARCHAR2(100),
    dni VARCHAR2(20),
    numero_tarjeta_credito NUMBER,
    cuenta_bancaria NUMBER,
    fecha_nacimiento DATE,
    dim_sucursal_id_sucursal NUMBER NOT NULL,
    CONSTRAINT fk_cliente_sucursal
        FOREIGN KEY (dim_sucursal_id_sucursal)
        REFERENCES dim_sucursal(id_sucursal)
);


CREATE TABLE dim_empleado (
    id_empleado NUMBER PRIMARY KEY,
    nombreEmpleado VARCHAR2(50) NOT NULL,
    apellidoEmpleado VARCHAR2(50) NOT NULL,
    dim_sucursal_id_sucursal NUMBER NOT NULL,
    CONSTRAINT fk_empleado_sucursal
        FOREIGN KEY (dim_sucursal_id_sucursal)
        REFERENCES dim_sucursal(id_sucursal)
);


CREATE TABLE dim_interacciones (
    id_interaccion NUMBER PRIMARY KEY,
    codigo_canal VARCHAR2(20),
    nombre_canal VARCHAR2(50),
    tipo_canal VARCHAR2(50),
    descripcion_canal VARCHAR2(150),
    estado_canal NUMBER(1),
    dim_sucursal_id_sucursal NUMBER,
    CONSTRAINT fk_interaccion_sucursal
        FOREIGN KEY (dim_sucursal_id_sucursal)
        REFERENCES dim_sucursal(id_sucursal)
);


CREATE TABLE dim_tiempo (
    id_tiempo NUMBER PRIMARY KEY,
    fecha DATE NOT NULL,
    anio NUMBER(4),
    mes NUMBER(2),
    nombre_mes VARCHAR2(20),
    trimestre NUMBER(1),
    dia_semana VARCHAR2(20)
);

CREATE TABLE fact_producto_contrato (
    id_contrato NUMBER PRIMARY KEY,
    id_cliente NUMBER NOT NULL,
    id_producto_financiero NUMBER NOT NULL,
    id_canal NUMBER NOT NULL,
    id_fecha_contratacion NUMBER NOT NULL,
    id_moneda NUMBER NOT NULL,
    monto_contrato NUMBER(15,2),
    plazos_meses NUMBER,
    tasa_aplicada NUMBER(5,2),
    saldo_inicial NUMBER(15,2),
    dim_estadoContrato_id_estadoContrato NUMBER NOT NULL,

    CONSTRAINT fk_fact_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dim_cliente(id_cliente),

    CONSTRAINT fk_fact_producto
        FOREIGN KEY (id_producto_financiero)
        REFERENCES dim_producto_financiero(id_producto_financiero),

    CONSTRAINT fk_fact_canal
        FOREIGN KEY (id_canal)
        REFERENCES dim_interacciones(id_interaccion),

    CONSTRAINT fk_fact_tiempo
        FOREIGN KEY (id_fecha_contratacion)
        REFERENCES dim_tiempo(id_tiempo),

    CONSTRAINT fk_fact_moneda
        FOREIGN KEY (id_moneda)
        REFERENCES dim_moneda(id_moneda),

    CONSTRAINT fk_fact_estado
        FOREIGN KEY (dim_estadoContrato_id_estadoContrato)
        REFERENCES dim_estadoContrato(id_estadoContrato)
);

CREATE TABLE log_auditoria_sistema (
    id_auditoria NUMBER PRIMARY KEY,
    usuario_id VARCHAR2(50),
    fecha DATE,
    accionRealizada VARCHAR2(200)
);

/********************************************************************************************************************************************************************/
-- 6. Inserción Masiva

-- Script de los 60 registros para cada tabla
BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_moneda
    VALUES (
      i,
      100 + i,
      'Moneda_' || i,
      '$'
    );
  END LOOP;
END;
/
BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_estadoContrato
    VALUES (
      i,
      'EST' || i,
      'Estado_' || i,
      1,
      'Descripcion estado ' || i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_territorio
    VALUES (
      i,
      'Provincia_' || i,
      'Ciudad_' || i,
      'Direccion_' || i,
      'CP' || i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_sucursal
    VALUES (
      i,
      'Sucursal_' || i,
      '8888' || TO_CHAR(i,'FM0000'),
      i
    );
  END LOOP;
END;



/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_producto_financiero
    VALUES (
      i,
      'PROD' || i,
      'Categoria_' || i,
      12,
      60,
      1,
      ROUND(DBMS_RANDOM.VALUE(5,15),2),
      1,
      1,
      SYSDATE,
      i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_cliente
    VALUES (
      i,
      'Nombre_' || i,
      'Apellido_' || i,
      '7000' || TO_CHAR(i,'FM0000'),
      'cliente' || i || '@mail.com',
      'DNI' || i,
      4000000000000000 + i,
      1000000 + i,
      SYSDATE - (10000 + i),
      i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_empleado
    VALUES (
      i,
      'Empleado_' || i,
      'Apellido_' || i,
      i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_interacciones
    VALUES (
      i,
      'CAN' || i,
      'Canal_' || i,
      'Digital',
      'Descripcion canal ' || i,
      1,
      i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO dim_tiempo
    VALUES (
      i,
      SYSDATE - i,
      EXTRACT(YEAR FROM SYSDATE),
      EXTRACT(MONTH FROM SYSDATE),
      'Mes_' || i,
      1,
      'Lunes'
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO fact_producto_contrato
    VALUES (
      i,
      i,
      i,
      i,
      i,
      i,
      ROUND(DBMS_RANDOM.VALUE(1000,50000),2),
      24,
      ROUND(DBMS_RANDOM.VALUE(5,12),2),
      ROUND(DBMS_RANDOM.VALUE(1000,50000),2),
      i
    );
  END LOOP;
END;

/

BEGIN
  FOR i IN 1..60 LOOP
    INSERT INTO log_auditoria_sistema
    VALUES (
      i,
      'USER_' || i,
      SYSDATE,
      'Insercion registro ' || i
    );
  END LOOP;
END;

/

/********************************************************************************************************************************************************************/
-- 7. Creación de Índices

-- Índices para optimizar los JOINs )
CREATE INDEX FK_FACT_TIEMPO_I ON fact_producto_contrato(id_fecha_contratacion);
CREATE INDEX FK_FACT_CLIENTE_I ON fact_producto_contrato(id_cliente);
CREATE INDEX FK_FACT_PRODUCTO_I ON fact_producto_contrato(id_producto_financiero);
CREATE INDEX FK_FACT_MONEDA_I ON fact_producto_contrato(id_moneda);
CREATE INDEX FK_FACT_ESTADO_I ON fact_producto_contrato(dim_estadoContrato_id_estadoContrato);
CREATE INDEX FK_FACT_CANAL_I ON fact_producto_contrato(id_canal);

-- Optimización para reportes de ventas por periodo y producto
CREATE INDEX IDX_FACT_TIEMPO_PROD ON fact_producto_contrato(id_fecha_contratacion, id_producto_financiero);

-- Optimización para análisis de morosidad (Estado + Monto)
CREATE INDEX IDX_FACT_ESTADO_MONTO ON fact_producto_contrato(dim_estadoContrato_id_estadoContrato, monto_contrato);

-- Búsqueda rápida de clientes por DNI (Unicidad y rapidez)
CREATE UNIQUE INDEX IDX_DIM_CLIENTE_DNI ON dim_cliente(dni);

-- Búsqueda de empleados por apellido
CREATE INDEX IDX_DIM_EMPLEADO_APELLIDO ON dim_empleado(apellidoEmpleado);
