module fsm (
    input  logic reset,
    input  logic ps2_clk,
    input  logic ps2_data,
    output logic fsmoutdetin
);
    typedef enum logic [1:0] { IDLE, DATA, P, STOP } state_t;
    state_t state, next_state;


    logic [2:0] bit_cnt;
    logic       en;


    // estado = o que o bit amostrado NESTA borda representa
    always_ff @(negedge ps2_clk or posedge reset) begin
        if (reset) begin
            state   <= IDLE;
            bit_cnt <= 3'd0;
        end else begin
            state <= next_state;
            if (state == DATA) bit_cnt <= bit_cnt + 1'b1; // 7 -> 0 sozinho
            else               bit_cnt <= 3'd0;
        end
    end


    always_comb begin
        next_state = state;
        case (state)
            IDLE:    if (ps2_data == 1'b0) next_state = DATA; // start bit
            DATA:    if (bit_cnt == 3'd7)  next_state = P;    // d7 foi amostrado
            P:       next_state = STOP;
            STOP:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end


    // habilita só muda com ps2_clk = 1 
    always_ff @(posedge ps2_clk or posedge reset) begin
        if (reset) en <= 1'b0;
        else       en <= (state == DATA);
    end

    assign fsmoutdetin = ps2_clk | ~en;   // idle em 1, passa 8 bordas por quadro
endmodule