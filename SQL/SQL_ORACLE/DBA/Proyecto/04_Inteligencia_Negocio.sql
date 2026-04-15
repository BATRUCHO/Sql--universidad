-- Iniciar como USRCONSULTA

SET ROLE ROL_CONSULTA_APP;

-- Seccion con la que se tiene que iniciar es: USRCONSULTA

SELECT 
    s.nombreSucursal,
    avg(f.monto_contrato) as promedio_monto 
FROM fact_producto_contrato f
INNER JOIN dim_cliente c on f.id_cliente = c.id_cliente
INNER JOIN dim_sucursal s on c.dim_sucursal_id_sucursal = s.id_sucursal
GROUP BY s.nombreSucursal;

--Segunda consulta

--Mostrar el total de contratos por estado y cantidad
SELECT 
    ec.nombre_estado,
    count(f.id_contrato)as cantidad_contratos,
    SUM(f.monto_contrato) as total_monto
from fact_producto_contrato f inner join dim_estadoContrato ec
on f.dim_estadoContrato_id_estadoContrato = ec.id_estadoContrato
group by ec.nombre_estado;

--Consulta nos va a dar el total de dinero y cantidad por contratos por cliente
SELECT 
    c.id_cliente, c.nombre, c.apellido,
    COUNT(f.id_contrato)as cantidad_contratos,
    SUM(f.monto_contrato)as total_monto
from fact_producto_contrato f inner join dim_cliente c
on f.id_cliente = c.id_cliente
group by c.id_cliente, c.nombre, c.apellido;

--Consulta similar a la anterior, nos va a dar el total de dinero y cantidad de contratos por provincia
SELECT
    t.provincia,
    COUNT(f.id_contrato) as cantidad_contratos,
    SUM(f.monto_contrato) as total_monto
from fact_producto_contrato f inner join dim_cliente c
on f.id_cliente = c.id_cliente 
inner join dim_sucursal s on c.dim_sucursal_id_sucursal = s.id_sucursal
inner join dim_territorio t on s.dim_territorio_id_zona = t.id_zona
group by t.provincia;

--Analiza los contratos y cuanto dinero se genera por canal
SELECT 
    i.nombre_canal,
    COUNT(f.id_contrato) as cantidad_contratos,
    SUM(f.monto_contrato) as total_monto
from fact_producto_contrato f inner join dim_interacciones i
on f.id_canal = i.id_interaccion
group by i.nombre_canal;

-- AHORA PRUEBA EL SELECT
SELECT * FROM fact_producto_contrato WHERE ROWNUM <= 5;