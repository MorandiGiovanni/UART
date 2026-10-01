module transformador_ps2_ascii(

    input  logic [7:0] Dado_montado_ps2,

    output logic [7:0] dado_ascii_montado 
);

    // Decodifica para ascii
    always_comb begin
        case (Dado_montado_ps2)
            //NÚMEROS
            8'h45: dado_ascii_montado = 8'h30; // '0'
            8'h16: dado_ascii_montado = 8'h31; // '1'
            8'h1E: dado_ascii_montado = 8'h32; // '2'
            8'h26: dado_ascii_montado = 8'h33; // '3'
            8'h25: dado_ascii_montado = 8'h34; // '4'
            8'h2E: dado_ascii_montado = 8'h35; // '5'
            8'h36: dado_ascii_montado = 8'h36; // '6'
            8'h3D: dado_ascii_montado = 8'h37; // '7'
            8'h3E: dado_ascii_montado = 8'h38; // '8'
            8'h46: dado_ascii_montado = 8'h39; // '9'

            //LETRAS
            8'h1C: dado_ascii_montado = 8'h41; // 'A'
            8'h32: dado_ascii_montado = 8'h42; // 'b'
            8'h21: dado_ascii_montado = 8'h43; // 'C'
            8'h23: dado_ascii_montado = 8'h44; // 'd'
            8'h24: dado_ascii_montado = 8'h45; // 'E'
            8'h2B: dado_ascii_montado = 8'h46; // 'F'
            8'h34: dado_ascii_montado = 8'h47; // 'G'
            8'h33: dado_ascii_montado = 8'h48; // 'h'
            8'h43: dado_ascii_montado = 8'h49; // 'I'
            8'h3B: dado_ascii_montado = 8'h4A; // 'J'
            8'h42: dado_ascii_montado = 8'h4B; // 'K'
            8'h4B: dado_ascii_montado = 8'h4C; // 'L'
            8'h3A: dado_ascii_montado = 8'h4D; // 'M'
            8'h31: dado_ascii_montado = 8'h4E; // 'n'
            8'h44: dado_ascii_montado = 8'h4F; // 'O'
            8'h4D: dado_ascii_montado = 8'h50; // 'P'
            8'h15: dado_ascii_montado = 8'h51; // 'Q'
            8'h2D: dado_ascii_montado = 8'h52; // 'r'
            8'h1B: dado_ascii_montado = 8'h53; // 'S'
            8'h2C: dado_ascii_montado = 8'h54; // 't'
            8'h3C: dado_ascii_montado = 8'h55; // 'U'
            8'h2A: dado_ascii_montado = 8'h56; // 'v'
            8'h1D: dado_ascii_montado = 8'h57; // 'W'
            8'h22: dado_ascii_montado = 8'h58; // 'X'
            8'h35: dado_ascii_montado = 8'h59; // 'Y'
            8'h1A: dado_ascii_montado = 8'h5A; // 'Z'

            default: dado_ascii_montado = 8'b11111111; // Apagado, reset
        endcase
    end

endmodule