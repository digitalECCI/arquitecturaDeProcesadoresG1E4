
module top (
    input wire clk,
    input wire rst,
    output wire uart_tx,
    output wire halted
);

    // ==========================================
    // 1. CABLES DEL PC Y LA ROM
    // ==========================================

    wire [2:0] pc_address;
    wire pc_enable;

    wire [15:0] instruction_rom;
    reg [15:0] instruction_reg;

    wire ir_load;

    PC u_pc (
        .clk(clk),
        .rst(rst),
        .enable(pc_enable),
        .address(pc_address)
    );

    ROM u_rom (
        .address(pc_address),
        .instruction(instruction_rom)
    );

    always @(posedge clk or posedge rst) begin
        if (rst)
            instruction_reg <= 16'b0;
        else if (ir_load)
            instruction_reg <= instruction_rom;
    end

    // ==========================================
    // 2. CAMPOS DE LA INSTRUCCION
    // ==========================================

    wire [3:0] opcode;
    wire [2:0] rd;
    wire [2:0] rs;
    wire [2:0] rt;
    wire [8:0] immediate;

    assign opcode = instruction_reg[15:12];
    assign rd = instruction_reg[11:9];
    assign rs = instruction_reg[8:6];
    assign rt = instruction_reg[5:3];
    assign immediate = instruction_reg[8:0];

    // ==========================================
    // 3. BANCO DE REGISTROS
    // ==========================================

    wire [7:0] data_a;
    wire [7:0] data_b;
    wire [7:0] write_data;

    wire read_en;
    wire reg_write_en;

    bancoRegistro u_banco (
        .clk(clk),
        .rst(rst),
        .data_in(write_data),
        .write_addr(rd),
        .read_addr_a(rs),
        .read_addr_b(rt),
        .write_en(reg_write_en),
        .read_en(read_en),
        .data_out_a(data_a),
        .data_out_b(data_b)
    );

    // ==========================================
    // 4. ALU
    // ==========================================

    wire [15:0] alu_result;
    wire alu_zero;
    wire alu_carry;
    wire alu_overflow;
    wire alu_negative;

    ALU u_alu (
        .A(data_a),
        .B(data_b),
        .opcode(opcode[2:0]),
        .resultado(alu_result),
        .zero(alu_zero),
        .carry_out(alu_carry),
        .overflow(alu_overflow),
        .negative(alu_negative)
    );

    // Banderas almacenadas
    reg zero_flag;
    reg carry_flag;
    reg overflow_flag;
    reg negative_flag;

    wire flags_write_en;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            zero_flag <= 0;
            carry_flag <= 0;
            overflow_flag <= 0;
            negative_flag <= 0;
        end
        else if (flags_write_en) begin
            zero_flag <= alu_zero;
            carry_flag <= alu_carry;
            overflow_flag <= alu_overflow;
            negative_flag <= alu_negative;
        end
    end

    // ==========================================
    // 5. MULTIPLICADOR
    // ==========================================

    wire mul_start;
    wire mul_done;
    wire [15:0] mul_result;

    multiplicador u_multiplicador (
        .clk(clk),
        .rst(rst),
        .start(mul_start),
        .A(data_a),
        .B(data_b),
        .resultado(mul_result),
        .done(mul_done)
    );

    // ==========================================
    // 6. DIVISOR
    // ==========================================

    wire div_start;
    wire div_done;
    wire div_error;

    wire [7:0] div_quotient;
    wire [7:0] div_remainder;

    divisor u_divisor (
        .clk(clk),
        .rst(rst),
        .start(div_start),
        .A(data_a),
        .B(data_b),
        .cociente(div_quotient),
        .residuo(div_remainder),
        .done(div_done),
        .error(div_error)
    );

    // ==========================================
    // 7. UART
    // ==========================================

    wire uart_start;
    wire uart_busy;
    wire uart_done;

    uart u_uart (
        .clk(clk),
        .rst(rst),
        .start(uart_start),
        .data_in(data_a),
        .tx(uart_tx),
        .busy(uart_busy),
        .done(uart_done)
    );

    // ==========================================
    // 8. MULTIPLEXOR DE ESCRITURA
    // ==========================================

    reg [7:0] write_data_mux;

    always @(*) begin

        write_data_mux = 8'b0;

        case (opcode)

            4'b0000,
            4'b0001,
            4'b0010,
            4'b0011,
            4'b0100:
                write_data_mux = alu_result[7:0];

            4'b0110:
                write_data_mux = mul_result[7:0];

            4'b0111:
                write_data_mux = div_quotient;

            4'b1000:
                write_data_mux = immediate[7:0];

            4'b1001:
                write_data_mux = data_a;

            default:
                write_data_mux = 8'b0;

        endcase

    end

    assign write_data = write_data_mux;

    // ==========================================
    // 9. UNIDAD DE CONTROL
    // ==========================================

    UC u_uc (
        .clk(clk),
        .rst(rst),
        .opcode(opcode),

        .mul_done(mul_done),
        .div_done(div_done),
        .uart_done(uart_done),

        .pc_enable(pc_enable),
        .ir_load(ir_load),
        .read_en(read_en),
        .reg_write_en(reg_write_en),
        .flags_write_en(flags_write_en),

        .mul_start(mul_start),
        .div_start(div_start),
        .uart_start(uart_start),

        .halted(halted)
    );

endmodule
