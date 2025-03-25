library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||7 ||8 ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||0 ||  ||  ||  ||XX||XX||XX||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||1 ||  ||  ||XX||XX||XX||XX||XX||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||2 ||  ||XX||  ||  ||  ||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||3 ||XX||XX||  ||  ||  ||  ||  ||XX||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||4 ||XX||XX||  ||  ||OO||  ||  ||XX||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||5 ||XX||XX||  ||  ||  ||  ||  ||XX||XX||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||6 ||  ||XX||  ||  ||  ||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||7 ||  ||  ||XX||XX||XX||XX||XX||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||8 ||  ||  ||  ||XX||XX||XX||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||

-- 16-Point Census

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
	o_data_L	:out	std_logic_vector(31 downto 0);	-- -> 32-bit
	o_data_H	:out	std_logic_vector(31 downto 0)	-- -> 32-bit
	);
end entity Census_Transform;


architecture RTL of Census_Transform is
constant	Wt		:integer	:=(Wc+Wh);		-- 20
constant    Center  : integer 	:= (Wc-1)/2;	-- 3,3
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
process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(31 downto 0); -- 32-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to 2 loop		-- ROW-0
				if(Slide_Window(0,i+3) < Slide_Window(Center,Center)) then	
					data_tmp(31-i) := '0';		-- 31,30,29
				else
					data_tmp(31-i) := '1';
				end if;
			end loop;
			for i in 0 to 4 loop		-- ROW-1
				if(Slide_Window(1,i+2) < Slide_Window(Center,Center)) then	
					data_tmp(28-i) := '0';		-- 28,27,26,25,24
				else
					data_tmp(28-i) := '1';
				end if;
			end loop;
			for i in 0 to 4 loop		-- ROW-7
				if(Slide_Window(7,i+2) < Slide_Window(Center,Center)) then	
					data_tmp(7-i) := '0';		-- 7,6,5,4,3
				else
					data_tmp(7-i) := '1';
				end if;
			end loop;
			for i in 0 to 2 loop		-- ROW-8
				if(Slide_Window(8,i+3) < Slide_Window(Center,Center)) then	
					data_tmp(2-i) := '0';		-- 2,1,0
				else
					data_tmp(2-i) := '1';
				end if;
			end loop;
			for i in 0 to 1 loop		-- COL-0, COL-8
				for j in 0 to 2 loop		
					if(Slide_Window(j+3,8*i) < Slide_Window(Center,Center)) then	
						data_tmp(21-3*i-4*j) := '0';		-- 21,17,13,18,14,10
					else
						data_tmp(21-3*i-4*j) := '1';
					end if;
				end loop;
			end loop;
			for i in 0 to 1 loop		-- COL-1, COL-7 except 23,22,9,8
				for j in 0 to 2 loop		
					if(Slide_Window(j+3,6*i+1) < Slide_Window(Center,Center)) then	
						data_tmp(20-i-4*j) := '0';		-- 20,16,12,19,15,11
					else
						data_tmp(20-i-4*j) := '1';
					end if;
				end loop;
			end loop;
			if(Slide_Window(2,1) < Slide_Window(Center,Center)) then	
				data_tmp(23) := '0';		-- 23
			else
				data_tmp(23) := '1';
			end if;
			if(Slide_Window(2,7) < Slide_Window(Center,Center)) then	
				data_tmp(22) := '0';		-- 22
			else
				data_tmp(22) := '1';
			end if;
			if(Slide_Window(6,1) < Slide_Window(Center,Center)) then	
				data_tmp(9) := '0';			-- 9
			else
				data_tmp(9) := '1';
			end if;
			if(Slide_Window(6,7) < Slide_Window(Center,Center)) then	
				data_tmp(8) := '0';			-- 8
			else
				data_tmp(8) := '1';
			end if;
		end if;
	end if;
	o_data_L	<=	data_tmp;
end process;


process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(31 downto 0);
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to 2 loop		-- ROW-13
				if(Slide_Window(13,i+3) < Slide_Window(Center+Wh,Center)) then	
					data_tmp(31-i) := '0';		-- 31,30,29
				else
					data_tmp(31-i) := '1';
				end if;
			end loop;
			for i in 0 to 4 loop		-- ROW-14
				if(Slide_Window(14,i+2) < Slide_Window(Center+Wh,Center)) then	
					data_tmp(28-i) := '0';		-- 28,27,26,25,24
				else
					data_tmp(28-i) := '1';
				end if;
			end loop;
			for i in 0 to 4 loop		-- ROW-20
				if(Slide_Window(20,i+2) < Slide_Window(Center+Wh,Center)) then	
					data_tmp(7-i) := '0';		-- 7,6,5,4,3
				else
					data_tmp(7-i) := '1';
				end if;
			end loop;
			for i in 0 to 2 loop		-- ROW-21
				if(Slide_Window(21,i+3) < Slide_Window(Center+Wh,Center)) then	
					data_tmp(2-i) := '0';		-- 2,1,0
				else
					data_tmp(2-i) := '1';
				end if;
			end loop;
			for i in 0 to 1 loop		-- COL-0, COL-8
				for j in 0 to 2 loop		
					if(Slide_Window(j+3+Wh,8*i) < Slide_Window(Center+Wh,Center)) then	
						data_tmp(21-3*i-4*j) := '0';		-- 21,17,13,18,14,10
					else
						data_tmp(21-3*i-4*j) := '1';
					end if;
				end loop;
			end loop;
			for i in 0 to 1 loop		-- COL-1, COL-7 except 23,22,9,8
				for j in 0 to 2 loop		
					if(Slide_Window(j+3+Wh,6*i+1) < Slide_Window(Center+Wh,Center)) then	
						data_tmp(20-i-4*j) := '0';		-- 20,16,12,19,15,11
					else
						data_tmp(20-i-4*j) := '1';
					end if;
				end loop;
			end loop;
			if(Slide_Window(15,1) < Slide_Window(Center+Wh,Center)) then	
				data_tmp(23) := '0';		-- 23
			else
				data_tmp(23) := '1';
			end if;
			if(Slide_Window(15,7) < Slide_Window(Center+Wh,Center)) then	
				data_tmp(22) := '0';		-- 22
			else
				data_tmp(22) := '1';
			end if;
			if(Slide_Window(19,1) < Slide_Window(Center+Wh,Center)) then	
				data_tmp(9) := '0';			-- 9
			else
				data_tmp(9) := '1';
			end if;
			if(Slide_Window(19,7) < Slide_Window(Center+Wh,Center)) then	
				data_tmp(8) := '0';			-- 8
			else
				data_tmp(8) := '1';
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