package ejercicios;

import ejercicios.modelos.Asignatura;
import ejercicios.modelos.Estudiante;
import ejercicios.modelos.Profesor;

import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.time.LocalDate;

public class HogwartsManager {
    private static String URL = "jdbc:postgresql://ad-postgres.cka0iu2nfgnn.us-east-1.rds.amazonaws.com:5432/hogwarts";
    private static String USER = "postgres";
    private static String PASSWORD = "qwerty1234";

    public static void main(String[] args) {
        // Conectar a la base de datos
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {

            // Ejercicio 1a: Crear profesor y una nueva asignatura mediante transacción
            System.out.println("\nCreando profesor y asignatura mediante transacción:");
            Asignatura asignaturaOk = new Asignatura("Arte Muggle", "Aula 1", true);
            Profesor profesorOk = new Profesor("Albus", "Dumbledore", LocalDate.of(2024, 1, 1));
            crearAsignaturaProfesor(conn, asignaturaOk, profesorOk);

            // Ejercicio 1b: Error al crear profesor y asignatura mediante transacción
            System.out.println("\nError al crear profesor y asignatura mediante transacción:");
            Asignatura asignaturaError = new Asignatura("Defensa contra las artes oscuras", "Aula 2", true);
            Profesor profesorError = new Profesor("Minerva", "McGonagall", LocalDate.of(2024, 1, 1));
            crearAsignaturaProfesor(conn, asignaturaError, profesorError);

            // Ejercicio 2: Llamar a una función matricular estudiante
            System.out.println("\nMatricular estudiante mediante función:");
            Estudiante estudianteUno = new Estudiante("Selena", "Shade", 4, LocalDate.of(2007, 5, 23));
            matricularEstudiante(conn, estudianteUno);

            // Ejercicio 3: Llamar a un procedimiento crear estudiante
            System.out.println("\nMatricular estudiante mediante procedimiento:");
            Estudiante estudianteDos = new Estudiante("Theo", "Blackthorn", 3, LocalDate.of(2008, 10, 11));
            crearEstudiante(conn, estudianteDos);

        } catch (SQLException e) {
            System.err.println("Error al conectar a la base de datos: " + e.getMessage());
        }
    }

    public static void crearAsignaturaProfesor(Connection conn, Asignatura asignatura, Profesor profesor) {
        try {
            conn.setAutoCommit(false);
            // Insertar asignatura y obtener su ID
            int idGeneradoAsignatura = insertarAsignatura(conn, asignatura);
            // Insertar profesor asociado a la asignatura
            int idGeneradoProfesor = insertarProfesor(conn, profesor, idGeneradoAsignatura);

            // Confirmar la transacción
            conn.commit();
            System.out.println("Asignatura y Profesor insertados con éxito." +
                    " ID de la nueva asignatura: " + idGeneradoAsignatura +
                    ", ID del nuevo profesor: " + idGeneradoProfesor);
        } catch (Exception e) {
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

    private static int insertarAsignatura(Connection conn, Asignatura asignatura) throws SQLException {
        String sql = "INSERT INTO Asignatura (nombre_asignatura, aula, obligatoria) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, asignatura.getNombre());
            pstmt.setString(2, asignatura.getAula());
            pstmt.setBoolean(3, asignatura.getObligatoria());
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                } else {
                    throw new SQLException("Error al obtener ID de la asignatura.");
                }
            }
        }
    }

    private static int insertarProfesor(Connection conn, Profesor profesor, int idAsignatura) throws SQLException {
        String sql = "INSERT INTO Profesor (nombre, apellido, id_asignatura, fecha_inicio) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, profesor.getNombre());
            pstmt.setString(2, profesor.getApellido());
            pstmt.setInt(3, idAsignatura);
            pstmt.setDate(4, Date.valueOf(profesor.getFechaInicio()));
            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }else {
                    throw new SQLException("Error al obtener ID del profesor.");
                }
            }
        }
    }

    public static void matricularEstudiante(Connection conn, Estudiante estudiante) {
        String sql = "SELECT * FROM matricular_estudiante(?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, estudiante.getNombre());
            pstmt.setString(2, estudiante.getApellido());
            pstmt.setDate(3, Date.valueOf(estudiante.getFechaNacimiento()));
            pstmt.setInt(4, estudiante.getCurso());
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                System.out.println("Estudiante Matriculado: " + rs.getString("nombre") + " " + rs.getString("apellido"));
            }
        } catch (SQLException e) {
            System.err.println("Error al invocar la función: " + e.getMessage());
        }
    }

    public static void crearEstudiante(Connection conn, Estudiante estudiante) {
        String sql = "CALL crear_estudiante(?, ?, ?, ?)";
        try (CallableStatement cstmt = conn.prepareCall(sql)) {
            cstmt.setString(1, estudiante.getNombre());
            cstmt.setString(2, estudiante.getApellido());
            cstmt.setDate(3, Date.valueOf(estudiante.getFechaNacimiento()));
            cstmt.setInt(4, estudiante.getCurso());
            cstmt.execute();
            System.out.println("Estudiante creado con éxito: " + estudiante.getNombre() + " " + estudiante.getApellido());
        } catch (SQLException e) {
            System.err.println("Error al invocar el procedimiento: " + e.getMessage());
        }
    }
}
