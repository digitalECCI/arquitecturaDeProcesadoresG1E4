
module ALU (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [2:0] opcode,

    output reg  [15:0] resultado,
    output reg         zero,
    output reg         carry_out,
    output reg         overflow,
    output reg         negative
);

    reg [8:0] suma_ext;
    reg signed [8:0] resta_ext;

    always @(*) begin

        resultado = 16'b0;
        carry_out = 1'b0;
        overflow  = 1'b0;
        negative  = 1'b0;

        suma_ext  = 9'b0;
        resta_ext = 9'b0;

        case (opcode)

            // ADD: A + B
            3'b000: begin

                suma_ext = {1'b0, A} + {1'b0, B};

                resultado = {7'b0, suma_ext};

                carry_out = suma_ext[8];

                overflow = (~(A[7] ^ B[7])) &
                           (resultado[7] ^ A[7]);

            end

            // SUB: A - B
            3'b001: begin

                resta_ext = $signed({1'b0, A}) -
                            $signed({1'b0, B});

                resultado = {{7{resta_ext[8]}}, resta_ext};

                carry_out = (A >= B);

                overflow = 1'b0;

            end

            // AND: A & B
            3'b010: begin

                resultado = {8'b0, (A & B)};

            end

            // OR: A | B
            3'b011: begin

                resultado = {8'b0, (A | B)};

            end

            // XOR: A ^ B
            3'b100: begin

                resultado = {8'b0, (A ^ B)};

            end

            // CMP: Comparacion de A y B
            3'b101: begin

                if (A < B)
                    resultado = 16'd1;

                else if (A > B)
                    resultado = 16'd2;

                else
                    resultado = 16'd4;

            end

            default: begin

                resultado = 16'b0;

            end

        endcase

        zero = (resultado == 16'b0);
        negative = resultado[15];

    end

endmodule
