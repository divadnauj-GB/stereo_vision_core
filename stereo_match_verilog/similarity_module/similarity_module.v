module similarity_module #(
    parameter integer WC = 7,
    parameter integer WH = 13,
    parameter integer M  = 650
) (
    i_clk,
    i_rstn,
    i_data_ll,
    i_data_lh,
    i_data_rl,
    i_data_rh,
    i_dval,
    o_dval,
    o_data
);

  localparam integer NIBIT = (WC ** 2) / 2;
  localparam integer NOBIT = $clog2(((WC ** 2) / 2) * (WH ** 2));
  localparam integer NSTAGES = $clog2(NIBIT);
  localparam integer NBITC1 = NSTAGES;

  input i_clk;
  input i_rstn;
  input [NIBIT-1:0] i_data_ll;
  input [NIBIT-1:0] i_data_lh;
  input [NIBIT-1:0] i_data_rl;
  input [NIBIT-1:0] i_data_rh;
  input i_dval;
  output o_dval;
  output [NOBIT-1:0] o_data;


  wire [NIBIT-1:0] w_hamming_l;
  wire [NIBIT-1:0] w_hamming_h;
  wire w_valid_l;
  wire [NBITC1-1:0] w_phamming_l;
  wire w_valid_h;
  wire [NBITC1-1:0] w_phamming_h;
  wire w_valid_win;

  assign w_hamming_l = i_data_ll ^ i_data_rl;
  assign w_hamming_h = i_data_lh ^ i_data_rh;

  num_ones #(
      .WC(WC)
  ) count_ones_l (
      .i_clk (i_clk),
      .i_rstn(i_rstn),
      .i_data(w_hamming_l),
      .i_dval(i_dval),
      .o_dval(w_valid_l),
      .o_data(w_phamming_l)
  );

  num_ones #(
      .WC(WC)
  ) count_ones_h (
      .i_clk (i_clk),
      .i_rstn(i_rstn),
      .i_data(w_hamming_h),
      .i_dval(i_dval),
      .o_dval(w_valid_h),
      .o_data(w_phamming_h)
  );


  window_SHD #(
      .WC(WC),
      .WH(WH),
      .M (M)
  ) SHD (
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_data_l(w_phamming_l),
      .i_data_h(w_phamming_h),
      .i_dval(w_valid_l),
      .o_dval(o_dval),
      .o_data(o_data)
  );


endmodule
