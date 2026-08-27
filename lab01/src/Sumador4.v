`timescale 1s/1s 

module sumador4(
    input  [3:0]A,
    input  [3:0]B,
    input  Ci,
    output [3:0]S,
    output Co

);
wire c1,c2,c3;
Sumador uno(
     .A(A[0]),
    .B(B[0]),
    .Ci(Ci),
    .S(S[0]),
    .Co(c1)
);

Sumador dos(
     .A(A[1]),
    .B(B[1]),
    .Ci(c1),
    .S(S[1]),
    .Co(c2)
);
Sumador tres(
     .A(A[2]),
    .B(B[2]),
    .Ci(c2),
    .S(S[2]),
    .Co(c3)
);
Sumador cuatro(
     .A(A[3]),
    .B(B[3]),
    .Ci(c3),
    .S(S[3]),
    .Co(Co)
);


endmodule