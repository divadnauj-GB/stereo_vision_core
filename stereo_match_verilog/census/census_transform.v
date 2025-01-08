/*
||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||7 ||8 ||9 ||10||
||==||==||==||==||==||==||==||==||==||==||==||==||
||0 ||  ||XX||	 ||XX||  ||XX||  ||XX||	 ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
||1 ||XX||  ||XX||  ||XX||	 ||XX||  ||XX||  ||XX||
||==||==||==||==||==||==||==||==||==||==||==||==||
||2 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
||3 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
||==||==||==||==||==||==||==||==||==||==||==||==||
||4 ||  ||XX||  ||XX||  ||XX||  ||XX||	 ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
||5 ||XX||  ||XX||  ||XX||OO||XX||  ||XX||  ||XX||
||==||==||==||==||==||==||==||==||==||==||==||==||
||6 ||  ||XX||	 ||XX||  ||XX||  ||XX||	 ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
||7 ||XX||  ||XX||  ||XX||	 ||XX||  ||XX||  ||XX||
||==||==||==||==||==||==||==||==||==||==||==||==||
||8 ||  ||XX||	 ||XX||  ||XX||  ||XX||	 ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
||9 ||XX||  ||XX||  ||XX||	 ||XX||  ||XX||  ||XX||
||==||==||==||==||==||==||==||==||==||==||==||==||
||10||  ||XX||	 ||XX||  ||XX||  ||XX||	 ||XX||  ||
||==||==||==||==||==||==||==||==||==||==||==||==||
*/


module census_transform #(
    parameter integer WC = 7,
    parameter integer WH = 13,
    parameter integer M  = 450,
    parameter integer N  = 8
) (
    i_clk,
    i_rstn,
    i_data,
    i_dval,
    o_dval,
    o_data_l,
    o_data_h
);

  localparam integer WT = (WC + WH);
  localparam integer TOTAL_LAT=(((WC-1)*M+(WC-1))/2)+1; //slide window latency + window operaition latency
  integer i;
  integer j;

  input i_clk;
  input i_rstn;
  input [N-1:0] i_data;
  input i_dval;
  output o_dval;
  output [((WC**2)/2)-1:0] o_data_l;
  output [((WC**2)/2)-1:0] o_data_h;


  reg [((WC**2)/2)-1:0] o_data_l;
  reg [((WC**2)/2)-1:0] o_data_h;
  reg o_dval;


  reg [N-1:0] slide_window[0:(WT-1)][0:(M-1)];

  /*This process generates the rowbuffer (register based only) for slinding window*/
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      for (i = 0; i < WT; i = i + 1) begin
        for (j = 0; j < M; j = j + 1) begin
          slide_window[i][j] <= {N{1'b0}};
        end
      end
    end else if (i_dval) begin
      slide_window[0][0] <= i_data;
      for (i = 0; i < WT; i = i + 1) begin
        for (j = 0; j < M - 1; j = j + 1) begin
          slide_window[i][j+1] <= slide_window[i][j];
        end
      end
      for (i = 1; i < WT; i = i + 1) begin
        slide_window[i][0] <= slide_window[i-1][M-1];
      end
    end
  end


  /*Implementation of the Census tranform on the lower window*/
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_data_l <= {((WC ** 2) / 2) {1'b0}};
    end else if (i_dval) begin
      for (i = 0; i <= (WC - 1) / 2; i = i + 1) begin
        for (j = 0; j < (WC - 1) / 2; j = j + 1) begin
          if (slide_window[(2*i)][(2*j+1)] > slide_window[(WC-1)/2][(WC-1)/2])
            o_data_l[((WC**2)/2-1)-(((WC*2*i)+2*j+1)/2)] <= 1'b0;
          else o_data_l[((WC**2)/2-1)-(((WC*2*i)+2*j+1)/2)] <= 1'b1;
        end
      end

      for (i = 0; i < (WC - 1) / 2; i = i + 1) begin
        for (j = 0; j <= (WC - 1) / 2; j = j + 1) begin
          if (slide_window[(2*i+1)][(2*j)] > slide_window[(WC-1)/2][(WC-1)/2])
            o_data_l[((WC**2)/2-1)-(((WC*(2*i+1))+2*j)/2)] <= 1'b0;
          else o_data_l[((WC**2)/2-1)-(((WC*(2*i+1))+2*j)/2)] <= 1'b1;
        end
      end
    end
  end


  /*Implementation of the Census tranform on the upper window*/
  always @(posedge i_clk, negedge i_rstn) begin
    if (!i_rstn) begin
      o_data_h <= {((WC ** 2) / 2) {1'b0}};
    end else if (i_dval) begin
      for (i = 0; i <= (WC - 1) / 2; i = i + 1) begin
        for (j = 0; j < (WC - 1) / 2; j = j + 1) begin
          if (slide_window[(2*i+WT-WC)][(2*j+1)] > slide_window[(WT-WC)+((WC-1)/2)][(WC-1)/2])
            o_data_h[((WC**2)/2-1)-(((WC*2*i)+2*j+1)/2)] <= 1'b0;
          else o_data_h[((WC**2)/2-1)-(((WC*2*i)+2*j+1)/2)] <= 1'b1;
        end
      end

      for (i = 0; i < (WC - 1) / 2; i = i + 1) begin
        for (j = 0; j <= (WC - 1) / 2; j = j + 1) begin
          if (slide_window[(2*i+1+WT-WC)][(2*j)] > slide_window[(WT-WC)+((WC-1)/2)][(WC-1)/2])
            o_data_h[((WC**2)/2-1)-(((WC*(2*i+1))+2*j)/2)] <= 1'b0;
          else o_data_h[((WC**2)/2-1)-(((WC*(2*i+1))+2*j)/2)] <= 1'b1;
        end
      end
    end
  end


  /*This always process handle the valid signal generation*/

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
