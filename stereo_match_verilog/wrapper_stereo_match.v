module wrapper_stereo_match #(
    parameter integer D  = 64,
    parameter integer WC = 7,
    parameter integer WH = 13,
    parameter integer M  = 450,
    parameter integer N  = 8
) (
    i_clk,
    i_rstn,
    i_data_l,
    i_data_r,
    i_dval,
    i_thresh_lrcc,
    o_dval,
    o_data
);

  localparam integer DBIT = $clog2(D);

  input i_clk;
  input i_rstn;
  input [N-1:0] i_data_l;
  input [N-1:0] i_data_r;
  input i_dval;
  input [DBIT-1:0] i_thresh_lrcc;
  output o_dval;
  output [DBIT-1:0] o_data;
  /*Localparameter definitions*/

  stereo_match #(
      .D (D),
      .WC(WC),
      .WH(WH),
      .M (M),
      .N (N)
  ) stereo_match_inst (
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_data_l(i_data_l),
      .i_data_r(i_data_r),
      .i_dval(i_dval),
      .i_thresh_lrcc(i_thresh_lrcc),
      .o_dval(o_dval),
      .o_data(o_data)
  );

endmodule
