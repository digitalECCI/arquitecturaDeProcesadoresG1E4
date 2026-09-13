module dobble_dabble (
    input  [4:0] bin,
    output [3:0] decenas,
    output [3:0] unidades
);
    wire [3:0] c1, c2; // Cables de conexión entre las etapas del algoritmo

    assign c1 = ({1'b0, bin[4:2]} >= 3'b101) ? ({1'b0, bin[4:2]} + 2'b11) : {1'b0, bin[4:2]};

    assign c2 = ({c1[2:0], bin[1]} >= 3'b101) ? ({c1[2:0], bin[1]} + 2'b11) : {c1[2:0], bin[1]};

    // Salidas finales
    assign unidades = {c2[2:0], bin[0]};
    assign decenas  = {2'b00, c1[3], c2[3]}; 
endmodule