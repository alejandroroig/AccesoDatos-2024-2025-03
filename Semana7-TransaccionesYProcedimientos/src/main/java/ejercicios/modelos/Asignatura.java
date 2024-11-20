package ejercicios.modelos;

import lombok.Data;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@Data
@RequiredArgsConstructor
public class Asignatura {
    private int id;
    @NonNull private String nombre;
    @NonNull private String aula;
    @NonNull private Boolean obligatoria;
}
