--- ============================================================
-- Conectar como tablas cliente

-- 1 Creacion de regla clientes

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE peticion_cita CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE peticion_cita (
  idPeticion NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  idCliente  NUMBER,
  idMascota  NUMBER,
  fecha1     DATE,
  estado     VARCHAR2(20),
  motivo     VARCHAR2(100)
);

-- 2. Permisos sobre la tabla para DESA10 y la aplicacion
GRANT SELECT, INSERT, UPDATE ON peticion_cita TO UFPROY01;
GRANT SELECT, INSERT, UPDATE ON peticion_cita TO DESA10;


-- 3. Procedure que procesa una peticion de cita aplicando las reglas
--    de negocio. Recibe el ID de la peticion a procesar.

CREATE OR REPLACE PROCEDURE procesar_peticion_cita(p_id NUMBER) AS

  v_count NUMBER;

BEGIN

  -- Validacion 1 y 2 combinadas: verificamos que exista la mascota
  -- de la peticion Y que esa mascota pertenezca al cliente indicado.
  -- Si alguna de las dos cosas falla, el JOIN no devuelve filas.
 -- Dentro de procesar_peticion_cita
  SELECT COUNT(*) INTO v_count
  FROM TABLAS_MASCOTAS.mascota m -- Asegúrate de tener el permiso directo
  JOIN TABLAS_CLIENTES.cliente c ON m.idCliente = c.idCliente
  WHERE m.idMascota = (SELECT idMascota FROM peticion_cita WHERE idPeticion = p_id)
    AND c.idCliente = (SELECT idCliente FROM peticion_cita WHERE idPeticion = p_id);

  IF v_count = 0 THEN
    UPDATE peticion_cita
    SET estado = 'RECHAZADO',
        motivo = 'Cliente o mascota no existen'
    WHERE idPeticion = p_id;
    RETURN;
  END IF;

  -- Validacion 3: disponibilidad. La clinica atiende maximo 2 citas
  -- por dia; si ya hay 2 o mas programadas en la fecha solicitada,
  -- se rechaza la peticion.
  SELECT COUNT(*) INTO v_count
  FROM TABLAS_FACTURACION.cita
  WHERE fecha = (SELECT fecha1 FROM peticion_cita WHERE idPeticion = p_id);

  IF v_count >= 2 THEN
    UPDATE peticion_cita
    SET estado = 'RECHAZADO',
        motivo = 'No hay disponibilidad'
    WHERE idPeticion = p_id;
    RETURN;
  END IF;

  -- Si pasamos todas las validaciones, insertamos la cita en el
  -- modulo de facturacion. Asignamos veterinario 1 y servicio 1
  -- como valores por defecto.
  INSERT INTO TABLAS_FACTURACION.cita (idCita, fecha, idMascota, idVeterinario, idServicio)
  VALUES (
    (SELECT NVL(MAX(idCita),0)+1 FROM TABLAS_FACTURACION.cita),
    (SELECT fecha1    FROM peticion_cita WHERE idPeticion = p_id),
    (SELECT idMascota FROM peticion_cita WHERE idPeticion = p_id),
    1,
    1
  );

  -- Marcamos la peticion como aprobada
  UPDATE peticion_cita
  SET estado = 'APROBADO'
  WHERE idPeticion = p_id;

END;
/


-- 4. Permisos de ejecucion del procedure
GRANT EXECUTE ON procesar_peticion_cita TO UFPROY01;
GRANT EXECUTE ON procesar_peticion_cita TO DESA10;




--- ============================================================

-- Conectar como tablas Facturacion


CREATE OR REPLACE PROCEDURE facturar_cliente(p_idCliente NUMBER) AS

  v_count NUMBER;

BEGIN

  -- Contamos las citas del cliente usando la vista del modulo mascotas
  SELECT COUNT(*) INTO v_count
  FROM cita
  WHERE idMascota IN (
    SELECT idMascota
    FROM TABLAS_MASCOTAS.v_mascota_cliente
    WHERE idCliente = p_idCliente
  );

  -- Si no tiene ninguna cita, no se puede facturar
  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'No hay citas para facturar');
  END IF;

  -- Caso exitoso: se crea la factura
  INSERT INTO factura (idFactura, fecha, idCliente)
  VALUES (
    (SELECT NVL(MAX(idFactura), 0) + 1 FROM factura),
    SYSDATE,
    p_idCliente
  );

END;
/

-- Permisos de ejecucion del procedure
GRANT EXECUTE ON facturar_cliente TO UFPROY01;
GRANT EXECUTE ON facturar_cliente TO DESA10;

--- ============================================================

---Conectar como DESA10
-- Registrar Citas

CREATE OR REPLACE PROCEDURE RegistrarCita(vIdCliente   IN NUMBER,
                                          vIdMascota   IN NUMBER,
                                          vFecha       IN DATE,
                                          vIdServicio  IN NUMBER) AS

  -- Cursor que busca veterinarios con menos de 2 citas en la fecha indicada
  CURSOR cVeterinariosLibres(vFechaParam DATE) IS
    SELECT v.idVeterinario, v.nombre
    FROM TABLAS_FACTURACION.veterinario v
    WHERE (SELECT COUNT(*)
           FROM TABLAS_FACTURACION.cita c
           WHERE c.idVeterinario = v.idVeterinario
             AND TRUNC(c.fecha)  = TRUNC(vFechaParam)) < 2
    ORDER BY v.idVeterinario;

  -- Registro para recorrer el cursor (usamos %ROWTYPE como el profe)
  rCVet cVeterinariosLibres%ROWTYPE;

  -- Variables auxiliares para las validaciones
  existeClienteN  NUMBER;
  existeMascotaN  NUMBER;
  mascotaCliente  NUMBER;
  existeServicio  NUMBER;
  vIdVeterinario  NUMBER;
  llavePrimaria   NUMBER;
  encontrado      NUMBER := 0;

BEGIN

  -- Validacion 1: el cliente debe existir
  SELECT COUNT(*) INTO existeClienteN
  FROM TABLAS_CLIENTES.cliente
  WHERE idCliente = vIdCliente;

  IF existeClienteN = 0 THEN
    RAISE_APPLICATION_ERROR(-20001,
      'El cliente ' || vIdCliente || ' no existe');
  END IF;

  -- Validacion 2: la mascota debe existir
  SELECT COUNT(*) INTO existeMascotaN
  FROM TABLAS_MASCOTAS.mascota
  WHERE idMascota = vIdMascota;

  IF existeMascotaN = 0 THEN
    RAISE_APPLICATION_ERROR(-20002,
      'La mascota ' || vIdMascota || ' no existe');
  END IF;

  -- Validacion 3: la mascota debe pertenecer al cliente
  SELECT COUNT(*) INTO mascotaCliente
  FROM TABLAS_MASCOTAS.mascota
  WHERE idMascota = vIdMascota
    AND idCliente = vIdCliente;

  IF mascotaCliente = 0 THEN
    RAISE_APPLICATION_ERROR(-20003,
      'La mascota ' || vIdMascota ||
      ' no pertenece al cliente ' || vIdCliente);
  END IF;

  -- Validacion 4: el servicio debe existir
  SELECT COUNT(*) INTO existeServicio
  FROM TABLAS_FACTURACION.servicio
  WHERE idServicio = vIdServicio;

  IF existeServicio = 0 THEN
    RAISE_APPLICATION_ERROR(-20004,
      'El servicio ' || vIdServicio || ' no existe');
  END IF;

  -- Validacion 5: buscar veterinario disponible usando el cursor
  -- Regla de negocio: maximo 2 citas por dia por veterinario
  OPEN cVeterinariosLibres(vFecha);
  FETCH cVeterinariosLibres INTO rCVet;

  IF cVeterinariosLibres%FOUND THEN
    encontrado     := 1;
    vIdVeterinario := rCVet.idVeterinario;
  END IF;

  CLOSE cVeterinariosLibres;

  -- Si encontramos veterinario, registramos la cita
  IF encontrado = 1 THEN

    -- Generamos la PK manualmente (MAX + 1)
    SELECT NVL(MAX(idCita), 0) + 1 INTO llavePrimaria
    FROM TABLAS_FACTURACION.cita;

    INSERT INTO TABLAS_FACTURACION.cita
           (idCita, fecha, idMascota, idVeterinario, idServicio)
    VALUES (llavePrimaria, vFecha, vIdMascota, vIdVeterinario, vIdServicio);

    COMMIT;

  ELSE
    -- Ningun veterinario tenia disponibilidad ese dia
    RAISE_APPLICATION_ERROR(-20005,
      'No hay veterinarios disponibles el dia ' ||
      TO_CHAR(vFecha, 'dd/mm/yyyy') ||
      ' (todos tienen 2 o mas citas ese dia)');
  END IF;

END;
/

-- Damos EXECUTE al rol del usuario final
GRANT EXECUTE ON RegistrarCita TO ROLUFPROY;



--- ============================================================
-- Sinonimos

--Conectarse como: UFPROY01
CREATE SYNONYM procesar_peticion_cita
FOR TABLAS_CLIENTES.procesar_peticion_cita;

CREATE SYNONYM facturar_cliente
FOR TABLAS_FACTURACION.facturar_cliente;

CREATE SYNONYM RegistrarCita
FOR DESA10.RegistrarCita;


--Conectarse como: DESA10
CREATE SYNONYM procesar_peticion_cita
FOR TABLAS_CLIENTES.procesar_peticion_cita;

CREATE SYNONYM facturar_cliente
FOR TABLAS_FACTURACION.facturar_cliente;


--- ============================================================

-- Validaciones

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'TABLAS_FACTURACION';

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'FACTURAR_CLIENTE';

-----

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name = 'REGISTRARCITA';


----

SELECT synonym_name, table_owner, table_name
FROM user_synonyms
WHERE synonym_name IN ('PROCESAR_PETICION_CITA', 'FACTURAR_CLIENTE');

SELECT synonym_name, table_owner, table_name
FROM user_synonyms
WHERE synonym_name IN ('PROCESAR_PETICION_CITA', 'FACTURAR_CLIENTE');

SELECT synonym_name, table_owner, table_name
FROM user_synonyms
WHERE synonym_name = 'REGISTRARCITA';


