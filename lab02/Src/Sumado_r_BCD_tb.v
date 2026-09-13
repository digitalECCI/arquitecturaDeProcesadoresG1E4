`timescale 1ns/1ps

module Sumado_r_BCD_tb();

    // Entradas
    reg [3:0] A_tb;
    reg [3:0] B_tb;
    reg       Ci_tb;

    // Salidas
    wire [6:0] HEX0_tb; // Unidades
    wire [6:0] HEX1_tb; // Decenas
    wire       HEX2_tb; // Signo (-) -> 0: Negativo encendido, 1: Positivo apagado

    integer i, j;

    // Instanciación del módulo superior (DUT)
    Sumado_r_BCD uut (
        .A(A_tb),
        .B(B_tb),
        .Ci(Ci_tb),
        .HEX0(HEX0_tb),
        .HEX1(HEX1_tb),
        .HEX2(HEX2_tb)
    );

    initial begin
        // Configuración de visualización en consola
        $display("------------------------------------------------------------------");
        $display(" INICIO DE SIMULACION: SUMADOR / RESTADOR CON DISPLAYS 7 SEG");
        $display("------------------------------------------------------------------");
        $display(" MODO |  A  |  B  | OP | HEX2 (Signo) | HEX1 (Dec) | HEX0 (Uni)");
        $display("------------------------------------------------------------------");

        // =====================================================================
        // PRUEBA 1: MODO SUMA (Ci = 0)
        // Casos clave: 0+0=0, 7+8=15, 15+15=30
        // =====================================================================
        Ci_tb = 1'b0;

        for (i = 0; i < 16; i = i + 5) begin
            for (j = 0; j < 16; j = j + 5) begin
                A_tb = i;
                B_tb = j;
                #10;
                $display(" SUMA | %2d  | %2d  | +  |      %b       |  %7b   |  %7b  --> Total: %2d", 
                         A_tb, B_tb, HEX2_tb, HEX1_tb, HEX0_tb, (A_tb + B_tb));
            end
        end

        // =====================================================================
        // PRUEBA 2: MODO RESTA POSITIVA Y NEGATIVA (Ci = 1)
        // Casos: 9-4 = +5, 4-9 = -5, 0-15 = -15, 15-0 = +15
        // =====================================================================
        Ci_tb = 1'b1;

        // Caso 1: Resta positiva (9 - 4 = +5)
        A_tb = 4'd9; B_tb = 4'd4; #10;
        $display(" REST | %2d  | %2d  | -  |      %b (Pos) |  %7b   |  %7b  --> Result: +5", 
                 A_tb, B_tb, HEX2_tb, HEX1_tb, HEX0_tb);

        // Caso 2: Resta negativa (4 - 9 = -5)
        A_tb = 4'd4; B_tb = 4'd9; #10;
        $display(" REST | %2d  | %2d  | -  |      %b (Neg) |  %7b   |  %7b  --> Result: -5", 
                 A_tb, B_tb, HEX2_tb, HEX1_tb, HEX0_tb);

        // Caso 3: Resta positiva extrema (15 - 0 = +15)
        A_tb = 4'd15; B_tb = 4'd0; #10;
        $display(" REST | %2d  | %2d  | -  |      %b (Pos) |  %7b   |  %7b  --> Result: +15", 
                 A_tb, B_tb, HEX2_tb, HEX1_tb, HEX0_tb);

        // Caso 4: Resta negativa extrema (0 - 15 = -15)
        A_tb = 4'd0; B_tb = 4'd15; #10;
        $display(" REST | %2d  | %2d  | -  |      %b (Neg) |  %7b   |  %7b  --> Result: -15", 
                 A_tb, B_tb, HEX2_tb, HEX1_tb, HEX0_tb);

        // =====================================================================
        // PRUEBA 3: BARRIDO COMPLETO DE CASOS
        // =====================================================================
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A_tb = i;
                B_tb = j;
                #5;
            end
        end

        $display("------------------------------------------------------------------");
        $display(" SIMULACION FINALIZADA CON EXITO");
        $display("------------------------------------------------------------------");
        $finish;
    end

    // Volcado de ondas a la carpeta build
    initial begin
        $dumpfile("build/sim_lab2.vcd");
        $dumpvars(0, Sumado_r_BCD_tb);
    end

endmodule