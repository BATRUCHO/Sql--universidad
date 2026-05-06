--- ============================================================
-- 1 - MODULO CLIENTES
-- Conectar como tablas cliente

CREATE TABLE tipo_cliente (
  idTipoCliente NUMBER CONSTRAINT pk_tipo_cliente PRIMARY KEY,
  descripcion   VARCHAR2(50)
);

CREATE TABLE cliente (
  idCliente     NUMBER CONSTRAINT pk_cliente PRIMARY KEY,
  nombre        VARCHAR2(50),
  apellido      VARCHAR2(50),
  fechaRegistro DATE,
  idTipoCliente CONSTRAINT fk1_cliente
    REFERENCES tipo_cliente
);

CREATE TABLE direccion (
  idDireccion NUMBER CONSTRAINT pk_direccion PRIMARY KEY,
  detalle     VARCHAR2(100),
  idCliente   CONSTRAINT fk1_direccion
    REFERENCES cliente
);

CREATE TABLE telefono (
  idTelefono NUMBER CONSTRAINT pk_telefono PRIMARY KEY,
  numero     VARCHAR2(20),
  idCliente  CONSTRAINT fk1_telefono
    REFERENCES cliente
);

CREATE TABLE correo (
  idCorreo  NUMBER CONSTRAINT pk_correo PRIMARY KEY,
  correo    VARCHAR2(100),
  idCliente CONSTRAINT fk1_correo
    REFERENCES cliente
);


-- Permiso REFERENCES para que los otros esquemas puedan apuntar a cliente
GRANT REFERENCES ON cliente TO TABLAS_MASCOTAS;
GRANT REFERENCES ON cliente TO TABLAS_FACTURACION;



-- ============================================================
-- 2 - MODULO Mascotas
-- conectar como tablas mascota


CREATE TABLE especie (
  idEspecie NUMBER CONSTRAINT pk_especie PRIMARY KEY,
  nombre    VARCHAR2(50)
);

CREATE TABLE raza (
  idRaza    NUMBER CONSTRAINT pk_raza PRIMARY KEY,
  nombre    VARCHAR2(50),
  idEspecie CONSTRAINT fk1_raza
    REFERENCES especie
);

CREATE TABLE mascota (
  idMascota       NUMBER CONSTRAINT pk_mascota PRIMARY KEY,
  nombre          VARCHAR2(50),
  fechaNacimiento DATE,
  idCliente       CONSTRAINT fk1_mascota
    REFERENCES TABLAS_CLIENTES.cliente,
  idRaza          CONSTRAINT fk2_mascota
    REFERENCES raza
);

CREATE TABLE historial_medico (
  idHistorial NUMBER CONSTRAINT pk_historial PRIMARY KEY,
  descripcion VARCHAR2(200),
  fecha       DATE,
  idMascota   CONSTRAINT fk1_historial
    REFERENCES mascota
);


-- Permiso REFERENCES para que TABLAS_FACTURACION pueda apuntar a mascota
GRANT REFERENCES ON mascota TO TABLAS_FACTURACION;

-- Permisos SELECT para los procedures que consultan mascota desde otros esquemas
GRANT SELECT ON mascota TO TABLAS_CLIENTES;
GRANT SELECT ON mascota TO TABLAS_FACTURACION;


CREATE OR REPLACE VIEW v_mascota_cliente AS
SELECT idMascota, idCliente
FROM mascota;

-- Damos acceso a la vista a TABLAS_FACTURACION
GRANT SELECT ON v_mascota_cliente TO TABLAS_FACTURACION;


--- Confirmamos vista
SELECT view_name
FROM user_views
WHERE view_name = 'V_MASCOTA_CLIENTE';
-- ============================================================
-- 2 - MODULO FACTURACION
-- conectar como tablas facturacion

CREATE TABLE veterinario (
  idVeterinario NUMBER CONSTRAINT pk_veterinario PRIMARY KEY,
  nombre        VARCHAR2(50),
  especialidad  VARCHAR2(50)
);

CREATE TABLE servicio (
  idServicio  NUMBER CONSTRAINT pk_servicio PRIMARY KEY,
  descripcion VARCHAR2(50),
  costo       NUMBER(8,2)
);

CREATE TABLE cita (
  idCita        NUMBER CONSTRAINT pk_cita PRIMARY KEY,
  fecha         DATE,
  idMascota     CONSTRAINT fk1_cita
    REFERENCES TABLAS_MASCOTAS.mascota,
  idVeterinario CONSTRAINT fk2_cita
    REFERENCES veterinario,
  idServicio    CONSTRAINT fk3_cita
    REFERENCES servicio
);

CREATE TABLE factura (
  idFactura NUMBER CONSTRAINT pk_factura PRIMARY KEY,
  fecha     DATE,
  idCliente CONSTRAINT fk1_factura
    REFERENCES TABLAS_CLIENTES.cliente
);

CREATE TABLE detalle_factura (
  idDetalle NUMBER CONSTRAINT pk_detalle PRIMARY KEY,
  idFactura CONSTRAINT fk1_detalle
    REFERENCES factura,
  idServicio CONSTRAINT fk2_detalle
    REFERENCES servicio
);


-- ============================================================
--- Conectarce como admin


-- Permisos cruzados requeridos por los procedures que veremos mas adelante
GRANT SELECT, INSERT ON TABLAS_FACTURACION.cita TO TABLAS_CLIENTES;
GRANT SELECT, INSERT ON TABLAS_FACTURACION.factura TO TABLAS_FACTURACION; 

GRANT SELECT ON TABLAS_CLIENTES.cliente  TO TABLAS_MASCOTAS;
GRANT SELECT ON TABLAS_CLIENTES.cliente  TO TABLAS_FACTURACION;
GRANT SELECT ON TABLAS_MASCOTAS.mascota  TO TABLAS_FACTURACION;


-- 2. Permisos sobre para el usuario de Desarrollador y cliente final

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLAS_CLIENTES.cliente TO DESA10;
GRANT SELECT, INSERT                 ON TABLAS_CLIENTES.cliente TO UFPROY01;

GRANT SELECT, INSERT ON TABLAS_CLIENTES.bitacora_clientes TO DESA10;  --
GRANT SELECT, INSERT ON TABLAS_CLIENTES.bitacora_clientes TO UFPROY01; --

GRANT SELECT, INSERT ON TABLAS_MASCOTAS.mascota    TO UFPROY01;
GRANT SELECT, INSERT ON TABLAS_FACTURACION.factura TO UFPROY01;

-- 3. Permisos sobre las tablas del modulo facturacion

GRANT SELECT         ON TABLAS_FACTURACION.servicio    TO DESA10;
GRANT SELECT         ON TABLAS_FACTURACION.veterinario TO DESA10;
GRANT SELECT, INSERT ON TABLAS_FACTURACION.cita        TO DESA10;


GRANT SELECT ON TABLAS_CLIENTES.cliente TO DESA10;
GRANT SELECT ON TABLAS_MASCOTAS.mascota TO DESA10;



