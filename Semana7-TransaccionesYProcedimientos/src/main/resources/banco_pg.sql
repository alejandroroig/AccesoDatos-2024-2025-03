-- Conectarse a la base de datos postgres
\c postgres;

-- Verificar si la base de datos 'banco' ya existe y crearla si no existe
SELECT 'CREATE DATABASE banco'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'banco')\gexec

-- Conectarse a la base de datos banco
\c banco;

-- Borrar tablas si existen
DROP TABLE IF EXISTS usuarios, cuentas;

-- Crear tabla usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(50) NOT NULL,  -- Para propósitos educativos, usaremos texto plano
    email VARCHAR(100) NOT NULL UNIQUE
);

-- Crear tabla cuentas_bancarias
CREATE TABLE IF NOT EXISTS cuentas (
    id_cuenta SERIAL PRIMARY KEY,
    id_usuario INT NOT NULL,
    saldo DECIMAL(10, 2) DEFAULT 0.00 CHECK (saldo >= 0.00),
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
);

-- Insertar algunos datos en usuarios
INSERT INTO usuarios (username, password, email) VALUES
('admin', '12345', 'admin@example.com'),  -- Usar un password simple para SQL Injection
('user1', 'password1', 'user1@example.com'),
('user2', 'password2', 'user2@example.com');

-- Insertar algunos datos en cuentas_bancarias
INSERT INTO cuentas (id_usuario, saldo) VALUES
(1, 1000.00),  -- Cuenta de admin
(2, 500.00),   -- Cuenta de user1
(3, 750.00);   -- Cuenta de user2

DROP FUNCTION IF EXISTS transferencia_bancaria;

CREATE OR REPLACE PROCEDURE transferencia_bancaria(
    p_usuario_origen INT,
    p_usuario_destino INT,
    p_monto DECIMAL(10, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    saldo_actual DECIMAL(10, 2);
BEGIN
    -- Comenzar la transacción
    -- En PostgreSQL, las transacciones se manejan automáticamente a menos que se especifique lo contrario.

    -- Verificar que el usuario origen tenga saldo suficiente
    SELECT saldo INTO saldo_actual
    FROM cuentas
    WHERE id_usuario = p_usuario_origen;

    IF saldo_actual IS NULL THEN
        RAISE EXCEPTION 'Usuario origen no existe';
    ELSIF saldo_actual < p_monto THEN
        -- Si no hay saldo suficiente, se lanza un error
        RAISE EXCEPTION 'Saldo insuficiente';
    ELSE
        -- Restar el monto de la cuenta de origen
        UPDATE cuentas
        SET saldo = saldo - p_monto
        WHERE id_usuario = p_usuario_origen;

        -- Sumar el monto a la cuenta de destino
        UPDATE cuentas
        SET saldo = saldo + p_monto
        WHERE id_usuario = p_usuario_destino;
    END IF;

END; $$;

CREATE OR REPLACE FUNCTION obtener_saldo(p_id_usuario INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    saldo DECIMAL(10, 2);
BEGIN
    SELECT c.saldo INTO saldo
    FROM cuentas c
    WHERE c.id_usuario = p_id_usuario;

    IF saldo IS NULL THEN
        RAISE EXCEPTION 'Usuario no encontrado o sin cuenta asociada';
    END IF;

    RETURN saldo;
END; $$
LANGUAGE plpgsql;