
module uart (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] data_in,

    output reg tx,
    output reg busy,
    output reg done
);

    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    reg [31:0] baud_count;
    reg [3:0] bit_index;
    reg [9:0] tx_frame;

    always @(posedge clk or posedge rst) begin

        if (rst) begin

            tx <= 1'b1;
            busy <= 1'b0;
            done <= 1'b0;

            baud_count <= 0;
            bit_index <= 0;

            tx_frame <= 10'b1111111111;

        end

        else begin

            done <= 1'b0;

            if (!busy) begin

                tx <= 1'b1;
                baud_count <= 0;
                bit_index <= 0;

                if (start) begin

                    tx_frame <= {1'b1, data_in, 1'b0};

                    tx <= 1'b0;
                    busy <= 1'b1;

                end

            end

            else begin

                if (baud_count == BAUD_DIV - 1) begin

                    baud_count <= 0;

                    if (bit_index < 9) begin

                        bit_index <= bit_index + 1'b1;

                        tx <= tx_frame[bit_index + 1'b1];

                    end

                    else begin

                        tx <= 1'b1;
                        busy <= 1'b0;
                        done <= 1'b1;

                        bit_index <= 0;

                    end

                end

                else begin

                    baud_count <= baud_count + 1'b1;

                end

            end

        end

    end

endmodule
