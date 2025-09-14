-- =======================================================
-- 1. Modelado de la Base de Datos
-- =======================================================

-- Creación de la base de datos
CREATE DATABASE coworking_db;
USE coworking_db;

-- Tabla de usuarios
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    empresa VARCHAR(100),
    documento_id VARCHAR(50) UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de tipos de membresía
CREATE TABLE tipos_membresia (
    tipo_membresia_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10, 2) NOT NULL,
    duracion_dias INT NOT NULL,
    beneficios TEXT
);

-- Tabla de membresías
CREATE TABLE membresias (
    membresia_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tipo_membresia_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Activa', 'Suspendida', 'Vencida') DEFAULT 'Activa',
    precio_final DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (tipo_membresia_id) REFERENCES tipos_membresia(tipo_membresia_id),
    INDEX idx_usuario_estado (usuario_id, estado),
    INDEX idx_fecha_fin (fecha_fin)
);

-- Tabla de espacios
CREATE TABLE espacios (
    espacio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_espacio ENUM('Escritorio flexible', 'Oficina privada', 'Sala de reuniones', 'Sala de eventos') NOT NULL,
    capacidad_max INT NOT NULL,
    descripcion TEXT,
    precio_hora DECIMAL(10, 2) NOT NULL,
    precio_dia DECIMAL(10, 2),
    estado ENUM('Disponible', 'Mantenimiento', 'No disponible') DEFAULT 'Disponible',
    caracteristicas TEXT
);

-- Tabla de reservas
CREATE TABLE reservas (
    reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    espacio_id INT NOT NULL,
    fecha_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_horas DECIMAL(4, 2) NOT NULL,
    estado ENUM('Confirmada', 'En curso', 'Finalizada', 'Cancelada') DEFAULT 'Confirmada',
    precio_total DECIMAL(10, 2) NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (espacio_id) REFERENCES espacios(espacio_id),
    INDEX idx_fecha_reserva (fecha_reserva),
    INDEX idx_usuario_fecha (usuario_id, fecha_reserva)
);

-- Tabla de servicios adicionales
CREATE TABLE servicios (
    servicio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    tipo_servicio ENUM('Internet', 'Almacenamiento', 'Consumibles', 'Equipamiento') NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla de relación servicios-reservas
CREATE TABLE servicios_reserva (
    servicio_reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT NOT NULL,
    servicio_id INT NOT NULL,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    precio_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id) ON DELETE CASCADE,
    FOREIGN KEY (servicio_id) REFERENCES servicios(servicio_id)
);

-- Tabla de facturas
CREATE TABLE facturas (
    factura_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha_emision DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento DATE NOT NULL,
    concepto ENUM('Membresía', 'Reserva', 'Servicios') NOT NULL,
    concepto_id INT NOT NULL, -- ID de la membresía, reserva o servicio
    subtotal DECIMAL(10, 2) NOT NULL,
    impuestos DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    estado ENUM('Pagada', 'Pendiente', 'Vencida', 'Cancelada') DEFAULT 'Pendiente',
    detalles TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    INDEX idx_estado_vencimiento (estado, fecha_vencimiento)
);

-- Tabla de pagos
CREATE TABLE pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id INT NOT NULL,
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'Transferencia', 'PayPal') NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100),
    estado ENUM('Completado', 'Pendiente', 'Fallido', 'Reembolsado') DEFAULT 'Completado',
    detalles TEXT,
    FOREIGN KEY (factura_id) REFERENCES facturas(factura_id) ON DELETE CASCADE,
    INDEX idx_fecha_metodo (fecha_pago, metodo_pago)
);

-- Tabla de control de acceso
CREATE TABLE acceso (
    acceso_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    espacio_id INT,
    fecha_hora_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_hora_salida DATETIME,
    metodo_acceso ENUM('RFID', 'QR', 'Manual') NOT NULL,
    resultado ENUM('Permitido', 'Denegado') NOT NULL,
    motivo_denegacion TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (espacio_id) REFERENCES espacios(espacio_id),
    INDEX idx_usuario_fecha (usuario_id, fecha_hora_entrada)
);

-- Tabla de registros de asistencia
CREATE TABLE asistencia (
    asistencia_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,
    tiempo_total TIME,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id) ON DELETE CASCADE,
    INDEX idx_usuario_fecha (usuario_id, fecha)
);

-- =======================================================
-- 1.2. Insercion de datos
-- =======================================================

-- 1. Insertar usuarios
INSERT INTO usuarios (nombre, apellidos, fecha_nacimiento, email, telefono, empresa, documento_id) VALUES
('Juan', 'García Pérez', '1990-05-15', 'juan@email.com', '+34600123456', 'Tech Solutions', '12345678A'),
('María', 'López Martínez', '1985-08-22', 'maria@email.com', '+34611234567', 'Design Studio', '87654321B'),
('Carlos', 'Rodríguez Sánchez', '1992-11-03', 'carlos@email.com', '+34622345678', NULL, '13579246C'),
('Ana', 'Fernández Ruiz', '1988-03-30', 'ana@email.com', '+34633456789', 'Data Analytics', '24681357D'),
('Pedro', 'González Castro', '1995-07-18', 'pedro@email.com', '+34644567890', NULL, '98765432E'),
('Laura', 'Martín Díaz', '1991-09-25', 'laura@email.com', '+34655678901', 'Web Developers', '55544433F'),
('Sergio', 'Moreno Jiménez', '1987-12-12', 'sergio@email.com', '+34666789012', 'Consulting Group', '11122233G'),
('Elena', 'Torres Romero', '1993-04-05', 'elena@email.com', '+34677890123', 'Creative Minds', '99988877H'),
('Pablo', 'Sanz Navarro', '1989-06-28', 'pablo@email.com', '+34688901234', NULL, '44455566I'),
('Marta', 'Rubio Molina', '1994-01-14', 'marta@email.com', '+34699012345', 'Tech Innovations', '77788899J');

-- 2. Insertar tipos de membresía
INSERT INTO tipos_membresia (nombre, descripcion, precio_base, duracion_dias, beneficios) VALUES
('Básica', 'Acceso a zonas comunes en horario estándar', 99.99, 30, 'Wi-Fi, café y impresiones limitadas'),
('Premium', 'Acceso 24/7 y escritorio fijo', 199.99, 30, 'Todos los beneficios básicos + locker gratuito'),
('Empresa', 'Múltiples usuarios y oficina privada', 499.99, 30, '10 accesos, meeting rooms 5h/mes'),
('Flex', 'Acceso por horas sin compromiso', 0.00, 0, 'Pago solo por uso'),
('Nocturna', 'Acceso de 20:00 a 08:00', 79.99, 30, 'Wi-Fi y café gratis'),
('Estudiante', 'Descuento especial para estudiantes', 69.99, 30, 'Acceso a zonas comunes'),
('Day Pass', 'Acceso por un día', 19.99, 1, 'Todos los servicios básicos'),
('Virtual', 'Servicios remotos sin espacio físico', 29.99, 30, 'Dirección postal y mail handling'),
('Meeting Pass', 'Acceso a salas de reuniones', 39.99, 0, '3 horas diarias de sala'),
('Event Pass', 'Acceso a eventos exclusivos', 49.99, 0, 'Participación en eventos mensuales');

-- 3. Insertar membresías
INSERT INTO membresias (usuario_id, tipo_membresia_id, fecha_inicio, fecha_fin, estado, precio_final) VALUES
(1, 2, '2024-01-01', '2024-01-31', 'Activa', 199.99),
(2, 1, '2024-01-05', '2024-02-04', 'Activa', 99.99),
(3, 5, '2024-01-10', '2024-02-09', 'Vencida', 79.99),
(4, 3, '2024-01-15', '2024-02-14', 'Suspendida', 449.99),
(5, 6, '2024-01-20', '2024-02-19', 'Activa', 69.99),
(6, 2, '2024-02-01', '2024-03-02', 'Activa', 199.99),
(7, 4, '2024-02-05', '2024-02-05', 'Vencida', 0.00),
(8, 8, '2024-02-10', '2024-03-11', 'Activa', 29.99),
(9, 7, '2024-02-15', '2024-02-15', 'Vencida', 19.99),
(10, 9, '2024-02-20', '2024-02-20', 'Activa', 39.99);

-- 4. Insertar espacios
INSERT INTO espacios (nombre, tipo_espacio, capacidad_max, descripcion, precio_hora, precio_dia, estado, caracteristicas) VALUES
('Sala Berlin', 'Sala de reuniones', 8, 'Sala con pantalla 4K y pizarra', 15.50, 100.00, 'Disponible', 'Pantalla 55", café incluido'),
('Oficina Paris', 'Oficina privada', 4, 'Oficina con vistas al parque', 20.00, 150.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio A1', 'Escritorio flexible', 1, 'En zona silenciosa', 5.00, 30.00, 'Mantenimiento', 'Monitor externo opcional'),
('Event Space', 'Sala de eventos', 50, 'Espacio para conferencias', 100.00, 600.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Tokyo', 'Sala de reuniones', 6, 'Estilo japonés con tatami', 12.00, 80.00, 'Disponible', 'Té verde gratis, zapatos prohibidos'),
('Oficina London', 'Oficina privada', 6, 'Decoración vintage', 25.00, 180.00, 'No disponible', 'Biblioteca incluida'),
('Escritorio B2', 'Escritorio flexible', 1, 'Zona networking', 4.50, 25.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Madrid', 'Sala de reuniones', 10, 'Mesa de reuniones grande', 18.00, 120.00, 'Disponible', 'Video conferencia equipada'),
('Oficina NY', 'Oficina privada', 8, 'Skyline view', 30.00, 200.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone', 'Escritorio flexible', 50, 'Zona abierta principal', 3.00, 20.00, 'Disponible', '24/7 access, coffee bar');

-- 5. Insertar reservas
INSERT INTO reservas (usuario_id, espacio_id, fecha_reserva, hora_inicio, hora_fin, duracion_horas, estado, precio_total) VALUES
(1, 1, '2024-03-01', '09:00:00', '11:00:00', 2.00, 'Finalizada', 31.00),
(2, 3, '2024-03-01', '10:00:00', '14:00:00', 4.00, 'Finalizada', 20.00),
(3, 5, '2024-03-02', '16:00:00', '17:30:00', 1.50, 'Cancelada', 18.00),
(4, 2, '2024-03-03', '08:00:00', '12:00:00', 4.00, 'En curso', 80.00),
(5, 4, '2024-03-04', '18:00:00', '22:00:00', 4.00, 'Confirmada', 400.00),
(6, 8, '2024-03-05', '11:00:00', '13:00:00', 2.00, 'Confirmada', 36.00),
(7, 10, '2024-03-05', '09:00:00', '18:00:00', 9.00, 'Finalizada', 20.00),
(8, 7, '2024-03-06', '14:00:00', '16:00:00', 2.00, 'Confirmada', 9.00),
(9, 9, '2024-03-07', '10:00:00', '14:00:00', 4.00, 'Confirmada', 120.00),
(10, 6, '2024-03-08', '15:00:00', '17:00:00', 2.00, 'Confirmada', 50.00);

-- 6. Insertar servicios
INSERT INTO servicios (nombre, descripcion, precio, tipo_servicio, disponible) VALUES
('Internet Premium', '1 Gbps dedicado', 9.99, 'Internet', TRUE),
('Alquiler Monitor', 'Monitor 4K 27"', 5.00, 'Equipamiento', TRUE),
('Impresiones Color', 'Hasta 100 páginas', 0.25, 'Consumibles', TRUE),
('Lockers', 'Lockers seguridad 24h', 2.50, 'Almacenamiento', TRUE),
('Cabina Teléfono', 'Cabina insonorizada', 7.50, 'Equipamiento', FALSE),
('Coffee Pack', 'Café ilimitado día', 3.00, 'Consumibles', TRUE),
('Correo Certificado', 'Gestión correo certificado', 12.00, 'Almacenamiento', TRUE),
('Projector', 'Proyector HD', 15.00, 'Equipamiento', TRUE),
('Scanner A3', 'Escáner profesional', 4.50, 'Equipamiento', FALSE),
('Recepción Paquetes', 'Recepción y almacenamiento', 1.50, 'Almacenamiento', TRUE);

-- 7. Insertar servicios_reserva
INSERT INTO servicios_reserva (reserva_id, servicio_id, cantidad, precio_unitario, precio_total) VALUES
(1, 1, 1, 9.99, 9.99),
(1, 3, 20, 0.25, 5.00),
(2, 6, 1, 3.00, 3.00),
(3, 8, 1, 15.00, 15.00),
(4, 2, 2, 5.00, 10.00),
(5, 9, 1, 4.50, 4.50),
(6, 4, 1, 2.50, 2.50),
(7, 7, 3, 12.00, 36.00),
(8, 10, 2, 1.50, 3.00),
(9, 5, 1, 7.50, 7.50);

-- 8. Insertar facturas
INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles) VALUES
(1, '2024-01-31', 'Membresía', 1, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium enero'),
(2, '2024-02-04', 'Membresía', 2, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica febrero'),
(3, '2024-02-09', 'Membresía', 3, 79.99, 16.80, 96.79, 'Vencida', 'Membresía Nocturna febrero'),
(4, '2024-02-14', 'Membresía', 4, 449.99, 94.50, 544.49, 'Pendiente', 'Membresía Empresa febrero'),
(5, '2024-02-19', 'Membresía', 5, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante febrero'),
(6, '2024-02-01', 'Reserva', 1, 31.00, 6.51, 37.51, 'Pagada', 'Reserva Sala Berlin 2h'),
(7, '2024-02-05', 'Reserva', 2, 20.00, 4.20, 24.20, 'Cancelada', 'Reserva Escritorio A1 4h'),
(8, '2024-02-10', 'Servicios', 1, 9.99, 2.10, 12.09, 'Pagada', 'Internet Premium reserva #1'),
(9, '2024-02-15', 'Reserva', 3, 18.00, 3.78, 21.78, 'Pendiente', 'Reserva Sala Tokyo 1.5h'),
(10, '2024-02-20', 'Servicios', 2, 10.00, 2.10, 12.10, 'Pagada', '2 monitors reserva #4');

-- 9. Insertar pagos
INSERT INTO pagos (factura_id, metodo_pago, monto, fecha_pago, referencia, estado, detalles) VALUES
(1, 'Tarjeta', 241.99, '2024-01-31 10:30:00', 'REF123456', 'Completado', 'Pago completo con Visa'),
(2, 'PayPal', 120.99, '2024-02-04 14:22:00', 'PP987654', 'Completado', 'Pago via PayPal'),
(3, 'Transferencia', 96.79, '2024-02-10 09:45:00', 'TRF555444', 'Fallido', 'Transferencia no recibida'),
(4, 'Efectivo', 544.49, '2024-02-14 16:10:00', 'CASH789', 'Pendiente', 'Pendiente de entrega'),
(5, 'Tarjeta', 84.69, '2024-02-19 11:30:00', 'REF333222', 'Completado', 'Pago con Mastercard'),
(6, 'Tarjeta', 37.51, '2024-02-01 12:05:00', 'REF111222', 'Completado', 'Pago con American Express'),
(7, 'PayPal', 24.20, '2024-02-05 13:15:00', 'PP444555', 'Reembolsado', 'Cancelación reserva'),
(8, 'Transferencia', 12.09, '2024-02-10 08:45:00', 'TRF666777', 'Completado', 'Transferencia recibida'),
(9, 'Efectivo', 21.78, '2024-02-15 17:20:00', 'CASH888', 'Pendiente', 'Pago en efectivo pendiente'),
(10, 'Tarjeta', 12.10, '2024-02-20 10:00:00', 'REF999000', 'Completado', 'Pago con Visa Debit');

-- 10. Insertar acceso
INSERT INTO acceso (usuario_id, espacio_id, fecha_hora_entrada, fecha_hora_salida, metodo_acceso, resultado, motivo_denegacion) VALUES
(1, 1, '2024-03-01 08:58:00', '2024-03-01 11:02:00', 'QR', 'Permitido', NULL),
(2, 3, '2024-03-01 09:55:00', '2024-03-01 14:05:00', 'RFID', 'Permitido', NULL),
(3, 5, '2024-03-02 15:45:00', NULL, 'Manual', 'Denegado', 'Reserva cancelada previamente'),
(4, 2, '2024-03-03 07:59:00', '2024-03-03 12:01:00', 'RFID', 'Permitido', NULL),
(5, 4, '2024-03-04 17:45:00', NULL, 'QR', 'Permitido', NULL),
(6, 8, '2024-03-05 10:58:00', '2024-03-05 13:02:00', 'RFID', 'Permitido', NULL),
(7, 10, '2024-03-05 08:30:00', '2024-03-05 18:10:00', 'Manual', 'Permitido', NULL),
(8, 7, '2024-03-06 13:55:00', '2024-03-06 16:05:00', 'QR', 'Permitido', NULL),
(9, 9, '2024-03-07 09:30:00', NULL, 'RFID', 'Denegado', 'Falta de pago'),
(10, 6, '2024-03-08 14:50:00', '2024-03-08 17:00:00', 'Manual', 'Permitido', NULL);

-- 11. Insertar asistencia
INSERT INTO asistencia (usuario_id, fecha, hora_entrada, hora_salida, tiempo_total) VALUES
(1, '2024-03-01', '08:58:00', '11:02:00', '02:04:00'),
(2, '2024-03-01', '09:55:00', '14:05:00', '04:10:00'),
(4, '2024-03-03', '07:59:00', '12:01:00', '04:02:00'),
(5, '2024-03-04', '17:45:00', '22:00:00', '04:15:00'),
(6, '2024-03-05', '10:58:00', '13:02:00', '02:04:00'),
(7, '2024-03-05', '08:30:00', '18:10:00', '09:40:00'),
(8, '2024-03-06', '13:55:00', '16:05:00', '02:10:00'),
(10, '2024-03-08', '14:50:00', '17:00:00', '02:10:00'),
(1, '2024-03-08', '09:00:00', '17:00:00', '08:00:00'),
(3, '2024-03-09', '10:00:00', '15:30:00', '05:30:00');

 -- =======================================================
-- 3. Triggers SQL (20)
-- =======================================================

-- 1. Insertar fecha de vencimiento automáticamente al crear una nueva membresía
CREATE TRIGGER trg_membresias_set_fecha_fin
BEFORE INSERT ON membresias
FOR EACH ROW
BEGIN
    DECLARE duracion INT;
    SELECT duracion_dias INTO duracion FROM tipos_membresia WHERE tipo_membresia_id = NEW.tipo_membresia_id;
    IF duracion IS NOT NULL AND duracion > 0 THEN
        SET NEW.fecha_fin = DATE_ADD(NEW.fecha_inicio, INTERVAL duracion DAY);
    ELSE
        SET NEW.fecha_fin = NEW.fecha_inicio; -- Si es Day Pass u otro sin duración fija
    END IF;
END;

-- 2. Actualizar estado de membresía a "Activa" cuando se realiza un pago exitoso
CREATE TRIGGER trg_pago_activa_membresia
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    DECLARE concepto_val ENUM('Membresía','Reserva','Servicios');
    DECLARE concepto_id_val INT;
    SELECT concepto, concepto_id INTO concepto_val, concepto_id_val FROM facturas WHERE factura_id = NEW.factura_id;
    IF concepto_val = 'Membresía' AND NEW.estado = 'Completado' THEN
        UPDATE membresias SET estado = 'Activa' WHERE membresia_id = concepto_id_val;
    END IF;
END;

-- 3. Actualizar estado a "Suspendida" cuando no se paga antes de la fecha límite
CREATE TRIGGER trg_factura_vencida_suspendida
AFTER UPDATE ON facturas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Vencida' AND NEW.concepto = 'Membresía' THEN
        UPDATE membresias SET estado = 'Suspendida' WHERE membresia_id = NEW.concepto_id;
    END IF;
END;

-- 4. Registrar en log cada vez que se actualice el tipo de membresía
CREATE TABLE log_cambios_membresia (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    membresia_id INT,
    usuario_id INT,
    tipo_anterior INT,
    tipo_nuevo INT,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_cambio_membresia
BEFORE UPDATE ON membresias
FOR EACH ROW
BEGIN
    IF OLD.tipo_membresia_id <> NEW.tipo_membresia_id THEN
        INSERT INTO log_cambios_membresia (membresia_id, usuario_id, tipo_anterior, tipo_nuevo)
        VALUES (OLD.membresia_id, OLD.usuario_id, OLD.tipo_membresia_id, NEW.tipo_membresia_id);
    END IF;
END;

-- 5. Bloquear eliminación si el usuario tiene reservas activas
CREATE TRIGGER trg_bloqueo_delete_membresia
BEFORE DELETE ON membresias
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM reservas WHERE usuario_id = OLD.usuario_id AND estado IN ('Confirmada','En curso')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar la membresía: el usuario tiene reservas activas.';
    END IF;
END;

-- =====================================
-- MÓDULO: RESERVAS
-- =====================================

-- 1. Validar que no existan reservas duplicadas en mismo espacio, fecha y hora
CREATE TRIGGER trg_no_reservas_duplicadas
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM reservas WHERE espacio_id = NEW.espacio_id AND fecha_reserva = NEW.fecha_reserva AND ((NEW.hora_inicio BETWEEN hora_inicio AND hora_fin) OR (NEW.hora_fin BETWEEN hora_inicio AND hora_fin))) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe una reserva para ese espacio en ese horario.';
    END IF;
END;

-- 2. Estado "Pendiente de Confirmación" al crear una reserva
CREATE TRIGGER trg_reserva_pendiente
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    SET NEW.estado = 'Confirmada'; -- o 'Pendiente de Confirmación' si agregas ese estado a ENUM
END;

-- 3. Confirmar reserva al registrar pago
CREATE TRIGGER trg_pago_confirma_reserva
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    DECLARE concepto_val ENUM('Membresía','Reserva','Servicios');
    DECLARE concepto_id_val INT;
    SELECT concepto, concepto_id INTO concepto_val, concepto_id_val FROM facturas WHERE factura_id = NEW.factura_id;
    IF concepto_val = 'Reserva' AND NEW.estado = 'Completado' THEN
        UPDATE reservas SET estado = 'Confirmada' WHERE reserva_id = concepto_id_val;
    END IF;
END;

-- 4. Cancelar reserva si el usuario elimina su membresía
CREATE TRIGGER trg_cancelar_reservas_al_eliminar_membresia
AFTER DELETE ON membresias
FOR EACH ROW
BEGIN
    UPDATE reservas SET estado = 'Cancelada' WHERE usuario_id = OLD.usuario_id AND estado IN ('Confirmada','En curso');
END;

-- 5. Log de cancelaciones de reservas
CREATE TABLE log_cancelaciones_reservas (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT,
    usuario_id INT,
    fecha_cancelacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_cancelacion_reserva
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cancelada' AND OLD.estado <> 'Cancelada' THEN
        INSERT INTO log_cancelaciones_reservas (reserva_id, usuario_id)
        VALUES (NEW.reserva_id, NEW.usuario_id);
    END IF;
END;

-- =====================================
-- MÓDULO: PAGOS Y FACTURACIÓN
-- =====================================

-- 1. Crear automáticamente factura al registrar un pago (si no tiene factura)
-- (En este caso ya existe relación obligatoria, normalmente se haría en INSERT de reserva o membresía)

-- 2. Actualizar factura a "Pagada" cuando se confirma el pago
CREATE TRIGGER trg_factura_pagada
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Completado' AND OLD.estado <> 'Completado' THEN
        UPDATE facturas SET estado = 'Pagada' WHERE factura_id = NEW.factura_id;
    END IF;
END;

-- 3. Bloquear eliminación de pago si existe factura
CREATE TRIGGER trg_bloqueo_delete_pago
BEFORE DELETE ON pagos
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM facturas WHERE factura_id = OLD.factura_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el pago: existe factura asociada.';
    END IF;
END;

-- 4. Actualizar saldo pendiente de factura con pagos parciales
CREATE TRIGGER trg_actualizar_saldo_factura
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    UPDATE facturas SET total = total - NEW.monto WHERE factura_id = NEW.factura_id AND total > NEW.monto;
END;

-- 5. Log de pagos anulados
CREATE TABLE log_pagos_anulados (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    pago_id INT,
    factura_id INT,
    fecha_anulacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_pago_anulado
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Reembolsado' AND OLD.estado <> 'Reembolsado' THEN
        INSERT INTO log_pagos_anulados (pago_id, factura_id) VALUES (NEW.pago_id, NEW.factura_id);
    END IF;
END;

-- =====================================
-- MÓDULO: ACCESOS
-- =====================================

-- 1. Registrar asistencia automáticamente al validar acceso (QR o RFID)
CREATE TRIGGER trg_registra_asistencia
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Permitido' AND NEW.metodo_acceso IN ('QR','RFID') THEN
        INSERT INTO asistencia (usuario_id, fecha, hora_entrada)
        VALUES (NEW.usuario_id, DATE(NEW.fecha_hora_entrada), TIME(NEW.fecha_hora_entrada));
    END IF;
END;

-- 2. Bloquear acceso si no tiene membresía activa
CREATE TRIGGER trg_bloqueo_acceso_sin_membresia
BEFORE INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM membresias WHERE usuario_id = NEW.usuario_id AND estado = 'Activa') THEN
        SET NEW.resultado = 'Denegado';
        SET NEW.motivo_denegacion = 'Usuario sin membresía activa';
    END IF;
END;

-- 3. Actualizar última fecha de acceso del usuario
ALTER TABLE usuarios ADD COLUMN ultima_fecha_acceso DATETIME NULL;

CREATE TRIGGER trg_actualiza_ultima_fecha_acceso
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Permitido' THEN
        UPDATE usuarios SET ultima_fecha_acceso = NEW.fecha_hora_entrada WHERE usuario_id = NEW.usuario_id;
    END IF;
END;

-- 4. Registrar salida automáticamente si vuelve a entrar sin salida previa
CREATE TRIGGER trg_cierra_acceso_pendiente
BEFORE INSERT ON acceso
FOR EACH ROW
BEGIN
    UPDATE acceso SET fecha_hora_salida = NOW() WHERE usuario_id = NEW.usuario_id AND fecha_hora_salida IS NULL;
END;

-- 5. Log de accesos rechazados
CREATE TABLE log_accesos_rechazados (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    espacio_id INT,
    fecha_hora DATETIME,
    motivo TEXT
);

CREATE TRIGGER trg_log_acceso_denegado
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Denegado' THEN
        INSERT INTO log_accesos_rechazados (usuario_id, espacio_id, fecha_hora, motivo)
        VALUES (NEW.usuario_id, NEW.espacio_id, NEW.fecha_hora_entrada, NEW.motivo_denegacion);
    END IF;
END;

-- =======================================================
-- 2. Consultas SQL (100 en total)
-- =======================================================

-- =======================================================
-- CONSULTAS SQL - MÓDULO USUARIOS Y MEMBRESÍAS (1-20)
-- =======================================================

-- 1. Listar todos los usuarios con su información básica
SELECT 
    usuario_id, nombre, apellidos, fecha_nacimiento, 
    email, telefono, empresa, documento_id, fecha_registro
FROM usuarios;

-- 2. Listar los usuarios con membresía activa (vigente en la fecha actual)
SELECT 
    u.*, m.membresia_id, m.tipo_membresia_id, m.fecha_inicio, m.fecha_fin
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa' 
  AND m.fecha_fin >= CURDATE();

-- 3. Listar los usuarios cuya membresía está vencida
SELECT 
    u.*, m.membresia_id, m.fecha_fin, m.estado
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Vencida' 
   OR m.fecha_fin < CURDATE();

-- 4. Listar los usuarios con membresía suspendida
SELECT 
    u.*, m.membresia_id, m.fecha_inicio, m.fecha_fin
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Suspendida';

-- 5. Contar cuántos usuarios tienen cada tipo de membresía
SELECT 
    t.nombre AS tipo_membresia, 
    COUNT(DISTINCT m.usuario_id) AS cantidad_usuarios
FROM tipos_membresia t
LEFT JOIN membresias m 
    ON t.tipo_membresia_id = m.tipo_membresia_id
GROUP BY t.tipo_membresia_id, t.nombre;

-- 6. Mostrar el top 10 de usuarios con más antigüedad
-- (Ordena por fecha_registro más antigua)
SELECT 
    usuario_id, nombre, apellidos, fecha_registro
FROM usuarios
ORDER BY fecha_registro ASC
LIMIT 10;

-- 7. Listar usuarios que pertenecen a una empresa específica
-- Reemplazar :empresa por el nombre deseado
SELECT 
    usuario_id, nombre, apellidos, empresa, email, telefono
FROM usuarios
WHERE empresa = :empresa;

-- 8. Contar cuántos usuarios están asociados a cada empresa
-- Muestra también los que no tienen empresa
SELECT 
    COALESCE(empresa, 'Sin empresa') AS empresa, 
    COUNT(*) AS cantidad_usuarios
FROM usuarios
GROUP BY empresa
ORDER BY cantidad_usuarios DESC;

-- 9. Mostrar usuarios que nunca han hecho una reserva
SELECT 
    u.usuario_id, u.nombre, u.apellidos, u.email
FROM usuarios u
LEFT JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE r.reserva_id IS NULL;

-- 10. Mostrar usuarios con más de 5 reservas activas en el mes actual
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    COUNT(r.reserva_id) AS reservas_activas_mes
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE r.estado IN ('Confirmada','En curso')
  AND YEAR(r.fecha_reserva) = YEAR(CURDATE())
  AND MONTH(r.fecha_reserva) = MONTH(CURDATE())
GROUP BY u.usuario_id
HAVING COUNT(r.reserva_id) > 5;

-- 11. Calcular el promedio de edad de los usuarios
SELECT 
    ROUND(AVG(TIMESTAMPDIFF(YEAR, fecha_nacimiento, CURDATE())), 2) 
    AS promedio_edad
FROM usuarios
WHERE fecha_nacimiento IS NOT NULL;

-- 12. Listar usuarios que han cambiado de membresía más de 2 veces
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    COUNT(m.membresia_id) AS cantidad_membresias
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
GROUP BY u.usuario_id
HAVING COUNT(m.membresia_id) > 2;

-- 13. Listar usuarios que han gastado más de $500 en reservas
-- (Usa facturas con concepto = 'Reserva')
SELECT 
    f.usuario_id, u.nombre, u.apellidos, 
    SUM(f.total) AS total_gastado_reservas
FROM facturas f
JOIN usuarios u ON f.usuario_id = u.usuario_id
WHERE f.concepto = 'Reserva'
GROUP BY f.usuario_id
HAVING SUM(f.total) > 500;

-- 14. Mostrar usuarios que tienen membresía y servicios adicionales
SELECT DISTINCT 
    u.usuario_id, u.nombre, u.apellidos, u.email
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE EXISTS (
    SELECT 1
    FROM reservas r
    JOIN servicios_reserva sr ON r.reserva_id = sr.reserva_id
    WHERE r.usuario_id = u.usuario_id
);

-- 15. Listar usuarios con membresía Premium y reservas activas
SELECT DISTINCT 
    u.usuario_id, u.nombre, u.apellidos, 
    m.membresia_id, r.reserva_id
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia t ON m.tipo_membresia_id = t.tipo_membresia_id
JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE t.nombre = 'Premium'
  AND r.estado IN ('Confirmada','En curso');

-- 16. Mostrar usuarios con membresía Corporativa y su empresa
-- (Nombre del tipo de membresía = 'Empresa')
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    u.empresa, t.nombre AS tipo_membresia, 
    m.fecha_inicio, m.fecha_fin
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia t ON m.tipo_membresia_id = t.tipo_membresia_id
WHERE t.nombre = 'Empresa';

-- 17. Identificar usuarios con membresía Day Pass que la renovaron > 10 veces
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    COUNT(m.membresia_id) AS renovaciones_daypass
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia t ON m.tipo_membresia_id = t.tipo_membresia_id
WHERE t.nombre = 'Day Pass'
GROUP BY u.usuario_id
HAVING COUNT(m.membresia_id) > 10;

-- 18. Mostrar usuarios cuya membresía vence en los próximos 7 días
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    m.membresia_id, m.fecha_fin
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.fecha_fin BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
  AND m.estado = 'Activa';

-- 19. Listar usuarios que se registraron en el último mes (últimos 30 días)
SELECT 
    usuario_id, nombre, apellidos, fecha_registro
FROM usuarios
WHERE fecha_registro BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE()
ORDER BY fecha_registro DESC;

-- 20. Mostrar usuarios que nunca han asistido al coworking (sin registros en acceso)
SELECT 
    u.usuario_id, u.nombre, u.apellidos, u.email
FROM usuarios u
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE a.acceso_id IS NULL;

-- 21. Listar todos los espacios disponibles con su capacidad
SELECT 
    espacio_id, nombre, tipo_espacio_id, capacidad, estado
FROM espacios
WHERE estado = 'Disponible';

-- 22. Listar reservas activas en el día actual
SELECT 
    r.reserva_id, r.usuario_id, r.espacio_id, r.fecha_reserva, 
    r.hora_inicio, r.hora_fin, r.estado
FROM reservas r
WHERE r.estado IN ('Confirmada','En curso')
  AND DATE(r.fecha_reserva) = CURDATE();

-- 23. Mostrar reservas canceladas en el último mes
SELECT 
    r.reserva_id, r.usuario_id, r.espacio_id, r.fecha_reserva, 
    r.estado, r.motivo_cancelacion
FROM reservas r
WHERE r.estado = 'Cancelada'
  AND r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE();

-- 24. Listar reservas de salas de reuniones en horario pico (9 am – 11 am)
SELECT 
    r.reserva_id, r.usuario_id, e.nombre AS espacio, 
    r.hora_inicio, r.hora_fin
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
WHERE t.nombre = 'Sala de reuniones'
  AND TIME(r.hora_inicio) BETWEEN '09:00:00' AND '11:00:00';

-- 25. Contar cuántas reservas se hacen por cada tipo de espacio
SELECT 
    t.nombre AS tipo_espacio, COUNT(r.reserva_id) AS total_reservas
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
GROUP BY t.tipo_espacio_id, t.nombre;

-- 26. Mostrar el espacio más reservado del último mes
SELECT 
    e.espacio_id, e.nombre, COUNT(r.reserva_id) AS total_reservas
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE()
GROUP BY e.espacio_id, e.nombre
ORDER BY total_reservas DESC
LIMIT 1;

-- 27. Listar usuarios que más han reservado salas privadas (TOP 10)
SELECT 
    u.usuario_id, u.nombre, u.apellidos, COUNT(r.reserva_id) AS total_reservas
FROM reservas r
JOIN usuarios u ON r.usuario_id = u.usuario_id
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
WHERE t.nombre = 'Sala privada'
GROUP BY u.usuario_id
ORDER BY total_reservas DESC
LIMIT 10;

-- 28. Mostrar reservas que exceden la capacidad máxima del espacio
SELECT 
    r.reserva_id, r.usuario_id, e.nombre AS espacio, 
    r.numero_personas, e.capacidad
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.numero_personas > e.capacidad;

-- 29. Listar espacios que no se han reservado en la última semana
SELECT 
    e.espacio_id, e.nombre, e.capacidad
FROM espacios e
LEFT JOIN reservas r 
    ON e.espacio_id = r.espacio_id 
    AND r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
WHERE r.reserva_id IS NULL;

-- 30. Calcular la tasa de ocupación promedio de cada espacio
-- (Asumiendo que existe un campo duracion_horas)
SELECT 
    e.espacio_id, e.nombre,
    ROUND(SUM(r.duracion_horas) / (7*24), 2) AS tasa_ocupacion_promedio
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.estado IN ('Confirmada','En curso','Completada')
  AND r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
GROUP BY e.espacio_id, e.nombre;

-- 31. Mostrar reservas de más de 8 horas
SELECT 
    r.reserva_id, r.usuario_id, e.nombre AS espacio, 
    TIMESTAMPDIFF(HOUR, r.hora_inicio, r.hora_fin) AS duracion_horas
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
HAVING duracion_horas > 8;

-- 32. Identificar usuarios con más de 20 reservas en total
SELECT 
    u.usuario_id, u.nombre, u.apellidos, COUNT(r.reserva_id) AS total_reservas
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id
HAVING COUNT(r.reserva_id) > 20;

-- 33. Mostrar reservas realizadas por empresas con más de 10 empleados
SELECT 
    r.reserva_id, r.usuario_id, u.empresa
FROM reservas r
JOIN usuarios u ON r.usuario_id = u.usuario_id
JOIN (
    SELECT empresa, COUNT(usuario_id) AS empleados
    FROM usuarios
    WHERE empresa IS NOT NULL
    GROUP BY empresa
    HAVING COUNT(usuario_id) > 10
) emp ON u.empresa = emp.empresa;

-- 34. Listar reservas que se solapan en horario
SELECT 
    r1.reserva_id AS reserva_1, r2.reserva_id AS reserva_2,
    r1.espacio_id, r1.hora_inicio, r1.hora_fin, 
    r2.hora_inicio, r2.hora_fin
FROM reservas r1
JOIN reservas r2 ON r1.espacio_id = r2.espacio_id 
    AND r1.reserva_id < r2.reserva_id
    AND r1.hora_inicio < r2.hora_fin
    AND r2.hora_inicio < r1.hora_fin;

-- 35. Listar reservas de fin de semana (sábado y domingo)
SELECT 
    r.reserva_id, r.usuario_id, r.fecha_reserva, 
    DAYNAME(r.fecha_reserva) AS dia_semana
FROM reservas r
WHERE DAYOFWEEK(r.fecha_reserva) IN (7, 1); 
-- 7 = Sábado, 1 = Domingo en MySQL

-- 36. Mostrar el porcentaje de ocupación por cada tipo de espacio
SELECT 
    t.nombre AS tipo_espacio,
    ROUND(SUM(r.duracion_horas) / (COUNT(DISTINCT e.espacio_id) * 7 * 24) * 100, 2) AS porcentaje_ocupacion
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
WHERE r.estado IN ('Confirmada','En curso','Completada')
  AND r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE()
GROUP BY t.tipo_espacio_id, t.nombre;

-- 37. Mostrar la duración promedio de reservas por tipo de espacio
SELECT 
    t.nombre AS tipo_espacio,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, r.hora_inicio, r.hora_fin)), 2) AS duracion_promedio_horas
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
GROUP BY t.tipo_espacio_id, t.nombre;

-- 38. Mostrar reservas con servicios adicionales incluidos
SELECT DISTINCT 
    r.reserva_id, r.usuario_id, e.nombre AS espacio
FROM reservas r
JOIN servicios_reserva sr ON r.reserva_id = sr.reserva_id
JOIN espacios e ON r.espacio_id = e.espacio_id;

-- 39. Listar usuarios que reservaron sala de eventos en los últimos 6 meses
SELECT DISTINCT 
    u.usuario_id, u.nombre, u.apellidos
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN espacios e ON r.espacio_id = e.espacio_id
JOIN tipos_espacio t ON e.tipo_espacio_id = t.tipo_espacio_id
WHERE t.nombre = 'Sala de eventos'
  AND r.fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 6 MONTH) AND CURDATE();

-- 40. Identificar reservas realizadas y nunca asistidas
-- (Asumiendo que tabla asistencia_reserva registra check-in de la reserva)
SELECT 
    r.reserva_id, r.usuario_id, r.fecha_reserva
FROM reservas r
LEFT JOIN asistencia_reserva ar ON r.reserva_id = ar.reserva_id
WHERE ar.reserva_id IS NULL
  AND r.estado = 'Confirmada';

-- 41. Listar todos los pagos realizados con método tarjeta
SELECT 
    p.pago_id, p.usuario_id, p.factura_id, p.monto, 
    p.metodo_pago, p.fecha_pago, p.estado
FROM pagos p
WHERE p.metodo_pago = 'Tarjeta';

-- 42. Listar pagos pendientes de usuarios
SELECT 
    p.pago_id, p.usuario_id, p.factura_id, p.monto, p.estado
FROM pagos p
WHERE p.estado = 'Pendiente';

-- 43. Mostrar pagos cancelados en los últimos 3 meses
SELECT 
    p.pago_id, p.usuario_id, p.monto, p.fecha_pago, p.estado
FROM pagos p
WHERE p.estado = 'Cancelado'
  AND p.fecha_pago BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 MONTH) AND CURDATE();

-- 44. Listar facturas generadas por membresías
SELECT 
    f.factura_id, f.usuario_id, f.total, f.fecha_emision
FROM facturas f
WHERE f.concepto = 'Membresía';

-- 45. Listar facturas generadas por reservas
SELECT 
    f.factura_id, f.usuario_id, f.total, f.fecha_emision
FROM facturas f
WHERE f.concepto = 'Reserva';

-- 46. Mostrar el total de ingresos por membresías en el último mes
SELECT 
    SUM(f.total) AS total_ingresos_membresias
FROM facturas f
WHERE f.concepto = 'Membresía'
  AND f.fecha_emision BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE()
  AND f.estado = 'Pagada';

-- 47. Mostrar el total de ingresos por reservas en el último mes
SELECT 
    SUM(f.total) AS total_ingresos_reservas
FROM facturas f
WHERE f.concepto = 'Reserva'
  AND f.fecha_emision BETWEEN DATE_SUB(CURDATE(), INTERVAL 1 MONTH) AND CURDATE()
  AND f.estado = 'Pagada';

-- 48. Mostrar el total de ingresos por servicios adicionales
SELECT 
    SUM(f.total) AS total_ingresos_servicios
FROM facturas f
WHERE f.concepto = 'Servicio Adicional'
  AND f.estado = 'Pagada';

-- 49. Identificar usuarios que nunca han pagado con PayPal
SELECT 
    u.usuario_id, u.nombre, u.apellidos
FROM usuarios u
WHERE NOT EXISTS (
    SELECT 1
    FROM pagos p
    WHERE p.usuario_id = u.usuario_id AND p.metodo_pago = 'PayPal'
);

-- 50. Calcular el promedio de gasto por usuario
SELECT 
    ROUND(AVG(total_por_usuario), 2) AS promedio_gasto
FROM (
    SELECT usuario_id, SUM(total) AS total_por_usuario
    FROM facturas
    WHERE estado = 'Pagada'
    GROUP BY usuario_id
) t;

-- 51. Mostrar el top 5 de usuarios que más han pagado en total
SELECT 
    u.usuario_id, u.nombre, u.apellidos, 
    SUM(f.total) AS total_pagado
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE f.estado = 'Pagada'
GROUP BY u.usuario_id
ORDER BY total_pagado DESC
LIMIT 5;

-- 52. Mostrar facturas con monto mayor a $1000
SELECT 
    factura_id, usuario_id, total, fecha_emision
FROM facturas
WHERE total > 1000;

-- 53. Listar pagos realizados después de la fecha de vencimiento
SELECT 
    p.pago_id, p.usuario_id, p.factura_id, p.fecha_pago, f.fecha_vencimiento
FROM pagos p
JOIN facturas f ON p.factura_id = f.factura_id
WHERE p.fecha_pago > f.fecha_vencimiento;

-- 54. Calcular el total recaudado en el año actual
SELECT 
    SUM(f.total) AS total_recaudado_anual
FROM facturas f
WHERE YEAR(f.fecha_emision) = YEAR(CURDATE())
  AND f.estado = 'Pagada';

-- 55. Mostrar facturas anuladas y su motivo
SELECT 
    factura_id, usuario_id, total, motivo_anulacion, fecha_emision
FROM facturas
WHERE estado = 'Anulada';

-- 56. Mostrar usuarios con facturas pendientes mayores a $200
SELECT 
    u.usuario_id, u.nombre, u.apellidos, SUM(f.total) AS total_pendiente
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE f.estado = 'Pendiente'
GROUP BY u.usuario_id
HAVING SUM(f.total) > 200;

-- 57. Mostrar usuarios que han pagado más de una vez el mismo servicio
SELECT 
    p.usuario_id, s.servicio_id, COUNT(p.pago_id) AS cantidad_pagos
FROM pagos p
JOIN servicios_factura s ON p.factura_id = s.factura_id
GROUP BY p.usuario_id, s.servicio_id
HAVING COUNT(p.pago_id) > 1;

-- 58. Listar ingresos por cada método de pago
SELECT 
    p.metodo_pago, SUM(p.monto) AS total_ingresos
FROM pagos p
WHERE p.estado = 'Completado'
GROUP BY p.metodo_pago;

-- 59. Mostrar facturación acumulada por empresa
SELECT 
    u.empresa, SUM(f.total) AS facturacion_total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE u.empresa IS NOT NULL AND f.estado = 'Pagada'
GROUP BY u.empresa
ORDER BY facturacion_total DESC;

-- 60. Mostrar ingresos netos por mes del último año
SELECT 
    DATE_FORMAT(f.fecha_emision, '%Y-%m') AS mes,
    SUM(f.total) AS ingresos_mes
FROM facturas f
WHERE f.estado = 'Pagada'
  AND f.fecha_emision >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(f.fecha_emision, '%Y-%m')
ORDER BY mes ASC;


-- 81. Mostrar los usuarios con el mayor gasto acumulado (subconsulta con SUM)
SELECT 
    u.usuario_id, u.nombre, u.apellidos,
    (SELECT SUM(p.monto) FROM pagos p WHERE p.usuario_id = u.usuario_id) AS gasto_total
FROM usuarios u
ORDER BY gasto_total DESC;

-- 82. Mostrar los espacios más ocupados considerando reservas confirmadas y asistencias reales
SELECT 
    e.espacio_id, e.nombre, COUNT(r.reserva_id) AS total_reservas
FROM espacios e
JOIN reservas r ON e.espacio_id = r.espacio_id
WHERE r.estado = 'Confirmada'
  AND EXISTS (
    SELECT 1 FROM accesos a WHERE a.reserva_id = r.reserva_id
  )
GROUP BY e.espacio_id
ORDER BY total_reservas DESC;

-- 83. Calcular el promedio de ingresos por usuario usando subconsultas
SELECT 
    ROUND(
        (SELECT SUM(p.monto) FROM pagos p) / 
        (SELECT COUNT(*) FROM usuarios), 2
    ) AS promedio_ingresos_usuario;

-- 84. Listar usuarios que tienen reservas activas y facturas pendientes
SELECT DISTINCT 
    u.usuario_id, u.nombre, u.apellidos
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id AND r.estado = 'Activa'
JOIN facturas f ON u.usuario_id = f.usuario_id AND f.estado = 'Pendiente';

-- 85. Mostrar empresas cuyos empleados generan más del 20% de los ingresos totales
SELECT 
    u.empresa, SUM(p.monto) AS ingresos_empresa
FROM usuarios u
JOIN pagos p ON u.usuario_id = p.usuario_id
GROUP BY u.empresa
HAVING SUM(p.monto) > 0.2 * (SELECT SUM(monto) FROM pagos);

-- 86. Mostrar el top 5 de usuarios que más usan servicios adicionales
SELECT 
    u.usuario_id, u.nombre, COUNT(s.servicio_id) AS total_servicios
FROM usuarios u
JOIN servicios_usuarios s ON u.usuario_id = s.usuario_id
GROUP BY u.usuario_id
ORDER BY total_servicios DESC
LIMIT 5;

-- 87. Mostrar reservas que generaron facturas mayores al promedio
SELECT 
    r.reserva_id, r.usuario_id, f.total
FROM reservas r
JOIN facturas f ON r.reserva_id = f.reserva_id
WHERE f.total > (SELECT AVG(total) FROM facturas);

-- 88. Calcular el porcentaje de ocupación global del coworking por mes
SELECT 
    MONTH(r.fecha_inicio) AS mes,
    ROUND(SUM(TIMESTAMPDIFF(HOUR, r.fecha_inicio, r.fecha_fin)) / 
        (30 * 12 * (SELECT COUNT(*) FROM espacios)) * 100, 2) AS porcentaje_ocupacion
FROM reservas r
WHERE r.estado = 'Confirmada'
GROUP BY mes;

-- 89. Mostrar usuarios que tienen más horas de reserva que el promedio del sistema
SELECT 
    u.usuario_id, u.nombre, 
    SUM(TIMESTAMPDIFF(HOUR, r.fecha_inicio, r.fecha_fin)) AS horas_reservadas
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id
HAVING horas_reservadas > (
    SELECT AVG(duracion_total) 
    FROM (
        SELECT SUM(TIMESTAMPDIFF(HOUR, r2.fecha_inicio, r2.fecha_fin)) AS duracion_total
        FROM reservas r2
        GROUP BY r2.usuario_id
    ) AS t
);

-- 90. Mostrar el top 3 de salas más usadas en el último trimestre
SELECT 
    e.espacio_id, e.nombre, COUNT(r.reserva_id) AS total_reservas
FROM espacios e
JOIN reservas r ON e.espacio_id = r.espacio_id
WHERE r.fecha_inicio >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
GROUP BY e.espacio_id
ORDER BY total_reservas DESC
LIMIT 3;

-- 91. Calcular ingresos promedio por tipo de membresía (agrupado con AVG)
SELECT 
    m.tipo, AVG(p.monto) AS promedio_ingresos
FROM membresias m
JOIN pagos p ON m.usuario_id = p.usuario_id
GROUP BY m.tipo;

-- 92. Mostrar usuarios que pagan solo con un método de pago (subconsulta)
SELECT 
    u.usuario_id, u.nombre
FROM usuarios u
WHERE (
    SELECT COUNT(DISTINCT p.metodo_pago)
    FROM pagos p WHERE p.usuario_id = u.usuario_id
) = 1;

-- 93. Mostrar reservas canceladas por usuarios que nunca asistieron
SELECT 
    r.reserva_id, r.usuario_id, r.estado
FROM reservas r
WHERE r.estado = 'Cancelada'
  AND NOT EXISTS (
    SELECT 1 FROM accesos a WHERE a.reserva_id = r.reserva_id
  );

-- 94. Mostrar facturas con pagos parciales y calcular saldo pendiente
SELECT 
    f.factura_id, f.total, SUM(p.monto) AS total_pagado,
    f.total - SUM(p.monto) AS saldo_pendiente
FROM facturas f
JOIN pagos p ON f.factura_id = p.factura_id
GROUP BY f.factura_id
HAVING saldo_pendiente > 0;

-- 95. Calcular la facturación total de cada empresa y ordenarla de mayor a menor
SELECT 
    u.empresa, SUM(f.total) AS facturacion_total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
GROUP BY u.empresa
ORDER BY facturacion_total DESC;

-- 96. Identificar usuarios que superan en reservas al promedio de su empresa
SELECT 
    u.usuario_id, u.nombre, COUNT(r.reserva_id) AS total_reservas
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id, u.empresa
HAVING total_reservas > (
    SELECT AVG(sub.total)
    FROM (
        SELECT COUNT(r2.reserva_id) AS total
        FROM reservas r2
        JOIN usuarios u2 ON r2.usuario_id = u2.usuario_id
        WHERE u2.empresa = u.empresa
        GROUP BY u2.usuario_id
    ) sub
);

-- 97. Mostrar las 3 empresas con más empleados activos en el coworking
SELECT 
    u.empresa, COUNT(u.usuario_id) AS empleados_activos
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa'
GROUP BY u.empresa
ORDER BY empleados_activos DESC
LIMIT 3;

-- 98. Calcular el porcentaje de usuarios activos frente al total de registrados
SELECT 
    ROUND(
        (SELECT COUNT(*) FROM membresias WHERE estado = 'Activa') / 
        (SELECT COUNT(*) FROM usuarios) * 100, 2
    ) AS porcentaje_activos;

-- 99. Mostrar ingresos mensuales acumulados con función de ventana (OVER)
SELECT 
    DATE_FORMAT(p.fecha_pago, '%Y-%m') AS mes,
    SUM(p.monto) AS ingresos_mes,
    SUM(SUM(p.monto)) OVER (ORDER BY DATE_FORMAT(p.fecha_pago, '%Y-%m')) AS acumulado
FROM pagos p
GROUP BY mes
ORDER BY mes;

-- 100. Mostrar usuarios con más de 10 reservas, más de $500 en facturación y membresía activa
SELECT 
    u.usuario_id, u.nombre, COUNT(r.reserva_id) AS total_reservas, SUM(f.total) AS total_facturado
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN facturas f ON u.usuario_id = f.usuario_id
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa'
GROUP BY u.usuario_id
HAVING total_reservas > 10 AND total_facturado > 500;

-- funcion que permite ver si un usuario tiene una membresia activa

CREATE FUNCTION tiene_membresia_activa(user_id INT) 
RETURNS BOOLEAN
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE membresia_activa BOOLEAN;
    
    SELECT COUNT(*) > 0 INTO membresia_activa
    FROM membresias 
    WHERE usuario_id = user_id 
      AND estado = 'Activa'
      AND CURDATE() BETWEEN fecha_inicio AND fecha_fin;
    
    RETURN membresia_activa;
end;

-- funcion que permite ver la cantidad de dias restantes de membresia de un usuario

CREATE FUNCTION fn_dias_restantes_membresia(user_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE dias_restantes INT;
    
    -- Obtener los días restantes de la membresía activa más reciente
    SELECT DATEDIFF(fecha_fin, CURDATE()) INTO dias_restantes
    FROM membresias 
    WHERE usuario_id = user_id 
      AND estado = 'Activa'
      AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
    ORDER BY fecha_fin DESC
    LIMIT 1;
    
    -- Si no hay membresía activa o ya está vencida, retornar 0
    IF dias_restantes IS NULL OR dias_restantes < 0 THEN
        SET dias_restantes = 0;
    END IF;
    
    RETURN dias_restantes;
end;


-- funcion que devuelve el tipo de membresia que tiene el usuario 

CREATE FUNCTION fn_tipo_membresia(user_id INT) 
RETURNS VARCHAR(50)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE tipo_membresia VARCHAR(50);
    
    -- Obtener el tipo de membresía activa más reciente
    SELECT tm.nombre INTO tipo_membresia
    FROM membresias m
    JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
    WHERE m.usuario_id = user_id 
      AND m.estado = 'Activa'
      AND CURDATE() BETWEEN m.fecha_inicio AND m.fecha_fin
    ORDER BY m.fecha_fin DESC
    LIMIT 1;
    
    -- Si no hay membresía activa, retornar mensaje
    IF tipo_membresia IS NULL THEN
        SET tipo_membresia = 'Sin membresía activa';
    END IF;
    
    RETURN tipo_membresia;
end;

-- funcion que permite ver la cantidad de veces que el usuario ha renovado la membresia 

CREATE FUNCTION fn_renovaciones_membresia(user_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_membresias INT;
    
    -- Contar el número de membresías del usuario
    SELECT COUNT(*) INTO total_membresias
    FROM membresias 
    WHERE usuario_id = user_id;
    
    -- Si no tiene membresías, devolver 0. Si tiene, devolver total_membresias - 1
    IF total_membresias = 0 THEN
        RETURN 0;
    ELSE
        RETURN total_membresias - 1;
    END IF;
end;


-- funcion que devuelve el estado de la membresia 

CREATE FUNCTION fn_estado_membresia_vigente(user_id INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE estado_actual VARCHAR(20);
    
    -- Verificar si tiene una membresía activa y vigente por fecha
    IF EXISTS (
        SELECT 1 FROM membresias 
        WHERE usuario_id = user_id 
        AND estado = 'Activa'
        AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
    ) THEN
        SET estado_actual = 'Activa';
    -- Verificar si tiene una membresía vencida (fecha_fin anterior a hoy)
    ELSEIF EXISTS (
        SELECT 1 FROM membresias 
        WHERE usuario_id = user_id 
        AND fecha_fin < CURDATE()
    ) THEN
        SET estado_actual = 'Vencida';
    -- Verificar si tiene una membresía suspendida
    ELSEIF EXISTS (
        SELECT 1 FROM membresias 
        WHERE usuario_id = user_id 
        AND estado = 'Suspendida'
    ) THEN
        SET estado_actual = 'Suspendida';
    ELSE
        SET estado_actual = 'Sin membresía';
    END IF;
    
    RETURN estado_actual;
end;

-- funcion que permite ver la cantidad de reservas totales que ha tenido el usuario 

CREATE FUNCTION fn_total_reservas(user_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_reservas INT;
    
    -- Contar todas las reservas del usuario
    SELECT COUNT(*) INTO total_reservas
    FROM reservas 
    WHERE usuario_id = user_id;
    
    -- Asegurar que no devuelva NULL
    IF total_reservas IS NULL THEN
        SET total_reservas = 0;
    END IF;
    
    RETURN total_reservas;
end;

-- funcion que permite ver la cantidad de horas reservadas en un periodo de tiempo

CREATE FUNCTION fn_horas_reservadas(
    user_id INT, 
    mes INT, 
    anio INT
) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_horas DECIMAL(10, 2);
    
    -- Calcular la suma de horas de las reservas del usuario en el mes y año especificados
    SELECT COALESCE(SUM(duracion_horas), 0) INTO total_horas
    FROM reservas 
    WHERE usuario_id = user_id
      AND MONTH(fecha_reserva) = mes
      AND YEAR(fecha_reserva) = anio;
    
    RETURN total_horas;
end;

-- funcion que retorna el id del espacio mas usado 

CREATE FUNCTION fn_espacio_mas_reservado() 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE espacio_id_mas_reservado INT;
    
    -- Encontrar el espacio con más reservas
    SELECT espacio_id INTO espacio_id_mas_reservado
    FROM reservas
    GROUP BY espacio_id
    ORDER BY COUNT(*) DESC, espacio_id ASC
    LIMIT 1;
    
    RETURN espacio_id_mas_reservado;
end;

-- funcion que muestra las reservas activas de un usuario

CREATE FUNCTION fn_reservas_activas(user_id INT) 
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE reservas_activas INT;
    
    -- Contar las reservas activas del usuario (Confirmadas o En curso)
    SELECT COUNT(*) INTO reservas_activas
    FROM reservas 
    WHERE usuario_id = user_id
      AND estado IN ('Confirmada', 'En curso');
    
    -- Asegurar que no devuelva NULL
    IF reservas_activas IS NULL THEN
        SET reservas_activas = 0;
    END IF;
    
    RETURN reservas_activas;
end;

-- funcion que permite ver el promedio de tiempo de las reservas 

CREATE FUNCTION fn_duracion_promedio_reservas(espacio_id_param INT) 
RETURNS DECIMAL(10, 2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE promedio_duracion DECIMAL(10, 2);
    
    -- Calcular el promedio de duración de las reservas no canceladas para el espacio específico
    SELECT COALESCE(AVG(duracion_horas), 0) INTO promedio_duracion
    FROM reservas 
    WHERE espacio_id = espacio_id_param
      AND estado != 'Cancelada';
    
    RETURN promedio_duracion;
end;

