use finan_db;
-- -------------------------------
-- Nivel 1
-- -------------------------------
-- 1
select nombre,
    apellido,
    email
from clientes
where estado like 'activo'
    AND fecha_registro >= '2024-01-01';
-- 2
select numero_cuenta,
    saldo
from cuentas
where tipo_cuenta in ('inversion', 'corriente')
    AND saldo > 10000;
-- 3 
Select e1.nombre AS empleado,
    coalesce(e2.nombre, 'Alta Gerencia') AS supervisor
From empleados e1
    left join empleados e2 ON e1.empleado_id = e2.supervisor_id;
-- 4
select sucursal_id,
    nombre,
    ciudad
From sucursales
where ciudad not like 'san jose';
-- 5
select nombre,
    salario,
    puesto
from empleados
where salario >= 1500
    AND salario <= 3000;
-- 6
select nombre,
    telefono
From clientes
where telefono = null;
-- 7
select nombre,
    puesto,
    fecha_contratacion
from empleados
order by fecha_contratacion desc;
-- 8
select nombre_tipo
from tipos_transaccion
where naturaleza like 'debito'
order by nombre_tipo asc;
-- 9
select numero_cuenta,
    saldo
from cuentas
where tipo_cuenta in ('congelada', 'cerrada');
-- 10
select monto,
    transaccion_id
from transacciones
where monto > 5000;
-- -------------------------------
-- Nivel 2
-- -------------------------------
-- 1 
select tipo_cuenta,
    sum(saldo) as saldo_total,
    avg(saldo) as promedio
from cuentas
group by tipo_cuenta;
-- 2
select tipo_cuenta,
    sum(cuenta_id) as totalCuentas
from cuentas
group by tipo_cuenta;
-- 3
select sucursal_id,
    sum(salario) as salarioTotal
from empleados
group by sucursal_id;
-- 4
select tipo_id,
    sum(tipo_id) as sumaTotal
from transacciones
group by tipo_id
order by sumaTotal desc;
-- 5
select cliente_id,
    SUM(saldo) as Saldo
from cuentas
group by cliente_id
having sum(saldo) > 20000;
-- 6
select tp.naturaleza,
    avg(tr.monto) as promedio
from tipos_transaccion tp
    left join transacciones tr ON tp.tipo_id = tr.tipo_id
group by tp.naturaleza;
-- 7
SELECT sucursal_id,
    COUNT(estado) AS total_activas
FROM cuentas
WHERE estado = 'Activa'
GROUP BY sucursal_id
having count(estado) > 2;
-- 8 
select transaccion_id,
    min(monto),
    max(monto)
from transacciones
where cuenta_id = 1
group by transaccion_id;
-- 9
select from_unixtime(avg(UNIX_TIMESTAMP(fecha_contratacion))) as fechaPromedio
from empleados;
-- 10
select count(email) as conteoCorreos
from clientes
where email like '%@%';
-- -------------------------------
-- Nivel 3
-- -------------------------------
-- 1
SELECT cl.nombre,
    cl.apellido,
    cu.numero_cuenta,
    su.nombre
FROM clientes cl
    INNER JOIN cuentas cu ON cu.cliente_id = cl.cliente_id
    INNER JOIN sucursales su ON su.sucursal_id = cu.sucursal_id;
-- 2
select cu.numero_cuenta,
    cl.nombre,
    tt.nombre_tipo,
    t.monto
from clientes cl
    inner join cuentas cu on cu.cliente_id = cl.cliente_id
    inner join transacciones t on t.cuenta_id = cu.cuenta_id
    inner join tipos_transaccion tt on tt.tipo_id = t.tipo_id;
-- 3
Select e1.nombre AS empleado,
    coalesce(e2.nombre, 'Alta Gerencia') AS supervisor
From empleados e1
    left join empleados e2 ON e1.empleado_id = e2.supervisor_id;
-- 4
select sum(cu.saldo) as saldoPorSucursal,
    su.ciudad
From cuentas cu
    inner join sucursales su on su.sucursal_id = cu.sucursal_id
group by su.ciudad;
-- 5
select cl.nombre,
    cl.apellido,
    cu.numero_cuenta,
    tr.transaccion_id
from clientes cl
    inner join cuentas cu on cu.cliente_id = cl.cliente_id
    left join transacciones tr on tr.cuenta_id = cu.cuenta_id
where tr.transaccion_id is null;
-- 6
select em.nombre,
    em.apellido,
    em.puesto,
    su.nombre
from empleados em
    inner join sucursales su on su.sucursal_id = em.sucursal_id;
-- 7
select cl.nombre,
    cl.apellido,
    tr.monto
from clientes cl
    inner join cuentas cu on cu.cliente_id = cl.cliente_id
    inner join transacciones tr on tr.cuenta_id = cu.cuenta_id
    inner join tipos_transaccion tt on tt.tipo_id = tr.tipo_id
where nombre_tipo like 'deposito';
-- 8
select sum(cu.saldo) as saldo,
    cu.tipo_cuenta,
    su.nombre
from cuentas cu
    inner join sucursales su on su.sucursal_id = cu.sucursal_id
group by su.nombre,
    cu.tipo_cuenta
order by nombre desc;
-- 9
select cl.nombre,
    cl.apellido,
    cl.identificacion,
    cu.saldo
from clientes cl
    inner join cuentas cu on cu.cliente_id = cl.cliente_id
where cu.saldo > 0
    AND cu.estado in ('Cerrada', 'Congelada');
-- 10 
select tr.fecha_hora,
    tr.monto,
    tr.descripcion_detallada,
    cl.email
from transacciones tr
    inner join cuentas cu on cu.cuenta_id = tr.cuenta_id
    inner join clientes cl on cl.cliente_id = cu.cliente_id
where monto > 10000;
-- -------------------------------
-- Nivel 4
-- -------------------------------
-- 1
select numero_cuenta,
    saldo,
    case
        when saldo > 50000 then 'Platinum'
        when saldo <= 50000
        and saldo >= 10000 then 'Gold'
        else 'Regular'
    end as 'Categoria_Cuenta'
from cuentas
order by saldo desc;
-- 2
select numero_cuenta,
    saldo,
    case
        when saldo > avg (saldo) over() then 'Salarios_altos'
        else 'Salarios_Promedio'
    end as 'Promedio_Salarios'
from cuentas
order by saldo desc;
-- 3
SELECT em.nombre,
    em.apellido,
    em.puesto,
    em.salario,
    su.nombre AS nombre_sucursal
FROM empleados em
    INNER JOIN sucursales su ON su.sucursal_id = em.sucursal_id
WHERE 1 = (
        CASE
            -- Compara el salario del empleado actual con el máximo de su misma sucursal
            WHEN em.salario = (
                SELECT MAX(sub.salario)
                FROM empleados sub
                WHERE sub.sucursal_id = em.sucursal_id -- o su.sucursal_id
            ) THEN 1
            ELSE 0
        END
    );
-- 4 
select cl.nombre,
    cl.apellido,
    cu.numero_cuenta
from clientes cl
    inner join cuentas cu on cu.cliente_id = cl.cliente_id
where cl.cliente_id in (
        SELECT cliente_id
        FROM cuentas
        WHERE estado = 'activa'
        GROUP BY cliente_id
        HAVING COUNT(*) > 1
    );
-- 5  
select tr.cuenta_id,
    sum(
        case
            when tt.naturaleza = 'credito' then tr.monto
            when tt.naturaleza = 'debito' then - tr.monto
            else 0
        end
    ) as Impacto_Total
from transacciones tr
    inner join tipos_transaccion tt on tt.tipo_id = tr.tipo_id
group by tr.cuenta_id;
-- 6 
select su.nombre
from sucursales su
WHERE NOT EXISTS (
        SELECT 1
        FROM empleados em
        WHERE em.sucursal_id = su.sucursal_id
            AND em.puesto = 'asesor financiero'
    );
-- 7
SELECT cu.numero_cuenta,
    (
        SELECT max(fecha_hora)
        FROM transacciones tr
        WHERE cu.cuenta_id = tr.cuenta_id
    ) AS fecha_ultima_transaccion
FROM cuentas cu;
-- 8
select cu.saldo,
    case
        when cu.saldo < 0 then 'Sobregiro'
        when cu.saldo = 0 then 'Cuenta_vacia'
        else 'Cuenta_Saludable'
    end as 'Verificacion_Saldos'
from cuentas cu;
-- 9
select tt.nombre_tipo,
    tr.cuenta_id
from tipos_transaccion tt
    inner join transacciones tr on tt.tipo_id = tr.tipo_id
where tr.monto > (
        select avg(tr1.monto)
        from transacciones tr1
            inner join tipos_transaccion tt1 on tt1.tipo_id = tr1.tipo_id
        where tr.cuenta_id = tr1.cuenta_id -- Compara el dato externo con el interno
            AND tt1.nombre_tipo = 'Depósito'
    );
-- 10 
Select distinct e1.empleado_id,
    e1.nombre,
    e1.apellido,
    e1.puesto,
    e1.salario
From empleados e1
    inner join empleados e2 ON e1.empleado_id = e2.supervisor_id;
-- -------------------------------
-- Nivel 5
-- -------------------------------	
-- 1
select cu.saldo,
    cu.numero_cuenta,
    su.nombre,
    ROW_NUMBER() OVER(
        partition by su.sucursal_id
        order by cu.saldo desc
    ) AS Clasificacion
from cuentas cu
    inner join sucursales su on su.sucursal_id = cu.sucursal_id;
-- 2
select cu.cuenta_id,
    cu.numero_cuenta,
    tr.transaccion_id,
    tr.fecha_hora,
    sum(
        case
            when tt.nombre_tipo = 'Depósito' then tr.monto
            else - tr.monto
        end
    ) over(
        partition by cu.cuenta_id
        order by tr.fecha_hora
    ) as Saldo_Acumulado
from cuentas cu
    inner join transacciones tr on tr.cuenta_id = cu.cuenta_id
    inner join tipos_transaccion tt on tt.tipo_id = tr.tipo_id;
-- 3 
select tr.cuenta_id,
    tr.transaccion_id,
    tr.fecha_hora,
    tr.monto as monto_actual,
    lag(tr.monto, 1) over(
        partition by tr.cuenta_id
        order by tr.fecha_hora asc
    ) as monto_anterior
from transacciones tr;
-- 4
select em.empleado_id,
    em.nombre,
    em.apellido,
    em.salario,
    round(
        percent_rank() OVER (
            order by em.salario asc
        ) * 100,
        2
    ) as Salario_Percentil
from empleados em;
-- 5
select cu.cuenta_id,
    cu.numero_cuenta,
    su.nombre,
    cu.saldo as saldo_cuenta,
    (
        cu.saldo / sum(cu.saldo) over(partition by su.sucursal_id)
    ) * 100 as Porcentaje_Aportacion
from cuentas cu
    inner join sucursales su on su.sucursal_id = cu.sucursal_id;
-- 6 
SELECT tr.cuenta_id,
    tr.transaccion_id,
    tr.fecha_hora,
    tr.monto,
    AVG(tr.monto) OVER(
        PARTITION BY tr.cuenta_id
        ORDER BY tr.fecha_hora ASC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS promedio_movil_3
FROM transacciones tr;
-- 7
With cuentas_rankeadas as (
    select cu.cliente_id,
        cu.cuenta_id,
        cu.numero_cuenta,
        cu.fecha_apertura,
        cu.saldo,
        row_number() over(
            partition by cu.cliente_id
            order by cu.fecha_apertura asc
        ) as rankeo_cuentas
    from cuentas cu
)
SELECT cliente_id,
    cuenta_id,
    numero_cuenta,
    fecha_apertura,
    saldo
FROM cuentas_rankeadas
WHERE rankeo_cuentas = 1;
-- 8 
WITH salario_lider AS (
    SELECT em.empleado_id,
        em.nombre AS nombre_empleado,
        em.apellido,
        em.puesto,
        em.salario,
        su.nombre AS nombre_sucursal,
        MAX(em.salario) OVER(PARTITION BY em.sucursal_id) AS salario_lideres
    FROM empleados em
        INNER JOIN sucursales su ON em.sucursal_id = su.sucursal_id
)
SELECT empleado_id,
    nombre_empleado,
    apellido,
    puesto,
    salario,
    nombre_sucursal,
    salario_lideres,
    (salario_lideres - salario) AS diferencia_con_lider
FROM salario_lider;
-- 9
SELECT CASE
        WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '00:00:00' AND '05:59:59' THEN 'madrugada'
        WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '06:00:00' AND '11:59:59' THEN 'mañana'
        WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'tarde'
        ELSE 'noche'
    END AS bloque_horario,
    SUM(
        CASE
            WHEN tt.naturaleza = 'credito' THEN tr.monto
            ELSE - tr.monto
        END
    ) AS monto_neto
FROM transacciones tr
    INNER JOIN tipos_transaccion tt ON tt.tipo_id = tr.tipo_id
GROUP BY bloque_horario
ORDER BY monto_neto DESC;
with bloque_horarios as (
    SELECT tr.transaccion_id,
        tr.fecha_hora,
        tr.monto,
        tt.naturaleza,
        CASE
            WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '00:00:00' AND '05:59:59' THEN 'madrugada'
            WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '06:00:00' AND '11:59:59' THEN 'mañana'
            WHEN CAST(tr.fecha_hora AS TIME) BETWEEN '12:00:00' AND '17:59:59' THEN 'tarde'
            ELSE 'noche'
        END AS bloque_horario
    FROM transacciones tr
        INNER JOIN tipos_transaccion tt ON tt.tipo_id = tr.tipo_id
)
select *
from bloque_horarios
where bloque_horario = 'mañana';
-- 10
with cuentas_por_sucursal as (
    SELECT cu.cliente_id,
        su.nombre AS nombre_sucursal,
        COUNT(cu.cuenta_id) AS total_cuentas,
        ROW_NUMBER() OVER(
            PARTITION BY cu.cliente_id
            ORDER BY COUNT(cu.cuenta_id) DESC
        ) AS ranking_sucursal
    FROM cuentas cu
        INNER JOIN sucursales su ON su.sucursal_id = cu.sucursal_id
    GROUP BY cu.cliente_id,
        su.sucursal_id
),
sucursal_preferida AS (
    SELECT cliente_id,
        nombre_sucursal
    FROM cuentas_por_sucursal
    WHERE ranking_sucursal = 1
),
transaccion_mas_alta as (
    SELECT cu.cliente_id,
        MAX(tr.monto) AS max_monto_realizado
    FROM transacciones tr
        INNER JOIN cuentas cu ON cu.cuenta_id = tr.cuenta_id
    GROUP BY cu.cliente_id
)
SELECT cl.cliente_id,
    cl.nombre,
    cl.apellido,
    COUNT(cu.cuenta_id) AS cuentas_activas,
    SUM(cu.saldo) AS saldo_total_combinado,
    tma.max_monto_realizado,
    sp.nombre_sucursal AS sucursal_preferida
FROM clientes cl
    INNER JOIN cuentas cu ON cu.cliente_id = cl.cliente_id
    LEFT JOIN sucursal_preferida sp ON sp.cliente_id = cl.cliente_id
    LEFT JOIN transaccion_mas_alta tma ON tma.cliente_id = cl.cliente_id
WHERE cl.estado = 'activo'
GROUP BY cl.cliente_id,
    cl.nombre,
    cl.apellido,
    tma.max_monto_realizado,
    sp.nombre_sucursal;
---------------------------------------------------------------------------------------------------------------------------------------------
WITH total_deposito AS (
    SELECT cu.cliente_id,
        SUM(tr.monto) AS total_depositado
    FROM transacciones tr
        INNER JOIN tipos_transaccion tt ON tt.tipo_id = tr.tipo_id
        INNER JOIN cuentas cu ON cu.cuenta_id = tr.cuenta_id
    WHERE tt.naturaleza = 'Credito'
    GROUP BY cu.cliente_id
),
transaccion_reciente AS (
    SELECT cu.cliente_id,
        MAX(tr.fecha_hora) AS ultima_transaccion
    FROM transacciones tr
        INNER JOIN cuentas cu ON cu.cuenta_id = tr.cuenta_id
    GROUP BY cu.cliente_id
),
tipo_transaccion_frecuente AS (
    SELECT cu.cliente_id,
        tt.nombre_tipo,
        COUNT(tr.transaccion_id) AS cantidad_transacciones,
        ROW_NUMBER() OVER(
            PARTITION BY cu.cliente_id
            ORDER BY COUNT(tr.transaccion_id) DESC
        ) AS ranking_frecuencia
    FROM tipos_transaccion tt
        INNER JOIN transacciones tr ON tr.tipo_id = tt.tipo_id
        INNER JOIN cuentas cu ON cu.cuenta_id = tr.cuenta_id
    GROUP BY cu.cliente_id,
        tt.nombre_tipo
),
tipo_frecuente_top AS (
    SELECT cliente_id,
        nombre_tipo AS tipo_transaccion_frecuente
    FROM tipo_transaccion_frecuente
    WHERE ranking_frecuencia = 1
)
SELECT cl.cliente_id,
    cl.nombre,
    cl.apellido,
    COALESCE(tp.total_depositado, 0) AS total_depositado,
    tft.tipo_transaccion_frecuente,
    trn.ultima_transaccion,
    AVG(cu.saldo) AS promedio_saldo_cuentas
FROM clientes cl
    INNER JOIN cuentas cu ON cu.cliente_id = cl.cliente_id
    LEFT JOIN total_deposito tp ON tp.cliente_id = cl.cliente_id
    LEFT JOIN transaccion_reciente trn ON trn.cliente_id = cl.cliente_id
    LEFT JOIN tipo_frecuente_top tft ON tft.cliente_id = cl.cliente_id
GROUP BY cl.cliente_id,
    cl.nombre,
    cl.apellido,
    tp.total_depositado,
    tft.tipo_transaccion_frecuente,
    trn.ultima_transaccion;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------