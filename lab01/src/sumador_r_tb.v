`timescale 1ns/1ps

module sumador_r_tb();

    // =========================================================
    // ENTRADAS (Simulan los interruptores físicos)
    // =========================================================
    reg [3:0] A_tb;
    reg [3:0] B_tb;
    reg       Ci_tb;

    // =========================================================
    // SALIDAS (Simulan los LEDs físicos)
    // =========================================================
    wire [3:0] S_tb;
    wire       Co_tb;

    integer i, j;

    // =========================================================
    // INSTANCIA DEL MÓDULO (Conectar los cables virtuales)
    // =========================================================
    sumador_r lito_r (
        .A(A_tb),
        .B(B_tb),
        .Ci(Ci_tb),
        .S(S_tb),
        .Co(Co_tb)
    );

    // =========================================================
    // GENERACIÓN DE ESTÍMULOS
    // =========================================================
    initial begin
        // Estado inicial (todo apagado)
        A_tb = 4'b0000;
        B_tb = 4'b0000;
        Ci_tb = 1'b0;

        // --- PRUEBA 1: 256 casos de SUMA (Selector Ci = 0) ---
        Ci_tb = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A_tb = i;
                B_tb = j;
                #5; // Espera 5 nanosegundos para estabilizar compuertas
            end
        end

        // --- PRUEBA 2: 256 casos de RESTA (Selector Ci = 1) ---
        Ci_tb = 1'b1;
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                A_tb = i;
                B_tb = j;
                #5; // Espera 5 nanosegundos
            end
        end

        $display("Simulacion finalizada correctamente.");
        $finish;
    end

    // =========================================================
    // ARCHIVO PARA GTKWAVE
    // =========================================================
    initial begin
        $dumpfile("build/simulacion_r_tb.vcd");
        $dumpvars(0, sumador_r_tb);
    end

endmodule