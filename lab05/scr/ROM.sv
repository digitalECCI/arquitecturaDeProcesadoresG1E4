
module ROM (
    input wire [2:0] address,
    output reg [15:0] instruction
);

always @(*) begin
    case (address)

        3'd0: instruction = 16'b1000_001_000001010; // LI R1, 10
        3'd1: instruction = 16'b1000_010_000001010; // LI R2, 10
        3'd2: instruction = 16'b0101_011_001_010_000; // CMP R3, R1, R2
        3'd3: instruction = 16'b1111_000_000000000; // HALT

        default: instruction = 16'b0000_000_000000000;

    endcase
end

endmodule
