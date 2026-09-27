module multi_c (
    input clk,            
    input btn_init,       // Pulsador físico para INIT
    input [2:0] MD,       // Switches para Multiplicando
    input [2:0] MR,       // Switches para Multiplicador
    output [5:0] LED_PP,  // Salida binaria cruda (LEDs)
    output LED_DONE,      // LED indicador de fin
    output [6:0] HEX0,    // Display Unidades
    output [6:0] HEX1     // Display Decenas
);

    wire init_limpio;
    wire [5:0] pp_bin;
    wire [3:0] bcd_dec, bcd_uni;
    reg  [5:0] pp_guardado; 
	 
	 // Bloque para evitar el efecto fantasma
    always @(posedge clk) begin
        if (LED_DONE == 1'b1) begin
            pp_guardado <= pp_bin;
        end
    end

    // 1. Acondicionar la señal del botón
    antirrebote u_btn (
        .clk(clk),
        .btn_in(btn_init),
        .btn_out(init_limpio)
    );

    // 2. Multiplicador ASM
    multi_sec u_mult (
        .clk(clk),
        .INIT(init_limpio),
        .MD(MD),
        .MR(MR),
        .PP(pp_bin),
        .DONE(LED_DONE)
    );

    // 3. Envío opcional directo a LEDs para prueba rápida
    assign LED_PP = pp_bin;

    // 4. Conversión algorítmica Binario a Decimal (BCD)
    dobble_dabble u_bcd (
        .bin(pp_guardado),
        .decenas(bcd_dec),
        .unidades(bcd_uni)
    );

    // 5. Salida Visual (Displays)
    bcd_7seg u_hex0 (
        .bcd(bcd_uni),
        .seg(HEX0)
    );

    bcd_7seg u_hex1 (
        .bcd(bcd_dec),
        .seg(HEX1)
    );

endmodule