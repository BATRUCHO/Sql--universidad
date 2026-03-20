CREATE TABLE paises (
    pais_id INT PRIMARY KEY,
    nombre_pais VARCHAR(50),
    continente VARCHAR(50)
);
CREATE TABLE clientes (
    cliente_id INT PRIMARY KEY,
    nombre VARCHAR(50),
    salario INT,
    pais_id INT,
    FOREIGN KEY (pais_id) REFERENCES paises(pais_id)
);
CREATE TABLE ventas (
    venta_id INT PRIMARY KEY,
    cliente_id INT,
    monto INT,
    fecha DATE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
);
INSERT INTO paises VALUES
(1, 'Costa Rica', 'América'),
(2, 'Argentina', 'América'),
(3, 'Alemania', 'Europa');
INSERT INTO clientes VALUES
(1, 'Bryan', 4500, 1),
(2, 'José', 1000, 2),
(3, 'Olaf', 5000, 3),
(4, 'Ana', 1800, NULL);
INSERT INTO ventas VALUES
(1, 1, 800, '2024-01-10'),
(2, 1, 1200, '2024-02-15'),
(3, 3, 3000, '2024-03-20'),
(4, 2, 500, '2023-12-01');


SELECT c.nombre, p.nombre_pais
FROM clientes c
LEFT JOIN paises p ON c.pais_id = p.pais_id;

SELECT c.nombre, SUM(v.monto) AS total_ventas
FROM clientes c
LEFT JOIN ventas v ON c.cliente_id = v.cliente_id
GROUP BY c.nombre;

SELECT c.nombre, SUM(v.monto)
FROM clientes c
JOIN ventas v ON c.cliente_id = v.cliente_id
WHERE EXTRACT(YEAR FROM v.fecha) = 2024
GROUP BY c.nombre;

-- 3 Challenge
SELECT c.nombre, p.nombre_pais
FROM clientes c
LEFT JOIN paises p 
ON c.pais_id = p.pais_id
AND p.nombre_pais = 'Costa Rica'

-- 4 Challenge

SELECT c.nombre, c.salario,p.nombre_pais 
FROM clientes c 
LEFT JOIN paises p 
ON c.pais_id = p.pais_id
WHERE c.salario > 1500

-- 5 Challenge

SELECT p.nombre_pais, 
COUNT(c.nombre) AS cantidad_clientes_Pais 
FROM  paises p 
LEFT JOIN  clientes c
ON c.pais_id = p.pais_id
GROUP BY p.nombre_pais 

-- 7 CHALLENGE 

SELECT COUNT(c.cliente_id) AS cantidad_clientes, 
CASE 
WHEN c.salario <= 1500 THEN 'BAJO' 
WHEN c.salario > 1500 AND c.salario <= 2500 THEN 'MEDIO' 
ELSE 'ALTO' 
END AS clasificacion 
FROM clientes c 
GROUP BY clasificacion 
ORDER BY cantidad_clientes DESC

