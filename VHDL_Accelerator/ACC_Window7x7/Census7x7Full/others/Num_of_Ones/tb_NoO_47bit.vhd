
library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use 	work.funciones.all;

entity tb_numOfones_47bit is
end entity tb_numOfones_47bit;

architecture tb_47bit of tb_numOfones_47bit is
	component Num_of_ones
		generic(
				W		:integer		:= 7
				);
		port(
			i_clk	:in			std_logic;
			i_rst	:in			std_logic;
			i_data	:in			std_logic_vector(W**2-2 downto 0); -- 47 downto 0
			i_dval	:in			std_logic;
			o_dval	:out		std_logic;
			o_data	:out		std_logic_vector(log2(W**2) downto 0) --  6 downto 0
			);	
	end component;

	constant W: integer := 7;
	signal clk : std_logic := '1';
	signal rst, i_val, o_val : std_logic;
	signal i_data : std_logic_vector(W**2-2 downto 0);
	signal o_data : std_logic_vector(log2(W**2) downto 0);

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
			i_data <= std_logic_vector(to_unsigned(i, W**2-1));
			i_val <= '1';
			wait until falling_edge(clk);
		end loop;
		i_data <= x"FFFFFFFFFFFF";
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
	
end tb_47bit;