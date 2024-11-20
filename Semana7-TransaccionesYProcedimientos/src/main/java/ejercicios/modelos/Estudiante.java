package ejercicios.modelos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@RequiredArgsConstructor
@Data
public class Estudiante {
    private int id;
    @NonNull private String nombre;
    @NonNull private String apellido;
    @NonNull private int curso;
    @NonNull private LocalDate fechaNacimiento;
}
