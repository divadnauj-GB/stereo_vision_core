`timescale 1ns / 1ps

module tb_basic_sabotuer;
	reg i_bit, i_en;
	reg [1:0] i_ctrl;
	wire o_fault;
	
	basic_sabotuer UUT(
		.i_bit(i_bit),
		.i_en(i_en),
		.i_ctrl(i_ctrl),
		.o_fault(o_fault)
	);


	initial
	begin
		i_bit  = 0;
		i_en   = 0;
		i_ctrl = 2'b00;
		#10;
		i_bit  = 1;
		i_en   = 0;
		i_ctrl = 2'b00;
		#10;
		i_bit  = 1;
		i_en   = 1;
		i_ctrl = 2'b00;
		#10;
		i_bit  = 1;
		i_en   = 1;
		i_ctrl = 2'b01;
		#10;
		i_bit  = 1;
		i_en   = 1;
		i_ctrl = 2'b10;
		#10;
		i_bit  = 1;
		i_en   = 1;
		i_ctrl = 2'b11;
		#10;
		i_bit  = 1;
		i_en   = 0;
		i_ctrl = 2'b01;
		#10;
		i_bit  = 0;
		i_en   = 0;
		i_ctrl = 2'b01;
		#10;
		i_bit  = 0;
		i_en   = 1;
		i_ctrl = 2'b01;
		#10;
		i_bit  = 0;
		i_en   = 1;
		i_ctrl = 2'b11;
		#20 $stop;
		
	end

endmodule