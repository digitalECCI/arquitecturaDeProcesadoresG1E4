`timescale 1ns/1ps

module sumador4_tb();

    reg [3:0] A_tb;
    reg [3:0] B_tb;
    reg       Ci_tb;
    wire [3:0] S_tb;
    wire       Co_tb;

    integer i, j;

    // Instancia del sumador de 4 bits
    sumador4 lito4 (
        .A(A_tb),
        .B(B_tb),
        .Ci(Ci_tb),
        .S(S_tb),
        .Co(Co_tb)
    );

    // Generación de estímulos (Todas las 256 combinaciones posibles)
    initial begin
        Ci_tb = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A_tb = i;
                B_tb = j;
                #5;
            end
        end
        $finish; // Detiene la simulación automáticamente al terminar el bucle
    end

    // Volcado de ondas para GTKWave
    initial begin: TEST_CASE
        $dumpfile("build/sim_4bit.vcd");
        $dumpvars(0, sumador4_tb); 
    end

endmodule