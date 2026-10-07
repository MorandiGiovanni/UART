module uart_tx (
    input  logic clock,
    input  logic reset,
    input  logic ps2_clk,
    input  logic ps2_data,

    output logic tx_data,     
    output logic tx_done
);


    //variaveis inteirnas
    logic       clock_div;
    logic [2:0] saida_contador;

    logic       data_ready;
    logic [7:0] data_out;
    logic       fsm_out;

    logic [7:0] AN_pos0, AN_pos1, AN_pos2, AN_pos3,
                AN_pos4, AN_pos5, AN_pos6, AN_pos7;

    divisor_clock div_clk (
        .clk_in  (clk),
        .clk_out (clock_div)
    );

    modulo_contador cont (
        .clock    (clock_div),
        .cont_out (saida_contador)
    );

    decoder dec (
        .contador   (saida_contador),
        .display_en (display_en)
    );

    fsm FSM (
        .reset       (rst),
        .ps2_clk     (ps2_clk),
        .ps2_data    (ps2_data),
        .fsmoutdetin (fsm_out)
    );

    detector_borda detectores (
        .rst         (rst),
        .fsmoutdetin (fsm_out),
        .ps2_data    (ps2_data),
        .data_ready  (data_ready),   // flag de 1 bit
        .novo_dado   (data_out)      // byte de 8 bits
    );

    shift_register sr (
        .reset     (rst),
        .clock     (clk),
        .AN_novo   (data_out),       // byte
        .novo_dado (data_ready),     // flag
        .AN_pos0   (AN_pos0),
        .AN_pos1   (AN_pos1),
        .AN_pos2   (AN_pos2),
        .AN_pos3   (AN_pos3),
        .AN_pos4   (AN_pos4),
        .AN_pos5   (AN_pos5),
        .AN_pos6   (AN_pos6),
        .AN_pos7   (AN_pos7)
    );

    mux_decoder mux (
        .contador (saida_contador),
        .AN_pos0  (AN_pos0),
        .AN_pos1  (AN_pos1),
        .AN_pos2  (AN_pos2),
        .AN_pos3  (AN_pos3),
        .AN_pos4  (AN_pos4),
        .AN_pos5  (AN_pos5),
        .AN_pos6  (AN_pos6),
        .AN_pos7  (AN_pos7),
        .display  (display)
    );

endmodule