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

-- 4. Tabla BitacoraCompra 
CREATE TABLE bitacoraCompra (
    idPeticion NUMBER,
    idProducto NUMBER,
    idBodega NUMBER,
    cantidadInventarioPrevia NUMBER,
    cantidadEntregada NUMBER,
    cantidadInventarioNueva NUMBER
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

CREATE OR REPLACE PACKAGE Peticion_Pkg AS
    v_id_peticion_actual NUMBER;
END Peticion_Pkg;
/

CREATE OR REPLACE TRIGGER trg_bitacora_inventario
AFTER UPDATE ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO bitacoraCompra (
        idPeticion,
        idProducto,
        idBodega,
        cantidadInventarioPrevia,
        cantidadEntregada,
        cantidadInventarioNueva
    ) VALUES (
        Peticion_Pkg.v_id_peticion_actual, 
        :OLD.idProducto,                  
        :OLD.idBodega,                    
        :OLD.cantidad,                    
        (:OLD.cantidad - :NEW.cantidad),  
        :NEW.cantidad                     
    );
END;
/

-----------------------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE ActualizarInventario (
    p_idPeticion IN NUMBER,
    p_idProducto IN NUMBER,
    p_cantidadPorComprar IN NUMBER
) AS

    CURSOR c_bodegas IS 
        SELECT idBodega, cantidad 
        FROM Productos 
        WHERE idProducto = p_idProducto 
        AND cantidad > 0
        ORDER BY idBodega 
        FOR UPDATE; 
        
    v_restante NUMBER := p_cantidadPorComprar;
BEGIN
   
    Peticion_Pkg.v_id_peticion_actual := p_idPeticion;

    FOR r_bodega IN c_bodegas LOOP
        IF v_restante > 0 THEN
            IF r_bodega.cantidad >= v_restante THEN
                
                UPDATE Productos 
                SET cantidad = cantidad - v_restante
                WHERE idProducto = p_idProducto 
                AND idBodega = r_bodega.idBodega;
                
                v_restante := 0;
            ELSE
                
                v_restante := v_restante - r_bodega.cantidad;
                
                UPDATE Productos 
                SET cantidad = 0
                WHERE idProducto = p_idProducto 
                AND idBodega = r_bodega.idBodega;
            END IF;
        END IF;
    END LOOP;

    
    IF v_restante > 0 THEN
        INSERT INTO Rechazos (idPeticion, idProducto, cantidadSolicitada, cantidadRechazada)
        VALUES (p_idPeticion, p_idProducto, p_cantidadPorComprar, v_restante);
    END IF;
END;
/

--------------------------------------------------------------------------------------------------------------

-- Procedimiento de disparo
CREATE OR REPLACE PROCEDURE SeleccionarPeticiones AS
BEGIN
    
    FOR r_peticion IN (SELECT * FROM Compras WHERE estado = 0) LOOP
        
        
        ActualizarInventario(
            r_peticion.idPeticion, 
            r_peticion.idProducto, 
            r_peticion.cantidadPorComprar
        );
        
        UPDATE Compras 
        SET estado = 1 
        WHERE idPeticion = r_peticion.idPeticion;
        
    END LOOP;
    
    COMMIT; 
END;
/

-- Verificación de resultados
SELECT * FROM Productos;
SELECT * FROM Compras;
SELECT * FROM Rechazos;
SELECT * FROM BitacoraCompra;



