module multi_sec(
    input clk,
    input INIT,          
    input [2:0] MD,      // Multiplicando (A)
    input [2:0] MR,      // Multiplicador (B)
    output reg [5:0] PP, // Producto Parcial 
    output reg DONE
);

    localparam START = 3'd0;
    localparam CHECK = 3'd1;
    localparam ADD   = 3'd2;
    localparam SHIFT = 3'd3;
    localparam END   = 3'd4;

    reg [2:0] estado_actual = START, estado_siguiente;
    reg ctrl_RESET, ctrl_ADD, ctrl_SH;
    reg [5:0] A; 
    reg [2:0] B; 
    
    wire LSB_B = B[0];             
    wire Z = (B == 3'b000);        

    // 1. Registro de Estado
    always @(posedge clk) begin
        estado_actual <= estado_siguiente;
    end

    // 2. Lógica de Próximo Estado
    always @(*) begin
        estado_siguiente = estado_actual; 
        case (estado_actual)
            START: if (INIT) estado_siguiente = CHECK;
            CHECK: if (LSB_B) estado_siguiente = ADD;
                   else       estado_siguiente = SHIFT;
            ADD:   estado_siguiente = SHIFT;
            SHIFT: if (Z) estado_siguiente = END;
                   else   estado_siguiente = CHECK;
            END:   estado_siguiente = START;
            default: estado_siguiente = START;
        endcase
    end

    // 3. Salidas de Control
    always @(*) begin
        ctrl_RESET = 0; ctrl_ADD = 0; ctrl_SH = 0; DONE = 0;
        case (estado_actual)
            START: ctrl_RESET = 1;
            ADD:   ctrl_ADD = 1;
            SHIFT: ctrl_SH = 1;
            END:   DONE = 1;
        endcase
    end

    // 4. Ruta de Datos
    always @(posedge clk) begin
        if (ctrl_RESET) begin
            A  <= {3'b000, MD}; // Rellenar con ceros
            B  <= MR;
            PP <= 6'b000000;
        end
        else begin
            if (ctrl_ADD) PP <= PP + A;
            if (ctrl_SH) begin
                A <= A << 1;
                B <= B >> 1;
            end
        end
    end
endmodule