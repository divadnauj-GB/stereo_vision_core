module num_ones #(
    parameter integer WC = 7
) (
    i_clk,
    i_rstn,
    i_data,
    i_dval,
    o_dval,
    o_data
);


  localparam integer NIBIT = (WC ** 2) / 2;
  localparam integer NSTAGES = $clog2(NIBIT);
  localparam integer NOPS = 2 ** NSTAGES;
  localparam integer NOBIT = NSTAGES;
  localparam integer total_lat = NSTAGES+1;


  input i_clk;
  input i_rstn;
  input [NIBIT-1:0] i_data;
  input i_dval;
  output reg o_dval;
  output [NOBIT-1:0] o_data;

  reg [NOBIT-1:0] sum[0:NSTAGES-1][0:NOPS-1];
  reg [NOBIT-1:0] sum1[0:NSTAGES-1][0:NOPS-1];

  reg [NOPS-1:0] s_input;



  genvar i;
  genvar j;
  generate
    for (i = 0; i < NSTAGES; i = i + 1) begin : Row
      for (j = 0; j < (NOPS / (2 ** (i+1))); j = j + 1) begin : Col
        if (i == 0) begin : Input
          always @(*) begin
            sum1[i][j] = ({{(NOBIT-1){1'b0}},s_input[2*j]})+({{(NOBIT-1){1'b0}},s_input[2*j+1]});
          end
        end else begin : Tree
          always @(*) begin
            sum1[i][j] = sum[i-1][2*j] + sum[i-1][2*j+1];
          end
        end
      end
    end
  endgenerate

  integer ii;
  integer jj;
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      s_input <= 0;
      for (ii = 0; ii < NSTAGES; ii = ii + 1) begin
        for (jj = 0; jj < (NOPS / (2 ** (ii+1))); jj = jj + 1) begin
          sum[ii][jj] <= 0;
        end
      end
    end else if (i_dval) begin
      s_input[NIBIT-1:0] <= i_data;
      for (ii = 0; ii < NSTAGES; ii = ii + 1) begin
        for (jj = 0; jj < (NOPS / (2 ** (ii+1))); jj = jj + 1) begin
          sum[ii][jj] <= sum1[ii][jj];
        end
      end
    end
  end

  assign o_data = sum[NSTAGES-1][0];

  reg [31:0] counter;

  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      counter <= 0;
      o_dval  <= 1'b0;
    end else if (i_dval) begin
      if (counter < total_lat) begin
        counter <= counter + 1;
        o_dval  <= 1'b0;
      end else o_dval <= 1'b1;
    end else o_dval <= 1'b0;
  end

endmodule
