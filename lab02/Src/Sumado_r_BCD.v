module Sumado_r_BCD(
    input  [3:0] A,
    input  [3:0] B,
    input        Ci,
    output [6:0] HEX0, // Unidades
    output [6:0] HEX1, // Decenas
    output  HEX2  // Signo (-)
);

    wire [3:0] magnitud_S;
    wire       acarreo_Co;

    sumador_r mi_sumador (
        .A(A),
        .B(B),
        .Ci(Ci),
        .S(magnitud_S),
        .Co(acarreo_Co)
    );

    wire es_negativo;
    wire quinto_bit;
    wire [4:0] cable_5bits;

    assign es_negativo = Ci & (~acarreo_Co);
    assign quinto_bit = (~Ci) & acarreo_Co;
	 
    assign cable_5bits = {quinto_bit, magnitud_S};


    wire [3:0] bcd_dec;
    wire [3:0] bcd_uni;

    dobble_dabble algoritmo_bcd (
        .bin(cable_5bits),
        .decenas(bcd_dec),
        .unidades(bcd_uni)
    );

    bcd_7seg display_unidades (
        .bcd(bcd_uni),
        .seg(HEX0)
    );

    bcd_7seg display_decenas (
        .bcd(bcd_dec),
        .seg(HEX1)
    );

    assign HEX2 = es_negativo ? 0 : 1;

endmodule