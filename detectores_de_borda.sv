module detector_borda (
    input  logic rst,          
    input  logic fsmoutdetin,  // ps2_clk filtrado, vindo da FSM
    input  logic ps2_data,     // dado bruto do PS2

    output logic       data_ready, //flag de quando tem novo dado
    output logic [7:0] novo_dado   // o novo dado que vai entrar no trilho
);

    logic [7:0] byte_acc;     // acumula os bits recebidos
    logic [2:0] bit_cnt;      // conta 0 a 7
    logic [7:0] byte_full;    // byte com o bit atual ja inserido
    logic       ignore_next;  // flag para ignorar quandoa tecla é soltada

    assign byte_full = {ps2_data, byte_acc[7:1]}; 

    always_ff @(negedge fsmoutdetin or posedge rst) begin
        if (rst) begin
            byte_acc    <= 8'd0;
            bit_cnt     <= 3'd0;
            data_ready  <= 1'b0;
            novo_dado   <= 8'd0;
            ignore_next <= 1'b0;
        end else begin
            byte_acc <= byte_full;

            if (bit_cnt == 3'd7) begin
                // ultimo bit -> byte completo
                novo_dado <= byte_full;
                bit_cnt   <= 3'd0;

                if (byte_full == 8'hF0) begin
                    // prefixo de break: ignora ele e o byte seguinte
                    ignore_next <= 1'b1;
                    data_ready  <= 1'b0;
                end else if (ignore_next) begin
                    // scan code da tecla solta
                    ignore_next <= 1'b0;
                    data_ready  <= 1'b0;
                end else begin
                    // valido
                    data_ready  <= 1'b1;
                end
            end else begin
                data_ready <= 1'b0;
                bit_cnt    <= bit_cnt + 1'b1;
            end
        end
    end

endmodule