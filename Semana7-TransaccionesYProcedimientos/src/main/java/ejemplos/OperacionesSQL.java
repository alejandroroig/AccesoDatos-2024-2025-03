package ejemplos;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

public class OperacionesSQL {
    private static String URL;
    private static String USER;
    private static String PASSWORD;

    public static void main(String[] args) {

        // Cargar las propiedades de conexión
        loadDatabaseProperties();

        // Conectar a la base de datos
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            // Mostrar usuarios y cuentas
            System.out.println("Usuarios y cuentas iniciales:");
            mostrarUsuariosYCuentas(conn);
            System.out.println();

            // 1. Realizar una transacción con éxito
            realizarTransaccion(conn, 2, 3, 100.00);
            System.out.println("Usuarios y cuentas tras transacción exitosa:");
            mostrarUsuariosYCuentas(conn);
            System.out.println();

            // 1. Realizar una transacción fallida (usuario de destino no existe)
            realizarTransaccion(conn, 2, 100, 50.00);
            System.out.println("Usuarios y cuentas tras transacción fallida:");
            mostrarUsuariosYCuentas(conn);
            System.out.println();

            // 2. Ejemplo de Inserción en ambas tablas
            int nuevoUsuarioId = insertarUsuarioYCuenta(conn, "nuevo_usuario",
                    "password123",
                    "maildeprueba@gmail.com",
                    500.00);
            System.out.println("Usuarios y cuentas tras inserción:");
            mostrarUsuariosYCuentas(conn);
            System.out.println();

            // 3. Ejecutar un procedimiento almacenado sin retorno (transferencia)
            transferenciaBancaria(conn, 2, 3, 200.00);
            System.out.println("Usuarios y cuentas tras procedimiento almacenado:");
            mostrarUsuariosYCuentas(conn);
            System.out.println();

            // 4. Ejecutar una función con retorno (saldo)
            System.out.println("Función ejecutada: Saldo del usuario 2: " + obtenerSaldo(conn, 2));
            System.out.println();

            // 5. Borrar el usuario y cuenta insertados
            borrarUsuarioYCuenta(conn, nuevoUsuarioId);
            System.out.println("Usuarios y cuentas tras borrado:");
            mostrarUsuariosYCuentas(conn);

        } catch (SQLException e) {
            System.err.println("Error al conectar a la base de datos: " + e.getMessage());
        }
    }



    // 1. Ejemplo de Transacción: Transferir saldo entre dos usuarios
    public static void realizarTransaccion(Connection conn, int usuarioOrigen, int usuarioDestino, double monto) {
        try {
            // Iniciar la transacción
            conn.setAutoCommit(false);

            String sqlOrigen = "UPDATE cuentas SET saldo = saldo - ? WHERE id_usuario = ?";
            String sqlDestino = "UPDATE cuentas SET saldo = saldo + ? WHERE id_usuario = ?";

            try (PreparedStatement pstmtRestar = conn.prepareStatement(sqlOrigen);
                 PreparedStatement pstmtSumar = conn.prepareStatement(sqlDestino)) {

                // Restar el monto en el saldo del usuario origen
                pstmtRestar.setDouble(1, monto);
                pstmtRestar.setInt(2, usuarioOrigen);
                int filasAfectadasOrigen = pstmtRestar.executeUpdate();

                // Sumar el monto en el saldo del usuario destino
                pstmtSumar.setDouble(1, monto);
                pstmtSumar.setInt(2, usuarioDestino);
                int filasAfectadasDestino = pstmtSumar.executeUpdate();

                // Verificar que ambas operaciones afectaron una fila para confirmar la transacción
                if (filasAfectadasOrigen == 1 && filasAfectadasDestino == 1) {
                    // Confirmar la transacción
                    conn.commit();
                    System.out.println("Transacción realizada con éxito. Monto transferido: " + monto);
                } else {
                    throw new SQLException("Usuario origen o destino no existe. Transacción cancelada.");
                }
            }
        } catch (SQLException e) {
            try {
                // Si algo falla, hacemos rollback
                conn.rollback();
                System.out.println("Transacción fallida. Haciendo rollback.");
            } catch (SQLException rollbackEx) {
                System.err.println("Error al hacer rollback: " + rollbackEx.getMessage());
            }
        } finally {
            try {
                // Restaurar el modo autocommit al final
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Error al restaurar autocommit: " + e.getMessage());
            }
        }
    }

    // 2. Ejemplo de Inserción en ambas tablas
    public static int insertarUsuarioYCuenta(Connection conn, String username, String password, String email, double saldoInicial) {
        int idGenerado = -1;  // Para almacenar el ID del nuevo usuario
        try {
            // Comenzar la transacción
            conn.setAutoCommit(false);

            String sqlUsuario = "INSERT INTO usuarios (username, password, email) VALUES (?, ?, ?)";
            String sqlCuenta = "INSERT INTO cuentas (id_usuario, saldo) VALUES (?, ?)";

            // Inserción en la tabla usuarios
            try (PreparedStatement pstmtUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS)) {
                pstmtUsuario.setString(1, username);
                pstmtUsuario.setString(2, password);
                pstmtUsuario.setString(3, email);

                int filasAfectadasUsuario = pstmtUsuario.executeUpdate();
                System.out.println("Filas afectadas al insertar usuario: " + filasAfectadasUsuario);

                // Obtener el ID generado
                try (ResultSet rsUsuario = pstmtUsuario.getGeneratedKeys()) {
                    if (rsUsuario.next()) {
                        idGenerado = rsUsuario.getInt(1);
                    } else {
                        throw new SQLException("Error al obtener ID del nuevo usuario.");
                    }
                }
            }

            // Inserción en la tabla cuentas
            try (PreparedStatement pstmtCuenta = conn.prepareStatement(sqlCuenta)) {
                pstmtCuenta.setInt(1, idGenerado);
                pstmtCuenta.setDouble(2, saldoInicial);

                int filasAfectadasCuenta = pstmtCuenta.executeUpdate();
                System.out.println("Filas afectadas al insertar cuenta: " + filasAfectadasCuenta);
            }

            // Confirmar la transacción
            conn.commit();
            System.out.println("Usuario y cuenta insertados con éxito. ID del nuevo usuario: " + idGenerado);

        } catch (SQLException e) {
            try {
                // Si algo falla, hacemos rollback
                conn.rollback();
                System.out.println("Transacción fallida. Haciendo rollback.");
            } catch (SQLException rollbackEx) {
                System.err.println("Error al hacer rollback: " + rollbackEx.getMessage());
            }
        } finally {
            try {
                // Restaurar el modo autocommit al final
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Error al restaurar autocommit: " + e.getMessage());
            }
        }
        return idGenerado;
    }


    // 3. Ejemplo de PROCEDIMIENTO ALMACENADO sin retorno (transferencia)
    public static void transferenciaBancaria(Connection conn, int usuarioOrigen, int usuarioDestino, double cantidad) {
        // Un procedimiento permite realizar cambios en las tablas sin necesidad de retornar un valor
        // Podemos invocar un procedimiento almacenado con CallableStatement y la llamada a la función CALL
        String sql = "CALL transferencia_bancaria(?, ?, ?::NUMERIC)"; // Convertimos el double a DECIMAL/NUMERIC
        try (CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setInt(1, usuarioOrigen);
            cstmt.setInt(2, usuarioDestino);
            cstmt.setDouble(3, cantidad);
            cstmt.execute();
            System.out.println("Procedimiento almacenado ejecutado con éxito. Cantidad transferido: " + cantidad);
        } catch (SQLException e) {
            System.err.println("Error al ejecutar el procedimiento almacenado: " + e.getMessage());
        }
    }

    // 4. Ejemplo de FUNCIÓN con retorno (obtener saldo)
    public static double obtenerSaldo(Connection conn, int idUsuario) {
        // Una función devuelve un valor, por lo que podemos usar un SELECT para obtenerlo mediante PreparedStatement
        double saldo = -1.0;  // Valor de error por si no se encuentra el saldo
        String sql = "SELECT obtener_saldo(?)";  // Usamos SELECT porque esperamos un retorno
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, idUsuario);

            try(ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    saldo = rs.getDouble(1);  // El saldo retornado está en la primera columna del resultado
                    System.out.println("Saldo actual del usuario con ID " + idUsuario + ": " + saldo);
                } else {
                    System.out.println("No se encontró el saldo para el usuario con ID: " + idUsuario);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al obtener el saldo: " + e.getMessage());
        }
        return saldo;
    }

    // 5. Ejemplo de Borrado en ambas tablas
    public static void borrarUsuarioYCuenta(Connection conn, int idUsuario) {
        try {
            // Iniciar la transacción
            conn.setAutoCommit(false);

            String sqlEliminarCuenta = "DELETE FROM cuentas WHERE id_usuario = ?";
            String sqlEliminarUsuario = "DELETE FROM usuarios WHERE id_usuario = ?";

            try (PreparedStatement pstmtCuenta = conn.prepareStatement(sqlEliminarCuenta);
                 PreparedStatement pstmtUsuario = conn.prepareStatement(sqlEliminarUsuario)) {

                // Eliminar primero la cuenta asociada al usuario
                pstmtCuenta.setInt(1, idUsuario);
                int filasAfectadasCuenta = pstmtCuenta.executeUpdate();

                // Eliminar el usuario de la tabla usuarios
                pstmtUsuario.setInt(1, idUsuario);
                int filasAfectadasUsuario = pstmtUsuario.executeUpdate();

                // Confirmar la transacción
                if (filasAfectadasCuenta == 1 && filasAfectadasUsuario == 1) {
                    conn.commit();
                    System.out.println("Usuario y cuenta borrados con éxito");
                }
            }
        } catch (SQLException e) {
            try {
                // Si algo falla, hacer rollback
                conn.rollback();
                System.out.println("Error al borrar usuario y cuenta. Se hizo rollback.");
            } catch (SQLException rollbackEx) {
                System.err.println("Error al hacer rollback: " + rollbackEx.getMessage());
            }
        } finally {
            try {
                // Restaurar el modo autocommit
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Error al restaurar autocommit: " + e.getMessage());
            }
        }
    }

    /*
    *
    * Métodos vistos en la semana anterior
    *
    */

    private static void loadDatabaseProperties() {
        Properties properties = new Properties();
        try (InputStream input = OperacionesSQL.class.getClassLoader().getResourceAsStream("db.properties")) {
            properties.load(input);
            URL = properties.getProperty("db.url");
            USER = properties.getProperty("db.user");
            PASSWORD = properties.getProperty("db.password");

            if (URL == null || USER == null || PASSWORD == null) {
                throw new SQLException("Error: propiedades de conexión no válidas.");
            }
        } catch (IOException ex) {
            System.err.println("Error al cargar el archivo de propiedades: " + ex.getMessage());
        } catch (SQLException ex) {
            System.err.println(ex.getMessage());
        }
    }

    public static void mostrarUsuariosYCuentas(Connection conn) {
        try {
            String sql = "SELECT u.id_usuario, u.username, u.password, u.email, c.id_cuenta, c.saldo " +
                    "FROM usuarios u INNER JOIN cuentas c ON u.id_usuario = c.id_usuario";
            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    Cuenta cuenta = new Cuenta(rs.getInt("id_cuenta"), rs.getDouble("saldo"));
                    Usuario usuario = new Usuario(rs.getInt("id_usuario"),
                            rs.getString("username"),
                            rs.getString("password"),
                            rs.getString("email"),
                            cuenta);
                    System.out.println(usuario);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error al ejecutar la consulta: " + e.getMessage());
        }
    }
}
