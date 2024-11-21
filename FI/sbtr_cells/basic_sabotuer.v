module basic_sabotuer(
	input i_bit,
	input i_en,
	input [1:0] i_ctrl,
	output reg o_fault
);
	
	reg fault;
	
	always @*
	begin
		casez(i_ctrl)
			2'b00   : fault = 1'b0;			// stuck-at-0
			2'b01   : fault = 1'b1;			// stuck-at-1
			2'b1?   : fault = ~i_bit;		// bit flip
			default : fault = i_bit;
		endcase
	end
	
	always @*
	begin
		case(i_en)
			1'b1    : o_fault = fault;
			default : o_fault = i_bit;
		endcase
	end

endmodule