library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

entity tb_census4point is
end entity tb_census4point;

architecture tb_4p of tb_census4point is
	component Census_Transform
		generic(
			Wc		:integer		:= 3;	
			Wh		:integer		:= 5;	
			M		:integer		:= 50;	
			N		:integer		:= 8	
		);
		port(
			i_clk		:in		std_logic;
		    i_rst		:in		std_logic;
		    i_data		:in		std_logic_vector(N-1 downto 0);
		    i_dval		:in		std_logic;
		    o_dval		:out	std_logic;
		    o_data_L	:out	std_logic_vector(3 downto 0);	
		    o_data_H	:out	std_logic_vector(3 downto 0)
		);
	end component;

	constant Wc	:integer:= 9;	
	constant Wh	:integer:= 13;	
	constant M	:integer:= 9;	
    constant N	:integer:= 8;	
	signal rst,i_valid,o_valid: std_logic;
	signal clk: std_logic := '0';
	signal i_data:std_logic_vector(N-1 downto 0);
	signal o_data_L, o_data_H: std_logic_vector(3 downto 0);
	file vec_left 		: text open READ_MODE is "input_vector_left_image.txt";
	file vec_Valid_i	: TEXT OPEN READ_MODE is "input_vector_valid.txt";
begin

	CT: Census_Transform
		generic map(Wc,Wh,M,N)
		port map(clk,rst,i_data,i_valid,o_valid,o_data_L,o_data_H);

	process begin
		rst <= '0'; wait for 50 ns;
		rst <=  '1'; 
		wait;
	end process;
	
	process 
		variable Vect_Line_Data_in_L :line;
		variable Vect_Line_Valid_in	 :line;
		variable data_i_L			:integer;
		variable valid_i			 :integer;
		variable valid_vi		:std_logic_vector(0 downto 0);
	begin
		wait for 200 ns;
		wait until falling_edge(clk);
		while not endfile (vec_left) loop
			readline(vec_left, Vect_Line_Data_in_L);
			read(Vect_Line_Data_in_L,data_i_L);
		
			readline(vec_Valid_i, Vect_Line_Valid_in);
			read(Vect_Line_Valid_in,valid_i);
			
			i_data			<=	std_logic_vector(to_unsigned(data_i_L,8));

			valid_vi		:=	std_logic_vector(to_unsigned(valid_i,1));
			i_valid			<=	valid_vi(0);
			wait until falling_edge(clk);
		end loop;
		report " simulation Ends " severity failure;
		wait;
	end process;
	
	
	PCLOCK : process
	begin
		clk <= not(clk); wait for 5 ns;	
	end process;
end tb_4p;