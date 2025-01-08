

module window_SHD #(
    parameter integer WC = 7,
    parameter integer WH = 13,
    parameter integer M  = 650
) (
    i_clk,
    i_rstn,
    i_data_l,
    i_data_h,
    i_dval,
    o_dval,
    o_data
);


  localparam integer NIBIT = $clog2((WC ** 2) / 2);
  localparam integer NOBIT = $clog2(((WC ** 2) / 2) * (WH ** 2));
  //localparam integer TOTAL_LAT=(((WH+1)*(M+1))/2-M+3);
  localparam integer TOTAL_LAT = ((WH - 1) * M + (WH - 1)) / 2 + 4;


  input i_clk;
  input i_rstn;
  input [NIBIT-1:0] i_data_l;
  input [NIBIT-1:0] i_data_h;
  input i_dval;
  output reg o_dval;
  output [NOBIT-1:0] o_data;

  integer i;
  integer j;

  reg signed [NOBIT-1:0] s_col_line[0:M-1];
  reg signed [NOBIT-1:0] s_row_win[0:WH-1];

  reg signed [NIBIT:0] s_input_col;
  reg signed [NIBIT:0] s_input_col_w;
  reg signed [NIBIT:0] s_tab_1;
  reg signed [NOBIT-1:0] s_tab_2;
  reg signed [NOBIT-1:0] s_tab_3;
  reg signed [NOBIT-1:0] s_tab_4;
  wire signed [NOBIT-1:0] s_tmp_add_1;


  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_input_col <= 0;
      s_input_col_w <= 0;
      s_tab_1 <= 0;
    end else if (i_dval) begin
      s_input_col <= {1'b0, i_data_l};
      s_input_col_w <= {1'b0, i_data_h};
      s_tab_1 <= $signed(s_input_col) - $signed(s_input_col_w);
    end
  end

  //s_tmp_add_1	<=	to_integer(unsigned(s_col_line(M-1)))+to_integer(to_signed(s_tab_1,log2(Wh*(Wc**2)/2)+1));

  assign s_tmp_add_1 = $signed(s_col_line[M-1]) + $signed({{(NOBIT - NIBIT - 1) {s_tab_1[NIBIT]}}, s_tab_1});

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) s_tab_2 <= 0;
    else if (i_dval) s_tab_2 <= s_tmp_add_1;
  end


  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) s_tab_3 <= 0;
    else if (i_dval) s_tab_3 <= $signed(s_tab_2) - $signed(s_row_win[WH-1]);
  end

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) s_tab_4 <= 0;
    else if (i_dval) s_tab_4 <= $signed(s_tab_3) + $signed(s_tab_4);
  end


  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < M; i=i+1) begin
        s_col_line[i] <= 0;
      end
      for (j = 0; j < M; j=j+1) begin
        s_row_win[j] <= 0;
      end
    end else if (i_dval) begin
      for (i = 0; i < M; i=i+1) begin
        if (i == 0) s_col_line[i] <= s_tmp_add_1;
        else s_col_line[i] <= s_col_line[i-1];
      end
      for (j = 0; j < WH; j=j+1) begin
        if (j == 0) s_row_win[j] <= s_tab_2;
        else s_row_win[j] <= s_row_win[j-1];
      end
    end
  end

  assign o_data = s_tab_4;


  reg [31:0] counter;
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      counter <= 0;
      o_dval  <= 1'b0;
    end else if (i_dval) begin
      if (counter < TOTAL_LAT) begin
        counter <= counter + 1;
        o_dval  <= 1'b0;
      end else o_dval <= 1'b1;
    end else o_dval <= 1'b0;
  end

endmodule
