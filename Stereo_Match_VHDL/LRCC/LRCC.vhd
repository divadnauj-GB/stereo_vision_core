library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use   work.funciones_pkg.all;

entity LRCC is
generic(
		D		:integer		:=	5
		);
port(
	i_clk			:in		std_logic;
	i_rst			:in		std_logic;
	i_data_L		:in		std_logic_vector(log2(D) downto 0);
	i_data_R		:in		std_logic_vector(log2(D) downto 0);
	i_dval		:in		std_logic;
	i_Tresh		:in		std_logic_vector(log2(D) downto 0);
	o_dval		:out		std_logic;
	o_data_LRCC		:out		std_logic_vector(log2(D) downto 0)
	);
end entity LRCC;


architecture RTL of LRCC is
type taps is array (0 to D-1) of std_logic_vector(log2(D) downto 0);


signal	s_taps_R2L	:taps;
signal	s_taps_L2R	: std_logic_vector(log2(D) downto 0);

signal	s_selector	: std_logic_vector(log2(D) downto 0);
signal	s_tap1	: std_logic_vector(log2(D) downto 0);
signal	s_tap2	: std_logic_vector(log2(D) downto 0);
signal	s_tap3	: std_logic_vector(log2(D) downto 0);
--signal	s_tap4	: std_logic_vector(log2(D) downto 0);

signal	s_sub	: integer range -D-1 to D+1;

signal	s_abs	: std_logic_vector(log2(D) downto 0);

begin


process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_taps_R2L	<=	(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if i_dval='1' then	
			s_taps_R2L(1 to D-1)	<=	s_taps_R2L(0 to D-2);
			s_taps_R2L(0)	<=	i_data_R;
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_taps_L2R	<=	(others=>'0');
	elsif rising_edge(i_clk) then
		if i_dval='1' then
			s_taps_L2R	<=	i_data_L;
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_selector	<=	(others=>'0');		
		s_tap1		<=	(others=>'0');
	elsif rising_edge(i_clk) then
		if i_dval='1' then
			s_tap1		<=	s_taps_L2R;
			s_selector	<=	s_taps_R2L(to_integer(unsigned(s_taps_L2R)));
		end if;
	end if;
end process;

process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_sub	<=	0;	
		s_tap2 <=	(others=>'0');
	elsif rising_edge(i_clk) then
		if i_dval='1' then
			s_tap2	<= s_tap1;
			s_sub		<=	(to_integer(unsigned(s_tap1))-to_integer(unsigned(s_selector)));
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
		s_abs	<=	(others=>'0');	
		s_tap3 <=	(others=>'0');
	elsif rising_edge(i_clk) then
		if i_dval='1' then
			s_tap3	<= s_tap2;
			s_abs		<=	std_logic_vector(unsigned(abs(to_signed(s_sub,log2(D)+1))));
		end if;
	end if;
end process;

process(i_clk,i_rst)
begin
	if (i_rst='0') then
		o_data_LRCC	<=	(others=>'0');		
	elsif rising_edge(i_clk) then
		if i_dval='1' then
			if (to_integer(unsigned(s_abs))<to_integer(unsigned(i_Tresh))) then
				o_data_LRCC	<=	s_tap3;
			else
				o_data_LRCC	<=	(others=>'0');
			end if;
		end if;
	end if;
end process;



process(i_clk,i_rst)
variable  count	:integer range 0 to 4;
variable	 v_valid	:std_logic;
begin
	if(i_rst='0') then
		count := 0;
		o_dval	<=	'0';
		v_valid	:=	'0';
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (count<(4)) then	
				count	:=	count +1;
				v_valid	:=	'0';
			else
				count:=	count;
				v_valid	:=	'1';
			end if;
			o_dval	<=	v_valid;
		else
			o_dval	<=	'0';
		end if;
	end if;
end process;

--o_data_LRCC	<=	s_tap3;
end RTL;
