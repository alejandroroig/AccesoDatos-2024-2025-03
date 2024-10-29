package ejemplos;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Usuario {
    private int id;
    private String nombre;
    private String password;
    private String email;
    private Cuenta cuenta;
}
