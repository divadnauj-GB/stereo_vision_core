`timescale 1ns / 1ps

module tb_super_sabouter;
	parameter WIDTH = 1;
	
	reg [WIDTH-1:0] i_sig;
	reg i_en_super_sabouter;
	reg [WIDTH-1:0] i_en_basic_sabouter;
	reg [1:0] i_ctrl;
	wire [WIDTH-1:0] o_sig;

	super_sabouter #(WIDTH) UUT(
		.i_sig(i_sig),
		.i_en_super_sabouter(i_en_super_sabouter),
		.i_en_basic_sabouter(i_en_basic_sabouter),
		.i_ctrl(i_ctrl),
		.o_sig(o_sig)
	);
	
	initial
	begin
		i_en_super_sabouter = 0;
		i_en_basic_sabouter = 0;
		i_sig = 0;
		i_ctrl = 0;
		#10;
		i_en_super_sabouter = 1'b0;
		i_en_basic_sabouter = 1'd0;
		i_sig = 3'b101;
		i_ctrl = 2'b00;
		#10;
		i_en_super_sabouter = 1'b1;
		i_en_basic_sabouter = 1'd1;
		i_sig = 3'b101;
		i_ctrl = 2'b00;
		#10;
		i_en_super_sabouter = 1'b1;
		i_en_basic_sabouter = 1'd0;
		i_sig = 3'b101;
		i_ctrl = 2'b01;
		#10;
		i_en_super_sabouter = 1'b1;
		i_en_basic_sabouter = 1'd0;
		i_sig = 3'b101;
		i_ctrl = 2'b11;
		#10;
		i_en_super_sabouter = 1'b1;
		i_en_basic_sabouter = 1'd0;
		i_sig = 3'b101;
		i_ctrl = 2'b11;
		#10;
		i_en_super_sabouter = 1'b1;
		i_en_basic_sabouter = 1'd1;
		i_sig = 3'b101;
		i_ctrl = 2'b00;
		#10;
		i_en_super_sabouter = 1'b0;
		i_en_basic_sabouter = 1'd1;
		i_sig = 3'b101;
		i_ctrl = 2'b11;
		
		#20 $stop;
	end

endmodule