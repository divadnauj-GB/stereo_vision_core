library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||
-- ||==||==||==||==||==||==||==||==||
-- ||0 ||  ||  ||  ||XX||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||1 ||  ||  ||XX||XX||XX||  ||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||2 ||  ||XX||  ||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||3 ||XX||XX||  ||OO||  ||XX||XX||
-- ||==||==||==||==||==||==||==||==||
-- ||4 ||  ||XX||  ||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||5 ||  ||  ||XX||XX||XX||||  ||  
-- ||==||==||==||==||==||==||==||==||
-- ||6 ||  ||  ||  ||XX||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||

-- 16-Point Census

entity Census_Transform is
generic(
		Wc		:integer		:= 7;	-- Tamaño de la ventana de Census_Transform 	-> Census_Transform penceresinin boyutu
		Wh		:integer		:= 13;	-- Tamaño de la ventana de Hamming 				-> correlation window
		M		:integer		:= 384;	-- Ancho de la imagen
		N		:integer		:= 8	-- Numero de bits del dato de entrada
		);
port(
	i_clk		:in		std_logic;
	i_rst		:in		std_logic;
	i_data		:in		std_logic_vector(N-1 downto 0);
	i_dval		:in		std_logic;
	o_dval		:out	std_logic;
	o_data_L	:out	std_logic_vector(15 downto 0);	-- -> 16-bit
	o_data_H	:out	std_logic_vector(15 downto 0)	-- -> 16-bit
	);
end entity Census_Transform;


architecture RTL of Census_Transform is
constant	Wt		:integer	:=(Wc+Wh);		-- 20
constant    Center  : integer 	:= (Wc-1)/2;	-- 3,3
type Line_Buffer is array(0 to Wt-1,0 to M-1) of std_logic_vector(N-1 downto 0);

signal	Slide_Window 	:Line_Buffer	:=(others=>(others=>(others=>'0')));
signal	s_valid			:std_logic;
signal	s_valid1		:std_logic;
signal	s_valid2		:std_logic;

begin

-- Slide Winddow dolduruyor shift ederek.
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Slide_Window	<=	(others=>(others=>(others=>'0')));
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			Slide_Window(0,0)	<=	i_data;
			for i in 0 to Wt-1 loop  -- 0dan 19a
				for j in 0 to M-2 loop	-- 0dan 638e
					Slide_Window(i,j+1)	<=	Slide_Window(i,j);
				end loop;
			end loop;
			for i in 1 to Wt-1 loop		-- burada eğer son sütuna ulaşmışsak onu bir alt satırın ilk indexine yolluyor
				Slide_Window(i,0)	<=	Slide_Window(i-1,M-1);
			end loop;
		end if;
	end if;
end process;


-- Window nerede olursa olsun bir window içinde bit stream oluşturuyor merkezdekiyle karşılaştırıp.
process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(15 downto 0); -- 16-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if(Slide_Window(0,3) < Slide_Window(Center,Center)) then		-- 15
				data_tmp(15) := '0';
			else
				data_tmp(15) := '1';
			end if;
			for i in 2 to 4 loop											-- 14,13,12
				if(Slide_Window(1,i) < Slide_Window(Center,Center)) then
					data_tmp(16-i) := '0';
				else
					data_tmp(16-i) := '1';
				end if;
			end loop;
			if(Slide_Window(2,1) < Slide_Window(Center,Center)) then		-- 11
					data_tmp(11) := '0';
				else
					data_tmp(11) := '1';
			end if;
			if(Slide_Window(2,5) < Slide_Window(Center,Center)) then		-- 10
					data_tmp(10) := '0';
				else
					data_tmp(10) := '1';
				end if;
			for i in 0 to 1 loop											-- 9,8
				if(Slide_Window(3,i) < Slide_Window(Center,Center)) then		
					data_tmp(9-i) := '0';
				else
					data_tmp(9-i) := '1';
				end if;
			end loop;
			for i in 5 to 6 loop											-- 7,6
				if(Slide_Window(3,i) < Slide_Window(Center,Center)) then		
					data_tmp(12-i) := '0';
				else
					data_tmp(12-i) := '1';
				end if;
			end loop;		
			if(Slide_Window(4,1) < Slide_Window(Center,Center)) then		-- 5
					data_tmp(5) := '0';
				else
					data_tmp(5) := '1';
			end if;
			if(Slide_Window(4,5) < Slide_Window(Center,Center)) then		-- 4
					data_tmp(4) := '0';
				else
					data_tmp(4) := '1';
				end if;
			for i in 2 to 4 loop											-- 3,2,1
				if(Slide_Window(5,i) < Slide_Window(Center,Center)) then
					data_tmp(5-i) := '0';
				else
					data_tmp(5-i) := '1';
				end if;
			end loop;
			if(Slide_Window(6,3) < Slide_Window(Center,Center)) then		-- 0
					data_tmp(0) := '0';
				else
					data_tmp(0) := '1';
			end if;
		end if;
	end if;
	o_data_L	<=	data_tmp;
end process;


process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(15 downto 0);
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
				if(Slide_Window(13,3) < Slide_Window(Center+Wh,Center)) then		-- 15
				data_tmp(15) := '0';
			else
				data_tmp(15) := '1';
			end if;
			for i in 2 to 4 loop											-- 14,13,12
				if(Slide_Window(14,i) < Slide_Window(Center+Wh,Center)) then
					data_tmp(16-i) := '0';
				else
					data_tmp(16-i) := '1';
				end if;
			end loop;
			if(Slide_Window(15,1) < Slide_Window(Center+Wh,Center)) then		-- 11
					data_tmp(11) := '0';
				else
					data_tmp(11) := '1';
			end if;
			if(Slide_Window(15,5) < Slide_Window(Center+Wh,Center)) then		-- 10
					data_tmp(10) := '0';
				else
					data_tmp(10) := '1';
				end if;
			for i in 0 to 1 loop											-- 9,8
				if(Slide_Window(16,i) < Slide_Window(Center+Wh,Center)) then		
					data_tmp(9-i) := '0';
				else
					data_tmp(9-i) := '1';
				end if;
			end loop;
			for i in 5 to 6 loop											-- 7,6
				if(Slide_Window(16,i) < Slide_Window(Center+Wh,Center)) then		
					data_tmp(12-i) := '0';
				else
					data_tmp(12-i) := '1';
				end if;
			end loop;		
			if(Slide_Window(17,1) < Slide_Window(Center+Wh,Center)) then		-- 5
					data_tmp(5) := '0';
				else
					data_tmp(5) := '1';
			end if;
			if(Slide_Window(17,5) < Slide_Window(Center+Wh,Center)) then		-- 4
					data_tmp(4) := '0';
				else
					data_tmp(4) := '1';
				end if;
			for i in 2 to 4 loop											-- 3,2,1
				if(Slide_Window(18,i) < Slide_Window(Center+Wh,Center)) then
					data_tmp(5-i) := '0';
				else
					data_tmp(5-i) := '1';
				end if;
			end loop;
			if(Slide_Window(19,3) < Slide_Window(Center+Wh,Center)) then		-- 0
					data_tmp(0) := '0';
				else
					data_tmp(0) := '1';
			end if;		
		end if;
	end if;
	o_data_H	<=	data_tmp;
end process;


process(i_clk,i_rst)
variable counter :integer;
variable v_valid :std_logic;
begin
	if (i_rst='0') then
		v_valid	:=	'0';
		o_dval	<=	'0';
		counter	:=	 0;
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			if (counter<(((Wc+1)*(M+1))/2-M)) then	-- 8*641/2 - 640 = 1924 :: ilk valid verebilmek için (7x7 window merkez (3,3))
													--						   windowun (3,3). datası gelmeli. yani ilk 3 satır gelecek
													--						   artı 4. satırın 4. datası (merkez) gelmeli
													--						   3*640 + 4 = 1924
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