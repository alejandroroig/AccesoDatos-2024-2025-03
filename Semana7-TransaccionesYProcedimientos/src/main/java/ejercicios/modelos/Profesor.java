package ejercicios.modelos;

import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;

@Data
@RequiredArgsConstructor
public class Profesor {
    private int id;
    @NonNull private String nombre;
    @NonNull private String apellido;
    @NonNull private LocalDate fechaInicio;
}
