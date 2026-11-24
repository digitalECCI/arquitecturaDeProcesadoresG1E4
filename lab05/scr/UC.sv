
module UC (
    input wire clk,
    input wire rst,

    // Codigo de operacion
    input wire [3:0] opcode,

    // Senales de finalizacion
    input wire mul_done,
    input wire div_done,
    input wire uart_done,

    // Senales de control
    output reg pc_enable,
    output reg ir_load,
    output reg read_en,
    output reg reg_write_en,
    output reg flags_write_en,

    // Inicio de operaciones secuenciales
    output reg mul_start,
    output reg div_start,
    output reg uart_start,

    // Indicador de parada
    output reg halted
);

    // Estados de la maquina de control
    localparam FETCH     = 4'b0000;
    localparam DECODE    = 4'b0001;
    localparam EXECUTE   = 4'b0010;
    localparam WAIT_MUL  = 4'b0011;
    localparam WAIT_DIV  = 4'b0100;
    localparam WAIT_UART = 4'b0101;
    localparam WRITEBACK = 4'b0110;
    localparam HALT      = 4'b0111;

    reg [3:0] state;
    reg [3:0] next_state;

    // Registro de estado
    always @(posedge clk or posedge rst) begin

        if (rst)
            state <= FETCH;

        else
            state <= next_state;

    end

    // Logica de siguiente estado
    always @(*) begin

        next_state = state;

        case (state)

            FETCH:
                next_state = DECODE;

            DECODE:
                next_state = EXECUTE;

            EXECUTE: begin

                case (opcode)

                    4'b0000,
                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b0101,
                    4'b1000,
                    4'b1001:
                        next_state = WRITEBACK;

                    4'b0110:
                        next_state = WAIT_MUL;

                    4'b0111:
                        next_state = WAIT_DIV;

                    4'b1010:
                        next_state = WAIT_UART;

                    4'b1111:
                        next_state = HALT;

                    default:
                        next_state = HALT;

                endcase

            end

            WAIT_MUL:
                if (mul_done)
                    next_state = WRITEBACK;

            WAIT_DIV:
                if (div_done)
                    next_state = WRITEBACK;

            WAIT_UART:
                if (uart_done)
                    next_state = FETCH;

            WRITEBACK:
                next_state = FETCH;

            HALT:
                next_state = HALT;

            default:
                next_state = FETCH;

        endcase

    end

    // Logica de salidas
    always @(*) begin

        // Valores por defecto
        pc_enable = 1'b0;
        ir_load = 1'b0;
        read_en = 1'b0;
        reg_write_en = 1'b0;
        flags_write_en = 1'b0;

        mul_start = 1'b0;
        div_start = 1'b0;
        uart_start = 1'b0;

        halted = 1'b0;

        case (state)

            FETCH: begin
                pc_enable = 1'b1;
                ir_load = 1'b1;
            end

            DECODE: begin
                read_en = 1'b1;
            end

            EXECUTE: begin

                case (opcode)

                    4'b0110:
                        mul_start = 1'b1;

                    4'b0111:
                        div_start = 1'b1;

                    4'b1010:
                        uart_start = 1'b1;

                endcase

            end

            WRITEBACK: begin

                case (opcode)

                    4'b0000,
                    4'b0001,
                    4'b0010,
                    4'b0011,
                    4'b0100,
                    4'b1000,
                    4'b1001,
                    4'b0110,
                    4'b0111:
                        reg_write_en = 1'b1;

                    4'b0101:
                        flags_write_en = 1'b1;

                endcase

            end

            HALT: begin
                halted = 1'b1;
            end

        endcase

    end

endmodule
