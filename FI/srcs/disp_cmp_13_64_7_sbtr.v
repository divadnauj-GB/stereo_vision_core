/* Generated by Yosys 0.47+61 (git sha1 81011ad92, clang++ 18.1.8 -fPIC -O3) */
module disp_cmp_13_64_7_sbtr(i_data_c1, i_data_d1, i_data_c2, i_data_d2, o_data_c, o_data_d, i_TFEn, i_CLK, i_RST, i_EN, i_SI, o_TFEn, o_CLK, o_RST, o_EN, o_SI);
  wire _nw_000_;
  wire _nw_001_;
  wire _nw_002_;
  wire _nw_003_;
  wire _nw_004_;
  wire _nw_005_;
  wire _nw_006_;
  wire _nw_007_;
  wire _nw_008_;
  wire _nw_009_;
  wire _nw_010_;
  wire _nw_011_;
  wire _nw_012_;
  wire _nw_013_;
  wire _nw_014_;
  wire _nw_015_;
  wire _nw_016_;
  wire _nw_017_;
  wire _nw_018_;
  wire _nw_019_;
  wire _nw_020_;
  wire _nw_021_;
  wire _nw_022_;
  wire _nw_023_;
  wire _nw_024_;
  wire [30:8] _nw_025_;
  wire _nw_026_;
  wire _nw_027_;
  wire _nw_028_;
  wire _nw_029_;
  wire _nw_030_;
  wire _nw_031_;
  wire _nw_032_;
  wire _nw_033_;
  wire _nw_034_;
  wire _nw_035_;
  wire _nw_036_;
  wire _nw_037_;
  wire _nw_038_;
  wire _nw_039_;
  wire [30:0] _nw_040_;
  wire _nw_041_;
  wire _nw_042_;
  wire _nw_043_;
  wire _nw_044_;
  wire _nw_045_;
  wire _nw_046_;
  wire _nw_047_;
  wire _nw_048_;
  wire _nw_049_;
  wire _nw_050_;
  wire _nw_051_;
  wire _nw_052_;
  wire _nw_053_;
  wire _nw_054_;
  wire _nw_055_;
  wire _nw_056_;
  wire _nw_057_;
  wire _nw_058_;
  wire _nw_059_;
  wire _nw_060_;
  wire _nw_061_;
  wire _nw_062_;
  wire _nw_063_;
  wire _nw_064_;
  wire _nw_065_;
  wire _nw_066_;
  wire _nw_067_;
  wire _nw_068_;
  wire _nw_069_;
  wire _nw_070_;
  wire _nw_071_;
  input i_CLK, i_RST, i_EN, i_SI, i_TFEn;
  wire i_CLK, i_RST, i_EN, i_SI, i_TFEn;
  output o_CLK, o_RST, o_EN, o_SI, o_TFEn;
  wire o_CLK, o_RST, o_EN, o_SI, o_TFEn;
  input [11:0] i_data_c1;
  wire [11:0] i_data_c1;
  input [11:0] i_data_c2;
  wire [11:0] i_data_c2;
  input [6:0] i_data_d1;
  wire [6:0] i_data_d1;
  input [6:0] i_data_d2;
  wire [6:0] i_data_d2;
  output [11:0] o_data_c;
  wire [11:0] o_data_c;
  output [6:0] o_data_d;
  wire [6:0] o_data_d;
  wire [6:0] tmp_o_data_d;
  wire [11:0] tmp_o_data_c;
  wire [20:0] s_SR;
  
  assign _nw_040_[30] = ~_nw_025_[30];
  assign _nw_000_ = _nw_028_ & _nw_031_;
  assign _nw_006_ = _nw_000_ & _nw_001_;
  assign _nw_009_ = _nw_006_ & _nw_007_;
  assign _nw_010_ = _nw_009_ & _nw_008_;
  assign tmp_o_data_d[0] = _nw_053_ ? i_data_d1[0] : i_data_d2[0];
  assign tmp_o_data_d[1] = _nw_053_ ? i_data_d1[1] : i_data_d2[1];
  assign tmp_o_data_d[2] = _nw_053_ ? i_data_d1[2] : i_data_d2[2];
  assign tmp_o_data_d[3] = _nw_053_ ? i_data_d1[3] : i_data_d2[3];
  assign tmp_o_data_d[4] = _nw_053_ ? i_data_d1[4] : i_data_d2[4];
  assign tmp_o_data_d[5] = _nw_053_ ? i_data_d1[5] : i_data_d2[5];
  assign tmp_o_data_d[6] = _nw_053_ ? i_data_d1[6] : i_data_d2[6];
  assign tmp_o_data_c[0] = _nw_053_ ? i_data_c1[0] : i_data_c2[0];
  assign tmp_o_data_c[1] = _nw_053_ ? i_data_c1[1] : i_data_c2[1];
  assign tmp_o_data_c[2] = _nw_053_ ? i_data_c1[2] : i_data_c2[2];
  assign tmp_o_data_c[3] = _nw_053_ ? i_data_c1[3] : i_data_c2[3];
  assign tmp_o_data_c[4] = _nw_053_ ? i_data_c1[4] : i_data_c2[4];
  assign tmp_o_data_c[5] = _nw_053_ ? i_data_c1[5] : i_data_c2[5];
  assign tmp_o_data_c[6] = _nw_053_ ? i_data_c1[6] : i_data_c2[6];
  assign tmp_o_data_c[7] = _nw_053_ ? i_data_c1[7] : i_data_c2[7];
  assign tmp_o_data_c[8] = _nw_053_ ? i_data_c1[8] : i_data_c2[8];
  assign tmp_o_data_c[9] = _nw_053_ ? i_data_c1[9] : i_data_c2[9];
  assign tmp_o_data_c[10] = _nw_053_ ? i_data_c1[10] : i_data_c2[10];
  assign tmp_o_data_c[11] = _nw_053_ ? i_data_c1[11] : i_data_c2[11];
  assign _nw_011_ = ~i_data_c2[0];
  assign _nw_014_ = ~i_data_c2[1];
  assign _nw_015_ = ~i_data_c2[2];
  assign _nw_016_ = ~i_data_c2[3];
  assign _nw_017_ = ~i_data_c2[4];
  assign _nw_018_ = ~i_data_c2[5];
  assign _nw_019_ = ~i_data_c2[6];
  assign _nw_020_ = ~i_data_c2[7];
  assign _nw_021_ = ~i_data_c2[8];
  assign _nw_022_ = ~i_data_c2[9];
  assign _nw_012_ = ~i_data_c2[10];
  assign _nw_013_ = ~i_data_c2[11];
  assign _nw_053_ = _nw_040_[30] | _nw_010_;
  assign _nw_041_ = i_data_c1[0] & _nw_011_;
  assign _nw_044_ = i_data_c1[1] & _nw_014_;
  assign _nw_045_ = i_data_c1[2] & _nw_015_;
  assign _nw_046_ = i_data_c1[3] & _nw_016_;
  assign _nw_047_ = i_data_c1[4] & _nw_017_;
  assign _nw_048_ = i_data_c1[5] & _nw_018_;
  assign _nw_049_ = i_data_c1[6] & _nw_019_;
  assign _nw_050_ = i_data_c1[7] & _nw_020_;
  assign _nw_051_ = i_data_c1[8] & _nw_021_;
  assign _nw_052_ = i_data_c1[9] & _nw_022_;
  assign _nw_042_ = i_data_c1[10] & _nw_012_;
  assign _nw_043_ = i_data_c1[11] & _nw_013_;
  assign _nw_028_ = i_data_c1[0] ^ _nw_011_;
  assign _nw_031_ = i_data_c1[1] ^ _nw_014_;
  assign _nw_032_ = i_data_c1[2] ^ _nw_015_;
  assign _nw_033_ = i_data_c1[3] ^ _nw_016_;
  assign _nw_034_ = i_data_c1[4] ^ _nw_017_;
  assign _nw_035_ = i_data_c1[5] ^ _nw_018_;
  assign _nw_036_ = i_data_c1[6] ^ _nw_019_;
  assign _nw_037_ = i_data_c1[7] ^ _nw_020_;
  assign _nw_038_ = i_data_c1[8] ^ _nw_021_;
  assign _nw_039_ = i_data_c1[9] ^ _nw_022_;
  assign _nw_029_ = i_data_c1[10] ^ _nw_012_;
  assign _nw_030_ = i_data_c1[11] ^ _nw_013_;
  assign _nw_025_[30] = _nw_064_ | _nw_065_;
  assign _nw_027_ = _nw_071_ | _nw_063_;
  assign _nw_064_ = _nw_070_ | _nw_062_;
  assign _nw_071_ = _nw_068_ | _nw_061_;
  assign _nw_026_ = _nw_066_ | _nw_060_;
  assign _nw_070_ = _nw_043_ | _nw_059_;
  assign _nw_069_ = _nw_052_ | _nw_058_;
  assign _nw_068_ = _nw_050_ | _nw_057_;
  assign _nw_067_ = _nw_048_ | _nw_056_;
  assign _nw_066_ = _nw_046_ | _nw_055_;
  assign _nw_024_ = _nw_044_ | _nw_054_;
  assign _nw_023_ = _nw_041_ | _nw_028_;
  assign _nw_065_ = _nw_008_ & _nw_027_;
  assign _nw_008_ = _nw_005_ & _nw_004_;
  assign _nw_007_ = _nw_003_ & _nw_002_;
  assign _nw_005_ = _nw_030_ & _nw_029_;
  assign _nw_004_ = _nw_039_ & _nw_038_;
  assign _nw_003_ = _nw_037_ & _nw_036_;
  assign _nw_002_ = _nw_035_ & _nw_034_;
  assign _nw_001_ = _nw_033_ & _nw_032_;
  assign _nw_063_ = _nw_007_ & _nw_026_;
  assign _nw_062_ = _nw_005_ & _nw_069_;
  assign _nw_061_ = _nw_003_ & _nw_067_;
  assign _nw_060_ = _nw_001_ & _nw_024_;
  assign _nw_059_ = _nw_030_ & _nw_042_;
  assign _nw_058_ = _nw_039_ & _nw_051_;
  assign _nw_057_ = _nw_037_ & _nw_049_;
  assign _nw_056_ = _nw_035_ & _nw_047_;
  assign _nw_055_ = _nw_033_ & _nw_045_;
  assign _nw_054_ = _nw_031_ & _nw_023_;
  assign _nw_025_[29:11] = { _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30], _nw_025_[30] };
  assign _nw_040_[29:12] = { _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30], _nw_040_[30] };
super_sabouter #(.WIDTH(7)) SS0(
                  .i_sig(tmp_o_data_d),
                  .i_en_super_sabouter(i_TFEn),
                  .i_en_basic_sabouter(s_SR[6:0]),
                  .i_ctrl(s_SR[20:19]),
                  .o_sig(o_data_d)
                  );
super_sabouter #(.WIDTH(12)) SS1(
                  .i_sig(tmp_o_data_c),
                  .i_en_super_sabouter(i_TFEn),
                  .i_en_basic_sabouter(s_SR[18:7]),
                  .i_ctrl(s_SR[20:19]),
                  .o_sig(o_data_c)
                  );
shift_register #(.WIDTH(21)) SR(
                    .i_CLK(i_CLK),
                    .i_RST(i_RST),
                    .i_EN(i_EN),
                    .i_SI(i_SI),
                    .o_DATA(s_SR)
                    );
assign o_CLK=i_CLK;
assign o_RST=i_RST;
assign o_EN=i_EN;
assign o_SI=s_SR[0];
assign o_TFEn=i_TFEn;
endmodule