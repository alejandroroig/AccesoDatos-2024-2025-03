package ejemplos;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class Cuenta {
    private int id;
    private double saldo;
}
