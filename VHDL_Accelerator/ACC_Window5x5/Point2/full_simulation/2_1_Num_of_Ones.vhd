library ieee;
use	ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.funciones.all;

entity Num_of_ones is
generic(
		W		:integer		:= 7
		);
port(
	i_clk	:in			std_logic;
	i_rst	:in			std_logic;
	i_data	:in			std_logic_vector(1  downto 0); -- 2-bit
	i_dval	:in			std_logic;
	o_dval	:out		std_logic;
	o_data	:out		std_logic_vector(log2(2) downto 0) -- 1 downto 0 = 2-bit
	);
end entity Num_of_ones;


architecture RTL of Num_of_ones is

signal	sum, s_input  :std_logic_vector(1 downto 0);

begin
--===========================================================================================
--			Implementacion urilizando for-generate y process
--===========================================================================================
process(i_clk,i_rst)
variable counter 	:integer range 0 to 1;  
variable v_valid	:std_logic;
begin	
	if i_rst='0' then
		counter	:= 0;
		v_valid	:=	'0';
		o_dval	<=	'0';
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (counter < 1) then
				counter	:=	counter +1;
				v_valid	:=	'0';
			else
				counter:=	counter;
				v_valid	:=	'1';
			end if;
			o_dval	<=	v_valid;
		else
			o_dval	<=	'0';
		end if;
	end if;
end process;

--===========================================================================================
--			Implementacion urilizando for-loop dentro de un process
--===========================================================================================
-- Similarity Module Architecture: XOR operation outputlarını input olarak alıyor ve HD outputunu üretiyor.
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_input		<=	(others=>'0');
		sum			<=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			s_input	<=	i_data;
		--  ********************************************
			sum <= ('0' & s_input(1)) + ('0' & s_input(0));
		end if;
	end if;
end process;
-- HD burada		
o_data	<=	sum; -- 2-bit

end RTL;
