module antirrebote (
    input clk,
    input btn_in,
    output reg btn_out
);
    reg [15:0] count = 0;
    
    // El operador de reducción AND (&) da '1' solo cuando todos los bits son '1'
    wire max_count = &count; 

    always @(posedge clk) begin
        // Operador ternario: Si entrada y salida son diferentes (XOR), cuenta. Si no, resetea a 0.
        count <= (btn_in ^ btn_out) ? (count + 1'b1) : 16'd0;
        
        // Solo actualiza la salida si la señal se mantuvo estable el tiempo suficiente
        if (max_count) btn_out <= btn_in;
    end
endmodule