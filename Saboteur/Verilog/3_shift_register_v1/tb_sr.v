`timescale 1ns / 1ps

module tb_SR;
	parameter WIDTH = 4;
	
	reg i_CLK;
	reg i_RST;
	reg i_En;	
	reg i_SI;
	wire [WIDTH-1:0] out;
	integer i;
	
	shift_register #(WIDTH) SR(
		.i_CLK(i_CLK),
		.i_RST(i_RST),
		.i_En(i_En),
		.i_SI(i_SI),
		.o_DATA(out)
	);
	
	always begin
		#5 i_CLK = ~i_CLK; 
	end
	
	initial
	begin
		i_CLK = 0;
		i_RST = 1;
		i_En = 0;
		i_SI = 0;
		#25;
		i_RST = 0;
		i_En = 1;
		for(i=0; i<WIDTH; i=i+1) begin
			i_SI = 1;
			#10;
		end
		i_En = 0;
		#20;
		i_En = 1;
		
		i_SI = 1;
		#10;
		i_SI = 0;
		#10;
		i_SI = 1;
		#10;
		i_SI = 0;
		#10;
		i_SI = 1;
		
		i_En = 0;
		
		i_SI = 1;
		#10;
		i_SI = 1;
		#10;
		i_SI = 0;
		#10;
		i_SI = 0;
		#10;
		i_SI = 0;
		#10;
		
		i_RST = 1;
		i_En = 1;
		i_SI = 1;
		#10;
		i_SI = 0;
		#10;
		i_SI = 0;
		#10;
		i_SI = 0;
		#10;
		i_RST = 0;
		i_SI = 1;
		i_En = 0;
		#20;

		
	end
endmodule