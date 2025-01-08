module stereo_match #(
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

  /*Localparameter definitions*/
  localparam integer DBIT=$clog2(D);
  localparam integer CBIT=$clog2(((WC ** 2) / 2) * (WH ** 2));

  /*port size and directions definitions*/
  input i_clk;
  input i_rstn;
  input [N-1:0] i_data_l;
  input [N-1:0] i_data_r;
  input i_dval;
  input [DBIT-1:0] i_thresh_lrcc;
  output o_dval;
  output [DBIT-1:0] o_data;

  /*Loop variables definitions*/

  integer i;

  /*wire/reg definitions*/

  wire s_val_census_left;
  wire s_val_census_right;
  wire s_val_census;
  wire [((WC**2)/2)-1:0] s_data_census_left_l;
  wire [((WC**2)/2)-1:0] s_data_census_left_h;
  wire [((WC**2)/2)-1:0] s_data_census_right_l;
  wire [((WC**2)/2)-1:0] s_data_census_right_h;


  wire [D-1:0] s_valid_W;
  reg [2*D-1:0] s_valid_In;
  //reg [2*D-1:0] s_valid_InH;


  reg [((WC**2)/2)-1:0] Slide_Window_LL[D-1:0];
  reg [((WC**2)/2)-1:0] Slide_Window_LH[D-1:0];
  reg [((WC**2)/2)-1:0] Slide_Window_RL[2*D-1:0];
  reg [((WC**2)/2)-1:0] Slide_Window_RH[2*D-1:0];

  wire [CBIT-1:0] s_sum_W[D-1:0];

  reg [DBIT-1:0] disp_R2L[0:D-1][0:1];
  reg [CBIT-1:0] cost_R2L[0:D-1][0:1];
  wire [DBIT-1:0] cmp_disp_R2L[0:D-1];
  wire [CBIT-1:0] cmp_cost_R2L[0:D-1];

  reg [DBIT-1:0] disp_L2R[0:D-1];
  reg [CBIT-1:0] cost_L2R[0:D-1];
  wire [DBIT-1:0] cmp_disp_L2R[0:D-1];
  wire [CBIT-1:0] cmp_cost_L2R[0:D-1];

  reg [DBIT-1:0] delay_reg[0:D-1];

  reg [DBIT-1:0] s_data_R;
  reg [DBIT-1:0] s_data_L;
  reg s_valid_lrcc;
  reg s_global_valid;

  /*Main hardware body description*/

  census_transform #(
      .WC(WC),
      .WH(WH),
      .M (M),
      .N (N)
  ) census_left (
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_data(i_data_l),
      .i_dval(i_dval),
      .o_dval(s_val_census_left),
      .o_data_l(s_data_census_left_l),
      .o_data_h(s_data_census_left_h)
  );

  census_transform #(
      .WC(WC),
      .WH(WH),
      .M (M),
      .N (N)
  ) census_right (
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_data(i_data_r),
      .i_dval(i_dval),
      .o_dval(s_val_census_right),
      .o_data_l(s_data_census_right_l),
      .o_data_h(s_data_census_right_h)
  );


  genvar gk;
  generate
    for (gk = 0; gk < D; gk = gk + 1) begin : smlrty_mod
      similarity_module #(
          .WC(WC),
          .WH(WH),
          .M (M)
      ) smlrty_mod (
          .i_clk(i_clk),
          .i_rstn(i_rstn),
          .i_data_ll(Slide_Window_LL[gk]),
          .i_data_lh(Slide_Window_LH[gk]),
          .i_data_rl(Slide_Window_RL[2*gk]),
          .i_data_rh(Slide_Window_RH[2*gk]),
          .i_dval(s_global_valid&s_valid_In[2*gk]),
          .o_dval(s_valid_W[gk]),
          .o_data(s_sum_W[gk])
      );
    end
  endgenerate


  generate
    for (gk = 1; gk < D; gk = gk + 1) begin : cmp_mod_R2L
      disp_cmp #(
          .WC(WC),
          .WH(WH),
          .D (D)
      ) cmp_mod_R2L (
          .i_data_c1(cost_R2L[gk-1][1]),
          .i_data_d1(disp_R2L[gk-1][1]),
          .i_data_c2(s_sum_W[gk]),
          .i_data_d2(gk[DBIT-1:0]),
          .o_data_c (cmp_cost_R2L[gk]),
          .o_data_d (cmp_disp_R2L[gk])
      );
    end
  endgenerate

  generate
    for (gk = 1; gk < D; gk = gk + 1) begin : cmp_mod_L2R
      disp_cmp #(
          .WC(WC),
          .WH(WH),
          .D (D)
      ) cmp_mod_L2R (
          .i_data_c1(cost_L2R[gk-1]),
          .i_data_d1(disp_L2R[gk-1]),
          .i_data_c2(s_sum_W[gk]),
          .i_data_d2(gk[DBIT-1:0]),
          .o_data_c (cmp_cost_L2R[gk]),
          .o_data_d (cmp_disp_L2R[gk])
      );
    end
  endgenerate


  lrcc #(
      .D(D)
  ) lrcc_inst (
      .i_clk(i_clk),
      .i_rstn(i_rstn),
      .i_data_l(s_data_L),
      .i_data_r(s_data_R),
      .i_dval(s_valid_lrcc),
      .i_thresh_lrcc(i_thresh_lrcc),
      .o_dval(o_dval),
      .o_data_lrcc(o_data)
  );

  assign s_val_census = s_val_census_left & s_val_census_right;


  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < D; i = i + 1) begin
        Slide_Window_LL[i] <= {((WC ** 2) / 2) {1'b0}};
        Slide_Window_LH[i] <= {((WC ** 2) / 2) {1'b0}};
      end
    end else if (s_val_census) begin
      for (i = 0; i < D; i = i + 1) begin
        if (i == 0) begin
          Slide_Window_LL[i] <= s_data_census_left_l;
          Slide_Window_LH[i] <= s_data_census_left_h;
        end else begin
          Slide_Window_LL[i] <= Slide_Window_LL[i-1];
          Slide_Window_LH[i] <= Slide_Window_LH[i-1];
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < 2 * D; i = i + 1) begin
        Slide_Window_RL[i] <= {((WC ** 2) / 2) {1'b0}};
        Slide_Window_RH[i] <= {((WC ** 2) / 2) {1'b0}};
      end
    end else if (s_val_census) begin
      for (i = 0; i < 2 * D; i = i + 1) begin
        if (i == 0) begin
          Slide_Window_RL[i] <= s_data_census_right_l;
          Slide_Window_RH[i] <= s_data_census_right_h;
        end else begin
          Slide_Window_RL[i] <= Slide_Window_RL[i-1];
          Slide_Window_RH[i] <= Slide_Window_RH[i-1];
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_valid_In <= {2 * D{1'b0}};
      s_global_valid <= 0;
    end else if (s_val_census) begin
      s_valid_In <= {s_valid_In[2*D-2:0], 1'b1};
      s_global_valid <= 1;
    end else begin
      s_global_valid <= 0;
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < D; i = i + 1) begin
        cost_R2L[i][0] <= {CBIT {1'b0}};
        cost_R2L[i][1] <= {CBIT {1'b0}};
        disp_R2L[i][0] <= 0;
        disp_R2L[i][1] <= 0;
      end
    end else begin
      for (i = 0; i < D; i = i + 1) begin
        if (i == 0) begin
          if (s_valid_W[i]) begin
            cost_R2L[i][0] <= s_sum_W[i];
            cost_R2L[i][1] <= cost_R2L[i][0];
            disp_R2L[i][0] <= 0;
            disp_R2L[i][1] <= disp_R2L[i][0];
          end
        end else begin
          if (s_valid_W[i]) begin
            cost_R2L[i][0] <= cmp_cost_R2L[i];
            cost_R2L[i][1] <= cost_R2L[i][0];
            disp_R2L[i][0] <= cmp_disp_R2L[i];
            disp_R2L[i][1] <= disp_R2L[i][0];
          end
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < D; i = i + 1) begin
        cost_L2R[i] <= {CBIT {1'b0}};
        disp_L2R[i] <= 0;
      end
    end else begin
      for (i = 0; i < D; i = i + 1) begin
        if (i == 0) begin
          if (s_valid_W[i]) begin
            cost_L2R[i] <= s_sum_W[i];
            disp_L2R[i] <= 0;
          end
        end else begin
          if (s_valid_W[i]) begin
            cost_L2R[i] <= cmp_cost_L2R[i];
            disp_L2R[i] <= cmp_disp_L2R[i];
          end
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < D; i = i + 1) begin
        delay_reg[i] <= 0;
      end
    end else if (s_valid_W[D-1]) begin
      for (i = 0; i < D; i = i + 1) begin
        if (i == 0) begin
          delay_reg[i] <= cmp_disp_L2R[D-1];
        end else begin
          delay_reg[i] <= delay_reg[i-1];
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_valid_lrcc <= 0;
      s_data_L <= 0;
      s_data_R <= 0;
    end else begin
      s_valid_lrcc <= s_valid_W[D-1];
      s_data_L <= delay_reg[D-1];
      s_data_R <= cmp_disp_R2L[D-1];
    end
  end

endmodule
