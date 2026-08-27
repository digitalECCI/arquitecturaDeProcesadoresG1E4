module Sumador(
    input A,
    input B,
    input Ci,
    output S,
    output Co
);

assign S = Ci^(A^B);
assign Co = Ci&(A^B)|A&B;


endmodule 
