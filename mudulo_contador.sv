module modulo_contador(
	input clock,
	output logic [2:0] cont_out = 3'b000
);

	always_ff @(posedge clock ) begin
		if(cont_out == 3'b111)begin
			cont_out <= 3'b000;
		end
		else begin
			cont_out <= cont_out + 3'b001;
		end
	end
endmodule
