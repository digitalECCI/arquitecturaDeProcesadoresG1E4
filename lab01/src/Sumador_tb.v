`timescale 1ns/1ps

module sumadortb();

    reg A_tb;
    reg B_tb;
    reg Ci_tb;
    wire S_tb;
    wire Co_tb;

    // Instancia del sumador de 1 bit
    Sumador uut (
        .A(A_tb),
        .B(B_tb),
        .Ci(Ci_tb),
        .S(S_tb),
        .Co(Co_tb)
    );

    // Generación de estímulos (Tabla de verdad de 8 combinaciones)
    initial begin
        A_tb = 1'b0; B_tb = 1'b0; Ci_tb = 1'b0; #5;
        A_tb = 1'b0; B_tb = 1'b0; Ci_tb = 1'b1; #5;
        A_tb = 1'b0; B_tb = 1'b1; Ci_tb = 1'b0; #5;
        A_tb = 1'b0; B_tb = 1'b1; Ci_tb = 1'b1; #5;
        A_tb = 1'b1; B_tb = 1'b0; Ci_tb = 1'b0; #5;
        A_tb = 1'b1; B_tb = 1'b0; Ci_tb = 1'b1; #5;
        A_tb = 1'b1; B_tb = 1'b1; Ci_tb = 1'b0; #5;
        A_tb = 1'b1; B_tb = 1'b1; Ci_tb = 1'b1; #5;
        
        $finish; // Cierra la simulación y finaliza la escritura del archivo .vcd
    end

    // Volcado de ondas para GTKWave
    initial begin: TEST_CASE
        $dumpfile("build/simulacion_tb.vcd");
        $dumpvars(0, sumadortb);
    end

endmodule