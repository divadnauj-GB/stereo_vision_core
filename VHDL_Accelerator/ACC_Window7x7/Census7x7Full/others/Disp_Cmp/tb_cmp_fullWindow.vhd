library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use work.funciones.all;

entity tb_Disp_Cmp_14bit is
end entity tb_Disp_Cmp_14bit;

architecture tb_14bitCMP of tb_Disp_Cmp_14bit is
	component Disp_Cmp
		generic(
			Wh		:integer		:= 3;	-- Tamaño de la ventana de hamming
			D		:integer		:=	5;
			Wc		:integer		:= 3
		);
		port(
			i_data_C1	:in		std_logic_vector(log2(((Wc**2))*(Wh**2)) downto 0);	-- 13 downto 0 = 14-bit
			i_data_D1	:in		std_logic_vector(log2(D) downto 0);
			i_data_C2	:in		std_logic_vector(log2(((Wc**2))*(Wh**2)) downto 0);
			i_data_D2	:in		std_logic_vector(log2(D) downto 0);
			
			o_data_C	:out	std_logic_vector(log2(((Wc**2))*(Wh**2)) downto 0);
			o_data_D	:out	std_logic_vector(log2(D) downto 0)	-- 6 downto 0
		);	
	end component;

	signal i_data_C1, i_data_C2, o_data_C: std_logic_vector(13 downto 0) := "10101010101010";
	signal i_data_D1, i_data_D2, o_data_D: std_logic_vector(6 downto 0) := "1111111"; 

	file f_data_C1 : text open READ_MODE is "i_data_C1_14bit.txt";
	file f_data_C2 : text open READ_MODE is "i_data_C2_14bit.txt";
	file f_data_D1 : text open READ_MODE is "i_data_D1_7bit.txt";
	file f_data_D2 : text open READ_MODE is "i_data_D2_7bit.txt";

begin
	CMP: Disp_Cmp
		generic map(13,64,7)
		port map(i_data_C1,i_data_D1,i_data_C2,i_data_D2,o_data_C,o_data_D);


	process 
		variable line_data_C1 : line;
		variable line_data_C2 : line;
		variable line_data_D1 : line;
		variable line_data_D2 : line;
	
		variable v_i_C1 : integer;
		variable v_i_C2 : integer;
		variable v_i_D1 : integer;
		variable v_i_D2 : integer;
	
	begin
		wait for 20 ns;
		
		while not endfile(f_data_C1) loop
		-- Read C1
			readline(f_data_C1, line_data_C1);
			read(line_data_C1, v_i_C1);
			i_data_C1 <= std_logic_vector(to_unsigned(v_i_C1,14));
		-- Read C2
			readline(f_data_C2, line_data_C2);
			read(line_data_C2, v_i_C2);
			i_data_C2 <= std_logic_vector(to_unsigned(v_i_C2,14));
		-- Read D1
			readline(f_data_D1, line_data_D1);
			read(line_data_D1, v_i_D1);
			i_data_D1 <= std_logic_vector(to_unsigned(v_i_D1,7));
		-- Read D2
			readline(f_data_D2, line_data_D2);
			read(line_data_D2, v_i_D2);
			i_data_D2 <= std_logic_vector(to_unsigned(v_i_D2,7));	
			
			wait for 10 ns;
		end loop;
		report " simulation Ends " severity failure;
		wait;	
	end process;

end tb_14bitCMP;







