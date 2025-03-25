library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.funciones.all;

entity tb_numOfones_1point is
end entity tb_numOfones_1point;

architecture tb_1bit of tb_numOfones_1point is
	component Num_of_ones
		generic(
				W		:integer		:= 7
				);
		port(
			i_clk	:in			std_logic;
			i_rst	:in			std_logic;
			i_data	:in			std_logic; -- 1-bit
			i_dval	:in			std_logic;
			o_dval	:out		std_logic;
			o_data	:out		std_logic  -- 1-bit
			);	
	end component;

	constant W: integer := 7;
	signal clk : std_logic := '1';
	signal rst, i_val, o_val : std_logic;
	signal i_data : std_logic;
	signal o_data : std_logic;

begin

	NoO: Num_of_ones
		generic map(W)
		port map(clk,rst,i_data,i_val,o_val,o_data);

	PCLOCK : process
	begin
		clk <= not(clk); wait for 5 ns;	
	end process PCLOCK;
	
	DATA: process 
		variable temp: std_logic_vector(1 downto 0);
	begin
		rst <= '0'; wait for 50 ns;
		rst <=  '1';
		wait until rising_edge(clk);

		for i in 1 to 100 loop
			temp := "01" + std_logic_vector(to_unsigned(i,2));
			i_data <= temp(0);
			i_val <= '1';
			wait until rising_edge(clk);
		end loop;
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		wait until falling_edge(clk);
		report " simulation Ends " severity failure;
		wait;
	end process DATA;
	
end tb_1bit;