library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use work.funciones.all;

entity tb_SHD_47bit is
end entity tb_SHD_47bit;

architecture tb_47bit of tb_SHD_47bit is
	component SHD
		generic(
			Wh		:integer		:=  13;	 -- Tamaño de la ventana de hamming
			M		:integer		:= 384;	 -- Ancho de la imagen - Resim genişliği
			D		:integer		:=	64;  -- Disparity level
			Wc		:integer		:=   7
		);
		port(
			i_clk			:in		std_logic;
			i_rst			:in		std_logic;
			i_data_LL		:in		std_logic_vector(Wc**2-2 downto 0);  -- 47 downto 0
			i_data_LH		:in		std_logic_vector(Wc**2-2 downto 0);
			i_data_RL		:in		std_logic_vector(Wc**2-2 downto 0);
			i_data_RH		:in		std_logic_vector(Wc**2-2 downto 0);
			i_dval			:in		std_logic;
			o_dval			:out	std_logic;
			o_data_L		:out	std_logic_vector(log2(D) downto 0);		-- 6 downto 0
			o_data_R		:out	std_logic_vector(log2(D) downto 0)
		);
	end component;

	constant Wh : integer := 13;
	constant M  : integer := 384;
	constant D  : integer := 64;
	constant Wc : integer := 7;
	
	signal clk : std_logic := '1';
	signal rst, i_val, o_val : std_logic;
	signal i_LL, i_LH, i_RL, i_RH : std_logic_vector(Wc**2-2 downto 0);
	signal o_R, o_L  : std_logic_vector(log2(D) downto 0);
	
	file f_data_LL : text open READ_MODE is "i_data_LL.txt";
	file f_data_LH : text open READ_MODE is "i_data_LH.txt";
	file f_data_RL : text open READ_MODE is "i_data_RL.txt";
	file f_data_RH : text open READ_MODE is "i_data_RH.txt";
	file f_val	   : text open READ_MODE is "i_val.txt";
	
begin
	cSHD: SHD
		generic map(Wh,M,D,Wc)
		port map(clk,rst,i_LL,i_LH,i_RL,i_RH,i_val,o_val,o_L,o_R);  

	PCLOCK : process
	begin
		clk <= not(clk); wait for 5 ns;	
	end process PCLOCK;

	DATA: process
		variable line_i_LL : line;
		variable line_i_LH : line;
		variable line_i_RL : line;
		variable line_i_RH : line;
		variable line_i_val: line;
	
		variable v_i_LL: std_logic_vector(47 downto 0);
		variable v_i_LH: std_logic_vector(47 downto 0);
		variable v_i_RL: std_logic_vector(47 downto 0);
		variable v_i_RH: std_logic_vector(47 downto 0);
		variable v_i_val: integer;
		
		variable vv_i_val: std_logic_vector(0 downto 0);
	begin
		rst <= '0'; wait for 50 ns;
		rst <=  '1';
		wait until falling_edge(clk);
			while not endfile(f_data_LL) loop
				readline(f_data_LL, line_i_LL);
				read(line_i_LL, v_i_LL);
				i_LL <= std_logic_vector(v_i_LL);
				
				readline(f_data_LH, line_i_LH);
				read(line_i_LH, v_i_LH);
				i_LH <= std_logic_vector(v_i_LH);
				
				readline(f_data_RL, line_i_RL);
				read(line_i_RL, v_i_RL);
				i_RL <= std_logic_vector(v_i_RL);
				
				readline(f_data_RH, line_i_RH);
				read(line_i_RH, v_i_RH);
				i_RH <= std_logic_vector(v_i_RH);
				
				readline(f_val, line_i_val);
				read(line_i_val, v_i_val);
				vv_i_val := std_logic_vector(to_unsigned(v_i_val,1));
				i_val <= vv_i_val(0);
				
				wait until falling_edge(clk);
			end loop;
			i_val <= '0';
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
			wait until falling_edge(clk);
		report " simulation Ends " severity failure;
		wait;
	end process DATA;



end tb_47bit;