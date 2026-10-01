module decoder (
    input logic [2:0] contador,
    output logic [7:0] display_en
    );

    always_comb begin
        case (contador)
            3'b000: display_en = 8'b11111110; // 0
            3'b001: display_en = 8'b11111101; // 1
            3'b010: display_en = 8'b11111011; // 2
            3'b011: display_en = 8'b11110111; // 3
            3'b100: display_en = 8'b11101111; // 4
            3'b101: display_en = 8'b11011111; // 5
            3'b110: display_en = 8'b10111111; // 6
            3'b111: display_en = 8'b01111111; // 7
            default: display_en = 8'b11111111;
        endcase
    end

endmodule
