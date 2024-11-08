-- Conectarse a la base de datos postgres
\c postgres;

-- Verificar si la base de datos 'hogwarts' ya existe y crearla si no existe
SELECT 'CREATE DATABASE hogwarts'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'hogwarts')\gexec

-- Conectarse a la base de datos hogwarts
\c hogwarts;

-- Borrar tablas si existen
DROP TABLE IF EXISTS Casa, Estudiante, Mascota, Asignatura, Profesor, Estudiante_Asignatura;

-- Crear tabla Asignatura
CREATE TABLE IF NOT EXISTS Asignatura (
    id_asignatura SERIAL PRIMARY KEY,
    nombre_asignatura VARCHAR(100) UNIQUE NOT NULL,
    aula VARCHAR(50),
    obligatoria BOOLEAN
);

-- Crear tabla Profesor
CREATE TABLE IF NOT EXISTS Profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    id_asignatura INT,
    fecha_inicio DATE,
	UNIQUE (nombre, apellido),
    FOREIGN KEY (id_asignatura) REFERENCES Asignatura(id_asignatura)
);

-- Crear tabla Casa
CREATE TABLE IF NOT EXISTS Casa (
    id_casa SERIAL PRIMARY KEY,
    nombre_casa VARCHAR(50) UNIQUE NOT NULL,
    fundador VARCHAR(50) NOT NULL,
    id_jefe INT NOT NULL,
    fantasma VARCHAR(50) NOT NULL,
    FOREIGN KEY (id_jefe) REFERENCES Profesor(id_profesor)
);

-- Crear tabla Estudiante
CREATE TABLE IF NOT EXISTS Estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    id_casa INT,
    anyo_curso INT,
    fecha_nacimiento DATE NOT NULL,
	UNIQUE (nombre, apellido),
    FOREIGN KEY (id_casa) REFERENCES Casa(id_casa)
);

-- Crear tabla Mascota
CREATE TABLE IF NOT EXISTS Mascota (
    id_mascota SERIAL PRIMARY KEY,
    nombre_mascota VARCHAR(50) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    id_estudiante INT,
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante)
);

-- Crear tabla Estudiante_Asignatura
CREATE TABLE IF NOT EXISTS Estudiante_Asignatura (
    id_estudiante INT,
    id_asignatura INT,
    calificacion DECIMAL(3,1),
    PRIMARY KEY (id_estudiante, id_asignatura),
    FOREIGN KEY (id_estudiante) REFERENCES Estudiante(id_estudiante),
    FOREIGN KEY (id_asignatura) REFERENCES Asignatura(id_asignatura)
);

-- Insertar Asignaturas (16)
INSERT INTO Asignatura (nombre_asignatura, aula, obligatoria) VALUES
('Transformaciones', '1B', TRUE),
('Pociones', 'Mazmorras', TRUE),
('Encantamientos', '2E', TRUE),
('Defensa Contra las Artes Oscuras', '3C', TRUE),
('Herbología', 'Invernadero', TRUE),
('Historia de la Magia', '4F', TRUE),
('Astronomía', 'Torre de Astronomía', TRUE),
('Adivinación', 'Torre Norte', FALSE),
('Cuidado de Criaturas Mágicas', 'Terrenos', FALSE),
('Estudios Muggles', '1A', FALSE),
('Aritmancia', '7C', FALSE),
('Runas Antiguas', '6A', FALSE),
('Alquimia', '5D', FALSE),
('Aparición', 'Gran Comedor', FALSE),
('Vuelo', 'Terrenos', TRUE),
('Estudios Avanzados de Aritmancia', '7D', FALSE);

-- Insertar Profesores (16)
INSERT INTO Profesor (nombre, apellido, id_asignatura, fecha_inicio) VALUES
('Minerva', 'McGonagall', 1, '1956-09-01'),
('Severus', 'Snape', 2, '1981-09-01'),
('Filius', 'Flitwick', 3, '1971-09-01'),
('Remus', 'Lupin', 4, '1993-09-01'),
('Pomona', 'Sprout', 5, '1975-09-01'),
('Cuthbert', 'Binns', 6, '1800-09-01'),
('Aurora', 'Sinistra', 7, '1985-09-01'),
('Sybill', 'Trelawney', 8, '1979-09-01'),
('Rubeus', 'Hagrid', 9, '1993-09-01'),
('Charity', 'Burbage', 10, '1990-09-01'),
('Septima', 'Vector', 11, '1982-09-01'),
('Bathsheda', 'Babbling', 12, '1988-09-01'),
('Horace', 'Slughorn', 2, '1996-09-01'),
('Alastor', 'Moody', 4, '1994-09-01'),
('Rolanda', 'Hooch', 15, '1974-09-01'),
('Firenze', 'Centauro', 8, '1996-03-01');

-- Insertar Casas
INSERT INTO Casa (nombre_casa, fundador, id_jefe, fantasma) VALUES
('Gryffindor', 'Godric Gryffindor', 1, 'Nick Casi Decapitado'),
('Hufflepuff', 'Helga Hufflepuff', 5, 'Fraile Gordo'),
('Ravenclaw', 'Rowena Ravenclaw', 3, 'Dama Gris'),
('Slytherin', 'Salazar Slytherin', 2, 'Barón Sanguinario');

-- Insertar Estudiantes (60)
INSERT INTO Estudiante (nombre, apellido, id_casa, anyo_curso, fecha_nacimiento) VALUES
('Harry', 'Potter', 1, 5, '1980-07-31'),
('Hermione', 'Granger', 1, 5, '1979-09-19'),
('Ron', 'Weasley', 1, 5, '1980-03-01'),
('Draco', 'Malfoy', 4, 5, '1980-06-05'),
('Neville', 'Longbottom', 1, 5, '1980-07-30'),
('Luna', 'Lovegood', 3, 4, '1981-02-13'),
('Ginny', 'Weasley', 1, 4, '1981-08-11'),
('Fred', 'Weasley', 1, 7, '1978-04-01'),
('George', 'Weasley', 1, 7, '1978-04-01'),
('Cho', 'Chang', 3, 6, '1979-04-07'),
('Cedric', 'Diggory', 2, 6, '1977-09-01'),
('Seamus', 'Finnigan', 1, 5, '1980-03-15'),
('Dean', 'Thomas', 1, 5, '1980-01-20'),
('Lavender', 'Brown', 1, 5, '1980-02-09'),
('Parvati', 'Patil', 1, 5, '1980-04-22'),
('Padma', 'Patil', 3, 5, '1980-04-22'),
('Hannah', 'Abbott', 2, 5, '1980-05-12'),
('Ernie', 'Macmillan', 2, 5, '1980-04-30'),
('Justin', 'Finch-Fletchley', 2, 5, '1980-06-17'),
('Susan', 'Bones', 2, 5, '1980-03-28'),
('Zacharias', 'Smith', 2, 5, '1980-09-05'),
('Terry', 'Boot', 3, 5, '1980-02-13'),
('Michael', 'Corner', 3, 5, '1980-08-18'),
('Anthony', 'Goldstein', 3, 5, '1980-04-03'),
('Pansy', 'Parkinson', 4, 5, '1979-12-30'),
('Blaise', 'Zabini', 4, 5, '1979-11-01'),
('Theodore', 'Nott', 4, 5, '1980-01-15'),
('Millicent', 'Bulstrode', 4, 5, '1979-09-05'),
('Vincent', 'Crabbe', 4, 5, '1979-10-17'),
('Gregory', 'Goyle', 4, 5, '1980-02-22'),
('Angelina', 'Johnson', 1, 7, '1977-10-30'),
('Alicia', 'Spinnet', 1, 7, '1977-11-15'),
('Katie', 'Bell', 1, 6, '1978-12-20'),
('Oliver', 'Wood', 1, 7, '1975-10-01'),
('Percy', 'Weasley', 1, 7, '1976-08-22'),
('Penelope', 'Clearwater', 3, 7, '1976-07-11'),
('Marcus', 'Flint', 4, 7, '1975-09-23'),
('Adrian', 'Pucey', 4, 6, '1977-11-05'),
('Terence', 'Higgs', 4, 6, '1977-12-18'),
('Lee', 'Jordan', 1, 7, '1977-06-08'),
('Cormac', 'McLaggen', 1, 6, '1978-07-14'),
('Romilda', 'Vane', 1, 4, '1981-10-09'),
('Colin', 'Creevey', 1, 3, '1982-05-25'),
('Dennis', 'Creevey', 1, 1, '1984-09-13'),
('Marietta', 'Edgecombe', 3, 6, '1978-11-22'),
('Eddie', 'Carmichael', 3, 7, '1977-03-17'),
('Stewart', 'Ackerley', 3, 1, '1983-08-05'),
('Orla', 'Quirke', 3, 1, '1983-09-30'),
('Eleanor', 'Branstone', 2, 1, '1983-10-12'),
('Owen', 'Cauldwell', 2, 1, '1983-07-07'),
('Laura', 'Madley', 2, 1, '1983-11-20'),
('Kevin', 'Whitby', 2, 1, '1983-12-01'),
('Graham', 'Pritchard', 4, 1, '1983-06-15'),
('Malcolm', 'Baddock', 4, 1, '1983-05-10'),
('Astoria', 'Greengrass', 4, 3, '1982-02-14'),
('Daphne', 'Greengrass', 4, 5, '1980-03-03'),
('Morag', 'MacDougal', 3, 5, '1980-01-23'),
('Lisa', 'Turpin', 3, 5, '1980-05-17'),
('Mandy', 'Brocklehurst', 3, 5, '1980-04-09');

-- Insertar Mascotas (30)
INSERT INTO Mascota (nombre_mascota, especie, id_estudiante) VALUES
('Hedwig', 'Lechuza', 1),
('Crookshanks', 'Gato', 2),
('Scabbers', 'Rata', 3),
('Trevor', 'Sapo', 5),
('Arnold', 'Micropuff', 7),
('Fang', 'Perro', NULL),
('Buckbeak', 'Hipogrifo', NULL),
('Fluffy', 'Perro de tres cabezas', NULL),
('Aragog', 'Acromántula', NULL),
('Norberta', 'Dragón', NULL),
('Fawkes', 'Fénix', NULL),
('Mrs. Norris', 'Gato', NULL),
('Errol', 'Lechuza', NULL),
('Hermes', 'Lechuza', 35),
('Binky', 'Conejo', 14),
('Tenebrus', 'Thestral', NULL),
('Witherwings', 'Hipogrifo', NULL),
('Firenze', 'Centauro', NULL),
('Grawp', 'Gigante', NULL),
('Nagini', 'Serpiente', NULL),
('Peeves', 'Poltergeist', NULL),
('Winky', 'Elfo doméstico', NULL),
('Dobby', 'Elfo doméstico', NULL),
('Kreacher', 'Elfo doméstico', NULL),
('Griphook', 'Goblin', NULL),
('Bane', 'Centauro', NULL),
('Ronan', 'Centauro', NULL),
('Magorian', 'Centauro', NULL),
('Aragog Jr.', 'Acromántula', NULL);

-- Insertar Estudiante_Asignatura para todos los estudiantes
INSERT INTO Estudiante_Asignatura (id_estudiante, id_asignatura, calificacion) VALUES
(1, 15, 7.3), (1, 8, 8.6), (1, 4, 9.6), (1, 2, 9.8),
(2, 1, 8.3), (2, 16, 5.9), (2, 4, 8.6), (2, 6, 5.6),
(3, 11, 6.4), (3, 8, 6.3), (3, 12, 9.3), (3, 13, 7.9),
(4, 14, 9.5), (4, 13, 9.4), (4, 15, 8.1), (4, 8, 9.5),
(5, 13, 9.6), (5, 16, 5.1), (5, 11, 6.5), (5, 5, 5.8),
(6, 3, 6.7), (6, 16, 7.8), (6, 13, 8.2), (6, 7, 7.9),
(7, 9, 5.2), (7, 2, 9.4), (7, 12, 8.6), (7, 6, 6.4),
(8, 3, 9.3), (8, 8, 5.7), (8, 2, 5.2), (8, 1, 9.9),
(9, 8, 9.6), (9, 16, 8.9), (9, 4, 6.9), (9, 10, 7.9),
(10, 11, 8.3), (10, 7, 7.7), (10, 2, 9.1), (10, 15, 6.7),
(11, 2, 7.1), (11, 9, 8.5), (11, 10, 9.3), (11, 16, 7.3),
(12, 2, 9.5), (12, 1, 7.6), (12, 16, 6.9), (12, 3, 6.7),
(13, 11, 7.2), (13, 9, 9.0), (13, 6, 6.5), (13, 5, 6.8),
(14, 3, 5.8), (14, 14, 7.6), (14, 4, 9.4), (14, 12, 9.2),
(15, 13, 7.9), (15, 1, 9.7), (15, 4, 5.0), (15, 3, 6.8),
(16, 11, 6.9), (16, 15, 6.8), (16, 12, 5.2), (16, 14, 5.5),
(17, 8, 5.7), (17, 1, 5.4), (17, 4, 7.2), (17, 6, 5.7),
(18, 5, 5.5), (18, 10, 5.1), (18, 12, 6.7), (18, 3, 9.5),
(19, 4, 7.2), (19, 8, 9.5), (19, 15, 9.5), (19, 1, 8.5),
(20, 1, 5.6), (20, 3, 9.2), (20, 7, 8.9), (20, 2, 9.1),
(21, 15, 9.2), (21, 13, 7.3), (21, 5, 8.6), (21, 7, 6.8),
(22, 4, 9.1), (22, 9, 8.4), (22, 8, 5.0), (22, 6, 9.1),
(23, 15, 6.1), (23, 10, 10.0), (23, 9, 7.7), (23, 5, 9.1),
(24, 16, 7.2), (24, 4, 6.0), (24, 12, 5.7), (24, 13, 7.9),
(25, 1, 5.6), (25, 14, 5.4), (25, 11, 9.5), (25, 15, 9.2),
(26, 14, 5.4), (26, 1, 8.6), (26, 13, 6.4), (26, 4, 9.9),
(27, 11, 9.8), (27, 16, 7.9), (27, 2, 5.2), (27, 15, 8.9),
(28, 12, 6.6), (28, 9, 5.7), (28, 5, 8.5), (28, 16, 6.4),
(29, 4, 7.1), (29, 7, 5.5), (29, 13, 9.5), (29, 15, 6.4),
(30, 14, 8.1), (30, 16, 8.9), (30, 9, 7.5), (30, 5, 8.8),
(31, 10, 5.6), (31, 7, 9.4), (31, 15, 9.3), (31, 11, 7.5),
(32, 8, 9.8), (32, 1, 8.0), (32, 6, 5.8), (32, 11, 5.5),
(33, 10, 8.0), (33, 6, 5.5), (33, 9, 9.1), (33, 11, 8.9),
(34, 8, 7.2), (34, 7, 5.8), (34, 3, 8.2), (34, 1, 6.1),
(35, 8, 9.4), (35, 5, 5.9), (35, 15, 5.6), (35, 16, 7.7),
(36, 8, 7.1), (36, 2, 5.3), (36, 16, 6.0), (36, 9, 6.4),
(37, 13, 9.1), (37, 7, 7.7), (37, 16, 8.8), (37, 1, 9.2),
(38, 14, 7.7), (38, 12, 8.5), (38, 5, 6.0), (38, 9, 8.3),
(39, 14, 8.4), (39, 11, 7.6), (39, 13, 5.4), (39, 4, 8.7),
(40, 9, 5.5), (40, 16, 7.7), (40, 1, 6.6), (40, 8, 8.6),
(41, 9, 5.4), (41, 4, 8.8), (41, 15, 5.1), (41, 1, 8.2),
(42, 6, 9.1), (42, 2, 8.2), (42, 1, 9.7), (42, 12, 8.7),
(43, 3, 5.8), (43, 15, 7.5), (43, 1, 9.5), (43, 11, 5.4),
(44, 4, 9.6), (44, 10, 8.8), (44, 1, 5.9), (44, 9, 7.0),
(45, 13, 8.7), (45, 16, 9.8), (45, 1, 8.4), (45, 4, 6.9),
(46, 13, 8.9), (46, 6, 8.2), (46, 16, 6.9), (46, 7, 6.2),
(47, 4, 6.7), (47, 12, 7.9), (47, 8, 10.0), (47, 7, 7.0),
(48, 14, 9.9), (48, 4, 7.4), (48, 9, 7.4), (48, 7, 7.2),
(49, 14, 7.7), (49, 1, 8.9), (49, 7, 6.9), (49, 4, 6.5),
(50, 13, 6.6), (50, 14, 9.8), (50, 11, 8.2), (50, 6, 6.5),
(51, 15, 9.8), (51, 7, 9.2), (51, 14, 9.7), (51, 5, 7.6),
(52, 9, 6.6), (52, 2, 9.6), (52, 8, 5.8), (52, 15, 9.2),
(53, 12, 9.2), (53, 11, 9.5), (53, 7, 7.0), (53, 13, 5.5),
(54, 5, 5.7), (54, 1, 8.8), (54, 14, 6.8), (54, 16, 9.4),
(55, 11, 9.4), (55, 7, 6.0), (55, 6, 8.9), (55, 16, 6.0),
(56, 5, 7.4), (56, 8, 6.3), (56, 10, 8.3), (56, 6, 9.5),
(57, 2, 9.8), (57, 13, 9.8), (57, 14, 7.4), (57, 7, 5.9),
(58, 14, 9.9), (58, 5, 5.5), (58, 11, 7.2), (58, 1, 8.4),
(59, 13, 7.8), (59, 3, 6.2), (59, 10, 8.7), (59, 6, 9.7);

DROP FUNCTION IF EXISTS matricular_estudiante(
    VARCHAR(50),
    VARCHAR(50),
    DATE,
    INT
);

CREATE OR REPLACE FUNCTION matricular_estudiante(
    p_nombre VARCHAR(50),
    p_apellido VARCHAR(50),
    p_fecha_nacimiento DATE,
    p_anyo_curso INT
) RETURNS TABLE (
    out_id_estudiante INT,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    nombre_casa VARCHAR(50),
    mascota VARCHAR(50)
) AS $$
DECLARE
    v_id_casa INT;
    v_nombre_mascota VARCHAR(50);
    v_especie_mascota VARCHAR(50);
BEGIN
    -- Asignar casa aleatoriamente (PostgreSQL usa RANDOM())
    v_id_casa := CEIL(RANDOM() * 4);
    
    -- Insertar el nuevo estudiante y devolver el ID insertado
    INSERT INTO Estudiante (nombre, apellido, id_casa, anyo_curso, fecha_nacimiento)
    VALUES (p_nombre, p_apellido, v_id_casa, p_anyo_curso, p_fecha_nacimiento)
    RETURNING id_estudiante INTO out_id_estudiante;

    -- Matricular al estudiante en las asignaturas básicas
    INSERT INTO Estudiante_Asignatura (id_estudiante, id_asignatura)
    SELECT out_id_estudiante, id_asignatura
    FROM Asignatura
    WHERE obligatoria = TRUE AND id_asignatura <= 7;

    -- Asignar mascota aleatoriamente
    v_especie_mascota := (ARRAY['Lechuza', 'Gato', 'Sapo', 'Rata'])[CEIL(RANDOM() * 4)];
    v_nombre_mascota := CONCAT('Mascota_', out_id_estudiante);
    
    -- Insertar la mascota
    INSERT INTO Mascota (nombre_mascota, especie, id_estudiante)
    VALUES (v_nombre_mascota, v_especie_mascota, out_id_estudiante);

    -- Devolver la información del estudiante matriculado
    RETURN QUERY
    SELECT e.id_estudiante, e.nombre, e.apellido, c.nombre_casa, m.especie AS mascota
    FROM Estudiante e
    JOIN Casa c ON e.id_casa = c.id_casa
    LEFT JOIN Mascota m ON e.id_estudiante = m.id_estudiante
    WHERE e.id_estudiante = out_id_estudiante;

END;
$$ LANGUAGE plpgsql;

DROP PROCEDURE IF EXISTS crear_estudiante(
    VARCHAR(50),
    VARCHAR(50),
    DATE,
    INT
);
CREATE OR REPLACE PROCEDURE crear_estudiante(
    p_nombre VARCHAR(50),
    p_apellido VARCHAR(50),
    p_fecha_nacimiento DATE,
    p_anyo_curso INT
) AS $$
DECLARE
    v_id_casa INT;
    v_id_estudiante INT;  -- Variable para almacenar el ID del estudiante recién creado
BEGIN
    -- Asignar casa aleatoriamente (PostgreSQL usa RANDOM())
    v_id_casa := CEIL(RANDOM() * 4);
    -- Insertar el nuevo estudiante
    INSERT INTO Estudiante (nombre, apellido, id_casa, anyo_curso, fecha_nacimiento)
    VALUES (p_nombre, p_apellido, v_id_casa, p_anyo_curso, p_fecha_nacimiento)
    RETURNING id_estudiante INTO v_id_estudiante;  -- Captura el ID del estudiante insertado
    -- Matricular al estudiante en las asignaturas básicas
    INSERT INTO Estudiante_Asignatura (id_estudiante, id_asignatura)
    SELECT v_id_estudiante, id_asignatura
    FROM Asignatura
    WHERE obligatoria = TRUE AND id_asignatura <= 7;  -- Asegúrate de matricular las asignaturas obligatorias
    RAISE NOTICE 'Estudiante % % ha sido creado y asignado a la casa %.', p_nombre, p_apellido, v_id_casa;
END;
$$ LANGUAGE plpgsql;
