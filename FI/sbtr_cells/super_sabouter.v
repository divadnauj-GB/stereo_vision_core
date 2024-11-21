module super_sabouter #(
	parameter WIDTH = 4
)(
	input [WIDTH-1:0] i_sig,
	input i_en_super_sabouter,
	input [WIDTH-1:0] i_en_basic_sabouter,
	input [1:0] i_ctrl,
	output reg [WIDTH-1:0] o_sig
);

	genvar i;
	wire [WIDTH-1:0] o_basic_sabouter;
	
	generate
		for(i = 0; i < WIDTH; i = i +1) begin
			basic_sabotuer BS(
				.i_bit(i_sig[i]),
				.i_en(i_en_basic_sabouter[i]),
				.i_ctrl(i_ctrl),
				.o_fault(o_basic_sabouter[i])
			);
		end
	endgenerate

	always @*
	begin
		case(i_en_super_sabouter)
			1'b1: o_sig = o_basic_sabouter;
			default: o_sig = i_sig;
		endcase
	end

endmodule