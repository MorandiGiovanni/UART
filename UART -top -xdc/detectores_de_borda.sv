module detector_borda (
    input  logic       rst,
    input  logic       fsmoutdetin,       // ps2_clk filtrado, vindo da FSM
    input  logic       ps2_data,           // dado bruto do PS2

    output logic       toggle_data_ready,  // toggle indicando novo dado válido
    output logic [7:0] novo_dado            // scancode recebido
);

    logic [7:0] byte_acc;       // acumula os bits recebidos
    logic [2:0] bit_cnt;        // conta de 0 a 7
    logic [7:0] byte_full;      // byte com o bit atual inserido
    logic       ignore_next;    // indica que o próximo byte deve ser ignorado

    // Insere o bit atual recebido no registrador.
    // Como estamos usando a borda de descida do clock PS/2,
    // cada bit recebido é deslocado para dentro do byte.
    assign byte_full = {ps2_data, byte_acc[7:1]};

    always_ff @(negedge fsmoutdetin or posedge rst) begin

        if (rst) begin

            byte_acc          <= 8'd0;
            bit_cnt           <= 3'd0;
            novo_dado         <= 8'd0;
            toggle_data_ready <= 1'b0;
            ignore_next       <= 1'b0;

        end else begin

            // Guarda o byte parcialmente recebido
            byte_acc <= byte_full;

            // -------------------------------------------------
            // Chegou o 8º bit do dado
            // -------------------------------------------------
            if (bit_cnt == 3'd7) begin

                // Byte completo
                novo_dado <= byte_full;

                // Reinicia contador para o próximo byte
                bit_cnt <= 3'd0;

                // -------------------------------------------------
                // Prefixo de BREAK
                // -------------------------------------------------
                if (byte_full == 8'hF0) begin

                    // O próximo scancode será a tecla solta
                    ignore_next <= 1'b1;

                end

                // -------------------------------------------------
                // Scancode da tecla solta
                // -------------------------------------------------
                else if (ignore_next) begin

                    // Não gera novo evento
                    ignore_next <= 1'b0;

                end

                // -------------------------------------------------
                // Scancode válido
                // -------------------------------------------------
                else begin

                    // Indica que existe um novo scancode válido.
                    // O toggle muda de estado a cada novo dado.
                    toggle_data_ready <= ~toggle_data_ready;

                end

            end else begin

                // Ainda estamos recebendo o byte
                bit_cnt <= bit_cnt + 1'b1;
            end

        end
    end

endmodule