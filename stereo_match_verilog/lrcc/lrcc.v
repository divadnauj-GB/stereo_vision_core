module lrcc #(
    parameter integer D = 64
) (
    i_clk,
    i_rstn,
    i_data_l,
    i_data_r,
    i_dval,
    i_thresh_lrcc,
    o_dval,
    o_data_lrcc
);

  localparam integer NBIT = $clog2(D);

  input i_clk;
  input i_rstn;
  input [NBIT-1:0] i_data_l;
  input [NBIT-1:0] i_data_r;
  input i_dval;
  input [NBIT-1:0] i_thresh_lrcc;
  output reg o_dval;
  output reg [NBIT-1:0] o_data_lrcc;

  integer i;

  reg [NBIT-1:0] s_taps_R2L[0:D-1];
  reg [NBIT-1:0] s_taps_L2R;

  reg [NBIT-1:0] s_selector;
  reg [NBIT-1:0] s_tap1;
  reg [NBIT-1:0] s_tap2;
  reg [NBIT-1:0] s_tap3;

  reg [NBIT:0] s_sub;

  reg [NBIT:0] s_abs;

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < D; i = i + 1) begin
        s_taps_R2L[i] <= {NBIT{1'b0}};
      end
    end else begin
      if (i_dval) begin
        for (i = 0; i < D; i = i + 1) begin
          if (i == 0) begin
            s_taps_R2L[i] <= i_data_r;
          end else begin
            s_taps_R2L[i] <= s_taps_R2L[i-1];
          end
        end
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_taps_L2R <= {NBIT{1'b0}};
    end else begin
      if (i_dval) begin
        s_taps_L2R <= i_data_l;
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_selector <= 0;
      s_tap1 <= 0;
    end else begin
      if (i_dval) begin
        s_selector <= s_taps_L2R;
        s_tap1 <= s_taps_R2L[s_taps_L2R];
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_sub  <= 0;
      s_tap2 <= 0;
    end else begin
      if (i_dval) begin
        s_tap2 <= s_tap1;
        s_sub  <= $signed({1'b0, s_tap1}) - $signed({1'b0, s_selector});
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_abs  <= 0;
      s_tap3 <= 0;
    end else begin
      if (i_dval) begin
        s_abs  <= ($signed(s_sub)<0) ? -s_sub : s_sub;
        s_tap3 <= s_tap2;
      end
    end
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_data_lrcc <= 0;
    end else begin
      if (i_dval) begin
        if (s_abs < {1'b0, i_thresh_lrcc}) begin
          o_data_lrcc <= s_tap3;
        end else begin
          o_data_lrcc <= 0;
        end
      end
    end
  end

  reg [31:0] counter;

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      counter <= 0;
      o_dval  <= 1'b0;
    end else if (i_dval) begin
      if (counter < 4) begin
        counter <= counter + 1;
        o_dval  <= 1'b0;
      end else o_dval <= 1'b1;
    end else o_dval <= 1'b0;
  end

endmodule
