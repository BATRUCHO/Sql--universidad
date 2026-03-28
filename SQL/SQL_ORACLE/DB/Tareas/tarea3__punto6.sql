
CREATE OR REPLACE PROCEDURE ActualizarInventario (
    p_idPeticion IN NUMBER,
    p_idProducto IN NUMBER,
    p_cantidadPorComprar IN NUMBER
) AS
    -- Cursor para encontrar el producto coincidente
    CURSOR c_producto IS 
        SELECT cantidad 
        FROM Productos 
        WHERE idProducto = p_idProducto 
        FOR UPDATE; 
    
    v_stock_actual NUMBER;
BEGIN
    OPEN c_producto;
    FETCH c_producto INTO v_stock_actual;
    
    IF c_producto%FOUND THEN
        -- Validar si hay suficiente cantidad
        IF v_stock_actual >= p_cantidadPorComprar THEN
            -- Reducir inventario
            UPDATE Productos 
            SET cantidad = cantidad - p_cantidadPorComprar
            WHERE idProducto = p_idProducto;
            
            -- Actualizar estado de la compra a procesada
            UPDATE Compras 
            SET estado = 1 
            WHERE idPeticion = p_idPeticion;
        ELSE
            -- Cantidad insuficiente: Insertar en Rechazos
            INSERT INTO Rechazos (idPeticion, idProducto, cantidadRechazada)
            VALUES (p_idPeticion, p_idProducto, p_cantidadPorComprar);
        END IF;
    END IF;
    
    CLOSE c_producto;
    COMMIT; 
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/