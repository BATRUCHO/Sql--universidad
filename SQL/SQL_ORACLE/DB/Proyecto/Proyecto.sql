--Proyecto SQL para la gestión de una clínica veterinaria

-- Creación de usuarios con cuotas
-- Limpieza (opcional por si quieres re-ejecutar)
DROP USER TABLAS_CLIENTES CASCADE;
DROP USER TABLAS_MASCOTAS CASCADE;
DROP USER TABLAS_FACTURACION CASCADE;

CREATE USER TABLAS_CLIENTES IDENTIFIED BY "palabraPaso2026" DEFAULT TABLESPACE DATA QUOTA UNLIMITED ON DATA; --- usuario para el módulo de clientes
CREATE USER TABLAS_MASCOTAS IDENTIFIED BY "palabraPaso2026" DEFAULT TABLESPACE DATA QUOTA UNLIMITED ON DATA;
CREATE USER TABLAS_FACTURACION IDENTIFIED BY "palabraPaso2026" DEFAULT TABLESPACE DATA QUOTA UNLIMITED ON DATA;

GRANT CONNECT, RESOURCE, CREATE SESSION, CREATE TABLE TO TABLAS_CLIENTES, TABLAS_MASCOTAS, TABLAS_FACTURACION;



-- --- MÓDULO CLIENTES ---
CREATE TABLE TABLAS_CLIENTES.tipo_cliente (
    idTipoCliente NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion   VARCHAR2(50) NOT NULL
);

CREATE TABLE TABLAS_CLIENTES.cliente (
    idCliente     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR2(50) NOT NULL,
    apellido      VARCHAR2(50) NOT NULL,
    fechaRegistro DATE DEFAULT SYSDATE,
    idTipoCliente NUMBER NOT NULL,
    CONSTRAINT fk1_cliente FOREIGN KEY (idTipoCliente) REFERENCES TABLAS_CLIENTES.tipo_cliente(idTipoCliente)
);

-- Permisos para que otros vean a los clientes
GRANT SELECT, REFERENCES ON TABLAS_CLIENTES.cliente TO TABLAS_MASCOTAS;
GRANT SELECT, REFERENCES ON TABLAS_CLIENTES.cliente TO TABLAS_FACTURACION;

-- --- MÓDULO MASCOTAS ---
CREATE TABLE TABLAS_MASCOTAS.especie (
    idEspecie NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre    VARCHAR2(50) NOT NULL
);

CREATE TABLE TABLAS_MASCOTAS.raza (
    idRaza    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre    VARCHAR2(50) NOT NULL,
    idEspecie NUMBER NOT NULL,
    CONSTRAINT fk1_raza FOREIGN KEY (idEspecie) REFERENCES TABLAS_MASCOTAS.especie(idEspecie)
);

CREATE TABLE TABLAS_MASCOTAS.mascota (
    idMascota       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre          VARCHAR2(50) NOT NULL,
    fechaNacimiento DATE,
    idCliente       NUMBER NOT NULL,
    idRaza          NUMBER NOT NULL,
    CONSTRAINT fk1_mascota FOREIGN KEY (idCliente) REFERENCES TABLAS_CLIENTES.cliente(idCliente),
    CONSTRAINT fk2_mascota FOREIGN KEY (idRaza) REFERENCES TABLAS_MASCOTAS.raza(idRaza)
);

GRANT SELECT, REFERENCES ON TABLAS_MASCOTAS.mascota TO TABLAS_FACTURACION;

-- --- MÓDULO FACTURACIÓN ---
CREATE TABLE TABLAS_FACTURACION.servicio (
    idServicio  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    descripcion VARCHAR2(50) NOT NULL,
    costo       NUMBER(10,2) CHECK (costo >= 0)
);

CREATE TABLE TABLAS_FACTURACION.factura (
    idFactura NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha     DATE DEFAULT SYSDATE,
    idCliente NUMBER NOT NULL,
    CONSTRAINT fk1_factura FOREIGN KEY (idCliente) REFERENCES TABLAS_CLIENTES.cliente(idCliente)
);

CREATE TABLE TABLAS_FACTURACION.detalle_factura (
    idDetalle  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idFactura  NUMBER NOT NULL,
    idServicio NUMBER NOT NULL,
    CONSTRAINT fk1_detalle FOREIGN KEY (idFactura) REFERENCES TABLAS_FACTURACION.factura(idFactura),
    CONSTRAINT fk2_detalle FOREIGN KEY (idServicio) REFERENCES TABLAS_FACTURACION.servicio(idServicio)
);

--USUARIO DESARROLLADOR y ROL DESAROLLADOR

-- Crear Usuario Desarrollador --

CREATE USER desa10
IDENTIFIED BY palabraPaso2026
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP;

-- Crear Rol Desarrollador --
CREATE ROLE roldesaProy;

-- Otorgamos Permisos a el Rol Desarrollador --
GRANT CREATE SESSION TO roldesaProy;
GRANT CREATE PROCEDURE TO roldesaProy;
GRANT CREATE SEQUENCE TO roldesaProy;
GRANT CREATE ROLE TO roldesaProy;

GRANT roldesaProy TO desa10;

----------------------------------------------------------
--Ha este punto todo iba bien con los avances, ahora lo siguiente es las instrucciones del comap;ero con sus comandos, podemo
----------------------------------------------------------



-- Crear Usuario para el Proyecto --
GRANT CREATE SESSION TO ROLUFPROY;

--Usuario final
CREATE USER UFPROY01
IDENTIFIED BY palabraPaso2026
DEFAULT TABLESPACE DATA
TEMPORARY TABLESPACE TEMP
QUOTA 0 ON DATA;

-- Se otorga rol a usuario final
GRANT ROLUFPROY TO UFPROY01;

CREATE ROLE ROLUFPROY;
GRANT CREATE SESSION TO ROLUFPROY;

GRANT ROLUFPROY TO UFPROY01;

GRANT ROLUFPROY TO desa10 WITH ADMIN OPTION;

-- Permisos para la tabla de CLIENTES
GRANT SELECT, INSERT ON TABLAS_CLIENTES.CLIENTE TO UFPROY01;

-- Permisos para las tablas de MASCOTAS
GRANT SELECT, INSERT ON TABLAS_MASCOTAS.MASCOTA TO UFPROY01;
GRANT SELECT ON TABLAS_MASCOTAS.RAZA TO UFPROY01; -- Generalmente solo lectura

-- Permisos para las tablas de FACTURACIÓN
GRANT SELECT, INSERT ON TABLAS_FACTURACION.FACTURA TO UFPROY01;
GRANT SELECT, INSERT ON TABLAS_FACTURACION.DETALLE_FACTURA TO UFPROY01; -- ¡Importante!
GRANT SELECT ON TABLAS_FACTURACION.SERVICIO TO UFPROY01; -- Lectura para ver precios


-------------------------------------------------------------------------
-------------------------------------------------------------------------




SELECT username, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username LIKE 'TABLAS%';

SELECT *
FROM dba_ts_quotas
WHERE username LIKE 'TABLAS%';

SELECT *
FROM dba_sys_privs
WHERE grantee LIKE 'TABLAS%';

 
select owner, object_name, object_type
from dba_objects
where owner like 'TABLAS%'
order by 1,3,2;

 
select *
from dba_tab_privs
where grantee like 'TABLAS%';

--- Revisión de Usuario Desarrollador

select username, default_tablespace, temporary_tablespace
from dba_users
where username like 'TABLAS%'
   or username = 'DESA10';
 
select  *
from dba_ts_quotas
where username like 'TABLAS%'
   or username = 'DESA10';
 
 
-- Revisa privilegios de sistema
select *
from dba_sys_privs
where grantee like 'TABLAS%'
   or grantee = 'DESA10'
   or grantee = 'ROLDESAPROY'
order by 1;
 
 
-- Revisar objetos
select owner, object_name, object_type
from dba_objects
where owner like 'TABLAS%'
   or owner = 'DESA10'
order by 1,3,2;
 
-- Revisa privilegios sobre objetos
select *
from dba_tab_privs
where grantee like 'TABLAS%'
   or grantee = 'DESA10';
 
-- Revisa roles
select *
from dba_roles
where role like 'ROLDESAPROY';
 
-- Revisar asignación de roles
select *
from dba_role_privs
where granted_role like 'ROLDESAPROY%'
order by 2;
 
---------------------------------------------


-- Revisa usuarios
select username, default_tablespace, temporary_tablespace
from dba_users
where username like 'TABLAS%'
   or username = 'DESA01'
   or username = 'UF01'
order by 1;

select  *
from dba_ts_quotas
where username like 'TABLAS%'
   or username = 'DESA01'
   or username = 'UF01'
order by 1;


-- Revisa privilegios de sistema
select *
from dba_sys_privs
where grantee like 'TABLAS%'
   or grantee = 'DESA01'
   or grantee = 'ROLDESA'
   or grantee = 'UF01'
   or grantee = 'ROLAP01'
   or grantee = 'ROLUF'
order by 1;


-- Revisar objetos
select owner, object_name, object_type
from dba_objects
where owner like 'TABLAS%'
   or owner = 'DESA01'
   or owner = 'UF01'
order by 1,3,2;

-- Revisa privilegios sobre objetos
select *
from dba_tab_privs
where grantee like 'TABLAS%'
   or grantee = 'DESA01'
   or grantee = 'UF01'
   or grantee = 'ROLAP01'
order by 1;

-- Revisa roles
--REVISAR

select *
from dba_roles
where role like 'ROLDES%'
   or role like 'ROLAP%'
   or role like 'ROLUF%'
order by 1;

-- Revisar asignación de roles
select *
from dba_role_privs
where granted_role like 'ROLDES%'
   or granted_role like 'ROLAP%'
   or granted_role like 'ROLUF%'
order by 2;

