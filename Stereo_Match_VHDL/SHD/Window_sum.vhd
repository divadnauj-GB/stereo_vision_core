library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use   work.funciones_pkg.all;

entity Window_sum is
generic(
		Wh		:integer		:= 11;	-- Tamaño de la ventana de hamming
		M		:integer		:= 100;	-- Ancho de la imagen
		Wc		:integer		:= 11 
		);
port(
	i_clk		:in		std_logic;
	i_rst		:in		std_logic;
	i_data_L	:in		std_logic_vector(log2((Wc**2)/2) downto 0);
	i_data_H	:in		std_logic_vector(log2((Wc**2)/2) downto 0);
	i_dval	:in		std_logic;
	o_dval	:out		std_logic;
	o_data	:out		std_logic_vector(log2(((Wc**2)/2)*(Wh**2)) downto 0)
	);
end entity Window_sum;

architecture RTL of Window_sum is

type Line_Buffer is array(0 to M-1) of std_logic_vector(log2(Wh*(Wc**2)/2) downto 0);
type Win_Buffer is array(0 to Wh-1) of std_logic_vector(log2(Wh*(Wc**2)/2) downto 0);
 
signal 	s_col_line		:Line_Buffer;
signal 	s_row_win		:Win_Buffer;

signal	s_input_col		:integer;
signal	s_input_col_w	:integer;

signal	s_tab_1			:integer;

signal	s_tab_2			:integer;

signal	s_tab_3			:integer;

signal	s_tab_4			:integer;

signal	s_tmp_add_1			:integer;

begin


process(i_clk,i_rst)
begin
	if (i_rst='0') then
			s_input_col		<=	0;
			s_input_col_w	<=	0;
			s_tab_1			<=	0;
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			s_input_col		<=	to_integer(unsigned(i_data_L));
			s_input_col_w	<=	to_integer(unsigned(i_data_H));
			s_tab_1			<=	to_integer(to_unsigned(s_input_col,log2((Wc**2)/2)+1))-to_integer(to_unsigned(s_input_col_w,log2((Wc**2)/2)+1));
		end if;
	end if;
end process;

s_tmp_add_1	<=	to_integer(unsigned(s_col_line(M-1)))+to_integer(to_signed(s_tab_1,log2(Wh*(Wc**2)/2)+1));

process(i_clk,i_rst)
begin
	if (i_rst='0') then
			s_tab_2			<=	0;
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			s_tab_2			<=	s_tmp_add_1;
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
			s_tab_3			<=	0;
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			s_tab_3			<=	to_integer(to_unsigned(s_tab_2,log2(Wh*(Wc**2)/2)+1))-to_integer(unsigned(s_row_win(Wh-1)));
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
			s_tab_4			<=	0;
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			s_tab_4			<=	to_integer(to_signed(s_tab_3,log2(Wh*(Wc**2)/2)+2))+to_integer(to_unsigned(s_tab_4,log2((Wh**2)*(Wc**2)/2)+1));
		end if;
	end if;
end process;


process(i_clk,i_rst)
begin
	if (i_rst='0') then
			s_col_line			<=	(others=>(others=>'0'));
			s_row_win			<=	(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			s_col_line(0)			<=	std_logic_vector(to_unsigned(s_tmp_add_1,log2(Wh*(Wc**2)/2)+1));
			s_col_line(1 to M-1)	<= s_col_line(0 to M-2);
			s_row_win(0)			<=	std_logic_vector(to_unsigned(s_tab_2,log2(Wh*(Wc**2)/2)+1));
			s_row_win(1 to Wh-1)	<= s_row_win(0 to Wh-2);
		end if;
	end if;
end process;


o_data		<=	std_logic_vector(to_unsigned(s_tab_4,log2(((Wc**2)/2)*(Wh**2))+1));

process(i_clk,i_rst)
variable	counter :integer range 0 to Wh*M;
variable v_valid :std_logic;
begin
	if (i_rst='0') then
		v_valid	:=		'0';
		o_dval	<=		'0';
		counter	:=		0;
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (counter<(((Wh+1)*(M+1))/2-M+3)) then	
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



end RTL;
