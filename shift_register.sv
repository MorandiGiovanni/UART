module shift_register (
    input  logic [7:0] AN_novo,   // byte vindo do detector (novo_dado[7:0])
    input  logic       reset,
    input  logic       clock,
    input  logic       novo_dado, // flag vindo do detector (data_ready)

    output logic [7:0] AN_pos0,
    output logic [7:0] AN_pos1,
    output logic [7:0] AN_pos2,
    output logic [7:0] AN_pos3,
    output logic [7:0] AN_pos4,
    output logic [7:0] AN_pos5,
    output logic [7:0] AN_pos6,
    output logic [7:0] AN_pos7
);

    //variaveis para sincronizar os clocks
    logic       novo_dado_ff1, novo_dado_ff2, novo_dado_ff3;
    logic [7:0] AN_novo_ff1, AN_novo_ff2;

    //sincronização dos clocks diferentes
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            novo_dado_ff1 <= 1'b0;
            novo_dado_ff2 <= 1'b0;
            novo_dado_ff3 <= 1'b0;
            AN_novo_ff1   <= 8'd0;
            AN_novo_ff2   <= 8'd0;
        end else begin
            novo_dado_ff1 <= novo_dado;
            novo_dado_ff2 <= novo_dado_ff1;
            novo_dado_ff3 <= novo_dado_ff2;

            AN_novo_ff1   <= AN_novo;
            AN_novo_ff2   <= AN_novo_ff1;
        end
    end

    // pulso de 1 ciclo na borda de subida do flag sincronizado
    logic novo_dado_pulse, novo_dado_pulse_d;
    assign novo_dado_pulse = novo_dado_ff2 & ~novo_dado_ff3;

    // atrasa o pulso 1 ciclo: le o byte com folga
    always_ff @(posedge clock or posedge reset) begin
        if (reset) novo_dado_pulse_d <= 1'b0;
        else       novo_dado_pulse_d <= novo_dado_pulse;
    end

    // deslocamento dos displays
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            AN_pos7 <= 8'hFF; //hFF cai no caso default ficando apagado
            AN_pos6 <= 8'hFF;
            AN_pos5 <= 8'hFF;
            AN_pos4 <= 8'hFF;
            AN_pos3 <= 8'hFF;
            AN_pos2 <= 8'hFF;
            AN_pos1 <= 8'hFF;
            AN_pos0 <= 8'hFF;
        end else if (novo_dado_pulse_d) begin
            AN_pos7 <= AN_pos6;
            AN_pos6 <= AN_pos5;
            AN_pos5 <= AN_pos4;
            AN_pos4 <= AN_pos3;
            AN_pos3 <= AN_pos2;
            AN_pos2 <= AN_pos1;
            AN_pos1 <= AN_pos0;
            AN_pos0 <= AN_novo_ff2;
        end
    end

endmodule