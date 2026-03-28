-- Procedimiento para seleccionar y procesar peticiones

ALTER SESSION DISABLE PARALLEL DML;

CREATE OR REPLACE PROCEDURE seleccionaPeticion AS
    CURSOR c_compras_pendientes IS 
        SELECT idPeticion, idProducto, cantidadPorComprar 
        FROM Compras 
        WHERE estado = 0;
BEGIN
    FOR r_compra IN c_compras_pendientes LOOP
        ActualizarInventario(r_compra.idPeticion, r_compra.idProducto, r_compra.cantidadPorComprar);
    END LOOP;
END;
/


-- Procedimiento final de ejecución
CREATE OR REPLACE PROCEDURE pruebaActualizarInventario AS
BEGIN
    seleccionaPeticion;
END;
/

-- Ejecución de la prueba
EXEC pruebaActualizarInventario;