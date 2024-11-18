library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use 	work.funciones_pkg.all;

entity Num_of_ones is
generic(
		W		:integer		:= 11	-- Tamaño de la ventana
		);
port(
	i_clk		:in		std_logic;
	i_rst		:in		std_logic;
	i_data	:in		std_logic_vector((W**2)/2-1  downto 0);
	i_dval	:in		std_logic;
	o_dval	:out		std_logic;
	o_data	:out		std_logic_vector(log2(W**2/2) downto 0)
	);
end entity Num_of_ones;


architecture RTL of Num_of_ones is
constant		Q		:integer		:=(W**2)/2;
constant		N		:integer		:=Q/2;
constant		K		:integer		:=Q+(Q-2*N);
constant		LOGK	:integer		:=log2(K-1);

type Pyramid is array(0 to LOGK,0 to K-1) of integer;

signal	s_input			:std_logic_vector(K-1 downto 0);
signal	s_valid			:std_logic_vector(LOGK+1 downto 0);

signal	sum		:Pyramid	:=(others=>(others=>0));
signal	sum1		:Pyramid	:=(others=>(others=>0));

begin
--===========================================================================================
--			Implementacion urilizando for-generate y process
--===========================================================================================

--process(i_clk,i_rst)
--begin	
--	if i_rst='0' then
--		s_input		<=	(others=>'0');
--		s_valid		<=	(others=>'0');
--		sum1		<=	(others=>(others=>0));
--	elsif rising_edge(i_clk) then
--		s_input(Q-1 downto 0)	<=	i_data;
--		s_valid(LOGK+1)	<=	i_dval;
--		s_valid(LOGK downto 0)	<= s_valid(LOGK+1 downto 1);
--		sum1<= sum;
--	end if;
--end process;

process(i_clk,i_rst)
variable counter 	:integer range 0 to LOGK+1;
variable v_valid	:std_logic;
begin	
	if i_rst='0' then
		counter	:= 0;
		v_valid	:=	'0';
		o_dval	<=	'0';
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (counter<(LOGK+1)) then	
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
--
--o_dval	<=	s_valid(0);	
--
Col0:	for j in 0 to (K-1)/2 generate
				sum1(0,j)	<=	(to_integer(unsigned(s_input(2*j downto 2*j)))+to_integer(unsigned(s_input(2*j+1 downto 2*j+1))));
		end generate Col0;

Row0: for i in 1 to LOGK generate
		Col1:	for j in 0 to (K-1)/((2**(i+1))) generate
						sum1(i,j)	<=	(to_integer(to_unsigned(sum(i-1,2*j),i+1))+to_integer(to_unsigned(sum(i-1,2*j+1),i+1)));
				end generate Col1;
		end generate Row0;


--===========================================================================================
--			Implementacion urilizando for-loop dentro de un process
--===========================================================================================
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_input		<=	(others=>'0');
--		s_valid		<=	(others=>'0');
		sum			<=	(others=>(others=>0));
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			s_input(Q-1 downto 0)	<=	i_data;
			--s_input(K-1 downto Q)	<=	(others => '0');
	--		s_valid(LOGK+1)	<=	i_dval;
	--		s_valid(LOGK downto 0)	<= s_valid(LOGK+1 downto 1);
			--for jj in 0 to (K-1)/2 loop
			--	sum(0,jj)	<=	(to_integer(unsigned(s_input(2*jj downto 2*jj)))+to_integer(unsigned(s_input(2*jj+1 downto 2*jj+1))));
			--end loop;
			--for i in 1 to LOGK loop
			--	for j in 0 to (K-1)/((2**(i+1))) loop
			--			sum(i,j)	<=	(to_integer(to_unsigned(sum(i-1,2*j),i+1))+to_integer(to_unsigned(sum(i-1,2*j+1),i+1)));
			--		end loop;
			--end loop;
			sum <= sum1;

		end if;
	end if;
end process;
		
o_data	<=	std_logic_vector(to_unsigned(sum(LOGK,0),log2((W**2)/2)+1));

end RTL;
