

library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use 	work.funciones.all;

entity tb_numOfones_12point is
end entity tb_numOfones_12point;

architecture tb_12bit of tb_numOfones_12point is
	component Num_of_ones
		generic(
				W		:integer		:= 7
				);
		port(
			i_clk	:in			std_logic;
			i_rst	:in			std_logic;
			i_data	:in			std_logic_vector(19 downto 0); -- 16-bit
			i_dval	:in			std_logic;
			o_dval	:out		std_logic;
			o_data	:out		std_logic_vector(4 downto 0) --  4 downto 0
			);	
	end component;

	constant W: integer := 7;
	signal clk : std_logic := '1';
	signal rst, i_val, o_val : std_logic;
	signal i_data : std_logic_vector(19 downto 0);
	signal o_data : std_logic_vector(4 downto 0);

begin

	NoO: Num_of_ones
		generic map(W)
		port map(clk,rst,i_data,i_val,o_val,o_data);

	PCLOCK : process
	begin
		clk <= not(clk); wait for 5 ns;	
	end process PCLOCK;
	
	DATA: process begin
		rst <= '0'; wait for 50 ns;
		rst <=  '1';
		wait until falling_edge(clk);

		for i in 279 to 5000 loop
			i_data <= std_logic_vector(to_unsigned(i, 20));
			i_val <= '1';
			wait until rising_edge(clk);
		end loop;
		i_data <= x"FFFFF";
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		i_val <= '0';
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		report " simulation Ends " severity failure;
		wait;
	end process DATA;
	
end tb_12bit;