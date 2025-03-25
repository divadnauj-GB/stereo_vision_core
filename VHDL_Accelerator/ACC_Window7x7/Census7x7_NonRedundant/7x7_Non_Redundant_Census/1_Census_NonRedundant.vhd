library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Non-Redundant
-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||
-- ||==||==||==||==||==||==||==||==||
-- ||0 ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||
-- ||1 ||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||2 ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||
-- ||3 ||  ||XX||  ||OO||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||
-- ||4 ||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||
-- ||5 ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||
-- ||6 ||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||


-- 24-BIT DATA

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
	o_data_L	:out	std_logic_vector(Wc**2/2-1 downto 0);	-- 23 downto 0 -> 24-bit
	o_data_H	:out	std_logic_vector(Wc**2/2-1 downto 0)	-- 23 downto 0 -> 24-bit
	);
end entity Census_Transform;


architecture RTL of Census_Transform is
constant	Wt	:integer	:=(Wc+Wh);	-- 20

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
DATA_L: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)/2-1 downto 0); -- 23 downto 0 -> 24-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
		-- fill with row-0 and row2 which have 4 values
			for i in 0 to (Wc-1)/2 - 2 loop -- 0 to 1 = 2 
				for j in 0 to (Wc-1)/2 loop  -- 0 to 3 = 4
					if( Slide_Window( (2*i),(2*j) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 23,22,21,20,16,15,14,13
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-1, row-4 with 3 values each row
			for i in 0 to 1 loop -- = 2 
				for j in 0 to 2 loop  -- = 3
					if( Slide_Window( (3*i+1),(2*j+1) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp( 19-j-10*i) := '0';	-- 19,18,17,9,8,7
					else
						data_tmp( 19-j-10*i) := '1';    -- 19,18,17,9,8,7
					end if;
				end loop;
			end loop;
		-- fill row-5 with 4 values
			for i in 0 to 3 loop
				if( Slide_Window( 5, 2*i ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
					data_tmp(6-i) := '0';	-- 6,5,4,3
				else
					data_tmp(6-i) := '1';	-- 6,5,4,3
				end if;
			end loop;
		-- fill row-6 with 3 values
			for i in 0 to 2 loop
				if(  Slide_Window(6,2*i+1) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
					data_tmp(2-i) := '0';	-- 2,1,0
				else
					data_tmp(2-i) := '1';	-- 2,1,0
				end if;
			end loop;
		-- fill row-3 with 3 values
			if(Slide_Window(3,1) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(12) := '0';
			else
				data_tmp(12) := '1';
			end if;
			if(Slide_Window(3,4) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(11) := '0';
			else
				data_tmp(11) := '1';
			end if;
			if(Slide_Window(3,6) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(10) := '0';
			else
				data_tmp(10) := '1';
			end if;
		end if;
	end if;
	o_data_L	<=	data_tmp;
end process DATA_L;

DATA_H: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)/2-1 downto 0);
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			-- fill with row-13 and row-15 which have 4 values
			for i in 0 to (Wc-1)/2 - 2 loop -- 0 to 1 = 2 
				for j in 0 to (Wc-1)/2 loop  -- 0 to 3 = 4
					if( Slide_Window( (2*i+Wh),(2*j) ) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2)) ) then
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 23,22,21,20,16,15,14,13
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-14, row-17 with 3 values each row
			for i in 0 to 1 loop -- = 2 
				for j in 0 to 2 loop  -- = 3
					if( Slide_Window( (3*i+1+Wh),(2*j+1) ) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
						data_tmp( 19-j-10*i) := '0';	-- 19,18,17,9,8,7
					else
						data_tmp( 19-j-10*i) := '1';    -- 19,18,17,9,8,7
					end if;
				end loop;
			end loop;
		-- fill row-18 with 4 values
			for i in 0 to 3 loop
				if( Slide_Window( 18, 2*i ) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
					data_tmp(6-i) := '0';	-- 6,5,4,3
				else
					data_tmp(6-i) := '1';	-- 6,5,4,3
				end if;
			end loop;
		-- fill row-19 with 3 values
			for i in 0 to 2 loop
				if(  Slide_Window(19,2*i+1) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
					data_tmp(2-i) := '0';	-- 2,1,0
				else
					data_tmp(2-i) := '1';	-- 2,1,0
				end if;
			end loop;
		-- fill row-16 with 3 values
			if( Slide_Window(16,1) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
				data_tmp(12) := '0';
			else
				data_tmp(12) := '1';
			end if;
			if(Slide_Window(16,4) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
				data_tmp(11) := '0';
			else
				data_tmp(11) := '1';
			end if;
			if(Slide_Window(16,6) < Slide_Window( ((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2) ) ) then
				data_tmp(10) := '0';
			else
				data_tmp(10) := '1';
			end if;
		end if;
	end if;
	o_data_H	<=	data_tmp;
end process DATA_H;

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