library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Non-Redundant
-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||7 ||8 ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||0 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||1 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||2 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||3 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||4 ||XX||  ||XX||  ||OO||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||5 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||6 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||7 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||8 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||


-- 40-BIT OUTPUT DATA

entity Census_Transform is
generic(
		Wc		:integer		:= 9;	-- Tamaño de la ventana de Census_Transform 	-> Census_Transform penceresinin boyutu
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
	o_data_L	:out	std_logic_vector(Wc**2/2-1 downto 0);	-- 39 downto 0 -> 40-bit
	o_data_H	:out	std_logic_vector(Wc**2/2-1 downto 0)	-- 39 downto 0 -> 40-bit
	);
end entity Census_Transform;


architecture RTL of Census_Transform is
constant	Wt	:integer	:=(Wc+Wh);	-- 20

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


-- Window nerede olursa olsun bir window içinde bit stream oluşturuyor merkezdekiyle karşılaştırıp.
DATA_L: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)/2-1 downto 0); -- 23 downto 0 -> 24-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
		-- fill with row-0,row-2
			for i in 0 to 1 loop 
				for j in 0 to 4 loop  
					if( Slide_Window( (2*i),(2*j) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 39,38,37,36,35,30,29,28,27,26
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-5,row-7
			for i in 0 to 1 loop 
				for j in 0 to 4 loop  
					if( Slide_Window( (2*i+5),(2*j) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp(17-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 17,16,15,14,13,8,7,6,5,4
					else
						data_tmp(17-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-1, row-3 
			for i in 0 to 1 loop
				for j in 0 to 3 loop  
					if( Slide_Window( (2*i+1),(2*j+1) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp( 34-j-9*i) := '0';	-- 34,33,32,31,25,24,23,22
					else
						data_tmp( 34-j-9*i) := '1';     
					end if;
				end loop;
			end loop;
			-- fill with row-6, row-8 
			for i in 0 to 1 loop
				for j in 0 to 3 loop  
					if( Slide_Window( (2*i+6),(2*j+1) ) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
						data_tmp( 12-j-9*i) := '0';	-- 12,11,10,9,3,2,1,0
					else
						data_tmp( 12-j-9*i) := '1';     
					end if;
				end loop;
			end loop;
		-- fill row-4
			if(Slide_Window(4,0) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(21) := '0';
			else
				data_tmp(21) := '1';
			end if;
			if(Slide_Window(4,2) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(20) := '0';
			else
				data_tmp(20) := '1';
			end if;
			if(Slide_Window(4,5) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(19) := '0';
			else
				data_tmp(19) := '1';
			end if;
			if(Slide_Window(4,7) < Slide_Window( ((Wc-1)/2),((Wc-1)/2) ) ) then
				data_tmp(18) := '0';
			else
				data_tmp(18) := '1';
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
			-- fill with row-13,row-15
			for i in 0 to 1 loop 
				for j in 0 to 4 loop  
					if( Slide_Window( (2*i+Wh),(2*j) ) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 39,38,37,36,35,30,29,28,27,26
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-18,row-20
			for i in 0 to 1 loop 
				for j in 0 to 4 loop  
					if( Slide_Window( (2*i+5+Wh),(2*j) ) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
						data_tmp(17-(((Wc*2*i)+2*j+1)/2)) := '0';	-- 17,16,15,14,13,8,7,6,5,4
					else
						data_tmp(17-(((Wc*2*i)+2*j+1)/2)) := '1';
					end if;
				end loop;
			end loop;
		-- fill with row-14, row-16 
			for i in 0 to 1 loop
				for j in 0 to 3 loop  
					if( Slide_Window( (2*i+1+Wh),(2*j+1) ) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
						data_tmp( 34-j-9*i) := '0';	-- 34,33,32,31,25,24,23,22
					else
						data_tmp( 34-j-9*i) := '1';     
					end if;
				end loop;
			end loop;
			-- fill with row-19, row-21 
			for i in 0 to 1 loop
				for j in 0 to 3 loop  
					if( Slide_Window( (2*i+6+Wh),(2*j+1) ) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
						data_tmp( 12-j-9*i) := '0';	-- 12,11,10,9,3,2,1,0
					else
						data_tmp( 12-j-9*i) := '1';     
					end if;
				end loop;
			end loop;
		-- fill row-17
			if(Slide_Window(17,0) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
				data_tmp(21) := '0';
			else
				data_tmp(21) := '1';
			end if;
			if(Slide_Window(17,2) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
				data_tmp(20) := '0';
			else
				data_tmp(20) := '1';
			end if;
			if(Slide_Window(17,5) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
				data_tmp(19) := '0';
			else
				data_tmp(19) := '1';
			end if;
			if(Slide_Window(17,7) < Slide_Window( ((Wc-1)/2)+Wh,((Wc-1)/2) ) ) then
				data_tmp(18) := '0';
			else
				data_tmp(18) := '1';
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