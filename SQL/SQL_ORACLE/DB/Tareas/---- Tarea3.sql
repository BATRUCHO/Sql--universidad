---- Tarea3
CREATE TABLE Productos (
    idProducto NUMBER PRIMARY KEY, -- Simplificamos para la práctica
    cantidad NUMBER,
    precio NUMBER(8,2)
);

CREATE TABLE Compras (
    idPeticion NUMBER PRIMARY KEY,
    idProducto NUMBER,
    cantidadPorComprar NUMBER,
    estado NUMBER -- 0: Pendiente, 1: Procesado, 2: Rechazado
);

CREATE TABLE Rechazos (
    idPeticion NUMBER,
    idProducto NUMBER,
    cantidadRechazada NUMBER
);

-- 2. Datos iniciales
INSERT INTO Productos VALUES (1, 10, 1500);
INSERT INTO Productos VALUES (4, 8, 1000);
INSERT INTO Compras VALUES (101, 1, 5, 0);  -- Debe pasar
INSERT INTO Compras VALUES (102, 4, 15, 0); -- Debe rechazar
COMMIT;

-- 3. Procedimiento Lógico
CREATE OR REPLACE PROCEDURE ActualizarInventario (
    p_idPeticion IN NUMBER,
    p_idProducto IN NUMBER,
    p_cantidadPorComprar IN NUMBER
) AS
    v_stock_actual NUMBER;
BEGIN
    -- Bloqueamos la fila para evitar el error de paralelismo
    SELECT cantidad INTO v_stock_actual 
    FROM Productos 
    WHERE idProducto = p_idProducto 
    FOR UPDATE;

    IF v_stock_actual >= p_cantidadPorComprar THEN
        UPDATE Productos SET cantidad = cantidad - p_cantidadPorComprar WHERE idProducto = p_idProducto;
        UPDATE Compras SET estado = 1 WHERE idPeticion = p_idPeticion;
    ELSE
        INSERT INTO Rechazos VALUES (p_idPeticion, p_idProducto, p_cantidadPorComprar);
        UPDATE Compras SET estado = 2 WHERE idPeticion = p_idPeticion;
    END IF;
END;
/

-- 4. Procedimiento de Control
CREATE OR REPLACE PROCEDURE seleccionaPeticion AS
BEGIN
    FOR r IN (SELECT * FROM Compras WHERE estado = 0) LOOP
        ActualizarInventario(r.idPeticion, r.idProducto, r.cantidadPorComprar);
    END LOOP;
    COMMIT; -- Confirmamos todo al final de la carga
END;
/

-- 5. Ejecución
EXEC seleccionaPeticion;

-- Desactivamos el paralelismo de la sesión actual
ALTER SESSION DISABLE PARALLEL DML;
ALTER SESSION DISABLE PARALLEL QUERY;

-- Ejecución
EXEC seleccionaPeticion;

-- Verificación de resultados
SELECT * FROM Productos;
SELECT * FROM Compras;
SELECT * FROM Rechazos;