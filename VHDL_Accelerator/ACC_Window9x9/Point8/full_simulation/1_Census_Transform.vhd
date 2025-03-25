library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||7 ||8 ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||0 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||1 ||  ||XX||  ||  ||XX||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||2 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||3 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||4 ||  ||XX||  ||  ||OO||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||5 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||6 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||7 ||  ||XX||  ||  ||XX||  ||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||
-- ||8 ||  ||  ||  ||  ||  ||  ||  ||  ||  ||
-- ||==||==||==||==||==||==||==||==||==||==||

-- 8-Point Census for 9x9 Window

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
	o_data_L	:out	std_logic_vector(7 downto 0);	-- -> 8-bit
	o_data_H	:out	std_logic_vector(7 downto 0)	-- -> 8-bit
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
DATA_L: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(8 downto 0); -- 9-bit: normally 7-bit, i will ignore bit-4
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to 2 loop		
				for j in 0 to 2 loop
					if(Slide_Window(3*i+1,3*j+1) < Slide_Window(Center,Center)) then
						data_tmp(8-3*i-j) := '0';
					else
						data_tmp(8-3*i-j) := '1';
					end if;	
				end loop;
			end loop;
			
		end if;
	end if;
	o_data_L	<=	data_tmp(8 downto 5) & data_tmp(3 downto 0);
end process DATA_L;

DATA_H: process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector(8 downto 0); -- 9-bit: normally 7-bit, i will ignore bit-4
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to 2 loop		
				for j in 0 to 2 loop
					if(Slide_Window(3*i+1+Wh,3*j+1) < Slide_Window(Center+Wh,Center)) then
						data_tmp(8-3*i-j) := '0';
					else
						data_tmp(8-3*i-j) := '1';
					end if;	
				end loop;
			end loop;
			
		end if;
	end if;
	o_data_H	<=	data_tmp(8 downto 5) & data_tmp(3 downto 0);
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