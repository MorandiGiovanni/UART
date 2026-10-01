module desmontador_ascii(
    input logic [7:0] dado_ascii_montado,
    input logic clock9600,
    input logic reset,

    output logic tx_data
);

    // Estados do transmissor
    typedef enum logic {IDLE, SENDING} estado_t;
    estado_t estado_atual;

    logic [7:0] shift_reg;   // Registrador de deslocamento
    logic [2:0] bit_cnt;     // Contador de bits (0 a 7)
    logic [7:0] dado_antigo; // Armazena o último dado enviado para detectar mudanças

    // Atribuição contínua: envia o bit menos significativo (LSB) primeiro (padrão em transmissões seriais)
    // Se precisar do MSB primeiro, altere para: shift_reg[7]
    assign tx_data = (estado_atual == SENDING) ? shift_reg[0] : 1'b1; // Linha em nível alto (1) quando ociosa

    always_ff @(posedge clock9600 or posedge reset) begin
        if (reset) begin
            estado_atual <= IDLE;
            shift_reg    <= 8'b0;
            bit_cnt      <= 3'b0;
            dado_antigo  <= 8'b0;
        end else begin
            case (estado_atual)
                
                IDLE: begin
                    // Detecta se um novo dado ASCII chegou para ser enviado
                    if (dado_ascii_montado != dado_antigo) begin
                        shift_reg    <= dado_ascii_montado; // Carrega o dado
                        dado_antigo  <= dado_ascii_montado; // Atualiza a referência
                        bit_cnt      <= 3'b0;               // Zerar contador
                        estado_atual <= SENDING;            // Inicia transmissão
                    end
                end

                SENDING: begin
                    if (bit_cnt == 3'd7) begin
                        estado_atual <= IDLE; // Terminou de enviar os 8 bits
                    end else begin
                        shift_reg    <= {1'b0, shift_reg[7:1]}; // Desloca para a direita (envio LSB primeiro)
                        bit_cnt      <= bit_cnt + 1'b1;         // Incrementa o contador
                    end
                end

            endcase
        end
    end

endmodule
