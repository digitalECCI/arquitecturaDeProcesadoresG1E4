
module PC (
    input wire clk,
    input wire rst,
    input wire enable,
    output reg [2:0] address
);

always @(posedge clk or posedge rst) begin

    if (rst)
        address <= 3'b000;

    else if (enable)
        address <= address + 1'b1;

end

endmodule
