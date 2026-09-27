module dobble_dabble(
    input  [5:0] bin,
    output [3:0] decenas,
    output [3:0] unidades
);
    wire [3:0] c1, c2, c3; 

    assign c1 = ({1'b0, bin[5:3]} >= 4'b0101) ? ({1'b0, bin[5:3]} + 4'b0011) : {1'b0, bin[5:3]};
    
    assign c2 = ({c1[2:0], bin[2]} >= 4'b0101) ? ({c1[2:0], bin[2]} + 4'b0011) : {c1[2:0], bin[2]};
    
    assign c3 = ({c2[2:0], bin[1]} >= 4'b0101) ? ({c2[2:0], bin[1]} + 4'b0011) : {c2[2:0], bin[1]};

    assign unidades = {c3[2:0], bin[0]};
    assign decenas  = {1'b0, c1[3], c2[3], c3[3]}; 
endmodule