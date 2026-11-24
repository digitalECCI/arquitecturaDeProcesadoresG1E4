module Sumador(
    input A,
    input B,
    input Ci,
    output S,
    output Co
);

assign S = A ^ B ^ Ci;
assign Co = (A & B) | (Ci & (A ^ B));

endmodule