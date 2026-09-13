module sumador_r(
    input  [3:0] A,
    input  [3:0] B,
    input        Ci,
    output [3:0] S,
    output       Co
);

   
    
    // Cables de la Etapa 1
    wire [3:0] cable_B_xor;         
    wire [3:0] cable_S_intermedio;  
    wire c1, c2, c3;                
    wire cable_Co_intermedio;       
    
   
    wire cable_es_negativo;         
    
    wire [3:0] cable_S_invertido;   
    wire k1, k2, k3, k4;            
    assign cable_B_xor[0] = Ci ^ B[0];
    assign cable_B_xor[1] = Ci ^ B[1];
    assign cable_B_xor[2] = Ci ^ B[2];
    assign cable_B_xor[3] = Ci ^ B[3];

    Sumador uno   (.A(A[0]), .B(cable_B_xor[0]), .Ci(Ci), .S(cable_S_intermedio[0]), .Co(c1));
    Sumador dos   (.A(A[1]), .B(cable_B_xor[1]), .Ci(c1), .S(cable_S_intermedio[1]), .Co(c2));
    Sumador tres  (.A(A[2]), .B(cable_B_xor[2]), .Ci(c2), .S(cable_S_intermedio[2]), .Co(c3));
    Sumador cuatro(.A(A[3]), .B(cable_B_xor[3]), .Ci(c3), .S(cable_S_intermedio[3]), .Co(cable_Co_intermedio));

    
    assign Co = cable_Co_intermedio;

    assign cable_es_negativo = Ci & (~cable_Co_intermedio);


   
    assign cable_S_invertido[0] = cable_S_intermedio[0] ^ cable_es_negativo;
    assign cable_S_invertido[1] = cable_S_intermedio[1] ^ cable_es_negativo;
    assign cable_S_invertido[2] = cable_S_intermedio[2] ^ cable_es_negativo;
    assign cable_S_invertido[3] = cable_S_intermedio[3] ^ cable_es_negativo;

  
    Sumador cinco (.A(cable_S_invertido[0]), .B(1'b0), .Ci(cable_es_negativo), .S(S[0]), .Co(k1));
    Sumador seis  (.A(cable_S_invertido[1]), .B(1'b0), .Ci(k1),                .S(S[1]), .Co(k2));
    Sumador siete (.A(cable_S_invertido[2]), .B(1'b0), .Ci(k2),                .S(S[2]), .Co(k3));
    Sumador ocho  (.A(cable_S_invertido[3]), .B(1'b0), .Ci(k3),                .S(S[3]), .Co(k4));

endmodule