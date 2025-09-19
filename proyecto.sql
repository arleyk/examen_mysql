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

-- =======================================================
-- 1.2.2. Inserciones adicionales hasta 50 registros por tabla
-- =======================================================

-- 1. Usuarios adicionales (40 más)
INSERT INTO usuarios (nombre, apellidos, fecha_nacimiento, email, telefono, empresa, documento_id) VALUES
('Lucía', 'Hernández Gil', '1990-02-18', 'lucia@email.com', '+34600123457', 'Tech Solutions', '12345678B'),
('Javier', 'Díaz Castro', '1988-07-22', 'javier@email.com', '+34611234568', 'Design Studio', '87654321C'),
('Sofía', 'Pérez López', '1993-11-15', 'sofia@email.com', '+34622345679', NULL, '13579246D'),
('Daniel', 'Ruiz Martín', '1985-04-30', 'daniel@email.com', '+34633456790', 'Data Analytics', '24681357E'),
('Eva', 'Gómez Sánchez', '1994-09-12', 'eva@email.com', '+34644567891', NULL, '98765432F'),
('Miguel', 'Serrano Torres', '1991-12-05', 'miguel@email.com', '+34655678902', 'Web Developers', '55544433G'),
('Carmen', 'Ortega Navarro', '1987-03-28', 'carmen@email.com', '+34666789013', 'Consulting Group', '11122233H'),
('Alejandro', 'Jiménez Ruiz', '1995-06-14', 'alejandro@email.com', '+34677890124', 'Creative Minds', '99988877I'),
('Isabel', 'Molina Vargas', '1989-08-07', 'isabel@email.com', '+34688901235', NULL, '44455566J'),
('Raúl', 'Castro Méndez', '1992-01-23', 'raul@email.com', '+34699012346', 'Tech Innovations', '77788899K'),
('Teresa', 'Santos León', '1990-05-19', 'teresa@email.com', '+34600123458', 'Tech Solutions', '12345678C'),
('Roberto', 'Lorenzo Campos', '1988-07-23', 'roberto@email.com', '+34611234569', 'Design Studio', '87654321D'),
('Olga', 'Vázquez Iglesias', '1993-11-16', 'olga@email.com', '+34622345680', NULL, '13579246E'),
('Francisco', 'Romero Silva', '1985-04-31', 'francisco@email.com', '+34633456791', 'Data Analytics', '24681357F'),
('Patricia', 'Núñez Cordero', '1994-09-13', 'patricia@email.com', '+34644567892', NULL, '98765432G'),
('Andrés', 'Méndez Peña', '1991-12-06', 'andres@email.com', '+34655678903', 'Web Developers', '55544433H'),
('Rosa', 'Gil Rojas', '1987-03-29', 'rosa@email.com', '+34666789014', 'Consulting Group', '11122233I'),
('Jorge', 'Herrera Soto', '1995-06-15', 'jorge@email.com', '+34677890125', 'Creative Minds', '99988877J'),
('Silvia', 'Flores Campos', '1989-08-08', 'silvia@email.com', '+34688901236', NULL, '44455566K'),
('Víctor', 'Reyes Ortega', '1992-01-24', 'victor@email.com', '+34699012347', 'Tech Innovations', '77788899L'),
('Beatriz', 'Cabrera Guzmán', '1990-05-20', 'beatriz@email.com', '+34600123459', 'Tech Solutions', '12345678D'),
('Alberto', 'Otero Montes', '1988-07-24', 'alberto@email.com', '+34611234570', 'Design Studio', '87654321E'),
('Nuria', 'Santana Pacheco', '1993-11-17', 'nuria@email.com', '+34622345681', NULL, '13579246F'),
('Guillermo', 'Rivas Aguilar', '1985-05-01', 'guillermo@email.com', '+34633456792', 'Data Analytics', '24681357G'),
('Concepción', 'Márquez Delgado', '1994-09-14', 'concepcion@email.com', '+34644567893', NULL, '98765432H'),
('Ricardo', 'Campos Calderón', '1991-12-07', 'ricardo@email.com', '+34655678904', 'Web Developers', '55544433I'),
('Aurora', 'Gutiérrez Vega', '1987-03-30', 'aurora@email.com', '+34666789015', 'Consulting Group', '11122233J'),
('Felix', 'Soto Cruz', '1995-06-16', 'felix@email.com', '+34677890126', 'Creative Minds', '99988877K'),
('Lorena', 'Iglesias Reyes', '1989-08-09', 'lorena@email.com', '+34688901237', NULL, '44455566L'),
('Héctor', 'Fuentes Navarro', '1992-01-25', 'hector@email.com', '+34699012348', 'Tech Innovations', '77788899M'),
('Marina', 'Cruz Molina', '1990-05-21', 'marina@email.com', '+34600123460', 'Tech Solutions', '12345678E'),
('Santiago', 'Montes Serrano', '1988-07-25', 'santiago@email.com', '+34611234571', 'Design Studio', '87654321F'),
('Ester', 'Pacheco López', '1993-11-18', 'ester@email.com', '+34622345682', NULL, '13579246G'),
('Jonatan', 'Aguilar Martínez', '1985-05-02', 'jonatan@email.com', '+34633456793', 'Data Analytics', '24681357H'),
('Amparo', 'Delgado Fernández', '1994-09-15', 'amparo@email.com', '+34644567894', NULL, '98765432I'),
('Fermín', 'Calderón González', '1991-12-08', 'fermin@email.com', '+34655678905', 'Web Developers', '55544433J'),
('Clara', 'Vega Díaz', '1987-03-31', 'clara@email.com', '+34666789016', 'Consulting Group', '11122233K'),
('Nicolás', 'Cruz Sánchez', '1995-06-17', 'nicolas@email.com', '+34677890127', 'Creative Minds', '99988877L'),
('Miriam', 'Reyes Pérez', '1989-08-10', 'miriam@email.com', '+34688901238', NULL, '44455566M'),
('Saúl', 'Navarro Torres', '1992-01-26', 'saul@email.com', '+34699012349', 'Tech Innovations', '77788899N');

-- 2. Tipos de membresía adicionales (ya tenemos 10, no es necesario añadir más)

-- 3. Membresías adicionales (40 más)
INSERT INTO membresias (usuario_id, tipo_membresia_id, fecha_inicio, fecha_fin, estado, precio_final) VALUES
(11, 1, '2024-03-01', '2024-03-31', 'Activa', 99.99),
(12, 2, '2024-03-05', '2024-04-04', 'Activa', 199.99),
(13, 3, '2024-03-10', '2024-04-09', 'Vencida', 449.99),
(14, 4, '2024-03-15', '2024-03-15', 'Activa', 0.00),
(15, 5, '2024-03-20', '2024-04-19', 'Activa', 79.99),
(16, 6, '2024-04-01', '2024-05-01', 'Activa', 69.99),
(17, 7, '2024-04-05', '2024-04-05', 'Vencida', 19.99),
(18, 8, '2024-04-10', '2024-05-10', 'Activa', 29.99),
(19, 9, '2024-04-15', '2024-04-15', 'Activa', 39.99),
(20, 10, '2024-04-20', '2024-04-20', 'Vencida', 49.99),
(21, 1, '2024-05-01', '2024-05-31', 'Activa', 99.99),
(22, 2, '2024-05-05', '2024-06-04', 'Activa', 199.99),
(23, 3, '2024-05-10', '2024-06-09', 'Suspendida', 449.99),
(24, 4, '2024-05-15', '2024-05-15', 'Activa', 0.00),
(25, 5, '2024-05-20', '2024-06-19', 'Activa', 79.99),
(26, 6, '2024-06-01', '2024-07-01', 'Activa', 69.99),
(27, 7, '2024-06-05', '2024-06-05', 'Vencida', 19.99),
(28, 8, '2024-06-10', '2024-07-10', 'Activa', 29.99),
(29, 9, '2024-06-15', '2024-06-15', 'Activa', 39.99),
(30, 10, '2024-06-20', '2024-06-20', 'Vencida', 49.99),
(31, 1, '2024-07-01', '2024-07-31', 'Activa', 99.99),
(32, 2, '2024-07-05', '2024-08-04', 'Activa', 199.99),
(33, 3, '2024-07-10', '2024-08-09', 'Vencida', 449.99),
(34, 4, '2024-07-15', '2024-07-15', 'Activa', 0.00),
(35, 5, '2024-07-20', '2024-08-19', 'Activa', 79.99),
(36, 6, '2024-08-01', '2024-09-01', 'Activa', 69.99),
(37, 7, '2024-08-05', '2024-08-05', 'Vencida', 19.99),
(38, 8, '2024-08-10', '2024-09-10', 'Activa', 29.99),
(39, 9, '2024-08-15', '2024-08-15', 'Activa', 39.99),
(40, 10, '2024-08-20', '2024-08-20', 'Vencida', 49.99),
(41, 1, '2024-09-01', '2024-09-30', 'Activa', 99.99),
(42, 2, '2024-09-05', '2024-10-05', 'Activa', 199.99),
(43, 3, '2024-09-10', '2024-10-10', 'Suspendida', 449.99),
(44, 4, '2024-09-15', '2024-09-15', 'Activa', 0.00),
(45, 5, '2024-09-20', '2024-10-20', 'Activa', 79.99),
(46, 6, '2024-10-01', '2024-11-01', 'Activa', 69.99),
(47, 7, '2024-10-05', '2024-10-05', 'Vencida', 19.99),
(48, 8, '2024-10-10', '2024-11-10', 'Activa', 29.99),
(49, 9, '2024-10-15', '2024-10-15', 'Activa', 39.99),
(50, 10, '2024-10-20', '2024-10-20', 'Vencida', 49.99);

-- 4. Espacios adicionales (40 más)
INSERT INTO espacios (nombre, tipo_espacio, capacidad_max, descripcion, precio_hora, precio_dia, estado, caracteristicas) VALUES
('Sala Amsterdam', 'Sala de reuniones', 6, 'Sala con decoración moderna', 14.00, 90.00, 'Disponible', 'Pantalla 50", café incluido'),
('Oficina Roma', 'Oficina privada', 3, 'Oficina con estilo clásico', 18.00, 130.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio C3', 'Escritorio flexible', 1, 'En zona tranquila', 4.50, 28.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events II', 'Sala de eventos', 40, 'Espacio para talleres', 90.00, 550.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Kyoto', 'Sala de reuniones', 4, 'Estilo minimalista', 11.00, 75.00, 'Disponible', 'Té verde gratis'),
('Oficina Barcelona', 'Oficina privada', 5, 'Vistas a la ciudad', 22.00, 160.00, 'No disponible', 'Biblioteca incluida'),
('Escritorio D4', 'Escritorio flexible', 1, 'Zona colaborativa', 5.50, 32.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Lisboa', 'Sala de reuniones', 8, 'Mesa de reuniones mediana', 16.00, 110.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Berlin', 'Oficina privada', 7, 'Diseño industrial', 28.00, 190.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone II', 'Escritorio flexible', 30, 'Zona abierta secundaria', 2.50, 18.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Vienna', 'Sala de reuniones', 7, 'Sala acogedora', 15.00, 95.00, 'Disponible', 'Pantalla 55", café incluido'),
('Oficina Dublin', 'Oficina privada', 4, 'Estilo rústico', 19.00, 140.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio E5', 'Escritorio flexible', 1, 'Zona silenciosa', 5.00, 30.00, 'Mantenimiento', 'Monitor externo opcional'),
('Sala Events III', 'Sala de eventos', 60, 'Espacio para conferencias grandes', 110.00, 650.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Osaka', 'Sala de reuniones', 5, 'Estilo japonés', 12.50, 85.00, 'Disponible', 'Té verde gratis'),
('Oficina Milan', 'Oficina privada', 6, 'Diseño elegante', 24.00, 170.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio F6', 'Escritorio flexible', 1, 'Zona networking', 4.00, 26.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Porto', 'Sala de reuniones', 9, 'Mesa de reuniones grande', 17.00, 115.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Munich', 'Oficina privada', 8, 'Vistas al jardín', 29.00, 195.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone III', 'Escritorio flexible', 40, 'Zona abierta terciaria', 3.50, 22.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Prague', 'Sala de reuniones', 6, 'Sala con estilo bohemio', 13.50, 88.00, 'Disponible', 'Pantalla 50", café incluido'),
('Oficina Athens', 'Oficina privada', 3, 'Estilo mediterráneo', 17.50, 125.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio G7', 'Escritorio flexible', 1, 'En zona luminosa', 4.75, 29.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events IV', 'Sala de eventos', 55, 'Espacio para presentaciones', 95.00, 580.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Hiroshima', 'Sala de reuniones', 4, 'Estilo tradicional', 11.50, 78.00, 'Disponible', 'Té verde gratis'),
('Oficina Valencia', 'Oficina privada', 5, 'Vistas al mar', 21.50, 155.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio H8', 'Escritorio flexible', 1, 'Zona creativa', 5.25, 31.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Coimbra', 'Sala de reuniones', 8, 'Mesa de reuniones moderna', 16.50, 105.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Hamburg', 'Oficina privada', 7, 'Diseño contemporáneo', 27.50, 185.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone IV', 'Escritorio flexible', 35, 'Zona abierta', 3.00, 20.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Budapest', 'Sala de reuniones', 7, 'Sala con detalles clásicos', 14.50, 92.00, 'Disponible', 'Pantalla 55", café incluido'),
('Oficina Edinburgh', 'Oficina privada', 4, 'Estilo victoriano', 18.50, 135.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio I9', 'Escritorio flexible', 1, 'Zona tranquila', 5.50, 33.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events V', 'Sala de eventos', 45, 'Espacio íntimo', 85.00, 520.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Nagoya', 'Sala de reuniones', 5, 'Estilo zen', 12.00, 80.00, 'Disponible', 'Té verde gratis'),
('Oficina Seville', 'Oficina privada', 6, 'Patio andaluz', 23.50, 165.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio J10', 'Escritorio flexible', 1, 'Zona inspiradora', 4.25, 27.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Braga', 'Sala de reuniones', 9, 'Mesa de reuniones ejecutiva', 17.50, 112.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Cologne', 'Oficina privada', 8, 'Vistas al río', 28.50, 192.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone V', 'Escritorio flexible', 25, 'Zona acogedora', 2.75, 19.00, 'Disponible', '24/7 access, coffee bar');

-- 5. Reservas adicionales (40 más)
-- Continuamos desde la reserva_id 11
INSERT INTO reservas (usuario_id, espacio_id, fecha_reserva, hora_inicio, hora_fin, duracion_horas, estado, precio_total) VALUES
(11, 11, '2024-03-10', '10:00:00', '12:00:00', 2.00, 'Finalizada', 28.00),
(12, 12, '2024-03-11', '11:00:00', '13:00:00', 2.00, 'Finalizada', 38.00),
(13, 13, '2024-03-12', '14:00:00', '16:00:00', 2.00, 'Cancelada', 9.00),
(14, 14, '2024-03-13', '15:00:00', '17:00:00', 2.00, 'En curso', 180.00),
(15, 15, '2024-03-14', '16:00:00', '18:00:00', 2.00, 'Confirmada', 23.00),
(16, 16, '2024-03-15', '09:00:00', '11:00:00', 2.00, 'Confirmada', 48.00),
(17, 17, '2024-03-16', '10:00:00', '12:00:00', 2.00, 'Finalizada', 8.00),
(18, 18, '2024-03-17', '11:00:00', '13:00:00', 2.00, 'Confirmada', 32.00),
(19, 19, '2024-03-18', '12:00:00', '14:00:00', 2.00, 'Confirmada', 56.00),
(20, 20, '2024-03-19', '13:00:00', '15:00:00', 2.00, 'Confirmada', 5.00),
(21, 21, '2024-03-20', '14:00:00', '16:00:00', 2.00, 'Confirmada', 27.00),
(22, 22, '2024-03-21', '15:00:00', '17:00:00', 2.00, 'Confirmada', 37.00),
(23, 23, '2024-03-22', '16:00:00', '18:00:00', 2.00, 'Cancelada', 9.50),
(24, 24, '2024-03-23', '17:00:00', '19:00:00', 2.00, 'En curso', 190.00),
(25, 25, '2024-03-24', '18:00:00', '20:00:00', 2.00, 'Confirmada', 23.00),
(26, 26, '2024-03-25', '09:00:00', '11:00:00', 2.00, 'Confirmada', 47.00),
(27, 27, '2024-03-26', '10:00:00', '12:00:00', 2.00, 'Finalizada', 8.50),
(28, 28, '2024-03-27', '11:00:00', '13:00:00', 2.00, 'Confirmada', 33.00),
(29, 29, '2024-03-28', '12:00:00', '14:00:00', 2.00, 'Confirmada', 55.00),
(30, 30, '2024-03-29', '13:00:00', '15:00:00', 2.00, 'Confirmada', 6.00),
(31, 31, '2024-03-30', '14:00:00', '16:00:00', 2.00, 'Confirmada', 29.00),
(32, 32, '2024-03-31', '15:00:00', '17:00:00', 2.00, 'Confirmada', 37.00),
(33, 33, '2024-04-01', '16:00:00', '18:00:00', 2.00, 'Cancelada', 9.50),
(34, 34, '2024-04-02', '17:00:00', '19:00:00', 2.00, 'En curso', 190.00),
(35, 35, '2024-04-03', '18:00:00', '20:00:00', 2.00, 'Confirmada', 23.00),
(36, 36, '2024-04-04', '09:00:00', '11:00:00', 2.00, 'Confirmada', 47.00),
(37, 37, '2024-04-05', '10:00:00', '12:00:00', 2.00, 'Finalizada', 8.50),
(38, 38, '2024-04-06', '11:00:00', '13:00:00', 2.00, 'Confirmada', 33.00),
(39, 39, '2024-04-07', '12:00:00', '14:00:00', 2.00, 'Confirmada', 55.00),
(40, 40, '2024-04-08', '13:00:00', '15:00:00', 2.00, 'Confirmada', 6.00),
(41, 41, '2024-04-09', '14:00:00', '16:00:00', 2.00, 'Confirmada', 29.00),
(42, 42, '2024-04-10', '15:00:00', '17:00:00', 2.00, 'Confirmada', 37.00),
(43, 43, '2024-04-11', '16:00:00', '18:00:00', 2.00, 'Cancelada', 9.50),
(44, 44, '2024-04-12', '17:00:00', '19:00:00', 2.00, 'En curso', 190.00),
(45, 45, '2024-04-13', '18:00:00', '20:00:00', 2.00, 'Confirmada', 23.00),
(46, 46, '2024-04-14', '09:00:00', '11:00:00', 2.00, 'Confirmada', 47.00),
(47, 47, '2024-04-15', '10:00:00', '12:00:00', 2.00, 'Finalizada', 8.50),
(48, 48, '2024-04-16', '11:00:00', '13:00:00', 2.00, 'Confirmada', 33.00),
(49, 49, '2024-04-17', '12:00:00', '14:00:00', 2.00, 'Confirmada', 55.00),
(50, 50, '2024-04-18', '13:00:00', '15:00:00', 2.00, 'Confirmada', 6.00);

-- 6. Servicios adicionales (40 más)
INSERT INTO servicios (nombre, descripcion, precio, tipo_servicio, disponible) VALUES
('Internet Básico', '100 Mbps compartido', 4.99, 'Internet', TRUE),
('Alquiler Portátil', 'Portátil HP 15"', 10.00, 'Equipamiento', TRUE),
('Impresiones Blanco/Negro', 'Hasta 100 páginas', 0.10, 'Consumibles', TRUE),
('Lockers Pequeños', 'Lockers 24h', 1.50, 'Almacenamiento', TRUE),
('Cabina Videollamadas', 'Cabina insonorizada con webcam', 10.00, 'Equipamiento', TRUE),
('Coffee Pack Premium', 'Café especial ilimitado', 5.00, 'Consumibles', TRUE),
('Mensajería', 'Gestión de mensajería urgente', 15.00, 'Almacenamiento', TRUE),
('Pantalla Táctil', 'Pantalla táctil 65"', 20.00, 'Equipamiento', TRUE),
('Escáner A4', 'Escáner rápido', 3.00, 'Equipamiento', TRUE),
('Recepción Paquetes Grande', 'Recepción y almacenamiento grande', 2.50, 'Almacenamiento', TRUE),
('Internet Empresarial', '500 Mbps dedicado', 19.99, 'Internet', TRUE),
('Alquiler Tablet', 'Tablet iPad', 7.00, 'Equipamiento', TRUE),
('Fotocopias Color', 'Hasta 50 páginas', 0.30, 'Consumibles', TRUE),
('Lockers Grandes', 'Lockers 48h', 3.00, 'Almacenamiento', TRUE),
('Sala Streaming', 'Equipo streaming completo', 25.00, 'Equipamiento', TRUE),
('Refresh Pack', 'Bebidas energéticas y snacks', 8.00, 'Consumibles', TRUE),
('Gestión Postal', 'Gestión de correo postal', 20.00, 'Almacenamiento', TRUE),
('Micrófono Profesional', 'Micrófono Shure', 12.00, 'Equipamiento', TRUE),
('Impresora 3D', 'Uso de impresora 3D', 18.00, 'Equipamiento', TRUE),
('Almacenamiento Archivos', 'Almacenamiento físico de archivos', 5.00, 'Almacenamiento', TRUE),
('Internet Gaming', '2 Gbps baja latencia', 29.99, 'Internet', TRUE),
('Alquiler Monitor Curvo', 'Monitor curvo 32"', 8.00, 'Equipamiento', TRUE),
('Tóner Impresora', 'Recambio tóner color', 50.00, 'Consumibles', FALSE),
('Lockers con Carga', 'Lockers con carga para dispositivos', 4.00, 'Almacenamiento', TRUE),
('Sala Podcast', 'Equipo podcast completo', 30.00, 'Equipamiento', TRUE),
('Lunch Pack', 'Comida ligera y bebida', 12.00, 'Consumibles', TRUE),
('Digitalización Documents', 'Digitalización de documentos', 0.50, 'Almacenamiento', TRUE),
('Cámara Video', 'Cámara 4K profesional', 25.00, 'Equipamiento', TRUE),
('Plotter Impresión', 'Plotter de impresión A0', 35.00, 'Equipamiento', TRUE),
('Archivado físico', 'Archivado físico mensual', 10.00, 'Almacenamiento', TRUE),
('Internet Respaldo', 'Conexión de respaldo', 9.99, 'Internet', TRUE),
('Alquiler Silla Ergonómica', 'Silla ergonómica premium', 5.00, 'Equipamiento', TRUE),
('Papel Premium', 'Resma de papel premium', 15.00, 'Consumibles', TRUE),
('Lockers con Refrigeración', 'Lockers refrigerados', 6.00, 'Almacenamiento', FALSE),
('Sala Fotografía', 'Sala con equipo fotografía', 40.00, 'Equipamiento', TRUE),
('Wellness Pack', 'Agua infusionada y fruta', 6.00, 'Consumibles', TRUE),
('Gestión Paquetes Frágiles', 'Gestión especial para frágiles', 8.00, 'Almacenamiento', TRUE),
('Trípode', 'Trípode profesional', 7.00, 'Equipamiento', TRUE),
('Impresión Gran Formato', 'Impresión hasta A0', 45.00, 'Equipamiento', TRUE),
('Bóveda Seguridad', 'Almacenamiento en caja fuerte', 20.00, 'Almacenamiento', TRUE);

-- 7. Servicios_reserva adicionales (40 más)
INSERT INTO servicios_reserva (reserva_id, servicio_id, cantidad, precio_unitario, precio_total) VALUES
(11, 11, 1, 4.99, 4.99),
(12, 12, 1, 10.00, 10.00),
(13, 13, 30, 0.10, 3.00),
(14, 14, 2, 1.50, 3.00),
(15, 15, 1, 10.00, 10.00),
(16, 16, 1, 5.00, 5.00),
(17, 17, 1, 15.00, 15.00),
(18, 18, 1, 20.00, 20.00),
(19, 19, 1, 3.00, 3.00),
(20, 20, 3, 2.50, 7.50),
(21, 21, 1, 19.99, 19.99),
(22, 22, 1, 7.00, 7.00),
(23, 23, 1, 50.00, 50.00),
(24, 24, 1, 4.00, 4.00),
(25, 25, 1, 30.00, 30.00),
(26, 26, 1, 12.00, 12.00),
(27, 27, 100, 0.50, 50.00),
(28, 28, 1, 25.00, 25.00),
(29, 29, 1, 35.00, 35.00),
(30, 30, 1, 10.00, 10.00),
(31, 31, 1, 9.99, 9.99),
(32, 32, 2, 5.00, 10.00),
(33, 33, 1, 15.00, 15.00),
(34, 34, 1, 6.00, 6.00),
(35, 35, 1, 40.00, 40.00),
(36, 36, 1, 6.00, 6.00),
(37, 37, 2, 8.00, 16.00),
(38, 38, 1, 7.00, 7.00),
(39, 39, 1, 45.00, 45.00),
(40, 40, 1, 20.00, 20.00),
(41, 11, 1, 4.99, 4.99),
(42, 12, 1, 10.00, 10.00),
(43, 13, 30, 0.10, 3.00),
(44, 14, 2, 1.50, 3.00),
(45, 15, 1, 10.00, 10.00),
(46, 16, 1, 5.00, 5.00),
(47, 17, 1, 15.00, 15.00),
(48, 18, 1, 20.00, 20.00),
(49, 19, 1, 3.00, 3.00),
(50, 20, 3, 2.50, 7.50);

-- 8. Facturas adicionales (40 más)
INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles) VALUES
(11, '2024-03-31', 'Membresía', 11, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica marzo'),
(12, '2024-04-04', 'Membresía', 12, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium abril'),
(13, '2024-04-09', 'Membresía', 13, 449.99, 94.50, 544.49, 'Vencida', 'Membresía Empresa abril'),
(14, '2024-03-15', 'Membresía', 14, 0.00, 0.00, 0.00, 'Pagada', 'Membresía Flex marzo'),
(15, '2024-04-19', 'Membresía', 15, 79.99, 16.80, 96.79, 'Pagada', 'Membresía Nocturna abril'),
(16, '2024-05-01', 'Membresía', 16, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante mayo'),
(17, '2024-04-05', 'Membresía', 17, 19.99, 4.20, 24.19, 'Vencida', 'Day Pass abril'),
(18, '2024-05-10', 'Membresía', 18, 29.99, 6.30, 36.29, 'Pagada', 'Membresía Virtual mayo'),
(19, '2024-04-15', 'Membresía', 19, 39.99, 8.40, 48.39, 'Pagada', 'Meeting Pass abril'),
(20, '2024-04-20', 'Membresía', 20, 49.99, 10.50, 60.49, 'Vencida', 'Event Pass abril'),
(21, '2024-05-31', 'Membresía', 21, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica mayo'),
(22, '2024-06-04', 'Membresía', 22, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium junio'),
(23, '2024-06-09', 'Membresía', 23, 449.99, 94.50, 544.49, 'Pendiente', 'Membresía Empresa junio'),
(24, '2024-05-15', 'Membresía', 24, 0.00, 0.00, 0.00, 'Pagada', 'Membresía Flex mayo'),
(25, '2024-06-19', 'Membresía', 25, 79.99, 16.80, 96.79, 'Pagada', 'Membresía Nocturna junio'),
(26, '2024-07-01', 'Membresía', 26, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante julio'),
(27, '2024-06-05', 'Membresía', 27, 19.99, 4.20, 24.19, 'Vencida', 'Day Pass junio'),
(28, '2024-07-10', 'Membresía', 28, 29.99, 6.30, 36.29, 'Pagada', 'Membresía Virtual julio'),
(29, '2024-06-15', 'Membresía', 29, 39.99, 8.40, 48.39, 'Pagada', 'Meeting Pass junio'),
(30, '2024-06-20', 'Membresía', 30, 49.99, 10.50, 60.49, 'Vencida', 'Event Pass junio'),
(31, '2024-07-31', 'Membresía', 31, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica julio'),
(32, '2024-08-04', 'Membresía', 32, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium agosto'),
(33, '2024-08-09', 'Membresía', 33, 449.99, 94.50, 544.49, 'Pendiente', 'Membresía Empresa agosto'),
(34, '2024-07-15', 'Membresía', 34, 0.00, 0.00, 0.00, 'Pagada', 'Membresía Flex julio'),
(35, '2024-08-19', 'Membresía', 35, 79.99, 16.80, 96.79, 'Pagada', 'Membresía Nocturna agosto'),
(36, '2024-09-01', 'Membresía', 36, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante septiembre'),
(37, '2024-08-05', 'Membresía', 37, 19.99, 4.20, 24.19, 'Vencida', 'Day Pass agosto'),
(38, '2024-09-10', 'Membresía', 38, 29.99, 6.30, 36.29, 'Pagada', 'Membresía Virtual septiembre'),
(39, '2024-08-15', 'Membresía', 39, 39.99, 8.40, 48.39, 'Pagada', 'Meeting Pass agosto'),
(40, '2024-08-20', 'Membresía', 40, 49.99, 10.50, 60.49, 'Vencida', 'Event Pass agosto'),
(41, '2024-09-30', 'Membresía', 41, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica septiembre'),
(42, '2024-10-05', 'Membresía', 42, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium octubre'),
(43, '2024-10-10', 'Membresía', 43, 449.99, 94.50, 544.49, 'Pendiente', 'Membresía Empresa octubre'),
(44, '2024-09-15', 'Membresía', 44, 0.00, 0.00, 0.00, 'Pagada', 'Membresía Flex septiembre'),
(45, '2024-10-20', 'Membresía', 45, 79.99, 16.80, 96.79, 'Pagada', 'Membresía Nocturna octubre'),
(46, '2024-11-01', 'Membresía', 46, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante noviembre'),
(47, '2024-10-05', 'Membresía', 47, 19.99, 4.20, 24.19, 'Vencida', 'Day Pass octubre'),
(48, '2024-11-10', 'Membresía', 48, 29.99, 6.30, 36.29, 'Pagada', 'Membresía Virtual noviembre'),
(49, '2024-10-15', 'Membresía', 49, 39.99, 8.40, 48.39, 'Pagada', 'Meeting Pass octubre'),
(50, '2024-10-20', 'Membresía', 50, 49.99, 10.50, 60.49, 'Vencida', 'Event Pass octubre');

-- 9. Pagos adicionales (40 más)
INSERT INTO pagos (factura_id, metodo_pago, monto, fecha_pago, referencia, estado, detalles) VALUES
(11, 'Tarjeta', 120.99, '2024-03-31 10:30:00', 'REF123457', 'Completado', 'Pago completo con Visa'),
(12, 'PayPal', 241.99, '2024-04-04 14:22:00', 'PP987655', 'Completado', 'Pago via PayPal'),
(13, 'Transferencia', 544.49, '2024-04-10 09:45:00', 'TRF555445', 'Fallido', 'Transferencia no recibida'),
(14, 'Efectivo', 0.00, '2024-03-15 16:10:00', 'CASH790', 'Completado', 'Pago en efectivo'),
(15, 'Tarjeta', 96.79, '2024-04-19 11:30:00', 'REF333223', 'Completado', 'Pago con Mastercard'),
(16, 'Tarjeta', 84.69, '2024-05-01 12:05:00', 'REF111223', 'Completado', 'Pago con American Express'),
(17, 'PayPal', 24.19, '2024-04-05 13:15:00', 'PP444556', 'Reembolsado', 'Cancelación membresía'),
(18, 'Transferencia', 36.29, '2024-05-10 08:45:00', 'TRF666778', 'Completado', 'Transferencia recibida'),
(19, 'Efectivo', 48.39, '2024-04-15 17:20:00', 'CASH889', 'Completado', 'Pago en efectivo'),
(20, 'Tarjeta', 60.49, '2024-04-20 10:00:00', 'REF999001', 'Fallido', 'Tarjeta rechazada'),
(21, 'Tarjeta', 120.99, '2024-05-31 10:30:00', 'REF123458', 'Completado', 'Pago completo con Visa'),
(22, 'PayPal', 241.99, '2024-06-04 14:22:00', 'PP987656', 'Completado', 'Pago via PayPal'),
(23, 'Transferencia', 544.49, '2024-06-10 09:45:00', 'TRF555446', 'Pendiente', 'Transferencia en proceso'),
(24, 'Efectivo', 0.00, '2024-05-15 16:10:00', 'CASH791', 'Completado', 'Pago en efectivo'),
(25, 'Tarjeta', 96.79, '2024-06-19 11:30:00', 'REF333224', 'Completado', 'Pago con Mastercard'),
(26, 'Tarjeta', 84.69, '2024-07-01 12:05:00', 'REF111224', 'Completado', 'Pago con American Express'),
(27, 'PayPal', 24.19, '2024-06-05 13:15:00', 'PP444557', 'Reembolsado', 'Cancelación membresía'),
(28, 'Transferencia', 36.29, '2024-07-10 08:45:00', 'TRF666779', 'Completado', 'Transferencia recibida'),
(29, 'Efectivo', 48.39, '2024-06-15 17:20:00', 'CASH890', 'Completado', 'Pago en efectivo'),
(30, 'Tarjeta', 60.49, '2024-06-20 10:00:00', 'REF999002', 'Fallido', 'Tarjeta rechazada'),
(31, 'Tarjeta', 120.99, '2024-07-31 10:30:00', 'REF123459', 'Completado', 'Pago completo con Visa'),
(32, 'PayPal', 241.99, '2024-08-04 14:22:00', 'PP987657', 'Completado', 'Pago via PayPal'),
(33, 'Transferencia', 544.49, '2024-08-10 09:45:00', 'TRF555447', 'Pendiente', 'Transferencia en proceso'),
(34, 'Efectivo', 0.00, '2024-07-15 16:10:00', 'CASH792', 'Completado', 'Pago en efectivo'),
(35, 'Tarjeta', 96.79, '2024-08-19 11:30:00', 'REF333225', 'Completado', 'Pago con Mastercard'),
(36, 'Tarjeta', 84.69, '2024-09-01 12:05:00', 'REF111225', 'Completado', 'Pago con American Express'),
(37, 'PayPal', 24.19, '2024-08-05 13:15:00', 'PP444558', 'Reembolsado', 'Cancelación membresía'),
(38, 'Transferencia', 36.29, '2024-09-10 08:45:00', 'TRF666780', 'Completado', 'Transferencia recibida'),
(39, 'Efectivo', 48.39, '2024-08-15 17:20:00', 'CASH891', 'Completado', 'Pago en efectivo'),
(40, 'Tarjeta', 60.49, '2024-08-20 10:00:00', 'REF999003', 'Fallido', 'Tarjeta rechazada'),
(41, 'Tarjeta', 120.99, '2024-09-30 10:30:00', 'REF123460', 'Completado', 'Pago completo con Visa'),
(42, 'PayPal', 241.99, '2024-10-05 14:22:00', 'PP987658', 'Completado', 'Pago via PayPal'),
(43, 'Transferencia', 544.49, '2024-10-10 09:45:00', 'TRF555448', 'Pendiente', 'Transferencia en proceso'),
(44, 'Efectivo', 0.00, '2024-09-15 16:10:00', 'CASH793', 'Completado', 'Pago en efectivo'),
(45, 'Tarjeta', 96.79, '2024-10-20 11:30:00', 'REF333226', 'Completado', 'Pago con Mastercard'),
(46, 'Tarjeta', 84.69, '2024-11-01 12:05:00', 'REF111226', 'Completado', 'Pago con American Express'),
(47, 'PayPal', 24.19, '2024-10-05 13:15:00', 'PP444559', 'Reembolsado', 'Cancelación membresía'),
(48, 'Transferencia', 36.29, '2024-11-10 08:45:00', 'TRF666781', 'Completado', 'Transferencia recibida'),
(49, 'Efectivo', 48.39, '2024-10-15 17:20:00', 'CASH892', 'Completado', 'Pago en efectivo'),
(50, 'Tarjeta', 60.49, '2024-10-20 10:00:00', 'REF999004', 'Fallido', 'Tarjeta rechazada');

-- 10. Acceso adicional (40 más)
INSERT INTO acceso (usuario_id, espacio_id, fecha_hora_entrada, fecha_hora_salida, metodo_acceso, resultado, motivo_denegacion) VALUES
(11, 11, '2024-03-10 09:58:00', '2024-03-10 12:02:00', 'QR', 'Permitido', NULL),
(12, 12, '2024-03-11 10:55:00', '2024-03-11 13:05:00', 'RFID', 'Permitido', NULL),
(13, 13, '2024-03-12 13:45:00', NULL, 'Manual', 'Denegado', 'Espacio en mantenimiento'),
(14, 14, '2024-03-13 14:59:00', '2024-03-13 17:01:00', 'RFID', 'Permitido', NULL),
(15, 15, '2024-03-14 15:45:00', '2024-03-14 18:00:00', 'QR', 'Permitido', NULL),
(16, 16, '2024-03-15 08:58:00', '2024-03-15 11:02:00', 'RFID', 'Permitido', NULL),
(17, 17, '2024-03-16 09:55:00', '2024-03-16 12:05:00', 'Manual', 'Permitido', NULL),
(18, 18, '2024-03-17 10:58:00', '2024-03-17 13:02:00', 'QR', 'Permitido', NULL),
(19, 19, '2024-03-18 11:55:00', '2024-03-18 14:05:00', 'RFID', 'Permitido', NULL),
(20, 20, '2024-03-19 12:50:00', '2024-03-19 15:00:00', 'Manual', 'Permitido', NULL),
(21, 21, '2024-03-20 13:58:00', '2024-03-20 16:02:00', 'QR', 'Permitido', NULL),
(22, 22, '2024-03-21 14:55:00', '2024-03-21 17:05:00', 'RFID', 'Permitido', NULL),
(23, 23, '2024-03-22 15:45:00', NULL, 'Manual', 'Denegado', 'Reserva cancelada'),
(24, 24, '2024-03-23 16:59:00', '2024-03-23 19:01:00', 'RFID', 'Permitido', NULL),
(25, 25, '2024-03-24 17:45:00', '2024-03-24 20:00:00', 'QR', 'Permitido', NULL),
(26, 26, '2024-03-25 08:58:00', '2024-03-25 11:02:00', 'RFID', 'Permitido', NULL),
(27, 27, '2024-03-26 09:55:00', '2024-03-26 12:05:00', 'Manual', 'Permitido', NULL),
(28, 28, '2024-03-27 10:58:00', '2024-03-27 13:02:00', 'QR', 'Permitido', NULL),
(29, 29, '2024-03-28 11:55:00', '2024-03-28 14:05:00', 'RFID', 'Permitido', NULL),
(30, 30, '2024-03-29 12:50:00', '2024-03-29 15:00:00', 'Manual', 'Permitido', NULL),
(31, 31, '2024-03-30 13:58:00', '2024-03-30 16:02:00', 'QR', 'Permitido', NULL),
(32, 32, '2024-03-31 14:55:00', '2024-03-31 17:05:00', 'RFID', 'Permitido', NULL),
(33, 33, '2024-04-01 15:45:00', NULL, 'Manual', 'Denegado', 'Falta de pago'),
(34, 34, '2024-04-02 16:59:00', '2024-04-02 19:01:00', 'RFID', 'Permitido', NULL),
(35, 35, '2024-04-03 17:45:00', '2024-04-03 20:00:00', 'QR', 'Permitido', NULL),
(36, 36, '2024-04-04 08:58:00', '2024-04-04 11:02:00', 'RFID', 'Permitido', NULL),
(37, 37, '2024-04-05 09:55:00', '2024-04-05 12:05:00', 'Manual', 'Permitido', NULL),
(38, 38, '2024-04-06 10:58:00', '2024-04-06 13:02:00', 'QR', 'Permitido', NULL),
(39, 39, '2024-04-07 11:55:00', '2024-04-07 14:05:00', 'RFID', 'Permitido', NULL),
(40, 40, '2024-04-08 12:50:00', '2024-04-08 15:00:00', 'Manual', 'Permitido', NULL),
(41, 41, '2024-04-09 13:58:00', '2024-04-09 16:02:00', 'QR', 'Permitido', NULL),
(42, 42, '2024-04-10 14:55:00', '2024-04-10 17:05:00', 'RFID', 'Permitido', NULL),
(43, 43, '2024-04-11 15:45:00', NULL, 'Manual', 'Denegado', 'Espacio no disponible'),
(44, 44, '2024-04-12 16:59:00', '2024-04-12 19:01:00', 'RFID', 'Permitido', NULL),
(45, 45, '2024-04-13 17:45:00', '2024-04-13 20:00:00', 'QR', 'Permitido', NULL),
(46, 46, '2024-04-14 08:58:00', '2024-04-14 11:02:00', 'RFID', 'Permitido', NULL),
(47, 47, '2024-04-15 09:55:00', '2024-04-15 12:05:00', 'Manual', 'Permitido', NULL),
(48, 48, '2024-04-16 10:58:00', '2024-04-16 13:02:00', 'QR', 'Permitido', NULL),
(49, 49, '2024-04-17 11:55:00', '2024-04-17 14:05:00', 'RFID', 'Permitido', NULL),
(50, 50, '2024-04-18 12:50:00', '2024-04-18 15:00:00', 'Manual', 'Permitido', NULL);

-- 11. Asistencia adicional (40 más)
INSERT INTO asistencia (usuario_id, fecha, hora_entrada, hora_salida, tiempo_total) VALUES
(11, '2024-03-10', '09:58:00', '12:02:00', '02:04:00'),
(12, '2024-03-11', '10:55:00', '13:05:00', '02:10:00'),
(14, '2024-03-13', '14:59:00', '17:01:00', '02:02:00'),
(15, '2024-03-14', '15:45:00', '18:00:00', '02:15:00'),
(16, '2024-03-15', '08:58:00', '11:02:00', '02:04:00'),
(17, '2024-03-16', '09:55:00', '12:05:00', '02:10:00'),
(18, '2024-03-17', '10:58:00', '13:02:00', '02:04:00'),
(19, '2024-03-18', '11:55:00', '14:05:00', '02:10:00'),
(20, '2024-03-19', '12:50:00', '15:00:00', '02:10:00'),
(21, '2024-03-20', '13:58:00', '16:02:00', '02:04:00'),
(22, '2024-03-21', '14:55:00', '17:05:00', '02:10:00'),
(24, '2024-03-23', '16:59:00', '19:01:00', '02:02:00'),
(25, '2024-03-24', '17:45:00', '20:00:00', '02:15:00'),
(26, '2024-03-25', '08:58:00', '11:02:00', '02:04:00'),
(27, '2024-03-26', '09:55:00', '12:05:00', '02:10:00'),
(28, '2024-03-27', '10:58:00', '13:02:00', '02:04:00'),
(29, '2024-03-28', '11:55:00', '14:05:00', '02:10:00'),
(30, '2024-03-29', '12:50:00', '15:00:00', '02:10:00'),
(31, '2024-03-30', '13:58:00', '16:02:00', '02:04:00'),
(32, '2024-03-31', '14:55:00', '17:05:00', '02:10:00'),
(34, '2024-04-02', '16:59:00', '19:01:00', '02:02:00'),
(35, '2024-04-03', '17:45:00', '20:00:00', '02:15:00'),
(36, '2024-04-04', '08:58:00', '11:02:00', '02:04:00'),
(37, '2024-04-05', '09:55:00', '12:05:00', '02:10:00'),
(38, '2024-04-06', '10:58:00', '13:02:00', '02:04:00'),
(39, '2024-04-07', '11:55:00', '14:05:00', '02:10:00'),
(40, '2024-04-08', '12:50:00', '15:00:00', '02:10:00'),
(41, '2024-04-09', '13:58:00', '16:02:00', '02:04:00'),
(42, '2024-04-10', '14:55:00', '17:05:00', '02:10:00'),
(44, '2024-04-12', '16:59:00', '19:01:00', '02:02:00'),
(45, '2024-04-13', '17:45:00', '20:00:00', '02:15:00'),
(46, '2024-04-14', '08:58:00', '11:02:00', '02:04:00'),
(47, '2024-04-15', '09:55:00', '12:05:00', '02:10:00'),
(48, '2024-04-16', '10:58:00', '13:02:00', '02:04:00'),
(49, '2024-04-17', '11:55:00', '14:05:00', '02:10:00'),
(50, '2024-04-18', '12:50:00', '15:00:00', '02:10:00'),
(11, '2024-04-19', '09:00:00', '17:00:00', '08:00:00'),
(12, '2024-04-20', '10:00:00', '16:30:00', '06:30:00'),
(13, '2024-04-21', '08:30:00', '14:30:00', '06:00:00'),
(14, '2024-04-22', '09:15:00', '18:15:00', '09:00:00');

-- 1. Listar todos los usuarios con su información básica
SELECT * FROM usuarios;

-- 2. Listar los usuarios con membresía activa
SELECT u.* 
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa';

-- 3. Listar los usuarios cuya membresía está vencida
SELECT u.* 
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Vencida';

-- 4. Listar los usuarios con membresía suspendida
SELECT u.* 
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Suspendida';

-- 5. Contar cuántos usuarios tienen cada tipo de membresía
SELECT tm.nombre, COUNT(*) as cantidad
FROM membresias m
JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
GROUP BY tm.nombre;

-- 6. Mostrar el top 10 de usuarios con más antigüedad en el coworking
SELECT * 
FROM usuarios 
ORDER BY fecha_registro ASC 
LIMIT 10;

-- 7. Listar usuarios que pertenecen a una empresa específica
SELECT * 
FROM usuarios 
WHERE empresa = 'Tech Solutions';

-- 8. Contar cuántos usuarios están asociados a cada empresa
SELECT empresa, COUNT(*) as cantidad
FROM usuarios
WHERE empresa IS NOT NULL
GROUP BY empresa;

-- 9. Mostrar usuarios que nunca han hecho una reserva
SELECT u.*
FROM usuarios u
LEFT JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE r.reserva_id IS NULL;

-- 10. Mostrar usuarios con más de 5 reservas activas en el mes
SELECT u.usuario_id, u.nombre, COUNT(*) as reservas_count
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE r.estado = 'Confirmada' 
AND MONTH(r.fecha_reserva) = MONTH(CURRENT_DATE())
AND YEAR(r.fecha_reserva) = YEAR(CURRENT_DATE())
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) > 5;

-- 11. Calcular el promedio de edad de los usuarios
SELECT AVG(YEAR(CURRENT_DATE) - YEAR(fecha_nacimiento)) as edad_promedio
FROM usuarios;

-- 12. Listar usuarios que han cambiado de membresía más de 2 veces
SELECT u.usuario_id, u.nombre, COUNT(*) as cambios_membresia
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) > 2;

-- 13. Listar usuarios que han gastado más de $500 en reservas
SELECT u.usuario_id, u.nombre, SUM(r.precio_total) as total_gastado
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id, u.nombre
HAVING SUM(r.precio_total) > 500;

-- 14. Mostrar usuarios que tienen tanto membresía como servicios adicionales
SELECT DISTINCT u.*
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN servicios_reserva sr ON r.reserva_id = sr.reserva_id;

-- 15. Listar usuarios con membresía Premium y reservas activas
SELECT DISTINCT u.*
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE tm.nombre = 'Premium' AND r.estado = 'Confirmada';

-- 16. Mostrar usuarios con membresía Corporativa y su empresa
SELECT u.*, tm.nombre as tipo_membresia
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
WHERE tm.nombre = 'Empresa' AND u.empresa IS NOT NULL;

-- 17. Identificar usuarios con membresía diaria que la han renovado más de 10 veces
SELECT u.usuario_id, u.nombre, COUNT(*) as renovaciones
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
WHERE tm.nombre = 'Day Pass'
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) > 10;

-- 18. Mostrar usuarios cuya membresía vence en los próximos 7 días
SELECT u.*, m.fecha_fin
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.fecha_fin BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY);

-- 19. Listar usuarios que se registraron en el último mes
SELECT *
FROM usuarios
WHERE fecha_registro >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);

-- 20. Mostrar usuarios que nunca han asistido al coworking (0 accesos)
SELECT u.*
FROM usuarios u
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE a.acceso_id IS NULL;

-- 21. Listar todos los espacios disponibles con su capacidad
SELECT nombre, capacidad_max, estado
FROM espacios
WHERE estado = 'Disponible';

-- 22. Listar reservas activas en el día actual
SELECT *
FROM reservas
WHERE fecha_reserva = CURDATE() AND estado = 'Confirmada';

-- 23. Mostrar reservas canceladas en el último mes
SELECT *
FROM reservas
WHERE estado = 'Cancelada' 
AND fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);

-- 24. Listar reservas de salas de reuniones en horario pico (9 am – 11 am)
SELECT r.*
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE e.tipo_espacio = 'Sala de reuniones'
AND TIME(r.hora_inicio) BETWEEN '09:00:00' AND '11:00:00';

-- 25. Contar cuántas reservas se hacen por cada tipo de espacio
SELECT e.tipo_espacio, COUNT(*) as cantidad_reservas
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
GROUP BY e.tipo_espacio;

-- 26. Mostrar el espacio más reservado del último mes
SELECT e.nombre, COUNT(*) as reservas_count
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
GROUP BY e.espacio_id, e.nombre
ORDER BY reservas_count DESC
LIMIT 1;

-- 27. Listar usuarios que más han reservado salas privadas
SELECT u.usuario_id, u.nombre, COUNT(*) as reservas_count
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE e.tipo_espacio = 'Oficina privada'
GROUP BY u.usuario_id, u.nombre
ORDER BY reservas_count DESC;

-- 28. Mostrar reservas que exceden la capacidad máxima del espacio
SELECT r.*, e.capacidad_max
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.capacidad > e.capacidad_max;

-- 29. Listar espacios que no se han reservado en la última semana
SELECT e.*
FROM espacios e
LEFT JOIN reservas r ON e.espacio_id = r.espacio_id 
AND r.fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 WEEK)
WHERE r.reserva_id IS NULL;

-- 30. Calcular la tasa de ocupación promedio de cada espacio
SELECT e.espacio_id, e.nombre,
AVG(TIMESTAMPDIFF(HOUR, r.hora_inicio, r.hora_fin)) as horas_promedio_ocupacion
FROM espacios e
LEFT JOIN reservas r ON e.espacio_id = r.espacio_id
GROUP BY e.espacio_id, e.nombre;

-- 31. Mostrar reservas de más de 8 horas
SELECT *
FROM reservas
WHERE duracion_horas > 8;

-- 32. Identificar usuarios con más de 20 reservas en total
SELECT u.usuario_id, u.nombre, COUNT(*) as total_reservas
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) > 20;

-- 33. Mostrar reservas realizadas por empresas con más de 10 empleados
SELECT r.*
FROM reservas r
JOIN usuarios u ON r.usuario_id = u.usuario_id
WHERE u.empresa IN (
    SELECT empresa
    FROM usuarios
    WHERE empresa IS NOT NULL
    GROUP BY empresa
    HAVING COUNT(*) > 10
);

-- 34. Listar reservas que se solapan en horario
SELECT r1.*, r2.*
FROM reservas r1
JOIN reservas r2 ON r1.espacio_id = r2.espacio_id 
AND r1.fecha_reserva = r2.fecha_reserva
AND r1.reserva_id != r2.reserva_id
AND r1.hora_inicio < r2.hora_fin
AND r1.hora_fin > r2.hora_inicio;

-- 35. Listar reservas de fin de semana
SELECT *
FROM reservas
WHERE DAYOFWEEK(fecha_reserva) IN (1, 7);

-- 36. Mostrar el porcentaje de ocupación por cada tipo de espacio
SELECT e.tipo_espacio,
(SUM(TIMESTAMPDIFF(HOUR, r.hora_inicio, r.hora_fin)) / (COUNT(DISTINCT e.espacio_id) * 24 * 30)) * 100 as porcentaje_ocupacion
FROM espacios e
LEFT JOIN reservas r ON e.espacio_id = r.espacio_id
WHERE r.fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
GROUP BY e.tipo_espacio;

-- 37. Mostrar la duración promedio de reservas por tipo de espacio
SELECT e.tipo_espacio, AVG(r.duracion_horas) as duracion_promedio
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
GROUP BY e.tipo_espacio;

-- 38. Mostrar reservas con servicios adicionales incluidos
SELECT DISTINCT r.*
FROM reservas r
JOIN servicios_reserva sr ON r.reserva_id = sr.reserva_id;

-- 39. Listar usuarios que reservaron sala de eventos en los últimos 6 meses
SELECT DISTINCT u.*
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE e.tipo_espacio = 'Sala de eventos'
AND r.fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH);

-- 40. Identificar reservas realizadas y nunca asistidas
SELECT r.*
FROM reservas r
LEFT JOIN acceso a ON r.usuario_id = a.usuario_id 
AND r.fecha_reserva = DATE(a.fecha_hora_entrada)
WHERE a.acceso_id IS NULL;

-- 41. Listar todos los pagos realizados con método tarjeta
SELECT *
FROM pagos
WHERE metodo_pago = 'Tarjeta';

-- 42. Listar pagos pendientes de usuarios
SELECT p.*
FROM pagos p
WHERE p.estado = 'Pendiente';

-- 43. Mostrar pagos cancelados en los últimos 3 meses
SELECT p.*
FROM pagos p
WHERE p.estado = 'Cancelada'
AND p.fecha_pago >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH);

-- 44. Listar facturas generadas por membresías
SELECT *
FROM facturas
WHERE concepto = 'Membresía';

-- 45. Listar facturas generadas por reservas
SELECT *
FROM facturas
WHERE concepto = 'Reserva';

-- 46. Mostrar el total de ingresos por membresías en el último mes
SELECT SUM(total) as ingresos_membresias
FROM facturas
WHERE concepto = 'Membresía'
AND fecha_emision >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);

-- 47. Mostrar el total de ingresos por reservas en el último mes
SELECT SUM(total) as ingresos_reservas
FROM facturas
WHERE concepto = 'Reserva'
AND fecha_emision >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH);

-- 48. Mostrar el total de ingresos por servicios adicionales
SELECT SUM(total) as ingresos_servicios
FROM facturas
WHERE concepto = 'Servicios';

-- 49. Identificar usuarios que nunca han pagado con PayPal
SELECT u.*
FROM usuarios u
WHERE u.usuario_id NOT IN (
    SELECT DISTINCT f.usuario_id
    FROM facturas f
    JOIN pagos p ON f.factura_id = p.factura_id
    WHERE p.metodo_pago = 'PayPal'
);

-- 50. Calcular el promedio de gasto por usuario
SELECT AVG(total) as gasto_promedio
FROM facturas;

-- 51. Mostrar el top 5 de usuarios que más han pagado en total
SELECT u.usuario_id, u.nombre, SUM(f.total) as total_pagado
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY total_pagado DESC
LIMIT 5;

-- 52. Mostrar facturas con monto mayor a $1000
SELECT *
FROM facturas
WHERE total > 1000;

-- 53. Listar pagos realizados después de la fecha de vencimiento
SELECT p.*
FROM pagos p
JOIN facturas f ON p.factura_id = f.factura_id
WHERE p.fecha_pago > f.fecha_vencimiento;

-- 54. Calcular el total recaudado en el año actual
SELECT SUM(total) as total_recaudado
FROM facturas
WHERE YEAR(fecha_emision) = YEAR(CURRENT_DATE);

-- 55. Mostrar facturas anuladas y su motivo
SELECT *
FROM facturas
WHERE estado = 'Cancelada';

-- 56. Mostrar usuarios con facturas pendientes mayores a $200
SELECT u.*, f.total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE f.estado = 'Pendiente' AND f.total > 200;

-- 57. Mostrar usuarios que han pagado más de una vez el mismo servicio
SELECT u.usuario_id, u.nombre, f.concepto_id, COUNT(*) as veces_pagado
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE f.concepto = 'Servicios'
GROUP BY u.usuario_id, u.nombre, f.concepto_id
HAVING COUNT(*) > 1;

-- 58. Listar ingresos por cada método de pago
SELECT metodo_pago, SUM(monto) as total_ingresos
FROM pagos
GROUP BY metodo_pago;

-- 59. Mostrar facturación acumulada por empresa
SELECT u.empresa, SUM(f.total) as facturacion_total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE u.empresa IS NOT NULL
GROUP BY u.empresa;

-- 60. Mostrar ingresos netos por mes del último año
SELECT YEAR(fecha_emision) as año, MONTH(fecha_emision) as mes, SUM(total) as ingresos
FROM facturas
WHERE fecha_emision >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
GROUP BY YEAR(fecha_emision), MONTH(fecha_emision)
ORDER BY año, mes;

-- 61. Listar todos los accesos registrados hoy
SELECT *
FROM acceso
WHERE DATE(fecha_hora_entrada) = CURDATE();

-- 62. Mostrar usuarios con más de 20 asistencias en el mes
SELECT u.usuario_id, u.nombre, COUNT(*) as asistencias
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE MONTH(a.fecha_hora_entrada) = MONTH(CURRENT_DATE())
AND YEAR(a.fecha_hora_entrada) = YEAR(CURRENT_DATE())
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) > 20;

-- 63. Mostrar usuarios que no asistieron en la última semana
SELECT u.*
FROM usuarios u
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id
AND a.fecha_hora_entrada >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 WEEK)
WHERE a.acceso_id IS NULL;

-- 64. Calcular la asistencia promedio por día de la semana
SELECT DAYNAME(fecha_hora_entrada) as dia_semana, COUNT(*) as asistencias
FROM acceso
GROUP BY DAYNAME(fecha_hora_entrada)
ORDER BY asistencias DESC;

-- 65. Mostrar los 10 usuarios más constantes (más asistencias)
SELECT u.usuario_id, u.nombre, COUNT(*) as total_asistencias
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY total_asistencias DESC
LIMIT 10;

-- 66. Mostrar accesos fuera del horario permitido
SELECT a.*
FROM acceso a
JOIN membresias m ON a.usuario_id = m.usuario_id
JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
WHERE TIME(a.fecha_hora_entrada) NOT BETWEEN '08:00:00' AND '20:00:00';

-- 67. Mostrar usuarios que accedieron sin membresía activa (rechazados)
SELECT a.*, u.nombre
FROM acceso a
JOIN usuarios u ON a.usuario_id = u.usuario_id
WHERE a.resultado = 'Denegado';

-- 68. Listar usuarios que solo acceden los fines de semana
SELECT u.usuario_id, u.nombre
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE DAYOFWEEK(a.fecha_hora_entrada) IN (1, 7)
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(*) = (
    SELECT COUNT(*) 
    FROM acceso a2 
    WHERE a2.usuario_id = u.usuario_id
);

-- 69. Mostrar usuarios que accedieron más de 2 veces en el mismo día
SELECT u.usuario_id, u.nombre, DATE(a.fecha_hora_entrada) as fecha, COUNT(*) as accesos
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
GROUP BY u.usuario_id, u.nombre, DATE(a.fecha_hora_entrada)
HAVING COUNT(*) > 2;

-- 70. Mostrar el total de accesos diarios en el último mes
SELECT DATE(fecha_hora_entrada) as fecha, COUNT(*) as total_accesos
FROM acceso
WHERE fecha_hora_entrada >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
GROUP BY DATE(fecha_hora_entrada)
ORDER BY fecha;

-- 71. Mostrar usuarios que han accedido pero no tienen reservas
SELECT DISTINCT u.*
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
LEFT JOIN reservas r ON u.usuario_id = r.usuario_id
WHERE r.reserva_id IS NULL;

-- 72. Mostrar los días con más concurrencia en el coworking
SELECT DATE(fecha_hora_entrada) as fecha, COUNT(*) as concurrencia
FROM acceso
GROUP BY DATE(fecha_hora_entrada)
ORDER BY concurrencia DESC
LIMIT 10;

-- 73. Mostrar usuarios que entraron pero no registraron salida
SELECT a.*, u.nombre
FROM acceso a
JOIN usuarios u ON a.usuario_id = u.usuario_id
WHERE a.fecha_hora_salida IS NULL;

-- 74. Mostrar accesos de usuarios con membresía vencida
SELECT a.*
FROM acceso a
JOIN membresias m ON a.usuario_id = m.usuario_id
WHERE m.estado = 'Vencida';

-- 75. Mostrar accesos de usuarios corporativos por empresa
SELECT a.*, u.empresa
FROM acceso a
JOIN usuarios u ON a.usuario_id = u.usuario_id
WHERE u.empresa IS NOT NULL;

-- 76. Mostrar clientes que nunca han usado el coworking a pesar de pagar membresía
SELECT u.*
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE a.acceso_id IS NULL AND m.estado = 'Activa';

-- 77. Mostrar accesos rechazados por intentos con QR inválido
SELECT *
FROM acceso
WHERE metodo_acceso = 'QR' AND resultado = 'Denegado';

-- 78. Mostrar accesos promedio por usuario
SELECT AVG(accesos_count) as promedio_accesos
FROM (
    SELECT usuario_id, COUNT(*) as accesos_count
    FROM acceso
    GROUP BY usuario_id
) as accesos_por_usuario;

-- 79. Identificar usuarios que asisten más en la mañana
SELECT u.usuario_id, u.nombre, COUNT(*) as asistencias_manana
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE TIME(a.fecha_hora_entrada) BETWEEN '06:00:00' AND '12:00:00'
GROUP BY u.usuario_id, u.nombre
ORDER BY asistencias_manana DESC;

-- 80. Identificar usuarios que asisten más en la noche
SELECT u.usuario_id, u.nombre, COUNT(*) as asistencias_noche
FROM usuarios u
JOIN acceso a ON u.usuario_id = a.usuario_id
WHERE TIME(a.fecha_hora_entrada) BETWEEN '18:00:00' AND '23:59:59'
GROUP BY u.usuario_id, u.nombre
ORDER BY asistencias_noche DESC;

-- 81. Mostrar los usuarios con el mayor gasto acumulado
SELECT u.usuario_id, u.nombre, SUM(f.total) as gasto_total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
GROUP BY u.usuario_id, u.nombre
ORDER BY gasto_total DESC;

-- 82. Mostrar los espacios más ocupados considerando reservas confirmadas y asistencias reales
SELECT e.espacio_id, e.nombre,
(COUNT(r.reserva_id) + COUNT(a.acceso_id)) as ocupacion_total
FROM espacios e
LEFT JOIN reservas r ON e.espacio_id = r.espacio_id AND r.estado = 'Confirmada'
LEFT JOIN acceso a ON e.espacio_id = a.espacio_id
GROUP BY e.espacio_id, e.nombre
ORDER BY ocupacion_total DESC;

-- 83. Calcular el promedio de ingresos por usuario
SELECT AVG(gasto_total) as promedio_ingresos_usuario
FROM (
    SELECT u.usuario_id, SUM(f.total) as gasto_total
    FROM usuarios u
    JOIN facturas f ON u.usuario_id = f.usuario_id
    GROUP BY u.usuario_id
) as gastos_usuarios;

-- 84. Listar usuarios que tienen reservas activas y facturas pendientes
SELECT DISTINCT u.*
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE r.estado = 'Confirmada' AND f.estado = 'Pendiente';

-- 85. Mostrar empresas cuyos empleados generan más del 20% de los ingresos totales
SELECT u.empresa, SUM(f.total) as ingresos_empresa,
(SUM(f.total) / (SELECT SUM(total) FROM facturas)) * 100 as porcentaje
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE u.empresa IS NOT NULL
GROUP BY u.empresa
HAVING porcentaje > 20;

-- 86. Mostrar el top 5 de usuarios que más usan servicios adicionales
SELECT u.usuario_id, u.nombre, COUNT(sr.servicio_reserva_id) as servicios_utilizados
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN servicios_reserva sr ON r.reserva_id = sr.reserva_id
GROUP BY u.usuario_id, u.nombre
ORDER BY servicios_utilizados DESC
LIMIT 5;

-- 87. Mostrar reservas que generaron facturas mayores al promedio
SELECT r.*
FROM reservas r
JOIN facturas f ON r.reserva_id = f.concepto_id AND f.concepto = 'Reserva'
WHERE f.total > (SELECT AVG(total) FROM facturas WHERE concepto = 'Reserva');

-- 88. Calcular el porcentaje de ocupación global del coworking por mes
SELECT YEAR(r.fecha_reserva) as año, MONTH(r.fecha_reserva) as mes,
(SUM(r.duracion_horas) / (COUNT(DISTINCT e.espacio_id) * 24 * 30)) * 100 as porcentaje_ocupacion
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
GROUP BY YEAR(r.fecha_reserva), MONTH(r.fecha_reserva);

-- 89. Mostrar usuarios que tienen más horas de reserva que el promedio del sistema
SELECT u.usuario_id, u.nombre, SUM(r.duracion_horas) as horas_totales
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id, u.nombre
HAVING horas_totales > (SELECT AVG(duracion_horas) FROM reservas);

-- 90. Mostrar el top 3 de salas más usadas en el último trimestre
SELECT e.espacio_id, e.nombre, COUNT(r.reserva_id) as usos
FROM espacios e
JOIN reservas r ON e.espacio_id = r.espacio_id
WHERE r.fecha_reserva >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
GROUP BY e.espacio_id, e.nombre
ORDER BY usos DESC
LIMIT 3;

-- 91. Calcular ingresos promedio por tipo de membresía
SELECT tm.nombre, AVG(f.total) as ingreso_promedio
FROM tipos_membresia tm
JOIN membresias m ON tm.tipo_membresia_id = m.tipo_membresia_id
JOIN facturas f ON m.membresia_id = f.concepto_id AND f.concepto = 'Membresía'
GROUP BY tm.nombre;

-- 92. Mostrar usuarios que pagan solo con un método de pago
SELECT u.usuario_id, u.nombre
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
JOIN pagos p ON f.factura_id = p.factura_id
GROUP BY u.usuario_id, u.nombre
HAVING COUNT(DISTINCT p.metodo_pago) = 1;

-- 93. Mostrar reservas canceladas por usuarios que nunca asistieron
SELECT r.*
FROM reservas r
JOIN usuarios u ON r.usuario_id = u.usuario_id
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id AND DATE(a.fecha_hora_entrada) = r.fecha_reserva
WHERE r.estado = 'Cancelada' AND a.acceso_id IS NULL;

-- 94. Mostrar facturas con pagos parciales y calcular saldo pendiente
SELECT f.factura_id, f.total, COALESCE(SUM(p.monto), 0) as pagado,
(f.total - COALESCE(SUM(p.monto), 0)) as saldo_pendiente
FROM facturas f
LEFT JOIN pagos p ON f.factura_id = p.factura_id
GROUP BY f.factura_id, f.total
HAVING saldo_pendiente > 0;

-- 95. Calcular la facturación total de cada empresa y ordenarla de mayor a menor
SELECT u.empresa, SUM(f.total) as facturacion_total
FROM usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
WHERE u.empresa IS NOT NULL
GROUP BY u.empresa
ORDER BY facturacion_total DESC;

-- 96. Identificar usuarios que superan en reservas al promedio de su empresa
SELECT u.usuario_id, u.nombre, u.empresa, COUNT(r.reserva_id) as reservas_usuario,
(SELECT AVG(reservas_count) 
 FROM (SELECT COUNT(*) as reservas_count
       FROM usuarios u2
       JOIN reservas r2 ON u2.usuario_id = r2.usuario_id
       WHERE u2.empresa = u.empresa
       GROUP BY u2.usuario_id) as promedio_empresa) as promedio_empresa
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
GROUP BY u.usuario_id, u.nombre, u.empresa
HAVING reservas_usuario > promedio_empresa;

-- 97. Mostrar las 3 empresas con más empleados activos en el coworking
SELECT u.empresa, COUNT(DISTINCT u.usuario_id) as empleados_activos
FROM usuarios u
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa' AND u.empresa IS NOT NULL
GROUP BY u.empresa
ORDER BY empleados_activos DESC
LIMIT 3;

-- 98. Calcular el porcentaje de usuarios activos frente al total de registrados
SELECT (COUNT(DISTINCT m.usuario_id) / (SELECT COUNT(*) FROM usuarios)) * 100 as porcentaje_activos
FROM membresias m
WHERE m.estado = 'Activa';

-- 99. Mostrar ingresos mensuales acumulados con función de ventana
SELECT YEAR(fecha_emision) as año, MONTH(fecha_emision) as mes,
SUM(total) OVER (ORDER BY YEAR(fecha_emision), MONTH(fecha_emision)) as ingresos_acumulados
FROM facturas
GROUP BY YEAR(fecha_emision), MONTH(fecha_emision)
ORDER BY año, mes;

-- 100. Mostrar usuarios con más de 10 reservas, más de $500 en facturación y membresía activa
SELECT u.usuario_id, u.nombre, 
COUNT(r.reserva_id) as total_reservas,
SUM(f.total) as total_facturado
FROM usuarios u
JOIN reservas r ON u.usuario_id = r.usuario_id
JOIN facturas f ON u.usuario_id = f.usuario_id
JOIN membresias m ON u.usuario_id = m.usuario_id
WHERE m.estado = 'Activa'
GROUP BY u.usuario_id, u.nombre
HAVING total_reservas > 10 AND total_facturado > 500;

use coworking_db;

-- =======================================================
-- Módulo Membresías (5 triggers)
-- =======================================================

-- 1. Insertar fecha de vencimiento automáticamente al crear una nueva membresía
CREATE TRIGGER trg_membresia_fecha_fin
BEFORE INSERT ON membresias
FOR EACH ROW
BEGIN
    DECLARE dias_duracion INT;
    
    SELECT duracion_dias INTO dias_duracion
    FROM tipos_membresia
    WHERE tipo_membresia_id = NEW.tipo_membresia_id;
    
    SET NEW.fecha_fin = DATE_ADD(NEW.fecha_inicio, INTERVAL dias_duracion DAY);
END;

-- 2. Actualizar estado de membresía a "Activa" cuando se realiza un pago exitoso
CREATE TRIGGER trg_membresia_activa_por_pago
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Completado' AND OLD.estado != 'Completado' THEN
        UPDATE membresias m
        JOIN facturas f ON m.membresia_id = f.concepto_id AND f.concepto = 'Membresía'
        SET m.estado = 'Activa'
        WHERE f.factura_id = NEW.factura_id;
    END IF;
END;

-- 3. Actualizar estado de membresía a "Suspendida" cuando no se paga antes de la fecha límite
CREATE TRIGGER trg_membresia_suspendida_por_vencimiento
BEFORE UPDATE ON facturas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Vencida' AND OLD.estado != 'Vencida' THEN
        UPDATE membresias m
        SET m.estado = 'Suspendida'
        WHERE m.membresia_id = NEW.concepto_id AND NEW.concepto = 'Membresía';
    END IF;
END;

-- 4. Registrar en un log cada vez que se actualice el tipo de membresía de un usuario
CREATE TABLE log_cambios_membresia (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    antiguo_tipo_membresia_id INT,
    nuevo_tipo_membresia_id INT,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    detalles TEXT
);

CREATE TRIGGER trg_log_cambio_membresia
AFTER UPDATE ON membresias
FOR EACH ROW
BEGIN
    IF OLD.tipo_membresia_id != NEW.tipo_membresia_id THEN
        INSERT INTO log_cambios_membresia (usuario_id, antiguo_tipo_membresia_id, nuevo_tipo_membresia_id, detalles)
        VALUES (NEW.usuario_id, OLD.tipo_membresia_id, NEW.tipo_membresia_id, 
                CONCAT('Cambio de membresía para usuario ', NEW.usuario_id));
    END IF;
END;

-- 5. Bloquear eliminación de membresía si el usuario tiene reservas activas
CREATE TRIGGER trg_bloquear_eliminacion_membresia
BEFORE DELETE ON membresias
FOR EACH ROW
BEGIN
    DECLARE reservas_activas INT;
    
    SELECT COUNT(*) INTO reservas_activas
    FROM reservas
    WHERE usuario_id = OLD.usuario_id
    AND estado IN ('Confirmada', 'En curso')
    AND fecha_reserva >= CURDATE();
    
    IF reservas_activas > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar la membresía: el usuario tiene reservas activas';
    END IF;
END;

-- =======================================================
-- Módulo Reservas (5 triggers)
-- =======================================================

-- 6. Validar que no existan reservas duplicadas en el mismo espacio, fecha y hora
CREATE TRIGGER trg_validar_reserva_duplicada
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    DECLARE existe_reserva INT;
    
    SELECT COUNT(*) INTO existe_reserva
    FROM reservas
    WHERE espacio_id = NEW.espacio_id
    AND fecha_reserva = NEW.fecha_reserva
    AND (
        (NEW.hora_inicio BETWEEN hora_inicio AND hora_fin) OR
        (NEW.hora_fin BETWEEN hora_inicio AND hora_fin) OR
        (hora_inicio BETWEEN NEW.hora_inicio AND NEW.hora_fin)
    )
    AND estado != 'Cancelada';
    
    IF existe_reserva > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe una reserva para este espacio en el horario seleccionado';
    END IF;
END;

-- 7. Registrar automáticamente el estado "Pendiente de Confirmación" al crear una reserva
CREATE TRIGGER trg_estado_pendiente_reserva
BEFORE INSERT ON reservas
FOR EACH ROW
BEGIN
    SET NEW.estado = 'Confirmada'; -- En nuestro schema ya tenemos Confirmada como default
END;

-- 8. Cambiar estado a "Confirmada" al registrar el pago de la reserva
CREATE TRIGGER trg_confirmar_reserva_por_pago
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Completado' AND OLD.estado != 'Completado' THEN
        UPDATE reservas r
        JOIN facturas f ON r.reserva_id = f.concepto_id AND f.concepto = 'Reserva'
        SET r.estado = 'Confirmada'
        WHERE f.factura_id = NEW.factura_id;
    END IF;
END;

-- 9. Cancelar reserva automáticamente si el usuario elimina su membresía
CREATE TRIGGER trg_cancelar_reservas_sin_membresia
AFTER DELETE ON membresias
FOR EACH ROW
BEGIN
    UPDATE reservas
    SET estado = 'Cancelada'
    WHERE usuario_id = OLD.usuario_id
    AND estado IN ('Confirmada', 'En curso')
    AND fecha_reserva >= CURDATE();
END;

-- 10. Registrar en un log cada vez que una reserva es cancelada
CREATE TABLE log_cancelaciones_reserva (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_cancelacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT
);

CREATE TRIGGER trg_log_cancelacion_reserva
AFTER UPDATE ON reservas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Cancelada' AND OLD.estado != 'Cancelada' THEN
        INSERT INTO log_cancelaciones_reserva (reserva_id, usuario_id, motivo)
        VALUES (NEW.reserva_id, NEW.usuario_id, 'Reserva cancelada');
    END IF;
END;

-- =======================================================
-- Módulo Pagos y Facturación (5 triggers)
-- =======================================================

-- 12. Actualizar factura a "Pagada" cuando se confirma el pago
CREATE TRIGGER trg_actualizar_estado_factura
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Completado' AND OLD.estado != 'Completado' THEN
        UPDATE facturas
        SET estado = 'Pagada'
        WHERE factura_id = NEW.factura_id;
    END IF;
END;

-- 13. Bloquear eliminación de un pago si ya existe factura asociada
CREATE TRIGGER trg_bloquear_eliminacion_pago
BEFORE DELETE ON pagos
FOR EACH ROW
BEGIN
    DECLARE factura_estado VARCHAR(20);
    
    SELECT estado INTO factura_estado
    FROM facturas
    WHERE factura_id = OLD.factura_id;
    
    IF factura_estado = 'Pagada' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede eliminar el pago: la factura asociada ya está pagada';
    END IF;
END;

-- 14. Actualizar saldo pendiente en facturas con pagos parciales
CREATE TRIGGER trg_actualizar_saldo_factura
AFTER INSERT ON pagos
FOR EACH ROW
BEGIN
    DECLARE total_pagado DECIMAL(10, 2);
    DECLARE total_factura DECIMAL(10, 2);
    
    SELECT SUM(monto) INTO total_pagado
    FROM pagos
    WHERE factura_id = NEW.factura_id
    AND estado = 'Completado';
    
    SELECT total INTO total_factura
    FROM facturas
    WHERE factura_id = NEW.factura_id;
    
    IF total_pagado >= total_factura THEN
        UPDATE facturas
        SET estado = 'Pagada'
        WHERE factura_id = NEW.factura_id;
    ELSE
        UPDATE facturas
        SET estado = 'Pendiente'
        WHERE factura_id = NEW.factura_id;
    END IF;
END;

-- 15. Registrar en a un log todos los pagos anulados
CREATE TABLE log_pagos_anulados (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    pago_id INT NOT NULL,
    factura_id INT NOT NULL,
    monto DECIMAL(10, 2),
    fecha_anulacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    motivo TEXT
);

CREATE TRIGGER trg_log_pagos_anulados
AFTER UPDATE ON pagos
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Reembolsado' AND OLD.estado != 'Reembolsado' THEN
        INSERT INTO log_pagos_anulados (pago_id, factura_id, monto, motivo)
        VALUES (NEW.pago_id, NEW.factura_id, NEW.monto, 'Pago reembolsado');
    END IF;
END;

-- =======================================================
-- Módulo Accesos (5 triggers)
-- =======================================================

-- 16. Registrar asistencia automáticamente al validar acceso con QR o tarjeta
CREATE TRIGGER trg_registrar_asistencia_acceso
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Permitido' THEN
        INSERT INTO asistencia (usuario_id, fecha, hora_entrada)
        VALUES (NEW.usuario_id, DATE(NEW.fecha_hora_entrada), TIME(NEW.fecha_hora_entrada))
        ON DUPLICATE KEY UPDATE 
            hora_entrada = TIME(NEW.fecha_hora_entrada),
            tiempo_total = TIMEDIFF(COALESCE(hora_salida, TIME(NEW.fecha_hora_entrada)), hora_entrada);
    END IF;
END;

-- 17. Bloquear acceso si el usuario no tiene membresía activa
CREATE TRIGGER trg_validar_acceso_membresia
BEFORE INSERT ON acceso
FOR EACH ROW
BEGIN
    DECLARE membresia_activa INT;
    
    SELECT COUNT(*) INTO membresia_activa
    FROM membresias
    WHERE usuario_id = NEW.usuario_id
    AND estado = 'Activa'
    AND fecha_fin >= CURDATE();
    
    IF membresia_activa = 0 THEN
        SET NEW.resultado = 'Denegado';
        SET NEW.motivo_denegacion = 'No tiene membresía activa';
    END IF;
END;

-- 18. Actualizar última fecha de acceso del usuario al ingresar
ALTER TABLE usuarios ADD COLUMN ultimo_acceso DATETIME;

CREATE TRIGGER trg_actualizar_ultimo_acceso
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Permitido' THEN
        UPDATE usuarios
        SET ultimo_acceso = NEW.fecha_hora_entrada
        WHERE usuario_id = NEW.usuario_id;
    END IF;
END;

-- 19. Registrar salida automáticamente si el usuario vuelve a entrar sin salida previa
CREATE TRIGGER trg_registrar_salida_automatica
BEFORE INSERT ON acceso
FOR EACH ROW
BEGIN
    DECLARE ultimo_acceso_id INT;
    DECLARE ultima_entrada DATETIME;
    
    -- Buscar el último acceso sin salida del mismo usuario
    SELECT acceso_id, fecha_hora_entrada INTO ultimo_acceso_id, ultima_entrada
    FROM acceso
    WHERE usuario_id = NEW.usuario_id
    AND fecha_hora_salida IS NULL
    AND acceso_id != COALESCE(NEW.acceso_id, 0)
    ORDER BY fecha_hora_entrada DESC
    LIMIT 1;
    
    -- Si existe un acceso anterior sin salida, registrar salida automática
    IF ultimo_acceso_id IS NOT NULL THEN
        UPDATE acceso
        SET fecha_hora_salida = NEW.fecha_hora_entrada
        WHERE acceso_id = ultimo_acceso_id;
        
        -- Actualizar también la tabla de asistencia
        UPDATE asistencia
        SET hora_salida = TIME(NEW.fecha_hora_entrada),
            tiempo_total = TIMEDIFF(TIME(NEW.fecha_hora_entrada), hora_entrada)
        WHERE usuario_id = NEW.usuario_id
        AND fecha = DATE(ultima_entrada)
        AND hora_salida IS NULL;
    END IF;
END;

-- 20. Registrar en un log cada intento de acceso rechazado
CREATE TABLE log_accesos_rechazados (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    espacio_id INT,
    fecha_hora_intento DATETIME,
    metodo_acceso ENUM('RFID', 'QR', 'Manual'),
    motivo_denegacion TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_accesos_rechazados
AFTER INSERT ON acceso
FOR EACH ROW
BEGIN
    IF NEW.resultado = 'Denegado' THEN
        INSERT INTO log_accesos_rechazados (usuario_id, espacio_id, fecha_hora_intento, metodo_acceso, motivo_denegacion)
        VALUES (NEW.usuario_id, NEW.espacio_id, NEW.fecha_hora_entrada, NEW.metodo_acceso, NEW.motivo_denegacion);
    END IF;
END;

use coworking_db;

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

USE coworking_db;

-- 1. Evento: Revisar membresías vencidas diariamente
CREATE EVENT actualizar_membresias_vencidas
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
UPDATE membresias 
SET estado = 'Vencida' 
WHERE fecha_fin < CURDATE() 
AND estado = 'Activa';

-- 2. Evento: Recordatorio renovación 5 días antes
CREATE EVENT recordatorio_renovacion_membresia
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO notificaciones (usuario_id, mensaje, fecha)
SELECT usuario_id, 
       'Su membresía vence en 5 días. Renueve ahora.',
       CURDATE()
FROM membresias 
WHERE fecha_fin = DATE_ADD(CURDATE(), INTERVAL 5 DAY)
AND estado = 'Activa';

-- 3. Evento: Suspender membresías inactivas
CREATE EVENT suspender_membresias_inactivas
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
UPDATE membresias m
JOIN facturas f ON m.membresia_id = f.concepto_id
SET m.estado = 'Suspendida'
WHERE f.estado = 'Vencida'
AND f.fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
AND m.estado = 'Activa';

-- 4. Evento: Reporte semanal nuevas membresías
CREATE EVENT reporte_nuevas_membresias
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_administrador (tipo_reporte, datos, fecha)
SELECT 'Nuevas Membresías Semanales',
       CONCAT(COUNT(*), ' nuevas membresías activadas'),
       CURDATE()
FROM membresias
WHERE fecha_inicio BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE();

-- 5. Evento: Notificar membresías suspendidas
CREATE EVENT notificar_membresias_suspendidas
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO notificaciones_recepcion (mensaje, prioridad, fecha)
SELECT CONCAT('Membresía suspendida: ', m.membresia_id, ' - ', u.nombre),
       'Alta',
       CURDATE()
FROM membresias m
JOIN usuarios u ON m.usuario_id = u.usuario_id
WHERE m.estado = 'Suspendida';

-- 6. Evento: Cancelar reservas no confirmadas
CREATE EVENT cancelar_reservas_no_confirmadas
ON SCHEDULE EVERY 2 HOUR
STARTS CURRENT_TIMESTAMP
DO
UPDATE reservas 
SET estado = 'Cancelada' 
WHERE estado = 'Confirmada'
AND fecha_creacion < DATE_SUB(NOW(), INTERVAL 2 HOUR);

-- 7. Evento: Recordatorio 1 hora antes reserva
CREATE EVENT recordatorio_reserva
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO notificaciones (usuario_id, mensaje, fecha)
SELECT usuario_id,
       CONCAT('Recordatorio: Su reserva inicia en 1 hora (Espacio: ', e.nombre, ')'),
       CURDATE()
FROM reservas r
JOIN espacios e ON r.espacio_id = e.espacio_id
WHERE r.fecha_reserva = CURDATE()
AND r.hora_inicio BETWEEN TIME(NOW()) AND TIME(DATE_ADD(NOW(), INTERVAL 1 HOUR));

-- 8. Evento: Eliminar reservas pasadas no asistidas
CREATE EVENT eliminar_reservas_antiguas
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
DELETE FROM reservas 
WHERE fecha_reserva < DATE_SUB(CURDATE(), INTERVAL 7 DAY)
AND estado IN ('Confirmada', 'Cancelada');

-- 9. Evento: Reporte ocupación semanal
CREATE EVENT reporte_ocupacion_semanal
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_administrador (tipo_reporte, datos, fecha)
SELECT 'Ocupación Semanal',
       CONCAT('Espacios utilizados: ', COUNT(DISTINCT espacio_id)),
       CURDATE()
FROM reservas
WHERE fecha_reserva BETWEEN DATE_SUB(CURDATE(), INTERVAL 7 DAY) AND CURDATE();

-- 10. Evento: Liberar reservas no iniciadas
CREATE EVENT liberar_reservas_no_iniciadas
ON SCHEDULE EVERY 15 MINUTE
STARTS CURRENT_TIMESTAMP
DO
UPDATE reservas r
LEFT JOIN acceso a ON r.reserva_id = a.reserva_id
SET r.estado = 'Cancelada'
WHERE r.estado = 'Confirmada'
AND r.fecha_reserva = CURDATE()
AND r.hora_inicio < DATE_SUB(NOW(), INTERVAL 15 MINUTE)
AND a.acceso_id IS NULL;

-- 11. Evento: Recordatorio pago pendiente
CREATE EVENT recordatorio_pago_pendiente
ON SCHEDULE EVERY 3 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO notificaciones (usuario_id, mensaje, fecha)
SELECT usuario_id,
       'Tiene facturas pendientes de pago. Verifique su cuenta.',
       CURDATE()
FROM facturas
WHERE estado = 'Pendiente'
AND fecha_vencimiento < CURDATE();

-- 12. Evento: Bloquear servicios por facturas vencidas
CREATE EVENT bloquear_servicios_morosidad
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
UPDATE usuarios u
JOIN facturas f ON u.usuario_id = f.usuario_id
SET u.servicios_bloqueados = TRUE
WHERE f.estado = 'Vencida'
AND f.fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL 10 DAY);

-- 13. Evento: Resumen facturación mensual
CREATE EVENT resumen_facturacion_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_contabilidad (periodo, ingresos_totales, fecha_generacion)
SELECT DATE_FORMAT(NOW(), '%Y-%m'),
       SUM(total),
       CURDATE()
FROM facturas
WHERE estado = 'Pagada'
AND YEAR(fecha_emision) = YEAR(CURDATE())
AND MONTH(fecha_emision) = MONTH(CURDATE());

-- 14. Evento: Aplicar recargos por mora
CREATE EVENT aplicar_recargos_mora
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
UPDATE facturas 
SET total = total * 1.10,
    detalles = CONCAT(detalles, ' | Recargo por mora aplicado')
WHERE estado = 'Vencida'
AND fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL 15 DAY);

-- 15. Evento: Reporte ingresos mensuales
CREATE EVENT reporte_ingresos_mensuales
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_contabilidad (periodo, ingresos_totales, detalle)
SELECT DATE_FORMAT(NOW(), '%Y-%m'),
       SUM(total),
       'Ingresos acumulados del mes'
FROM facturas
WHERE estado = 'Pagada'
AND YEAR(fecha_emision) = YEAR(CURDATE())
AND MONTH(fecha_emision) = MONTH(CURDATE());

-- 16. Evento: Limpiar accesos antiguos
CREATE EVENT limpiar_accesos_antiguos
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
DELETE FROM acceso 
WHERE fecha_hora_entrada < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- 17. Evento: Reporte diario de asistencias
CREATE EVENT reporte_asistencias_diario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_administrador (tipo_reporte, datos, fecha)
SELECT 'Asistencias Diarias',
       CONCAT(COUNT(*), ' accesos registrados'),
       CURDATE()
FROM acceso
WHERE DATE(fecha_hora_entrada) = CURDATE();

-- 18. Evento: Reporte usuarios inactivos
CREATE EVENT reporte_usuarios_inactivos
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_administrador (tipo_reporte, datos, fecha)
SELECT 'Usuarios Inactivos',
       CONCAT(COUNT(*), ' usuarios sin actividad'),
       CURDATE()
FROM usuarios u
WHERE NOT EXISTS (
    SELECT 1 FROM acceso a
    WHERE a.usuario_id = u.usuario_id
    AND a.fecha_hora_entrada >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
);

-- 19. Evento: Alertar accesos fuera de horario
CREATE EVENT alerta_accesos_no_laborales
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO alertas_seguridad (mensaje, nivel, fecha)
SELECT CONCAT('Acceso fuera de horario: ', u.nombre, ' - ', a.fecha_hora_entrada),
       'Medio',
       CURDATE()
FROM acceso a
JOIN usuarios u ON a.usuario_id = u.usuario_id
WHERE TIME(a.fecha_hora_entrada) NOT BETWEEN '08:00:00' AND '20:00:00'
AND DATE(a.fecha_hora_entrada) = CURDATE();

-- 20. Evento: Top 10 usuarios mensual
CREATE EVENT reporte_top_usuarios
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
INSERT INTO reportes_administrador (tipo_reporte, datos, fecha)
SELECT 'Top 10 Usuarios',
       GROUP_CONCAT(CONCAT(u.nombre, ' (', COUNT(a.acceso_id), ' accesos)') SEPARATOR ' | '),
       CURDATE()
FROM acceso a
JOIN usuarios u ON a.usuario_id = u.usuario_id
WHERE YEAR(a.fecha_hora_entrada) = YEAR(CURDATE())
AND MONTH(a.fecha_hora_entrada) = MONTH(CURDATE())
GROUP BY a.usuario_id
ORDER BY COUNT(a.acceso_id) DESC
LIMIT 10;

-- =======================================================
-- 6. Procedimientos Almacenados (20)
-- =======================================================
use coworking_db;
-- Membresías (4)

-- 1. Registrar nueva membresía y asignarla a un usuario
CREATE PROCEDURE sp_registrar_membresia(
    IN p_usuario_id INT,
    IN p_tipo_membresia_id INT,
    IN p_precio_final DECIMAL(10, 2)
)
BEGIN
    DECLARE v_duracion INT;
    DECLARE v_fecha_inicio DATE;
    DECLARE v_fecha_fin DATE;
    
    -- Obtener duración del tipo de membresía
    SELECT duracion_dias INTO v_duracion 
    FROM tipos_membresia 
    WHERE tipo_membresia_id = p_tipo_membresia_id;
    
    -- Calcular fechas
    SET v_fecha_inicio = CURDATE();
    SET v_fecha_fin = DATE_ADD(v_fecha_inicio, INTERVAL v_duracion DAY);
    
    -- Insertar nueva membresía
    INSERT INTO membresias (usuario_id, tipo_membresia_id, fecha_inicio, fecha_fin, estado, precio_final)
    VALUES (p_usuario_id, p_tipo_membresia_id, v_fecha_inicio, v_fecha_fin, 'Activa', p_precio_final);
    
    -- Generar factura automáticamente
    CALL sp_generar_factura_membresia(LAST_INSERT_ID());
END;

-- 2. Renovar una membresía existente
CREATE PROCEDURE sp_renovar_membresia(
    IN p_membresia_id INT
)
BEGIN
    DECLARE v_duracion INT;
    DECLARE v_tipo_membresia_id INT;
    DECLARE v_nueva_fecha_fin DATE;
    
    -- Obtener tipo de membresía y duración
    SELECT m.tipo_membresia_id, tm.duracion_dias 
    INTO v_tipo_membresia_id, v_duracion
    FROM membresias m
    JOIN tipos_membresia tm ON m.tipo_membresia_id = tm.tipo_membresia_id
    WHERE m.membresia_id = p_membresia_id;
    
    -- Calcular nueva fecha de fin
    SET v_nueva_fecha_fin = DATE_ADD(CURDATE(), INTERVAL v_duracion DAY);
    
    -- Actualizar membresía
    UPDATE membresias 
    SET fecha_inicio = CURDATE(),
        fecha_fin = v_nueva_fecha_fin,
        estado = 'Activa'
    WHERE membresia_id = p_membresia_id;
    
    -- Generar factura de renovación
    CALL sp_generar_factura_membresia(p_membresia_id);
END;

-- 3. Actualizar estado de membresías vencidas
CREATE PROCEDURE sp_actualizar_membresias_vencidas()
BEGIN
    UPDATE membresias 
    SET estado = 'Vencida' 
    WHERE fecha_fin < CURDATE() 
    AND estado = 'Activa';
END;

-- 4. Suspender membresías con facturas impagas
CREATE PROCEDURE sp_suspender_membresias_impagas(IN p_dias_impago INT)
BEGIN
    UPDATE membresias m
    JOIN facturas f ON m.usuario_id = f.usuario_id AND f.concepto = 'Membresía'
    SET m.estado = 'Suspendida'
    WHERE f.estado = 'Vencida'
    AND f.fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL p_dias_impago DAY)
    AND m.estado = 'Activa';
END;

-- Reservas y Espacios (5)

-- 5. Verificar disponibilidad de un espacio
CREATE PROCEDURE sp_verificar_disponibilidad(
    IN p_espacio_id INT,
    IN p_fecha DATE,
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    OUT p_disponible BOOLEAN
)
BEGIN
    DECLARE v_conflictos INT;
    
    -- Verificar si hay reservas que se solapan
    SELECT COUNT(*) INTO v_conflictos
    FROM reservas
    WHERE espacio_id = p_espacio_id
    AND fecha_reserva = p_fecha
    AND (
        (hora_inicio BETWEEN p_hora_inicio AND p_hora_fin) OR
        (hora_fin BETWEEN p_hora_inicio AND p_hora_fin) OR
        (p_hora_inicio BETWEEN hora_inicio AND hora_fin) OR
        (p_hora_fin BETWEEN hora_inicio AND hora_fin)
    )
    AND estado IN ('Confirmada', 'En curso');
    
    -- Verificar estado del espacio
    IF EXISTS (
        SELECT 1 FROM espacios 
        WHERE espacio_id = p_espacio_id 
        AND estado != 'Disponible'
    ) THEN
        SET v_conflictos = 1;
    END IF;
    
    SET p_disponible = (v_conflictos = 0);
END;

-- 6. Crear una nueva reserva de espacio
CREATE PROCEDURE sp_crear_reserva(
    IN p_usuario_id INT,
    IN p_espacio_id INT,
    IN p_fecha DATE,
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME,
    IN p_precio_total DECIMAL(10, 2)
)
BEGIN
    DECLARE v_duracion DECIMAL(4, 2);
    DECLARE v_disponible BOOLEAN;
    
    -- Calcular duración
    SET v_duracion = TIMESTAMPDIFF(HOUR, p_hora_inicio, p_hora_fin);
    
    -- Verificar disponibilidad
    CALL sp_verificar_disponibilidad(p_espacio_id, p_fecha, p_hora_inicio, p_hora_fin, v_disponible);
    
    IF v_disponible THEN
        -- Insertar reserva
        INSERT INTO reservas (usuario_id, espacio_id, fecha_reserva, hora_inicio, hora_fin, duracion_horas, estado, precio_total)
        VALUES (p_usuario_id, p_espacio_id, p_fecha, p_hora_inicio, p_hora_fin, v_duracion, 'Confirmada', p_precio_total);
        
        SELECT LAST_INSERT_ID() AS reserva_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El espacio no está disponible en el horario solicitado';
    END IF;
END;

-- 7. Confirmar reserva con pago
CREATE PROCEDURE sp_confirmar_reserva_pago(
    IN p_reserva_id INT,
    IN p_metodo_pago ENUM('Efectivo', 'Tarjeta', 'Transferencia', 'PayPal'),
    IN p_referencia VARCHAR(100)
)
BEGIN
    DECLARE v_usuario_id INT;
    DECLARE v_total DECIMAL(10, 2);
    DECLARE v_factura_id INT;
    
    -- Obtener información de la reserva
    SELECT usuario_id, precio_total INTO v_usuario_id, v_total
    FROM reservas WHERE reserva_id = p_reserva_id;
    
    -- Generar factura
    INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles)
    VALUES (v_usuario_id, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Reserva', p_reserva_id, v_total, v_total * 0.21, v_total * 1.21, 'Pagada', 'Reserva confirmada con pago');
    
    SET v_factura_id = LAST_INSERT_ID();
    
    -- Registrar pago
    INSERT INTO pagos (factura_id, metodo_pago, monto, referencia, estado, detalles)
    VALUES (v_factura_id, p_metodo_pago, v_total * 1.21, p_referencia, 'Completado', 'Pago de reserva');
    
    -- Actualizar estado de la reserva
    UPDATE reservas SET estado = 'Confirmada' WHERE reserva_id = p_reserva_id;
END;

-- 8. Cancelar reserva con opción de reembolso
CREATE PROCEDURE sp_cancelar_reserva(
    IN p_reserva_id INT,
    IN p_reembolso_parcial BOOLEAN
)
BEGIN
    DECLARE v_usuario_id INT;
    DECLARE v_precio_total DECIMAL(10, 2);
    DECLARE v_monto_reembolso DECIMAL(10, 2);
    DECLARE v_factura_id INT;
    
    -- Obtener información de la reserva
    SELECT usuario_id, precio_total INTO v_usuario_id, v_precio_total
    FROM reservas WHERE reserva_id = p_reserva_id;
    
    -- Calcular monto de reembolso (80% si es parcial)
    SET v_monto_reembolso = CASE 
        WHEN p_reembolso_parcial THEN v_precio_total * 0.8 
        ELSE v_precio_total 
    END;
    
    -- Generar factura de reembolso si aplica
    IF v_monto_reembolso > 0 THEN
        INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles)
        VALUES (v_usuario_id, CURDATE(), 'Reserva', p_reserva_id, -v_monto_reembolso, -v_monto_reembolso * 0.21, -v_monto_reembolso * 1.21, 'Pagada', 'Reembolso por cancelación de reserva');
        
        SET v_factura_id = LAST_INSERT_ID();
        
        -- Registrar pago de reembolso
        INSERT INTO pagos (factura_id, metodo_pago, monto, referencia, estado, detalles)
        VALUES (v_factura_id, 'Transferencia', -v_monto_reembolso * 1.21, CONCAT('REEMB-', p_reserva_id), 'Reembolsado', 'Reembolso por cancelación');
    END IF;
    
    -- Actualizar estado de la reserva
    UPDATE reservas SET estado = 'Cancelada' WHERE reserva_id = p_reserva_id;
END;

-- 9. Liberar reservas no confirmadas
CREATE PROCEDURE sp_liberar_reservas_no_confirmadas(IN p_horas_limite INT)
BEGIN
    UPDATE reservas 
    SET estado = 'Cancelada' 
    WHERE estado = 'Confirmada'
    AND fecha_creacion < DATE_SUB(NOW(), INTERVAL p_horas_limite HOUR)
    AND NOT EXISTS (
        SELECT 1 FROM pagos p
        JOIN facturas f ON p.factura_id = f.factura_id
        WHERE f.concepto = 'Reserva'
        AND f.concepto_id = reserva_id
        AND p.estado = 'Completado'
    );
END;

-- Pagos y Facturación (4)

-- 10. Generar factura por membresía
CREATE PROCEDURE sp_generar_factura_membresia(IN p_membresia_id INT)
BEGIN
    DECLARE v_usuario_id INT;
    DECLARE v_precio_final DECIMAL(10, 2);
    DECLARE v_impuestos DECIMAL(10, 2);
    
    -- Obtener información de la membresía
    SELECT usuario_id, precio_final INTO v_usuario_id, v_precio_final
    FROM membresias WHERE membresia_id = p_membresia_id;
    
    -- Calcular impuestos (21%)
    SET v_impuestos = v_precio_final * 0.21;
    
    -- Insertar factura
    INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles)
    VALUES (v_usuario_id, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'Membresía', p_membresia_id, v_precio_final, v_impuestos, v_precio_final + v_impuestos, 'Pendiente', 'Factura por membresía');
END;

-- 11. Generar factura consolidada para empresa
CREATE PROCEDURE sp_generar_factura_consolidada(IN p_empresa VARCHAR(100), IN p_mes INT, IN p_anio INT)
BEGIN
    DECLARE v_factura_id INT;
    DECLARE v_subtotal DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_impuestos DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_total DECIMAL(10, 2) DEFAULT 0;
    DECLARE v_usuario_id INT;
    
    -- Obtener un usuario representante de la empresa
    SELECT usuario_id INTO v_usuario_id
    FROM usuarios 
    WHERE empresa = p_empresa 
    LIMIT 1;
    
    -- Calcular totales de todas las facturas pendientes de los empleados de la empresa
    SELECT SUM(f.subtotal), SUM(f.impuestos), SUM(f.total)
    INTO v_subtotal, v_impuestos, v_total
    FROM facturas f
    JOIN usuarios u ON f.usuario_id = u.usuario_id
    WHERE u.empresa = p_empresa
    AND f.estado = 'Pendiente'
    AND MONTH(f.fecha_emision) = p_mes
    AND YEAR(f.fecha_emision) = p_anio;
    
    -- Insertar factura consolidada
    INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles)
    VALUES (v_usuario_id, DATE_ADD(CURDATE(), INTERVAL 15 DAY), 'Servicios', 0, v_subtotal, v_impuestos, v_total, 'Pendiente', CONCAT('Factura consolidada para ', p_empresa, ' - ', p_mes, '/', p_anio));
    
    SET v_factura_id = LAST_INSERT_ID();
    
    -- Marcar facturas individuales como consolidadas
    UPDATE facturas f
    JOIN usuarios u ON f.usuario_id = u.usuario_id
    SET f.estado = 'Consolidada',
        f.detalles = CONCAT(f.detalles, ' | Consolidada en factura #', v_factura_id)
    WHERE u.empresa = p_empresa
    AND f.estado = 'Pendiente'
    AND MONTH(f.fecha_emision) = p_mes
    AND YEAR(f.fecha_emision) = p_anio;
    
    SELECT v_factura_id AS factura_consolidada_id;
END;

-- 12. Aplicar recargos a facturas vencidas
CREATE PROCEDURE sp_aplicar_recargos_facturas(IN p_dias_vencimiento INT, IN p_porcentaje_recargo DECIMAL(5, 2))
BEGIN
    UPDATE facturas 
    SET total = total * (1 + p_porcentaje_recargo / 100),
        impuestos = impuestos * (1 + p_porcentaje_recargo / 100),
        detalles = CONCAT(detalles, ' | Recargo del ', p_porcentaje_recargo, '% aplicado')
    WHERE estado = 'Vencida'
    AND fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL p_dias_vencimiento DAY);
END;

-- 13. Bloquear servicios adicionales por falta de pago
CREATE PROCEDURE sp_bloquear_servicios_impagos(IN p_dias_impago INT)
BEGIN
    -- Actualizar estado de usuarios con facturas vencidas
    UPDATE usuarios u
    SET u.servicios_bloqueados = TRUE
    WHERE EXISTS (
        SELECT 1 FROM facturas f
        WHERE f.usuario_id = u.usuario_id
        AND f.estado = 'Vencida'
        AND f.fecha_vencimiento < DATE_SUB(CURDATE(), INTERVAL p_dias_impago DAY)
    );
    
    -- También actualizar el estado de servicios adicionales si es necesario
    UPDATE servicios s
    SET s.disponible = FALSE
    WHERE s.tipo_servicio IN ('Internet', 'Equipamiento')
    AND EXISTS (
        SELECT 1 FROM servicios_reserva sr
        JOIN reservas r ON sr.reserva_id = r.reserva_id
        JOIN usuarios u ON r.usuario_id = u.usuario_id
        WHERE u.servicios_bloqueados = TRUE
        AND sr.servicio_id = s.servicio_id
    );
END;

-- Accesos y Asistencias (4)

-- 14. Registrar acceso de usuario (entrada)
CREATE PROCEDURE sp_registrar_acceso_entrada(
    IN p_usuario_id INT,
    IN p_espacio_id INT,
    IN p_metodo_acceso ENUM('RFID', 'QR', 'Manual')
)
BEGIN
    DECLARE v_membresia_activa BOOLEAN;
    DECLARE v_reserva_activa BOOLEAN;
    
    -- Verificar si tiene membresía activa
    SELECT COUNT(*) INTO v_membresia_activa
    FROM membresias
    WHERE usuario_id = p_usuario_id
    AND estado = 'Activa'
    AND fecha_fin >= CURDATE();
    
    -- Verificar si tiene reserva activa para hoy
    SELECT COUNT(*) INTO v_reserva_activa
    FROM reservas
    WHERE usuario_id = p_usuario_id
    AND espacio_id = p_espacio_id
    AND fecha_reserva = CURDATE()
    AND hora_inicio <= CURTIME()
    AND hora_fin >= CURTIME()
    AND estado = 'Confirmada';
    
    IF v_membresia_activa > 0 OR v_reserva_activa > 0 THEN
        -- Registrar acceso permitido
        INSERT INTO acceso (usuario_id, espacio_id, metodo_acceso, resultado)
        VALUES (p_usuario_id, p_espacio_id, p_metodo_acceso, 'Permitido');
        
        -- Registrar asistencia
        INSERT INTO asistencia (usuario_id, fecha, hora_entrada)
        VALUES (p_usuario_id, CURDATE(), CURTIME())
        ON DUPLICATE KEY UPDATE hora_entrada = CURTIME();
    ELSE
        -- Registrar acceso denegado
        INSERT INTO acceso (usuario_id, espacio_id, metodo_acceso, resultado, motivo_denegacion)
        VALUES (p_usuario_id, p_espacio_id, p_metodo_acceso, 'Denegado', 'Sin membresía activa o reserva válida');
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Acceso denegado: Sin membresía activa o reserva válida';
    END IF;
END;

-- 15. Registrar salida de usuario
CREATE PROCEDURE sp_registrar_salida(IN p_usuario_id INT)
BEGIN
    DECLARE v_hora_entrada TIME;
    
    -- Obtener hora de entrada
    SELECT hora_entrada INTO v_hora_entrada
    FROM asistencia
    WHERE usuario_id = p_usuario_id
    AND fecha = CURDATE();
    
    -- Registrar salida en acceso
    UPDATE acceso 
    SET fecha_hora_salida = NOW()
    WHERE usuario_id = p_usuario_id
    AND DATE(fecha_hora_entrada) = CURDATE()
    AND fecha_hora_salida IS NULL;
    
    -- Actualizar asistencia con hora de salida and tiempo total
    UPDATE asistencia
    SET hora_salida = CURTIME(),
        tiempo_total = TIMEDIFF(CURTIME(), v_hora_entrada)
    WHERE usuario_id = p_usuario_id
    AND fecha = CURDATE();
END;

-- 16. Generar reporte diario de asistencias
CREATE PROCEDURE sp_reporte_diario_asistencias(IN p_fecha DATE)
BEGIN
    SELECT 
        p_fecha AS fecha,
        COUNT(DISTINCT usuario_id) AS usuarios_unicos,
        COUNT(*) AS total_accesos,
        MIN(hora_entrada) AS primera_entrada,
        MAX(hora_salida) AS ultima_salida,
        AVG(TIME_TO_SEC(tiempo_total)) / 3600 AS tiempo_promedio_horas
    FROM asistencia
    WHERE fecha = p_fecha;
END;

-- 17. Marcar reservas como "No Show" y generar penalización
CREATE PROCEDURE sp_marcar_no_show(IN p_minutos_tolerancia INT)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_reserva_id INT;
    DECLARE v_usuario_id INT;
    DECLARE v_precio_total DECIMAL(10, 2);
    DECLARE cur_reservas CURSOR FOR 
        SELECT r.reserva_id, r.usuario_id, r.precio_total
        FROM reservas r
        LEFT JOIN acceso a ON r.usuario_id = a.usuario_id AND DATE(a.fecha_hora_entrada) = r.fecha_reserva
        WHERE r.fecha_reserva = CURDATE()
        AND r.estado = 'Confirmada'
        AND r.hora_inicio < DATE_SUB(NOW(), INTERVAL p_minutos_tolerancia MINUTE)
        AND a.acceso_id IS NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_reservas;
    
    loop_reservas: LOOP
        FETCH cur_reservas INTO v_reserva_id, v_usuario_id, v_precio_total;
        IF done THEN
            LEAVE loop_reservas;
        END IF;
        
        -- Marcar reserva como No Show
        UPDATE reservas SET estado = 'No Show' WHERE reserva_id = v_reserva_id;
        
        -- Generar penalización (50% del valor de la reserva)
        INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles)
        VALUES (v_usuario_id, DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'Penalización', v_reserva_id, v_precio_total * 0.5, v_precio_total * 0.5 * 0.21, v_precio_total * 0.5 * 1.21, 'Pendiente', 'Penalización por No Show');
    END LOOP;
    
    CLOSE cur_reservas;
END;

-- Corporativos y Administración (3)

-- 18. Registrar lote de empleados de una empresa
CREATE PROCEDURE sp_registrar_empleados_empresa(
    IN p_empresa VARCHAR(100),
    IN p_tipo_membresia_id INT,
    IN p_usuarios_json JSON
)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_count INT;
    DECLARE v_usuario_id INT;
    DECLARE v_nombre VARCHAR(50);
    DECLARE v_apellidos VARCHAR(100);
    DECLARE v_email VARCHAR(100);
    
    -- Obtener cantidad de usuarios
    SET v_count = JSON_LENGTH(p_usuarios_json);
    
    -- Iterar sobre cada usuario
    WHILE i < v_count DO
        -- Extraer datos del usuario
        SET v_nombre = JSON_UNQUOTE(JSON_EXTRACT(p_usuarios_json, CONCAT('$[', i, '].nombre')));
        SET v_apellidos = JSON_UNQUOTE(JSON_EXTRACT(p_usuarios_json, CONCAT('$[', i, '].apellidos')));
        SET v_email = JSON_UNQUOTE(JSON_EXTRACT(p_usuarios_json, CONCAT('$[', i, '].email')));
        
        -- Insertar usuario
        INSERT INTO usuarios (nombre, apellidos, email, empresa)
        VALUES (v_nombre, v_apellidos, v_email, p_empresa);
        
        SET v_usuario_id = LAST_INSERT_ID();
        
        -- Asignar membresía
        CALL sp_registrar_membresia(v_usuario_id, p_tipo_membresia_id, 0);
        
        SET i = i + 1;
    END WHILE;
END;

-- 19. Cancelar reservas futuras al eliminar membresía
CREATE PROCEDURE sp_cancelar_reservas_membresia(IN p_usuario_id INT)
BEGIN
    UPDATE reservas
    SET estado = 'Cancelada',
        detalles = CONCAT(COALESCE(detalles, ''), ' | Cancelada por eliminación de membresía')
    WHERE usuario_id = p_usuario_id
    AND fecha_reserva >= CURDATE()
    AND estado IN ('Confirmada', 'Pendiente');
END;

-- 20. Generar reporte de ingresos mensuales acumulados
CREATE PROCEDURE sp_reporte_ingresos_mensuales(IN p_anio INT)
BEGIN
    SELECT 
        meses.mes,
        meses.nombre_mes,
        COALESCE(SUM(f.total), 0) AS ingresos_mensuales,
        @acumulado := @acumulado + COALESCE(SUM(f.total), 0) AS ingresos_acumulados
    FROM (
        SELECT 1 as mes, 'Enero' as nombre_mes UNION SELECT 2, 'Febrero' UNION SELECT 3, 'Marzo' 
        UNION SELECT 4, 'Abril' UNION SELECT 5, 'Mayo' UNION SELECT 6, 'Junio' 
        UNION SELECT 7, 'Julio' UNION SELECT 8, 'Agosto' UNION SELECT 9, 'Septiembre' 
        UNION SELECT 10, 'Octubre' UNION SELECT 11, 'Noviembre' UNION SELECT 12, 'Diciembre'
    ) meses
    LEFT JOIN facturas f ON meses.mes = MONTH(f.fecha_emision) AND YEAR(f.fecha_emision) = p_anio AND f.estado = 'Pagada'
    CROSS JOIN (SELECT @acumulado := 0) r
    GROUP BY meses.mes, meses.nombre_mes
    ORDER BY meses.mes;
END;

create user if not exists 'admin'@'localhost' identified by 'admin#2025';
create user if not exists 'recepcionista'@'localhost' identified by 'recepcionista#2025';
create user if not exists 'usuario'@'localhost' identified by 'usuario#2025';
create user if not exists 'contador'@'%' identified by 'contado#2025';


grant all privileges on coworking_db.* to 'admin'@'localhost' with grant option;

grant select, insert, update on coworking_db.usuarios to 'recepcionista'@'localhost';
grant select, insert, update on coworking_db.reservas to 'recepcionista'@'localhost';
grant select, insert, update on coworking_db.membresias to 'recepcionista'@'localhost';

alter user 'recepcionista'@'localhost' with max_queries_per_hour 200;

grant select on coworking_db.reservas to 'usuario'@'localhost';
grant select (nombre,correo) on coworking_db.servicios to 'contador'@'localhost';
grant select (nombre,correo) on coworking_db.membresias to 'contador'@'localhost';
grant select (nombre,correo) on coworking_db.servicios_reserva to 'contador'@'localhost';

-- =======================================================
-- EXAMEN PUNTO 1
-- =======================================================



-- =======================================================
-- EXAMEN PUNTO 2
-- =======================================================

CREATE VIEW VW_Estadisticas_Usuarios AS
SELECT 
    u.usuario_id,
    u.nombre,
    u.apellidos,
    u.empresa,
    COALESCE(u.empresa, 'Individual') AS tipo_usuario,
    COUNT(DISTINCT r.reserva_id) AS total_reservas,
    SUM(r.duracion_horas) AS total_horas_utilizadas,
    SUM(r.precio_total) AS total_gastado_reservas,
    COUNT(DISTINCT m.membresia_id) AS total_membresias,
    SUM(CASE WHEN m.estado = 'Activa' THEN 1 ELSE 0 END) AS membresias_activas,
    COUNT(DISTINCT a.acceso_id) AS total_accesos,
    MAX(a.fecha_hora_entrada) AS ultimo_acceso,
    DATEDIFF(CURDATE(), MAX(a.fecha_hora_entrada)) AS dias_desde_ultimo_acceso
FROM usuarios u
LEFT JOIN reservas r ON u.usuario_id = r.usuario_id
LEFT JOIN membresias m ON u.usuario_id = m.usuario_id
LEFT JOIN acceso a ON u.usuario_id = a.usuario_id AND a.resultado = 'Permitido'
GROUP BY u.usuario_id, u.nombre, u.apellidos, u.empresa
ORDER BY total_gastado_reservas DESC;

-- =======================================================
-- EXAMEN PUNTO 3
-- =======================================================

CREATE PROCEDURE sp_generar_reporte_mensual(IN p_mes INT, IN p_anio INT)
BEGIN
    -- Tabla temporal para el reporte
    DROP TEMPORARY TABLE IF EXISTS temp_reporte_mensual;
    CREATE TEMPORARY TABLE temp_reporte_mensual (
        categoria VARCHAR(50),
        metrica VARCHAR(50),
        valor DECIMAL(15,2),
        detalle TEXT
    );
    
    -- 1. Ingresos totales
    INSERT INTO temp_reporte_mensual
    SELECT 'Ingresos', 'Total', SUM(total), 'Ingresos totales del mes'
    FROM facturas 
    WHERE MONTH(fecha_emision) = p_mes 
    AND YEAR(fecha_emision) = p_anio
    AND estado = 'Pagada';
    
    -- 2. Ingresos por concepto
    INSERT INTO temp_reporte_mensual
    SELECT 'Ingresos', concepto, SUM(total), CONCAT('Ingresos por ', concepto)
    FROM facturas 
    WHERE MONTH(fecha_emision) = p_mes 
    AND YEAR(fecha_emision) = p_anio
    AND estado = 'Pagada'
    GROUP BY concepto;
    
    -- 3. Reservas realizadas
    INSERT INTO temp_reporte_mensual
    SELECT 'Reservas', 'Total', COUNT(*), 'Total de reservas del mes'
    FROM reservas 
    WHERE MONTH(fecha_reserva) = p_mes 
    AND YEAR(fecha_reserva) = p_anio;
   
    
    -- 4. Mostrar resultados
    SELECT * FROM temp_reporte_mensual;
    
END;

