package ejercicios.modelos;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@RequiredArgsConstructor
@Data
public class Asignatura {
    private int id;
    @NonNull private String nombre;
    @NonNull private String aula;
    @NonNull private Boolean obligatoria;
}
