
module divisor (
    input wire clk,
    input wire rst,
    input wire start,

    input wire [7:0] A,
    input wire [7:0] B,

    output reg [7:0] cociente,
    output reg [7:0] residuo,
    output reg done,
    output reg error
);

    // Registros internos
    reg [7:0] dividendo_reg;
    reg [7:0] divisor_reg;
    reg [7:0] cociente_reg;
    reg [8:0] residuo_reg;

    reg [3:0] contador;
    reg [1:0] estado;

    // Estados
    localparam INICIO = 2'b00;
    localparam CALCULO = 2'b01;
    localparam FINAL = 2'b10;

    // Desplazamiento del residuo
    wire [8:0] residuo_temp;

    assign residuo_temp = {
        residuo_reg[7:0],
        dividendo_reg[7]
    };

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            estado <= INICIO;

            dividendo_reg <= 0;
            divisor_reg <= 0;
            cociente_reg <= 0;
            residuo_reg <= 0;

            contador <= 0;

            cociente <= 0;
            residuo <= 0;

            done <= 0;
            error <= 0;

        end
        else begin

            done <= 0;

            case (estado)

                INICIO: begin

                    if (start) begin

                        error <= 0;
                        contador <= 0;

                        if (B == 0) begin

                            cociente <= 0;
                            residuo <= A;
                            error <= 1;
                            done <= 1;

                        end
                        else begin

                            dividendo_reg <= A;
                            divisor_reg <= B;
                            cociente_reg <= 0;
                            residuo_reg <= 0;

                            estado <= CALCULO;

                        end

                    end

                end

                CALCULO: begin

                    dividendo_reg <= dividendo_reg << 1;

                    if (residuo_temp >= {1'b0, divisor_reg}) begin

                        residuo_reg <= residuo_temp -
                                       {1'b0, divisor_reg};

                        cociente_reg <= {
                            cociente_reg[6:0], 1'b1
                        };

                    end
                    else begin

                        residuo_reg <= residuo_temp;

                        cociente_reg <= {
                            cociente_reg[6:0], 1'b0
                        };

                    end

                    contador <= contador + 1'b1;

                    if (contador == 7) begin

                        if (residuo_temp >= {1'b0, divisor_reg}) begin

                            residuo <= residuo_temp -
                                       {1'b0, divisor_reg};

                        end
                        else begin

                            residuo <= residuo_temp[7:0];

                        end

                        cociente <= {
                            cociente_reg[6:0],
                            (residuo_temp >= {1'b0, divisor_reg})
                        };

                        estado <= FINAL;

                    end

                end

                FINAL: begin

                    done <= 1;
                    estado <= INICIO;

                end

                default: begin

                    estado <= INICIO;

                end

            endcase

        end

    end

endmodule
