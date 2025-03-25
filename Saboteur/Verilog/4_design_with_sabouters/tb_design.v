`timescale 1ns / 1ps

module tb_modified_design;
	parameter WIDTH_SR = 131;

	reg i_SI;						  // FAULT INJECTION SIGNAL 
	reg i_EN_SR;                      // FAULT INJECTION SIGNAL
	reg i_TFEn;                       // FAULT INJECTION SIGNAL
	reg i_CLK_x;                      // FAULT INJECTION SIGNAL 
	reg i_RST_x;					  // FAULT INJECTION SIGNAL 
	
	reg [11:0] i_data_C1;			  // DESIGN INPUT
	reg [6:0] i_data_D1;              // DESIGN INPUT
	reg [11:0] i_data_C2;              // DESIGN INPUT
	reg [6:0] i_data_D2;              // DESIGN INPUT
	
	wire [11:0] o_data_C;			  // DESIGN OUTPUT
	wire [6:0] o_data_D;              // DESIGN OUTPUT
	
	wire o_SI;						  // FAULT INJECTION SIGNAL
	wire o_EN_SR;                     // FAULT INJECTION SIGNAL
	wire o_TFEn;                     // FAULT INJECTION SIGNAL
	wire o_CLK_x;                      // FAULT INJECTION SIGNAL
	wire o_RST_x;					// FAULT INJECTION SIGNAL

	reg [WIDTH_SR-1:0] temp_data;
	integer i;


	Disp_Cmp #(.WIDTH_SR(WIDTH_SR)) DUT (
		.i_SI(i_SI),            // FAULT INJECTION SIGNAL
		.i_EN_SR(i_EN_SR),      // FAULT INJECTION SIGNAL
		.i_TFEn(i_TFEn),        // FAULT INJECTION SIGNAL
		.i_CLK_x(i_CLK_x),		// FAULT INJECTION SIGNAL
		.i_RST_x(i_RST_x),		// FAULT INJECTION SIGNAL
		
		.i_data_C1(i_data_C1),	// DESIGN
		.i_data_D1(i_data_D1),  // DESIGN
		.i_data_C2(i_data_C2),  // DESIGN
		.i_data_D2(i_data_D2),  // DESIGN
		.o_data_C(o_data_C),    // DESIGN
		.o_data_D(o_data_D),    // DESIGN
		
		.o_CLK_x(o_CLK_x),		// FAULT INJECTION SIGNAL
		.o_RST_x(o_RST_x),		// FAULT INJECTION SIGNAL
		.o_EN_SR(o_EN_SR),      // FAULT INJECTION SIGNAL
		.o_TFEn(o_TFEn),        // FAULT INJECTION SIGNAL
		.o_SI(o_SI)             // FAULT INJECTION SIGNAL
	);

	always begin
		#5 i_CLK_x = ~i_CLK_x; 
	end

	initial
	begin
		i_CLK_x = 1;
		i_RST_x = 1;
		temp_data = 0;
		i_SI	= 0;
		i_EN_SR = 0;
        i_TFEn  = 0;
		#20;
		i_RST_x = 0;
	// NO FAULT INJECTION, NORMAL OPERATION
		i_data_C1 = 12'b01;
	    i_data_D1 = 7'b11;
	    i_data_C2 = 12'b11;
	    i_data_D2 = 7'b10;
		#10;
		i_data_C1 = 12'b01;
	    i_data_D1 = 7'b11;
	    i_data_C2 = 12'b00;
	    i_data_D2 = 7'b10;
	// SA-0 FAULT INJECTION (CTRL = "00") on SS-72 (the last bit)
		temp_data[83] = 1'b1;
		i_EN_SR = 1;                                 // SETUP
		for(i = 0; i < WIDTH_SR; i = i + 1) begin          // SETUP
			i_SI = temp_data[i];                  // SETUP
			#10;                                     // SETUP
		end                                          // SETUP
		i_EN_SR = 0;								 // SETUP
		i_TFEn  = 1;								 // FAULT INJECTED HERE
		#30;
	// NO FAULT INJECTION, NORMAL OPERATION
		i_TFEn  = 0;
		i_data_C1 = 2'b11;
	    i_data_D1 = 2'b01;
	    i_data_C2 = 2'b10;
	    i_data_D2 = 2'b10;
		#10;
/* 	// NO FAULT INJECTION, NORMAL OPERATION
		i_TFEn  = 0;
		i_data_C1 = 2'b00;
	    i_data_D1 = 2'b11;
	    i_data_C2 = 2'b10;
	    i_data_D2 = 2'b01;
		#10;
		
	// RESET SHIFT REGISTER
		i_RST_x = 1;
		#10;
		i_RST_x = 0;
		
	
	// SA-0 FAULT INJECTION (CTRL = "00") on SS-72 12th bit (the last bit)
		temp_data = 18'b010010000000000000;				// SETUP
		i_EN_SR = 1;                                    // SETUP
		for(i = 0; i < WIDTH_SR; i = i + 1) begin       // SETUP
			i_SI = temp_data[i];                     // SETUP
			#10;                                        // SETUP
		end                                             // SETUP
		i_EN_SR = 0;                                    // SETUP
        i_TFEn  = 1;	                                // FAULT INJECTED HERE
		#50;		
		i_TFEn  = 0;
	
		
		
	// SA-0 FAULT INJECTION (CTRL = "00") on SS-12 (2-bit) second bit
		temp_data = 18'b010010000000000000;				// SETUP
		i_EN_SR = 1;                                    // SETUP
		for(i = 0; i < WIDTH_SR; i = i + 1) begin       // SETUP
			i_SI = temp_data[i];                     // SETUP
			#10;                                        // SETUP
		end                                             // SETUP
		i_EN_SR = 0;                                    // SETUP
        i_TFEn  = 1;	                                // FAULT INJECTED HERE
		#50;		
		i_TFEn  = 0;
	// RESET SHIFT REGISTER
		i_RST_x = 1;
		#10;
		i_RST_x = 0;
		#10;
		
	// TRANSIENT FAULT (CTRL = "1x" on SS-13 (2-bit) on first bit
		i_TFEn  = 0;
		temp_data = 18'b100100000000000000;
		i_EN_SR = 1;
		for(i = 0; i < WIDTH_SR; i = i + 1) begin       // SETUP
			i_SI = temp_data[i];                     // SETUP
			#10;                                        // SETUP
		end 
		i_TFEn  = 1;									// FAULT INJECTED HERE
		i_EN_SR = 0;
		#60; 			// wait some time
		i_TFEn  = 0;
		#50; */
		
		$stop;
	end
endmodule