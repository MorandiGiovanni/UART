module desmontador_ascii (
    input  logic [7:0] dado_ascii_montado, // ASCII vindo do decoder
    input  logic       toggle_data_ready, // toggle vindo do detector_borda
    input  logic       clock9600,         // clock de aproximadamente 9600 Hz
    input  logic       reset,

    output logic       tx_data,
    output logic       tx_done
);

    // =========================================================
    // Estados da transmissão UART
    // =========================================================
    typedef enum logic [1:0] {
        IDLE,
        START_BIT,
        DATA,
        STOP_BIT
    } estado_t;

    estado_t estado_atual;

    // =========================================================
    // Registrador de deslocamento
    // =========================================================
    logic [7:0] shift_reg;

    // Conta os bits de dados: 0 até 7
    logic [2:0] bit_cnt;

    // =========================================================
    // Sincronização do toggle
    // =========================================================
    logic toggle_sync1;
    logic toggle_sync2;
    logic toggle_anterior;

    // Detecta uma mudança no toggle
    logic novo_ascii;

    assign novo_ascii = toggle_sync2 ^ toggle_anterior;

    // =========================================================
    // Saída TX
    // =========================================================
    //
    // IDLE      -> 1
    // START_BIT -> 0
    // DATA      -> bit atual do ASCII
    // STOP_BIT  -> 1
    //
    // =========================================================

    always_comb begin

        case (estado_atual)

            IDLE: begin
                tx_data = 1'b1;
            end

            START_BIT: begin
                tx_data = 1'b0;
            end

            DATA: begin
                tx_data = shift_reg[0];
            end

            STOP_BIT: begin
                tx_data = 1'b1;
            end

            default: begin
                tx_data = 1'b1;
            end

        endcase

    end

    // =========================================================
    // TX_DONE
    // =========================================================
    //
    // 1 -> transmissão concluída / transmissor ocioso
    // 0 -> transmissão em andamento
    //
    // =========================================================

    assign tx_done = (estado_atual == IDLE);

    // =========================================================
    // Máquina de estados
    // =========================================================

    always_ff @(posedge clock9600 or posedge reset) begin

        if (reset) begin

            estado_atual  <= IDLE;
            shift_reg     <= 8'b0;
            bit_cnt       <= 3'd0;

            toggle_sync1  <= 1'b0;
            toggle_sync2  <= 1'b0;
            toggle_anterior <= 1'b0;

        end else begin

            // -------------------------------------------------
            // Sincronizador do toggle
            // -------------------------------------------------

            toggle_sync1    <= toggle_data_ready;
            toggle_sync2    <= toggle_sync1;
            toggle_anterior <= toggle_sync2;

            // -------------------------------------------------
            // Máquina de estados
            // -------------------------------------------------

            case (estado_atual)

                // =============================================
                // IDLE
                // =============================================
                IDLE: begin

                    bit_cnt <= 3'd0;

                    // Detectou um novo ASCII
                    if (novo_ascii) begin

                        // Carrega o ASCII
                        shift_reg <= dado_ascii_montado;

                        // Começa pelo START bit
                        estado_atual <= START_BIT;

                    end
                end

                // =============================================
                // START BIT
                // =============================================
                START_BIT: begin

                    // tx_data = 0 neste estado
                    // durante um período de clock9600

                    estado_atual <= DATA;
                    bit_cnt <= 3'd0;

                end

                // =============================================
                // DATA
                // =============================================
                DATA: begin

                    if (bit_cnt == 3'd7) begin

                        // Último bit do ASCII enviado
                        estado_atual <= STOP_BIT;

                    end else begin

                        // Desloca para a direita
                        // para enviar LSB primeiro
                        shift_reg <= {
                            1'b0,
                            shift_reg[7:1]
                        };

                        bit_cnt <= bit_cnt + 1'b1;

                    end

                end

                // =============================================
                // STOP BIT
                // =============================================
                STOP_BIT: begin

                    // tx_data = 1 neste estado
                    // durante um período de clock9600

                    estado_atual <= IDLE;

                end

                // =============================================
                // Segurança
                // =============================================
                default: begin

                    estado_atual <= IDLE;
                    shift_reg    <= 8'b0;
                    bit_cnt      <= 3'd0;

                end

            endcase

        end

    end

endmodule