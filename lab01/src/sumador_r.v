module sumador_r(
    input  [3:0] A,
    input  [3:0] B,
    input        Ci,
    output [3:0] S,
    output       Co
);

    // =========================================================================
    // CABLES INTERNOS (Como puentes en una protoboard)
    // =========================================================================
    
    // Cables de la Etapa 1
    wire [3:0] cable_B_xor;         // Conecta las compuertas XOR con los primeros sumadores
    wire [3:0] cable_S_intermedio;  // Salida de los primeros sumadores (AÚN NO VA A LOS LEDS)
    wire c1, c2, c3;                // Acarreos entre los primeros sumadores
    wire cable_Co_intermedio;       // El acarreo final de la primera suma
    
    // Cable detector
    wire cable_es_negativo;         // Se enciende (1) solo si estamos restando y el resultado fue negativo
    
    // Cables de la Etapa 2
    wire [3:0] cable_S_invertido;   // Conecta las segundas XOR con los últimos sumadores
    wire k1, k2, k3, k4;            // Acarreos entre los últimos sumadores

    // =========================================================================
    // ETAPA 1: TU SUMADOR/RESTADOR ORIGINAL
    // =========================================================================
    
    assign cable_B_xor[0] = Ci ^ B[0];
    assign cable_B_xor[1] = Ci ^ B[1];
    assign cable_B_xor[2] = Ci ^ B[2];
    assign cable_B_xor[3] = Ci ^ B[3];

    Sumador uno   (.A(A[0]), .B(cable_B_xor[0]), .Ci(Ci), .S(cable_S_intermedio[0]), .Co(c1));
    Sumador dos   (.A(A[1]), .B(cable_B_xor[1]), .Ci(c1), .S(cable_S_intermedio[1]), .Co(c2));
    Sumador tres  (.A(A[2]), .B(cable_B_xor[2]), .Ci(c2), .S(cable_S_intermedio[2]), .Co(c3));
    Sumador cuatro(.A(A[3]), .B(cable_B_xor[3]), .Ci(c3), .S(cable_S_intermedio[3]), .Co(cable_Co_intermedio));

    // El LED de acarreo (Co) va directo al resultado del cuarto sumador. 
    // Como tú dijiste: si es resta y Co está apagado (0), sabes visualmente que es negativo.
    assign Co = cable_Co_intermedio;

    // Detectamos físicamente si es negativo: Selector en 1 (Resta) AND Acarreo apagado (0)
    assign cable_es_negativo = Ci & (~cable_Co_intermedio);

    // =========================================================================
    // ETAPA 2: CORRECCIÓN PARA LOS 4 LEDS DE SALIDA (S)
    // =========================================================================
    
    // Si el 'cable_es_negativo' lleva corriente (1), estas XOR invierten los 4 bits.
    // Si no lleva corriente (0), los dejan pasar igualitos.
    assign cable_S_invertido[0] = cable_S_intermedio[0] ^ cable_es_negativo;
    assign cable_S_invertido[1] = cable_S_intermedio[1] ^ cable_es_negativo;
    assign cable_S_invertido[2] = cable_S_intermedio[2] ^ cable_es_negativo;
    assign cable_S_invertido[3] = cable_S_intermedio[3] ^ cable_es_negativo;

    // Fila final de sumadores. Su única función es sumar un '1' si el número era negativo 
    // (para completar el complemento a 2). 
    // Las salidas de estos sumadores SÍ van conectadas directamente a los pines de tus 4 LEDs de salida (S).
    Sumador cinco (.A(cable_S_invertido[0]), .B(1'b0), .Ci(cable_es_negativo), .S(S[0]), .Co(k1));
    Sumador seis  (.A(cable_S_invertido[1]), .B(1'b0), .Ci(k1),                .S(S[1]), .Co(k2));
    Sumador siete (.A(cable_S_invertido[2]), .B(1'b0), .Ci(k2),                .S(S[2]), .Co(k3));
    Sumador ocho  (.A(cable_S_invertido[3]), .B(1'b0), .Ci(k3),                .S(S[3]), .Co(k4));

endmodule