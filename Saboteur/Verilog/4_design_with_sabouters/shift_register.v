`timescale 1ns / 1ps

// Serial input, parallel output shift_register

module shift_register #(
	parameter WIDTH = 10
)(
	input i_CLK,
	input i_RST,
	input i_EN,
	input i_SI,
	output reg [WIDTH-1:0] o_DATA
);
	
	reg [WIDTH-1:0] SHIFT_REGISTER, temp;
	
	
	always @(posedge i_CLK)
	begin
		if(i_RST) begin
			SHIFT_REGISTER <= {WIDTH{1'b0}};
			temp		   <= {WIDTH{1'b0}};
		end
		else
			SHIFT_REGISTER <= temp;		
	end
	
	always @*
	begin
		if(i_EN) 
			temp <= {i_SI, SHIFT_REGISTER[WIDTH-1:1]};
		else
			temp <= temp;	// when counter reach zero i_En will be zero and reset the shift register
		o_DATA <= SHIFT_REGISTER;
	end
	
endmodule