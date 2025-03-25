library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use 	work.funciones.all;

entity Num_of_ones is
generic(
		W		:integer		:= 7
		);
port(
	i_clk	:in			std_logic;
	i_rst	:in			std_logic;
	i_data	:in			std_logic_vector(15  downto 0); -- 16-bit
	i_dval	:in			std_logic;
	o_dval	:out		std_logic;
	o_data	:out		std_logic_vector(log2(16) downto 0) -- 4 downto 0
	);
end entity Num_of_ones;


architecture RTL of Num_of_ones is
constant		Q		:integer		:= 16;		-- input bit number
constant		K		:integer		:= Q/2;		-- 8
constant		LOGK	:integer		:=log2(Q);	-- 4

type Pyramid is array(0 to LOGK-1,0 to K-1) of integer;

signal	s_input	:std_logic_vector(Q-1 downto 0);	--  15 downto 0
signal	sum		:Pyramid	:=(others=>(others=>0));

begin
--===========================================================================================
--			Implementacion urilizando for-generate y process
--===========================================================================================
process(i_clk,i_rst)
variable counter 	:integer range 0 to LOGK+1;  -- 0dan 5ya
variable v_valid	:std_logic;
begin	
	if i_rst='0' then
		counter	:= 0;
		v_valid	:=	'0';
		o_dval	<=	'0';
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (counter<(LOGK)) then	-- < 4
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
		sum			<=	(others=>(others=>0));
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			s_input	<=	i_data;
		--  ********************************************
		--  ilk sıraya sadece bit by bit toplamı yazıyor
			for j in 0 to (K-1) loop	-- 0dan 7ye
					sum(0,j)	<=	(to_integer(unsigned(s_input(2*j downto 2*j)))+to_integer(unsigned(s_input(2*j+1 downto 2*j+1))));
			end loop;
		--  ********************************************
		--  Piramit şeklinde topluyor sonra
			for i in 1 to LOGK-1 loop	-- 1den 3e
				for j in 0 to (K-1)/((2**i)) loop	-- 0dan 7 / 1,2,4,8 = 7,3,1,0 
							sum(i,j)	<=	(to_integer(to_unsigned(sum(i-1,2*j),i+1))+to_integer(to_unsigned(sum(i-1,2*j+1),i+1)));
				end loop;
			end loop;
		end if;
	end if;
end process;
-- HD burada		
o_data	<=	std_logic_vector(to_unsigned(sum(LOGK-1,0),log2(Q)+1)); -- 5-bit

end RTL;
