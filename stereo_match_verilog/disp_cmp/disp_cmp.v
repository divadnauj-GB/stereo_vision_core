module disp_cmp #(
    parameter integer WC = 3,
    parameter integer WH = 7,
    parameter integer D  = 64
) (
    i_data_c1,
    i_data_d1,
    i_data_c2,
    i_data_d2,
    o_data_c,
    o_data_d
);

  localparam integer DBIT = $clog2(D);
  localparam integer CBIT = $clog2(((WC ** 2) / 2) * (WH ** 2));

  input [CBIT-1:0] i_data_c1;
  input [DBIT-1:0] i_data_d1;
  input [CBIT-1:0] i_data_c2;
  input [DBIT-1:0] i_data_d2;

  output [CBIT-1:0] o_data_c;
  output [DBIT-1:0] o_data_d;


  assign o_data_d = i_data_c2 < i_data_c1 ? i_data_d2 : i_data_d1;
  assign o_data_c = i_data_c2 < i_data_c1 ? i_data_c2 : i_data_c1;

endmodule
