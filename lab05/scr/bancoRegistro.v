
module bancoRegistro (
    input  wire       clk,
    input  wire       rst,

    // Entrada de datos
    input  wire [7:0] data_in,

    // Direccion de escritura
    input  wire [2:0] write_addr,

    // Dos direcciones de lectura
    input  wire [2:0] read_addr_a,
    input  wire [2:0] read_addr_b,

    // Habilitaciones
    input  wire       write_en,
    input  wire       read_en,

    // Dos salidas de lectura
    output reg  [7:0] data_out_a,
    output reg  [7:0] data_out_b
);

    // Ocho registros de 8 bits
    reg [7:0] registros [0:7];

    // Escritura y reset asincrono
    always @(posedge clk or posedge rst) begin

        if (rst) begin

            registros[0] <= 8'b0;
            registros[1] <= 8'b0;
            registros[2] <= 8'b0;
            registros[3] <= 8'b0;
            registros[4] <= 8'b0;
            registros[5] <= 8'b0;
            registros[6] <= 8'b0;
            registros[7] <= 8'b0;

            data_out_a <= 8'b0;
            data_out_b <= 8'b0;

        end
        else begin

            // Escritura: R0 no puede modificarse
            if (write_en && (write_addr != 3'b000)) begin
                registros[write_addr] <= data_in;
            end

            // Lectura simultanea de dos registros
            if (read_en) begin

                if (read_addr_a == 3'b000)
                    data_out_a <= 8'b0;
                else
                    data_out_a <= registros[read_addr_a];

                if (read_addr_b == 3'b000)
                    data_out_b <= 8'b0;
                else
                    data_out_b <= registros[read_addr_b];

            end

        end
    end

endmodule
