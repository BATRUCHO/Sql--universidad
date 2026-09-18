-- ==============================================================================
-- BASE DE DATOS PARA PRÁCTICAS ACADÉMICAS: SISTEMA BANCARIO Y FINANCIERO (FINAN_DB)
-- Diseñada para prácticas de SQL intermedio/avanzado (Joins, Agregaciones, Subconsultas, Ventanas)
-- ==============================================================================

DROP DATABASE IF EXISTS finan_db;
CREATE DATABASE finan_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE finan_db;

-- 1. TABLA: Clientes (Entidad Principal)
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    identificacion VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    telefono VARCHAR(20),
    fecha_registro DATE NOT NULL,
    estado ENUM('Activo', 'Inactivo', 'Bloqueado') DEFAULT 'Activo',
    CONSTRAINT pk_clientes PRIMARY KEY (cliente_id)
) ENGINE=InnoDB;

-- 2. TABLA: Sucursales
CREATE TABLE sucursales (
    sucursal_id INT AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    direccion VARCHAR(150),
    CONSTRAINT pk_sucursales PRIMARY KEY (sucursal_id)
) ENGINE=InnoDB;

-- 3. TABLA: Cuentas Bancarias (Relación 1:N con Clientes y Sucursales)
CREATE TABLE cuentas (
    cuenta_id INT AUTO_INCREMENT,
    cliente_id INT NOT NULL,
    sucursal_id INT NOT NULL,
    numero_cuenta VARCHAR(20) NOT NULL UNIQUE,
    tipo_cuenta ENUM('Corriente', 'Ahorros', 'Inversion') NOT NULL,
    saldo DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    fecha_apertura DATE NOT NULL,
    estado ENUM('Activa', 'Cerrada', 'Congelada') DEFAULT 'Activa',
    CONSTRAINT pk_cuentas PRIMARY KEY (cuenta_id),
    CONSTRAINT fk_cuentas_clientes FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_cuentas_sucursales FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. TABLA: Tipos de Transacción (Tabla Catálogo)
CREATE TABLE tipos_transaccion (
    tipo_id INT AUTO_INCREMENT,
    nombre_tipo VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(100),
    naturaleza ENUM('Debito', 'Credito') NOT NULL,
    CONSTRAINT pk_tipos_transaccion PRIMARY KEY (tipo_id)
) ENGINE=InnoDB;

-- 5. TABLA: Transacciones (Tabla de Hechos / Histórica)
CREATE TABLE transacciones (
    transaccion_id BIGINT AUTO_INCREMENT,
    cuenta_id INT NOT NULL,
    tipo_id INT NOT NULL,
    monto DECIMAL(15, 2) NOT NULL,
    fecha_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    descripcion_detallada VARCHAR(150),
    CONSTRAINT pk_transacciones PRIMARY KEY (transaccion_id),
    CONSTRAINT fk_transacciones_cuentas FOREIGN KEY (cuenta_id) REFERENCES cuentas(cuenta_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transacciones_tipos FOREIGN KEY (tipo_id) REFERENCES tipos_transaccion(tipo_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. TABLA: Empleados (Jerarquía / Auto-referenciada para prácticas de Self-Join)
CREATE TABLE empleados (
    empleado_id INT AUTO_INCREMENT,
    sucursal_id INT NOT NULL,
    supervisor_id INT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    puesto VARCHAR(50) NOT NULL,
    salario DECIMAL(10, 2) NOT NULL,
    fecha_contratacion DATE NOT NULL,
    CONSTRAINT pk_empleados PRIMARY KEY (empleado_id),
    CONSTRAINT fk_empleados_sucursales FOREIGN KEY (sucursal_id) REFERENCES sucursales(sucursal_id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_empleados_supervisor FOREIGN KEY (supervisor_id) REFERENCES empleados(empleado_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ==============================================================================
-- INSERCIÓN DE DATOS DE PRUEBA (DATASET CONTROLADO Y COHERENTE)
-- ==============================================================================

-- Insertar Sucursales
INSERT INTO sucursales (nombre, ciudad, direccion) VALUES
('Sucursal Central', 'San José', 'Av. Central, Calles 1 y 3'),
('Sucursal Este', 'San Pedro', 'De la Iglesia 200m Este'),
('Sucursal Norte', 'Heredia', 'Centro Comercial Paseo de las Flores'),
('Sucursal Oeste', 'Escazú', 'Multiplaza Escazú, Local 45');

-- Insertar Tipos de Transacción
INSERT INTO tipos_transaccion (nombre_tipo, descripcion, naturaleza) VALUES
('Depósito', 'Ingreso de efectivo en ventanilla o cajero automático', 'Credito'),
('Retiro', 'Retiro de efectivo en ventanilla o cajero automático', 'Debito'),
('Transferencia Recibida', 'Fondos recibidos desde otra cuenta bancaria', 'Credito'),
('Transferencia Enviada', 'Fondos enviados hacia otra cuenta bancaria', 'Debito'),
('Pago de Servicio', 'Débito automático o manual para servicios públicos o privados', 'Debito'),
('Intereses Ganados', 'Abono periódico por rendimiento de cuenta de ahorros o inversión', 'Credito');

-- Insertar Clientes
INSERT INTO clientes (nombre, apellido, identificacion, email, telefono, fecha_registro, estado) VALUES
('Carlos', 'Mendoza', '101110111', 'carlos.mendoza@email.com', '8888-1111', '2024-01-15', 'Activo'),
('Ana', 'Gutiérrez', '202220222', 'ana.gutierrez@email.com', '8888-2222', '2024-02-20', 'Activo'),
('Luis', 'Sánchez', '303330333', 'luis.sanchez@email.com', '8888-3333', '2024-03-05', 'Activo'),
('María', 'Alvarado', '404040404', 'maria.alvarado@email.com', '8888-4444', '2024-05-12', 'Activo'),
('Jorge', 'Castro', '505050505', 'jorge.castro@email.com', '8888-5555', '2024-06-01', 'Inactivo'),
('Elena', 'Rojas', '606060606', 'elena.rojas@email.com', '8888-6666', '2024-08-19', 'Activo'),
('Pedro', 'Chaves', '707070707', 'pedro.chaves@email.com', '8888-7777', '2024-10-10', 'Bloqueado');

-- Insertar Cuentas Bancarias
INSERT INTO cuentas (cliente_id, sucursal_id, numero_cuenta, tipo_cuenta, saldo, fecha_apertura, estado) VALUES
(1, 1, 'CR-000001', 'Corriente', 15000.00, '2024-01-16', 'Activa'),
(1, 1, 'CR-000002', 'Ahorros', 4500.50, '2024-03-01', 'Activa'),
(2, 2, 'CR-000003', 'Ahorros', 28000.00, '2024-02-22', 'Activa'),
(3, 3, 'CR-000004', 'Corriente', 1250.00, '2024-03-06', 'Activa'),
(4, 4, 'CR-000005', 'Inversion', 120000.00, '2024-05-15', 'Activa'),
(4, 2, 'CR-000006', 'Corriente', 850.00, '2024-05-15', 'Activa'),
(5, 1, 'CR-000007', 'Ahorros', 0.00, '2024-06-02', 'Cerrada'),
(6, 3, 'CR-000008', 'Ahorros', 9400.00, '2024-08-20', 'Activa'),
(7, 4, 'CR-000009', 'Corriente', 50.00, '2024-10-11', 'Congelada');

-- Insertar Empleados (Con Estructura Jerárquica)
INSERT INTO empleados (sucursal_id, supervisor_id, nombre, apellido, puesto, salario, fecha_contratacion) VALUES
(1, NULL, 'Sofía', 'Monge', 'Gerente General', 4500.00, '2020-01-10'),
(1, 1, 'Andrés', 'Herrera', 'Jefe de Operaciones', 2800.00, '2021-05-15'),
(2, 1, 'Beatriz', 'Solano', 'Gerente de Sucursal', 3200.00, '2021-06-01'),
(3, 1, 'Roberto', 'Díaz', 'Gerente de Sucursal', 3100.00, '2022-02-15'),
(4, 1, 'Laura', 'Vargas', 'Gerente de Sucursal', 3300.00, '2021-09-20'),
(1, 2, 'Gabriel', 'Mora', 'Cajero Principal', 1500.00, '2023-03-01'),
(1, 6, 'Lucía', 'Jiménez', 'Cajero', 1100.00, '2024-01-10'),
(2, 3, 'Esteban', 'Araya', 'Asesor Financiero', 1800.00, '2022-07-19'),
(3, 4, 'Mariela', 'Quesada', 'Cajero', 1100.00, '2024-02-01'),
(4, 5, 'Ricardo', 'Soto', 'Asesor Financiero', 1850.00, '2023-11-05');

-- Insertar Transacciones Históricas (Datos coherentes con los saldos actuales)
INSERT INTO transacciones (cuenta_id, tipo_id, monto, fecha_hora, descripcion_detallada) VALUES
(1, 1, 20000.00, '2024-01-20 09:15:00', 'Depósito inicial en ventanilla'),
(1, 2, 5000.00, '2024-01-22 14:30:22', 'Retiro en cajero automático sucursal central'),
(2, 1, 4000.00, '2024-03-02 10:00:00', 'Depósito por apertura'),
(2, 6, 500.50, '2024-12-31 23:59:59', 'Cierre de intereses anuales'),
(3, 1, 30000.00, '2024-02-25 11:12:40', 'Transferencia recibida del exterior'),
(3, 5, 2000.00, '2024-03-01 08:00:00', 'Pago automático de servicio eléctrico'),
(4, 1, 5000.00, '2024-03-10 15:45:10', 'Depósito cheque de gerencia'),
(4, 4, 3750.00, '2024-03-15 16:20:00', 'Transferencia enviada a tercero'),
(5, 1, 100000.00, '2024-05-15 09:00:00', 'Apertura de certificado de inversión a plazo fijo'),
(5, 6, 20000.00, '2024-11-15 00:00:00', 'Rendimiento de intereses semestrales'),
(6, 1, 1000.00, '2024-05-20 13:10:00', 'Depósito en efectivo'),
(6, 2, 150.00, '2024-06-01 18:22:15', 'Retiro cajero automático'),
(8, 1, 9000.00, '2024-08-25 10:30:00', 'Depósito por transferencia sinpe'),
(8, 6, 400.00, '2024-09-30 23:59:00', 'Intereses ganados mes de septiembre'),
(9, 1, 50.00, '2024-10-12 11:00:00', 'Depósito mínimo obligatorio');

-- 1. Nuevas cuentas para generar variedad por cliente y sucursal
INSERT INTO cuentas (cliente_id, sucursal_id, numero_cuenta, tipo_cuenta, saldo, fecha_apertura, estado) VALUES
(1, 3, 'CR-000010', 'Inversion', 85000.00, '2024-04-10', 'Activa'), -- Carlos abre cuenta en Sucursal Norte
(2, 1, 'CR-000011', 'Corriente', 12000.00, '2024-05-01', 'Activa'), -- Ana abre cuenta en Sucursal Central
(3, 2, 'CR-000012', 'Ahorros', 6700.00, '2024-06-15', 'Activa'),    -- Luis abre cuenta en Sucursal Este
(6, 4, 'CR-000013', 'Corriente', 3100.00, '2024-09-01', 'Activa');  -- Elena abre cuenta en Sucursal Oeste

-- 2. Historial de transacciones más denso para pruebas analíticas complejas
INSERT INTO transacciones (cuenta_id, tipo_id, monto, fecha_hora, descripcion_detallada) VALUES
-- Transacciones para Carlos (Cliente 1)
(1, 1, 12000.00, '2024-02-10 10:15:00', 'Depósito en efectivo ventanilla'),
(1, 3, 45000.00, '2024-02-18 16:45:00', 'Transferencia recibida cliente corporativo'),
(1, 5, 3200.00, '2024-03-05 08:30:00', 'Pago automático de internet y agua'),
(2, 6, 250.00, '2024-06-30 23:59:59', 'Intereses semestrales abonados'),
(10, 1, 85000.00, '2024-04-10 11:00:00', 'Depósito inicial fondo inversión'),

-- Transacciones para Ana (Cliente 2)
(3, 3, 15000.00, '2024-04-01 12:00:00', 'Transferencia recibida por servicios profesionales'),
(3, 4, 8000.00, '2024-04-15 15:20:00', 'Transferencia enviada pago de tarjeta'),
(3, 5, 1200.00, '2024-05-02 09:10:00', 'Pago de servicio telefónico'),
(11, 1, 12000.00, '2024-05-01 14:00:00', 'Apertura cuenta corriente'),
(11, 2, 2500.00, '2024-05-10 18:40:00', 'Retiro cajero automático'),

-- Transacciones para María (Cliente 4) - Actividad en inversión y corriente
(5, 6, 15000.00, '2024-12-31 23:59:00', 'Rendimiento anual certificado'),
(6, 3, 5000.00, '2024-06-10 10:05:00', 'Transferencia recibida'),
(6, 5, 800.00, '2024-07-01 11:30:00', 'Pago de Marchamo'),

-- Transacciones para Elena (Cliente 6)
(8, 3, 12000.00, '2024-09-05 07:45:00', 'Transferencia recibida nómina'),
(8, 4, 3000.00, '2024-09-12 19:15:00', 'Transferencia enviada alquiler'),
(13, 1, 3100.00, '2024-09-01 15:00:00', 'Depósito inicial sucursal oeste');

-- ==============================================================================
-- VALIDACIÓN INICIAL (OPCIONAL PARA ASEGURAR QUE TODO CARGÓ CORRECTAMENTE)
-- ==============================================================================
SELECT 'Base de datos creada exitosamente con sus tablas y datos base.' AS Estado_Instalacion;