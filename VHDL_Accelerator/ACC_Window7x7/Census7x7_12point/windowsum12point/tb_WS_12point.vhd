library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use work.funciones.all;

entity tb_WindowSum_12point is
end entity tb_WindowSum_12point;

architecture tb_ws12point of tb_WindowSum_12point is
	component Window_sum
		generic(
			Wh		:integer		:= 13;	-- Tamaño de la ventana de hamming -> 13
			M		:integer		:= 384;	-- Ancho de la imagen - Resim genişliği -> 384
			Wc		:integer		:= 7  
		);
		port(
			i_clk		:in		std_logic;
			i_rst		:in		std_logic;
			i_data_L	:in		std_logic_vector(log2(12) downto 0);	 -- 3-0 = 4-bit
			i_data_H	:in		std_logic_vector(log2(12) downto 0);  	 -- 3-0 = 4-bit
			i_dval		:in		std_logic;
			o_dval	:out		std_logic;
			o_data	:out		std_logic_vector(11 downto 0)	-- 12-bit
		);
	end component;

	constant Wh : integer := 13;
	constant Wc : integer := 7;
	constant M  : integer := 384;
	signal clk : std_logic := '1';
	signal rst, i_val, o_val : std_logic;
	signal i_data_L, i_data_H : std_logic_vector(3 downto 0);
	signal o_data : std_logic_vector(11 downto 0);
	
	file f_data_L : text open READ_MODE is "i_data4bit_L.txt";
	file f_data_H : text open READ_MODE is "i_data4bit_H.txt";
	file f_val_in : text open READ_MODE is "i_valid.txt";
	
	file f_data_o : text open WRITE_MODE is "o_data12bit.txt";
	file f_val_o  : text open WRITE_MODE is "o_val.txt";
begin
	WS: Window_sum
		generic map(Wh,M,Wc)
		port map(clk,rst,i_data_L,i_data_H,i_val,o_val,o_data);
	
	
	PCLOCK : process
	begin
		clk <= not(clk); wait for 5 ns;	
	end process PCLOCK;
	
	DATA: process 
		variable line_data_L : line;
		variable line_data_H : line;
		variable line_val_in : line;
		variable line_data_out : line;
		variable line_val_out  : line;
		
		variable v_i_data_L  : integer;
		variable v_i_data_H  : integer;
		variable v_i_val     : integer;

		variable v_o_data : integer;
		variable v_o_val  : integer;
		variable valid_vi :std_logic_vector(0 downto 0);
		variable valid_vo :std_logic_vector(0 downto 0);
	begin
		rst <= '0'; wait for 50 ns;
		rst <=  '1';
		wait until falling_edge(clk);
			while not endfile(f_data_L) loop
			-- READ DATA_L
				readline(f_data_L, line_data_L);
				read(line_data_L,v_i_data_L);
				i_data_L <= std_logic_vector(to_unsigned(v_i_data_L,4));
			-- READ DATA_H	
				readline(f_data_H, line_data_H);
				read(line_data_H,v_i_data_H);
				i_data_H <= std_logic_vector(to_unsigned(v_i_data_H,4));
			-- READ VALID
				readline(f_val_in, line_val_in);
				read(line_val_in,v_i_val);
				valid_vi := std_logic_vector(to_unsigned(v_i_val,1));
				i_val  <= valid_vi(0);
				wait until falling_edge(clk);
			-- WRITE OUT DATA
				v_o_data := to_integer(unsigned(o_data));
				write(line_data_out, v_o_data);
				writeline(f_data_o, line_data_out);
			-- WRITE OUT VALID
				valid_vo(0) := o_val;
				v_o_val     := to_integer(unsigned(valid_vo));
				write(line_val_out, v_o_val);
				writeline(f_val_o, line_val_out);
			end loop;
		report " simulation Ends " severity failure;
		wait;
	end process DATA;

end tb_ws12point;