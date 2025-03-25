library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 5x5 Full Census Transform Neighborhood

-- ||  ||0 ||1 ||2 ||3 ||4 ||
-- ||==||==||==||==||==||==||
-- ||0 ||XX||XX||XX||XX||XX||
-- ||==||==||==||==||==||==||
-- ||1 ||XX||XX||XX||XX||XX||
-- ||==||==||==||==||==||==||
-- ||2 ||XX||XX||OO||XX||XX||
-- ||==||==||==||==||==||==||
-- ||3 ||XX||XX||XX||XX||XX||
-- ||==||==||==||==||==||==||
-- ||4 ||XX||XX||XX||XX||XX||
-- ||==||==||==||==||==||==||



entity Census_Transform is
generic(
		Wc		:integer		:= 5;	-- Tamaño de la ventana de Census_Transform 	-> Census_Transform penceresinin boyutu
		Wh		:integer		:= 13;	-- Tamaño de la ventana de Hamming 				-> correlation window
		M		:integer		:= 30;	-- Ancho de la imagen
		N		:integer		:= 8	-- Numero de bits del dato de entrada
		);
port(
	i_clk		:in		std_logic;
	i_rst		:in		std_logic;
	i_data		:in		std_logic_vector(N-1 downto 0);
	i_dval		:in		std_logic;
	o_dval		:out	std_logic;
	o_data_L	:out	std_logic_vector(Wc**2-2 downto 0);	-- 23 downto 0 -> 24-bit
	o_data_H	:out	std_logic_vector(Wc**2-2 downto 0)	-- 23 downto 0 -> 24-bit
	);
end entity Census_Transform;


architecture RTL of Census_Transform is
constant	Wt	    	: integer	:= (Wc+Wh);	  -- 18
constant    Center_L    : integer   := (Wc-1)/2;  -- 2
constant    Center_H	: integer	:= (Wt-Wc)+((Wc-1)/2);	-- 13+2=15
type Line_Buffer is array(0 to Wt-1,0 to M-1) of std_logic_vector(N-1 downto 0);

signal	Slide_Window 	:Line_Buffer	:=(others=>(others=>(others=>'0')));

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


-- For Upper Window: Data_L
Data_L: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)-1 downto 0); -- 24 downto 0 -> 25-bit, dont assign data_tmp(12)
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to (Wc-1) loop	-- 0 to 4
				for j in 0 to (Wc-1) loop	-- 0 to 4
					if(Slide_Window(i,j) < Slide_Window(Center_L,Center_L)) then
						data_tmp( (Wc**2-1) - Wc*i - j )	:=  '0';
					else
						data_tmp( (Wc**2-1) - Wc*i - j )    :=  '1';
					end if;

				end loop;
			end loop;
		end if;
	end if;
-- do not consider the middle bit. The middle bit is compared with itself
	o_data_L	<=	(data_tmp((Wc**2)-1 downto (Wc**2/2) + 1) & data_tmp( (Wc**2/2)-1 downto 0));
end process Data_L;

-- For Upper Window: Data_H
Data_H: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)-1 downto 0); -- 48 downto 0 -> 49-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to (Wc-1) loop	-- 0 to 4
				for j in 0 to (Wc-1) loop	-- 0 to 4
					if(Slide_Window(Wh+i,j) < Slide_Window(Center_H,Center_L)) then
						data_tmp( (Wc**2-1) - Wc*i - j )	:=  '0';
					else
						data_tmp( (Wc**2-1) - Wc*i - j )    :=  '1';
					end if;

				end loop;
			end loop;
		end if;
	end if;
-- do not consider the middle bit. The middle bit is compared with itself
	o_data_H	<=	(data_tmp((Wc**2)-1 downto (Wc**2/2) + 1) & data_tmp( (Wc**2/2)-1 downto 0));
end process Data_H;


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
			if (counter<(((Wc+1)*(M+1))/2-M)) then	-- ilk valid verebilmek için (5,5 window merkez (2,2))
													-- windowun (2,2). datası gelmeli. yani ilk 2 satır gelecek
													-- artı 3. satırın 3. datası (merkez) gelmeli
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