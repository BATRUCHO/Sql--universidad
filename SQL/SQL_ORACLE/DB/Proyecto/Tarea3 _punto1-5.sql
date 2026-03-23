-- 1. Crear tabla Productos
CREATE TABLE Productos (
    idProducto NUMBER,
    idBodega NUMBER,
    cantidad NUMBER,
    precio NUMBER(8,2),
    CONSTRAINT pk_productos PRIMARY KEY (idProducto, idBodega)
);

-- 2. Insertar registros iniciales en Productos
INSERT INTO Productos (idProducto, idBodega, cantidad, precio) VALUES (1, 1, 10, 1500);
INSERT INTO Productos (idProducto, idBodega, cantidad, precio) VALUES (2, 1, 20, 2000);
INSERT INTO Productos (idProducto, idBodega, cantidad, precio) VALUES (3, 1, 15, 800);
INSERT INTO Productos (idProducto, idBodega, cantidad, precio) VALUES (4, 1, 8, 1000);
INSERT INTO Productos (idProducto, idBodega, cantidad, precio) VALUES (5, 1, 50, 600);

-- 3. Crear tabla Compras
CREATE TABLE Compras (
    idPeticion NUMBER PRIMARY KEY,
    idProducto NUMBER,
    cantidadPorComprar NUMBER,
    estado NUMBER 
);

-- 4. Insertar intenciones de compra 
INSERT INTO Compras VALUES (101, 1, 5, 0);  
INSERT INTO Compras VALUES (102, 4, 15, 0); 

-- 5. Crear tabla Rechazos
CREATE TABLE Rechazos (
    idPeticion NUMBER,
    idProducto NUMBER,
    cantidadRechazada NUMBER
);

COMMIT;




