-- Esquema de base de datos para gestión de usuarios, grupos y módulos con permisos.
CREATE TABLE grupo -- Tabla de grupos de usuarios.
(
    grupo_id INT PRIMARY KEY, -- Identificador único del grupo
    grupo_nombre VARCHAR(50) NOT NULL UNIQUE, -- Nombre del grupo
    grupo_descripcion TEXT -- Descripción del grupo
) ENGINE=InnoDB;

CREATE TABLE grupo (
    grupo_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    grupo_nombre VARCHAR(50) NOT NULL UNIQUE,
    grupo_descripcion TEXT
) ENGINE=InnoDB;

-- Tabla de usuarios con referencia al grupo al que pertenecen.
CREATE TABLE usuario -- Tabla de usuarios.
(
    usuario_id INT PRIMARY KEY, -- Identificador único del usuario
    usuario_nombre VARCHAR(100) NOT NULL, -- Nombre completo del usuario
    usuario_email VARCHAR(100) UNIQUE NOT NULL, -- Correo electrónico del usuario
    usuario_password TEXT NOT NULL, -- Hash de la contraseña
    grupo_id INT NOT NULL, -- Referencia al grupo del usuario
    usuario_activo BOOLEAN DEFAULT TRUE, -- Estado del usuario
    usuario_fechacreacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Fecha de creación
    CONSTRAINT fk_usuario_grupo -- Clave foránea al grupo
        FOREIGN KEY (grupo_id) -- Columna de referencia
        REFERENCES grupo(grupo_id) -- Referencia a la tabla grupo
) ENGINE=InnoDB; -- Motor de almacenamiento

-- Tabla de módulos del sistema.
CREATE TABLE modulo -- Tabla de módulos.
(
    modulo_id INT PRIMARY KEY, -- Identificador único del módulo
    modulo_nombre VARCHAR(50) NOT NULL UNIQUE, -- Nombre del módulo
    modulo_descripcion TEXT, -- Descripción del módulo
    modulo_ruta VARCHAR(100) -- Ruta o URL del módulo
) ENGINE=InnoDB; -- Motor de almacenamiento

CREATE TABLE modulo (
    modulo_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    modulo_nombre VARCHAR(50) NOT NULL UNIQUE,
    modulo_descripcion TEXT,
    modulo_ruta VARCHAR(100)
) ENGINE=InnoDB;



-- Tabla intermedia para asignar módulos a grupos.
CREATE TABLE grupos_modulos -- Tabla de asignación de módulos a grupos.
(
    grupo_id INT NOT NULL, -- Identificador del grupo
    modulo_id INT NOT NULL, -- Identificador del módulo
    PRIMARY KEY (grupo_id, modulo_id), -- Clave primaria compuesta
    CONSTRAINT fk_grupo --  Clave foránea al grupo
        FOREIGN KEY (grupo_id) -- Columna de referencia
        REFERENCES grupo(grupo_id), -- Referencia a la tabla grupo
    CONSTRAINT fk_modulo -- Clave foránea al módulo
        FOREIGN KEY (modulo_id) -- Columna de referencia
        REFERENCES modulo(modulo_id) -- Referencia a la tabla modulo
) ENGINE=InnoDB; -- Motor de almacenamiento

-- Insertar datos iniciales
INSERT INTO grupo (grupo_nombre) VALUES
('Administrador'),
('Administrativo'),
('Comercial'),
('Operaciones');

-- Insertar módulos
INSERT INTO modulo (modulo_nombre) VALUES
('Comercial'),
('Administrativo'),
('Operaciones'),
('Reportes'),
('Configuracion');


-- Asignar módulos a grupos
INSERT INTO grupos_modulos (grupo_id, modulo_id) -- Administrador → todos los módulos
SELECT g.grupo_id, m.modulo_id -- Selecciona todos los módulos
FROM grupo g, modulo m -- Producto cartesiano para asignar todos los módulos
WHERE g.grupo_nombre = 'Administrador'; -- Filtra solo el grupo Administrador

-- Comercial → solo módulo Comercial
INSERT INTO grupos_modulos (grupo_id, modulo_id)
SELECT g.grupo_id, m.modulo_id
FROM grupo g
JOIN modulo m ON m.modulo_nombre = 'Comercial'
WHERE g.grupo_nombre = 'Comercial';

-- Operaciones → módulo Operaciones
INSERT INTO grupos_modulos (grupo_id, modulo_id)
SELECT g.grupo_id, m.modulo_id
FROM grupo g
JOIN modulo m ON m.modulo_nombre = 'Operaciones'
WHERE g.grupo_nombre = 'Operaciones';

-- Crear usuarios
INSERT INTO usuario (usuario_nombre, usuario_email, usuario_password, grupo_id)
VALUES (
    'Juan Pérez',
    'juan@empresa.com',
    'hash_password',
    (SELECT grupo_id FROM grupo WHERE grupo_nombre = 'Administrador')
);

-- Consulta CLAVE: módulos que puede ver un usuario
-- Esta consulta la usarás cada vez que el usuario inicie sesión.
SELECT m.modulo_nombre
FROM usuario u
JOIN grupo g ON u.grupo_id = g.grupo_id
JOIN grupos_modulos gm ON g.grupo_id = gm.grupo_id
JOIN modulo m ON gm.modulo_id = m.modulo_id
WHERE u.usuario_id = 1;

