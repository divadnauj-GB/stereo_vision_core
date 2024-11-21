module shift_register #(
	parameter WIDTH = 10
)(
	input i_CLK,
	input i_RST,
	input i_EN,
	input i_SI,
	output [WIDTH-1:0] o_DATA
);
	
	reg [WIDTH-1:0] SHIFT_REGISTER;
	
	
	always @(posedge i_CLK, negedge i_RST)
	begin
		if(!i_RST) begin
            SHIFT_REGISTER <= {WIDTH{1'b0}};
        end
        else begin
            if(i_EN) begin
			    SHIFT_REGISTER <= {i_SI, SHIFT_REGISTER[WIDTH-1:1]};
            end
        end
    end
	
    assign o_DATA = SHIFT_REGISTER;
	
endmodule
