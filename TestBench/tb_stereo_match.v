module tb_stereo_match;
parameter integer D  = 64;
parameter integer WC = 7;
parameter integer WH = 13;
parameter integer M  = 450;
parameter integer N  = 8;

  /*Localparameter definitions*/
localparam integer DBIT=$clog2(D);
localparam integer CBIT=$clog2(((WC ** 2) / 2) * (WH ** 2));

/*port size and directions definitions*/
reg i_clk;
reg i_rstn;
reg [N-1:0] i_data_l;
reg [N-1:0] i_data_r;
reg i_dval;
reg [DBIT-1:0] i_thresh_lrcc;
wire o_dval;
wire [DBIT-1:0] o_data;


stereo_match /*#(
    .D(D),
    .WC(WC),
    .WH(WH),
    .M(M),
    .N(N)
) */DUT (
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_data_l(i_data_l),
    .i_data_r(i_data_r),
    .i_dval(i_dval),
    .i_thresh_lrcc(i_thresh_lrcc),
    .o_dval(o_dval),
    .o_data(o_data)
);


/*Testbench code*/

integer fd_il;
integer fd_ir;
integer fd_iv;
integer fd_od;
integer fd_ov;
integer i;
integer j;
integer k;
integer returnval;

always begin
    #10 i_clk = ~i_clk;
end


initial begin
    $dumpfile("tb_stereo_match.vcd");
    $dumpvars(0, tb_stereo_match);   
end


initial begin
    fd_il = $fopen("./input_vector_left_image.txt","r");
    fd_ir = $fopen("./input_vector_right_image.txt","r");
    fd_iv = $fopen("./input_vector_valid.txt","r");
    fd_od = $fopen("./output_vector_data.txt","w");
    fd_ov = $fopen("./output_vector_valid.txt","w");
    i_clk = 0;
    i_rstn = 0;
    i_data_l = 0;
    i_data_r = 0;
    i_dval = 0;
    i_thresh_lrcc = 8;
    #10 i_rstn = 1;
    while(!$feof(fd_iv)) begin
        @(negedge i_clk);
        returnval = $fscanf(fd_iv,"%d",i_dval);
        returnval = $fscanf(fd_il,"%d",i_data_l);
        returnval = $fscanf(fd_ir,"%d",i_data_r);
        $fwrite(fd_od,"%d\n",o_data);
        $fwrite(fd_ov,"%d\n",o_dval);
    end
    $fclose(fd_il);
    $fclose(fd_ir);
    $fclose(fd_iv);
    $fclose(fd_od);
    $fclose(fd_ov);
    $finish;    
end


endmodule
