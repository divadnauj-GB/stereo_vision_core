library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- ||  ||0 ||1 ||2 ||3 ||4 ||5 ||6 ||7 ||8 ||9 ||10||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||0 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||1 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||2 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||3 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||4 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||5 ||XX||  ||XX||  ||XX||OO||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||6 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||7 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||8 ||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||9 ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||
-- ||10||  ||XX||  ||XX||  ||XX||  ||XX||  ||XX||  ||
-- ||==||==||==||==||==||==||==||==||==||==||==||==||

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

-- 7x7 Window Sparse
-- data_tmp:  | 23  | 22  | 21  | 20  | 19  | 18  | 17  | 16  | 15  | 14  | 13  | 12  | 11  | 10  | 9   | 8   | 7   | 6   | 5   | 4   | 3   | 2   | 1   | 0   |
--            | 0e1 | 0e3 | 0e5 | 1e0 | 1e2 | 1e4 | 1e6 | 2e1 | 2e3 | 2e5 | 3e0 | 3e2 | 3e4 | 3e6 | 4e1 | 4e3 | 4e5 | 5e0 | 5e2 | 5e4 | 5e6 | 6e1 | 6e3 | 6e5 |

-- Window nerede olursa olsun bir window içinde bit stream oluşturuyor merkezdekiyle karşılaştırıp.
process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)/2-1 downto 0); -- 23 downto 0 -> 24-bit
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to (Wc-1)/2 loop		-- 0dan 3e	-> bu looplar rowda 3lü olanları karşılaştırıyor. 4 row var bunlarda 3 pixel var kullanılacak 
				for j in 0 to ((Wc-1)/2)-1 loop	-- 0dan 2ye
					if (Slide_Window((2*i),(2*j+1))<Slide_Window(((Wc-1)/2),((Wc-1)/2))) then	-- merkezdekiyle karşılaştırıyor M(3,3)
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2))	:=		'0';
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2))	:=		'1';
					end if;
				end loop;
			end loop;
			
			for i in 0 to (Wc-1)/2-1 loop	-- 0dan 2ye	-> bu looplar rowda 4lü olanları karşılaştırıyor. 3 row var bunlarda 4 pixel var kullanılacak			
				for j in 0 to (Wc-1)/2 loop		-- 0dan 3e
					if (Slide_Window(2*i+1,2*j)<Slide_Window(((Wc-1)/2),((Wc-1)/2))) then       -- merkezdekiyle karşılaştırıyor M(3,3)
						data_tmp(((Wc**2)/2-1)-(((Wc*(2*i+1))+2*j)/2))	:=		'0';
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*(2*i+1))+2*j)/2))	:=		'1';
					end if;
				end loop;
			end loop;
		end if;
	end if;
	o_data_L	<=	data_tmp;
end process;

-- 7x7 Window Sparse
-- data_tmp:  | 23   | 22   | 21   | 20   | 19   | 18   | 17   | 16   | 15   | 14   | 13   | 12   | 11   | 10   | 9    | 8    | 7    | 6    | 5    | 4    | 3    | 2    | 1    | 0    |
--            | 13e1 | 13e3 | 13e5 | 14e0 | 14e2 | 14e4 | 14e6 | 15e1 | 15e3 | 15e5 | 16e0 | 16e2 | 16e4 | 16e6 | 17e1 | 17e3 | 17e5 | 18e0 | 18e2 | 18e4 | 18e6 | 19e1 | 19e3 | 19e5 |

process(i_clk,i_rst)
variable  data_tmp	:std_logic_vector((Wc**2)/2-1 downto 0);
begin
	if (i_rst='0') then
		data_tmp		:=	(others=>'0');
	elsif rising_edge(i_clk) then
		if (i_dval='1') then
			for i in 0 to (Wc-1)/2 loop	-- 0dan 3e
				for j in 0 to ((Wc-1)/2)-1 loop	-- 0dan 2ye
					if (Slide_Window((2*i+Wt-Wc),(2*j+1))<Slide_Window(((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2))) then -- Slide_Window() < Slide_Window(16,3)
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2))	:=		'0';
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*2*i)+2*j+1)/2))	:=		'1';
					end if;
				end loop;
			end loop;
			
			for i in 0 to (Wc-1)/2-1 loop -- 0dan 2ye
				for j in 0 to (Wc-1)/2 loop	 -- 0dan 3e
					if (Slide_Window((2*i+1+Wt-Wc),2*j)<Slide_Window(((Wt-Wc)+((Wc-1)/2)),((Wc-1)/2))) then -- Slide_Window() < Slide_Window(16,3)
						data_tmp(((Wc**2)/2-1)-(((Wc*(2*i+1))+2*j)/2))	:=		'0';
					else
						data_tmp(((Wc**2)/2-1)-(((Wc*(2*i+1))+2*j)/2))	:=		'1';
					end if;
				end loop;
			end loop;
		end if;
	end if;
	o_data_H	<=	data_tmp;
end process;

--
--process(i_clk,i_rst)
--variable	counter :integer range 0 to Wc*(M+1)-M;
--begin
--	if (i_rst='0') then
--		s_valid	<=		'0';
--		counter	:=		0;
--	elsif rising_edge(i_clk) then
--		if (i_dval='1') then
--			if (counter<(((Wc+1)*(M+1))/2-M)) then	
--				counter	:=	counter +1;
--				s_valid	<=	'0';
--			else
--				counter:=	counter;
--				s_valid	<=	'1';
--			end if;			
--		else
--			null;
--		end if;
--	end if;
--end process;
--
--process(i_clk,i_rst)
--begin
--	if(i_rst='0') then
--		s_valid1	<=	'0';
--		s_valid2	<=	'0';
--	elsif rising_edge(i_clk) then
--		s_valid1	<=	i_dval;
--		s_valid2	<=	s_valid1;
--	end if;
--end process;
--
--
--o_dval	<=	s_valid	and	s_valid2;

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