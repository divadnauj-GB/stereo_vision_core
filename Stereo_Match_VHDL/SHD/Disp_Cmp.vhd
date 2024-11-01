library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use 	work.funciones_pkg.all;

entity Disp_Cmp is
generic(
		Wh		:integer		:= 3;	-- Tamaño de la ventana de hamming
		D		:integer		:=	5;
		Wc		:integer		:= 3
		);
port(
	i_data_C1	:in		std_logic_vector(log2(((Wc**2)/2)*(Wh**2)) downto 0);
	i_data_D1	:in		std_logic_vector(log2(D) downto 0);
	i_data_C2	:in		std_logic_vector(log2(((Wc**2)/2)*(Wh**2)) downto 0);
	i_data_D2	:in		std_logic_vector(log2(D) downto 0);
	o_data_C		:out		std_logic_vector(log2(((Wc**2)/2)*(Wh**2)) downto 0);
	o_data_D		:out		std_logic_vector(log2(D) downto 0)
	);
end entity Disp_Cmp;


architecture RTL of Disp_Cmp is

signal s_C1, s_C2		:integer range 0 to (Wh**2)*(Wc**2)/2+1;
begin

s_C1<=to_integer(unsigned(i_data_C1));
s_C2<=to_integer(unsigned(i_data_C2));

o_data_D	<=	i_data_D2 when (s_C2)<(s_C1) else
				i_data_D1;

o_data_C	<=	i_data_C2 when (s_C2)<(s_C1) else
				i_data_C1;


end RTL;