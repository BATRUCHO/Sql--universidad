
-- Seccion con la que se tiene que iniciar es: DW_BANCO_NOVA


GRANT SELECT ON DW_BANCO_NOVA.fact_producto_contrato TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.dim_cliente TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.dim_sucursal TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.dim_territorio TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.dim_estadoContrato TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.dim_interacciones TO ROL_CONSULTA_APP;
GRANT SELECT ON DW_BANCO_NOVA.VW_CLIENTE_SEGURA TO ROL_CONSULTA_APP;


-- Ejecutar como DW_BANCO_NOVA
GRANT SELECT ON dim_cliente TO USRCONSULTA;
GRANT SELECT ON fact_producto_contrato TO USRCONSULTA;
GRANT SELECT ON dim_sucursal TO USRCONSULTA;
GRANT SELECT ON VW_CLIENTE_SEGURA TO USRCONSULTA;

/********************************************************************************************************************************************************************/
-- 1. Crear Tablas

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
-- 2. Inserción Masiva

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

-- 4. Creación de Vistas

/*
1. SECUENCIA PARA LA TABLA DE AUDITORIAS
Este se utiliza para generar ids automaticos en log_auditoria_sistema
*/

CREATE SEQUENCE seq_log_auditoria
START WITH 1000
INCREMENT BY 1
NOCACHE
NOCYCLE;

/*
1. STORED PROCEDURE: Insertar contractos con validaciones
*/

CREATE OR REPLACE PROCEDURE insertar_contracto (
    -- Parametros para el stored procedure
    p_id_contrato                IN NUMBER,
    p_id_cliente                 IN NUMBER,
    p_id_producto_financiero     IN NUMBER,
    p_id_canal                   IN NUMBER,
    p_id_fecha_contratacion      IN NUMBER,
    p_id_moneda                  IN NUMBER,
    p_monto_contrato             IN NUMBER,
    p_plazos_meses               IN NUMBER,
    p_tasa_aplicada              IN NUMBER,
    p_saldo_inicial              IN NUMBER,
    p_id_estado_contrato         IN NUMBER
)
IS
   -- Contador
   v_cuenta NUMBER;
BEGIN
    -- Validacion que el contrato no tenga ya existencia
    SELECT COUNT(*)
      INTO v_cuenta
      FROM fact_producto_contrato
    WHERE id_contrato = p_id_contrato;
    
    -- If Para validar si, si existe y mostrar en consola que ya existe el contrato con ese ID
    IF v_cuenta > 0 THEN 
       RAISE_APPLICATION_ERROR(-20010, 'Ya hay un contrato con este ID');
    END IF;
    
    
    -- Validacion de existencia de cliente
    SELECT COUNT(*)
       INTO v_cuenta
       FROM dim_cliente
    WHERE id_cliente = p_id_cliente;
    
    -- If para validara si existe el cliente
    IF v_cuenta = 0 THEN
       RAISE_APPLICATION_ERROR(-20011,'No existe un cliente con este ID');
    END IF;
    
    -- Validacion de existencia de producto financiero
    SELECT COUNT(*)
       INTO v_cuenta 
       FROM dim_producto_financiero
    WHERE id_producto_financiero = p_id_producto_financiero;
    
    -- If que valida si existe el producto financiero
    IF v_cuenta = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'El producto financiero indicado no existe');
    END IF;
    
    -- Validacion de la existencia del canal
    SELECT COUNT(*)
      INTO v_cuenta
      FROM dim_interacciones
    WHERE id_interaccion = p_id_canal;
    
    -- If que valida si existe el canal
    IF v_cuenta = 0 THEN
        RAISE_APPLICATION_ERROR(-20013, 'El canal de interacción indicado no existe');
    END IF;
    
    -- Validacion de la existe de la fecha en dimension tiempo
    SELECT COUNT(*)
      INTO v_cuenta
      FROM dim_tiempo
     WHERE id_tiempo = p_id_fecha_contratacion;
    
    -- If que valida si existe la fecha en dimension tiempo
    IF v_cuenta = 0 THEN
        RAISE_APPLICATION_ERROR(-20014, 'La fecha de contratación indicada no existe en dim_tiempo.');
    END IF;
    
    
    --Validar si existe la moneda indicada
    SELECT COUNT(*)
      INTO v_cuenta
      FROM dim_moneda
     WHERE id_moneda = p_id_moneda;
     
     -- If que valida la existencia de la moneda
     IF v_cuenta = 0 THEN
        RAISE_APPLICATION_ERROR(-20015, 'La moneda indicada no existe.');
    END IF;
    
    -- Validacion de la existencia del estado de contrato
    SELECT COUNT(*)
      INTO v_cuenta
      FROM dim_estadoContrato
     WHERE id_estadoContrato = p_id_estado_contrato;
     
     -- IF que valida la existencia del estado del contrato
     IF v_cuenta = 0 THEN
        RAISE_APPLICATION_ERROR(-20016, 'El estado de contrato indicado no existe.');
    END IF;

    /*
    VALIDACIONES DEL BANCO
    */
    
    -- Validacion que el monto del contracto sea mayor a 0 
    IF p_monto_contrato IS NULL OR p_monto_contrato <= 0 THEN
        RAISE_APPLICATION_ERROR(-20017, 'El monto del contrato debe ser mayor a 0.');
    END IF;
    
    -- Validacion que el plazo en meses sea mayor a 0
    IF p_plazos_meses IS NULL OR p_plazos_meses <= 0 THEN
        RAISE_APPLICATION_ERROR(-20018, 'El plazo en meses debe ser mayor a 0.');
    END IF;
    
    -- Validacion que la tasa que se aplique no sea negativa
    IF p_tasa_aplicada IS NULL OR p_tasa_aplicada < 0 THEN
        RAISE_APPLICATION_ERROR(-20019, 'La tasa aplicada no puede ser negativa.');
    END IF;
    
    -- Validacion que el saldo inicial no sea negativo
    IF p_saldo_inicial IS NULL OR p_saldo_inicial < 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'El saldo inicial no puede ser negativo.');
    END IF;
    
    
    /*
    DESPUES DE VALIDAR LOS DATOS QUE SE VAN A INGRESAR, SE INSERTA EL NUEVO CONTRACTO
    */
    INSERT INTO fact_producto_contrato (
        id_contrato,
        id_cliente,
        id_producto_financiero,
        id_canal,
        id_fecha_contratacion,
        id_moneda,
        monto_contrato,
        plazos_meses,
        tasa_aplicada,
        saldo_inicial,
        dim_estadoContrato_id_estadoContrato
    )
    VALUES (
        p_id_contrato,
        p_id_cliente,
        p_id_producto_financiero,
        p_id_canal,
        p_id_fecha_contratacion,
        p_id_moneda,
        p_monto_contrato,
        p_plazos_meses,
        p_tasa_aplicada,
        p_saldo_inicial,
        p_id_estado_contrato
    );
    
    -- Guardar los cambios
    COMMIT;
    
    -- Catch de exeptions o errores que puedan dar
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
SHOW ERRORS;

    
/********************************************************************************************************************************************************************/

-- 5. Creación de Triggers
    
/*
3. TRIGGER DE AUDITORIA
Registra de manera automatica cambiso sobre el monto_contracto
*/

CREATE OR REPLACE TRIGGER trg_auditar_cambio_monto_contrato
BEFORE UPDATE OF monto_contrato
ON fact_producto_contrato
FOR EACH ROW
BEGIN
   IF NVL(:OLD.monto_contrato, 0) <> NVL(:NEW.monto_contrato, 0) THEN
       INSERT INTO log_auditoria_sistema (
            id_auditoria,
            usuario_id,
            fecha,
            accionRealizada
        )
        VALUES (
            seq_log_auditoria.NEXTVAL,
            USER,
            SYSDATE,
            'Se actualizo el monto_contrato en fact_producto_contrato. ID_CONTRATO='
            || :OLD.id_contrato
            || ', monto_anterior=' || :OLD.monto_contrato
            || ', monto_nuevo=' || :NEW.monto_contrato
        );
    END IF;
END;
/
SHOW ERRORS;

/********************************************************************************************************************************************************************/

-- 6. Creación de Funciones DE VISTAS



--Vista  1 de morosidad
CREATE OR REPLACE VIEW vw_morosidad
as 
select 
    ec.nombre_estado,
    SUM(f.monto_contrato) as total_monto,
    count(f.id_contrato) as cantidad_contratos
from fact_producto_contrato f 
inner join dim_estadoContrato ec
on f.dim_estadoContrato_id_estadoContrato = ec.id_estadoContrato
group by ec.nombre_estado;



--Vista 2 de rendimiento
CREATE OR REPLACE VIEW vw_rendimiento_sucursal
as
select
    t.provincia, s.nombreSucursal,
    SUM(f.monto_contrato) as total_monto
from fact_producto_contrato f inner join dim_cliente c
on f.id_cliente = c.id_cliente inner join dim_sucursal s
on c.dim_sucursal_id_sucursal = s.id_sucursal
inner join dim_territorio t on s.dim_territorio_id_zona = t.id_zona
group by t.provincia, s.nombreSucursal;

--Vista 3 de clientes VIP
CREATE OR REPLACE VIEW vw_clientes_vip
as 
select
    c.id_cliente, c.nombre, c.apellido,
    SUM(f.monto_contrato) as total_contratos
from fact_producto_contrato f inner join dim_cliente c
on f.id_cliente = c.id_cliente
group by c.id_cliente, c.nombre, c.apellido
having SUM(f.monto_contrato) >(select avg(monto_contrato)
from fact_producto_contrato);


/********************************************************************************************************************************************************************/

-- 7. Indices  

-- Índices para optimizar los JOINs 
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

