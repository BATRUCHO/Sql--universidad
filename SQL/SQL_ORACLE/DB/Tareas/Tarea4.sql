-- Eliminar las versiones anteriores 
DROP TABLE Productos CASCADE CONSTRAINTS;
DROP TABLE Compras CASCADE CONSTRAINTS;
DROP TABLE Rechazos CASCADE CONSTRAINTS;

-- 1. Tabla Productos 
CREATE TABLE Productos (
    idProducto NUMBER,
    idBodega   NUMBER,
    cantidad   NUMBER,
    precio     NUMBER(8,2),
    CONSTRAINT pk_productos_multibodega PRIMARY KEY (idProducto, idBodega)
);

-- 2. Tabla Compras 
CREATE TABLE Compras (
    idPeticion NUMBER PRIMARY KEY,
    idProducto NUMBER,
    cantidadPorComprar NUMBER,
    estado NUMBER -- 0: Pendiente, 1: Procesada Completa, 2: Rechazada/Incompleta
);

-- 3. Tabla Rechazos 
CREATE TABLE Rechazos (
    idPeticion NUMBER,
    idProducto NUMBER,
    cantidadSolicitada NUMBER,
    cantidadRechazada  NUMBER
);

INSERT INTO Productos VALUES (1, 1, 10, 1500); -- Bodega 1
INSERT INTO Productos VALUES (1, 2, 5, 1500);  -- Bodega 2
INSERT INTO Productos VALUES (1, 3, 3, 1500);  -- Bodega 3


INSERT INTO Productos VALUES (5, 1, 0, 600);
INSERT INTO Productos VALUES (5, 2, 0, 600);


INSERT INTO Compras VALUES (201, 1, 15, 0);


INSERT INTO Compras VALUES (202, 5, 10, 0);

COMMIT;

-------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE ActualizarInventario (
    p_idPeticion IN NUMBER,
    p_idProducto IN NUMBER,
    p_cantidadPorComprar IN NUMBER
) AS
    v_restante NUMBER := p_cantidadPorComprar;
    
    -- Cursor para recorrer bodegas del mismo producto 
    CURSOR c_bodegas IS 
        SELECT idBodega, cantidad 
        FROM Productos 
        WHERE idProducto = p_idProducto 
        AND cantidad > 0
        ORDER BY idBodega 
        FOR UPDATE;
BEGIN
    FOR r_bodega IN c_bodegas LOOP
        IF v_restante > 0 THEN
            IF r_bodega.cantidad >= v_restante THEN
                UPDATE Productos 
                SET cantidad = cantidad - v_restante
                WHERE idProducto = p_idProducto AND idBodega = r_bodega.idBodega;
                
                v_restante := 0;
            ELSE
                v_restante := v_restante - r_bodega.cantidad;
                
                UPDATE Productos 
                SET cantidad = 0
                WHERE idProducto = p_idProducto AND idBodega = r_bodega.idBodega;
            END IF;
        END IF;
    END LOOP;

    IF v_restante = 0 THEN
        UPDATE Compras SET estado = 1 WHERE idPeticion = p_idPeticion;
    ELSE
        -- Si quedó un restante, se rechaza la compra 
        INSERT INTO Rechazos (idPeticion, idProducto, cantidadSolicitada, cantidadRechazada)
        VALUES (p_idPeticion, p_idProducto, p_cantidadPorComprar, v_restante);
        UPDATE Compras SET estado = 2 WHERE idPeticion = p_idPeticion;
    END IF;
END;
/

--------------------------------------------------------------------------------------------------------------

-- Procedimiento de disparo
CREATE OR REPLACE PROCEDURE seleccionaPeticion AS
BEGIN
    FOR r IN (SELECT * FROM Compras WHERE estado = 0) LOOP
        ActualizarInventario(r.idPeticion, r.idProducto, r.cantidadPorComprar);
    END LOOP;
    COMMIT;
END;
/

ALTER SESSION DISABLE PARALLEL DML;
EXEC seleccionaPeticion;

-- Verificación de resultados
SELECT * FROM Productos;
SELECT * FROM Compras;
SELECT * FROM Rechazos;



