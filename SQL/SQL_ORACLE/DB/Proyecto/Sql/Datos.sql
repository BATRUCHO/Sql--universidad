--- ============================================================
--Conectarse como: TABLAS_CLIENTES

-- Catalogo de tipos de cliente
INSERT INTO tipo_cliente VALUES (1, 'Particular');
INSERT INTO tipo_cliente VALUES (2, 'Empresa');

-- Clientes de ejemplo
INSERT INTO cliente VALUES (1, 'Juan',   'Perez',     TO_DATE('2023-01-15','YYYY-MM-DD'), 1);
INSERT INTO cliente VALUES (2, 'Maria',  'Gonzalez',  TO_DATE('2023-02-20','YYYY-MM-DD'), 2);
INSERT INTO cliente VALUES (3, 'Carlos', 'Rodriguez', TO_DATE('2023-03-10','YYYY-MM-DD'), 1);
INSERT INTO cliente VALUES (4, 'Ana',    'Jimenez',   TO_DATE('2023-04-05','YYYY-MM-DD'), 2);
INSERT INTO cliente VALUES (5, 'Luis',   'Mora',      TO_DATE('2023-05-18','YYYY-MM-DD'), 1);

-- Datos de contacto de algunos clientes (mostrando la relacion 1 a N)
INSERT INTO direccion VALUES (1, 'San Jose, Sabanilla',    1);
INSERT INTO direccion VALUES (2, 'Heredia, San Francisco', 2);
INSERT INTO direccion VALUES (3, 'Cartago, Oreamuno',      3);

INSERT INTO telefono VALUES (1, '8888-1111', 1);
INSERT INTO telefono VALUES (2, '8888-2222', 2);
INSERT INTO telefono VALUES (3, '8888-3333', 3);

INSERT INTO correo VALUES (1, 'juan.perez@correo.com',     1);
INSERT INTO correo VALUES (2, 'maria.gonzalez@correo.com', 2);

-- Peticiones de cita: cubren los 4 escenarios de prueba del procedure
-- P1 y P2 son casos validos (deberian aprobar al procesarse)
-- P3 tiene un cliente inexistente (debe rechazar)
-- P4 tiene una mascota que no pertenece al cliente (debe rechazar)
INSERT INTO peticion_cita (idCliente, idMascota, fecha1, estado)
VALUES (1, 1, TO_DATE('2026-05-04','YYYY-MM-DD'), 'PENDIENTE');

INSERT INTO peticion_cita (idCliente, idMascota, fecha1, estado)
VALUES (2, 3, TO_DATE('2026-05-05','YYYY-MM-DD'), 'PENDIENTE');

INSERT INTO peticion_cita (idCliente, idMascota, fecha1, estado)
VALUES (99, 1, TO_DATE('2026-05-06','YYYY-MM-DD'), 'PENDIENTE');

INSERT INTO peticion_cita (idCliente, idMascota, fecha1, estado)
VALUES (4, 1, TO_DATE('2026-05-07','YYYY-MM-DD'), 'PENDIENTE');

COMMIT;


--- ============================================================
--Conectarse como: TABLAS_Mascotas

-- Catalogo de especies
INSERT INTO especie VALUES (1, 'Perro');
INSERT INTO especie VALUES (2, 'Gato');
INSERT INTO especie VALUES (3, 'Conejo');

-- Catalogo de razas (cada raza pertenece a una especie)
INSERT INTO raza VALUES (1, 'Labrador', 1);
INSERT INTO raza VALUES (2, 'Pastor',   1);
INSERT INTO raza VALUES (3, 'Persa',    2);
INSERT INTO raza VALUES (4, 'Siames',   2);
INSERT INTO raza VALUES (5, 'Holandes', 3);

-- Mascotas asociadas a los clientes
-- (El 4to parametro es el idCliente, el 5to es el idRaza)
INSERT INTO mascota VALUES (1, 'Rocky',  TO_DATE('2020-05-10','YYYY-MM-DD'), 1, 1);
INSERT INTO mascota VALUES (2, 'Luna',   TO_DATE('2021-08-22','YYYY-MM-DD'), 1, 3);
INSERT INTO mascota VALUES (3, 'Michi',  TO_DATE('2019-03-14','YYYY-MM-DD'), 2, 4);
INSERT INTO mascota VALUES (4, 'Toby',   TO_DATE('2022-01-30','YYYY-MM-DD'), 3, 2);
INSERT INTO mascota VALUES (5, 'Nala',   TO_DATE('2020-11-11','YYYY-MM-DD'), 3, 3);
INSERT INTO mascota VALUES (6, 'Copito', TO_DATE('2023-06-07','YYYY-MM-DD'), 5, 5);

COMMIT;

--- ============================================================

--Conectarse como: TABLAS_Facturacion

-- Planilla de veterinarios
INSERT INTO veterinario VALUES (1, 'Dra. Carmen Solis',  'General');
INSERT INTO veterinario VALUES (2, 'Dr.  Javier Umana',  'Cirugia');
INSERT INTO veterinario VALUES (3, 'Dra. Lucia Vargas',  'Dermatologia');

-- Catalogo de servicios (con sus precios en colones)
INSERT INTO servicio VALUES (1, 'Consulta general', 15000);
INSERT INTO servicio VALUES (2, 'Cirugia menor',    45000);
INSERT INTO servicio VALUES (3, 'Limpieza dental',  25000);
INSERT INTO servicio VALUES (4, 'Control de peso',  10000);

COMMIT;



--- ============================================================
-- Validaciones


SELECT * FROM veterinario ORDER BY idVeterinario;
SELECT * FROM servicio    ORDER BY idServicio;

-- Revisamos que los datos quedaron cargados correctamente
SELECT * FROM cliente       ORDER BY idCliente;
SELECT * FROM peticion_cita ORDER BY idPeticion;