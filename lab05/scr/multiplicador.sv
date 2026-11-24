
module multiplicador (
    input wire clk,
    input wire rst,
    input wire start,

    input wire [7:0] A,
    input wire [7:0] B,

    output reg [15:0] resultado,
    output reg done
);

    // Registros internos
    reg [15:0] multiplicando;
    reg [7:0] multiplicador_reg;
    reg [15:0] acumulador;
    reg [3:0] contador;

    // Estados de la maquina
    reg [2:0] estado;

    localparam INICIO  = 3'b000;
    localparam REVISAR = 3'b001;
    localparam SUMAR   = 3'b010;
    localparam SHIFT   = 3'b011;
    localparam FINAL   = 3'b100;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            estado <= INICIO;
            multiplicando <= 0;
            multiplicador_reg <= 0;
            acumulador <= 0;
            contador <= 0;
            resultado <= 0;
            done <= 0;

        end
        else begin

            done <= 0;

            case (estado)

                INICIO: begin

                    if (start) begin

                        multiplicando <= {8'b0, A};
                        multiplicador_reg <= B;
                        acumulador <= 0;
                        contador <= 0;

                        estado <= REVISAR;

                    end

                end

                REVISAR: begin

                    if (contador == 8)
                        estado <= FINAL;

                    else if (multiplicador_reg[0] == 1'b1)
                        estado <= SUMAR;

                    else
                        estado <= SHIFT;

                end

                SUMAR: begin

                    acumulador <= acumulador + multiplicando;

                    estado <= SHIFT;

                end

                SHIFT: begin

                    multiplicando <= multiplicando << 1;
                    multiplicador_reg <= multiplicador_reg >> 1;
                    contador <= contador + 1'b1;

                    estado <= REVISAR;

                end

                FINAL: begin

                    resultado <= acumulador;
                    done <= 1'b1;

                    estado <= INICIO;

                end

                default: begin

                    estado <= INICIO;

                end

            endcase

        end

    end

endmodule
