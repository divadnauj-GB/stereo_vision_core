library ieee;
use	ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.funciones.all;

entity SHD is
generic(
		Wh		:integer		:=  13;	 -- Tamaño de la ventana de hamming
		M		:integer		:= 384;	 -- Ancho de la imagen - Resim genişliği
		D		:integer		:=	64;  -- Disparity level
		Wc		:integer		:=   7
		);
port(
	i_clk			:in		std_logic;
	i_rst			:in		std_logic;
	i_data_LL		:in		std_logic_vector(0 downto 0);  -- 1-bit
	i_data_LH		:in		std_logic_vector(0 downto 0);
	i_data_RL		:in		std_logic_vector(0 downto 0);
	i_data_RH		:in		std_logic_vector(0 downto 0);
	i_dval			:in		std_logic;
	o_dval			:out	std_logic;
	o_data_L		:out	std_logic_vector(log2(D) downto 0);		-- 6 downto 0
	o_data_R		:out	std_logic_vector(log2(D) downto 0)
	);
end entity SHD;


architecture RTL of SHD is

type delay_census_L is array(0 to D-1) of std_logic_vector(0 downto 0);
type delay_census_R is array(0 to 2*(D-1)) of std_logic_vector(0 downto 0);

type partial_hamming is array(0 to D-1) of std_logic_vector(0 downto 0);

type Hamming is array(0 to D-1) of std_logic_vector(0 downto 0);

type Suma_window is array(0 to D-1) of std_logic_vector(8 downto 0);

type disp  is array(0 to D-2,0 to 1) of std_logic_vector(log2(D) downto 0); 

type Cost	is array(0 to D-2,0 to 1) of std_logic_vector(8 downto 0);

type sdisp  is array(0 to D-1) of std_logic_vector(log2(D) downto 0); 

type sCost	is array(0 to D-1) of std_logic_vector(8 downto 0);

signal	s_valid_L		:std_logic_vector(D-1 downto 0); 
signal	s_valid_H		:std_logic_vector(D-1 downto 0); 
signal	s_valid_And		:std_logic_vector(D-1 downto 0); 
signal	s_valid_W		:std_logic_vector(D-1 downto 0); 
signal	s_valid_In		:std_logic_vector(2*(D-1) downto 0); -- 126dan 0a
signal	s_valid_InH		:std_logic_vector(2*(D-1) downto 0); 

signal	Slide_Window_LL 	:delay_census_L;
signal	Slide_Window_LH 	:delay_census_L;

signal	Slide_Window_RL 	:delay_census_R;
signal	Slide_Window_RH 	:delay_census_R;

signal	s_hamming_L		:Hamming;
signal	s_hamming_H		:Hamming;

signal	s_phamming_L			:partial_hamming;
signal	s_phamming_H			:partial_hamming;

signal	s_valid				:std_logic;

signal	s_sum_W		:Suma_window;

signal	Costo				:Cost;

signal	dispa				:disp;

signal	cmpCosto				:sCost;

signal	cmpdispa				:sdisp;

signal	CostoL				:sCost;

signal	dispaL				:sdisp;

signal	cmpCostoL				:sCost;

signal	cmpdispaL				:sdisp;

signal	delay_reg			:sdisp;
	
begin


-- ************* Slide_Window_LL *************
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Slide_Window_LL	<=(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			Slide_Window_LL(0)	<=	i_data_LL;
			Slide_Window_LL(1 to D-1) <= Slide_Window_LL(0 to D-2);		-- 0-63 <= 0-62
		end if;
	end if;
end process;
-- ************* Slide_Window_LH *************
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Slide_Window_LH	<=(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			Slide_Window_LH(0)	<=	i_data_LH;
			Slide_Window_LH(1 to D-1) <= Slide_Window_LH(0 to D-2);      -- 0-63 <= 0-62
		end if;
	end if;
end process;
-- ************* Slide_Window_RL *************
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Slide_Window_RL	<=(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			Slide_Window_RL(0)	<=	i_data_RL;
			Slide_Window_RL(1 to 2*(D-1)) <= Slide_Window_RL(0 to 2*(D-1)-1);	-- 1-126 <= 0-125
		end if;
	end if;
end process;
-- ************* Slide_Window_RH *************
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Slide_Window_RH	<=(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			Slide_Window_RH(0)	<=	i_data_RH;
			Slide_Window_RH(1 to 2*(D-1)) <= Slide_Window_RH(0 to 2*(D-1)-1);	-- 1-126 <= 0-125
		end if;
	end if;
end process;

-- ****************************************************
-- ************* 		VALID		*******************
-- ****************************************************
process(i_clk,i_rst)
variable v_valid_In		:std_logic_vector(2*(D-1) downto 0);	-- 126dan 0a -> 127-bit
begin
	if (i_rst='0') then
		v_valid_In	:=(others=>'0');
		s_valid_In	<=(others=>'0');	-- 1. Num_of_ones'ın i_dval sinyaline bağlı
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			v_valid_In(0)	:=	'1';
			s_valid_In	<=	v_valid_In;
			v_valid_In(2*(D-1) downto 1) := v_valid_In(2*(D-1)-1 downto 0); -- 126-1 := 125-0
		else
			s_valid_In	<=(others=>'0');
		end if;
	end if;
end process;

process(i_clk,i_rst)
variable v_valid_In :std_logic_vector(2*(D-1) downto 0);
variable count		:integer range 0 to 4*Wh*M;		-- 0dan 4*13*384'e
begin
	if (i_rst='0') then
		v_valid_In	:=(others=>'0');
		s_valid_InH	<=(others=>'0');	-- 2. Num_of_ones'ın i_dval sinyaline bağlı
	elsif rising_edge(i_clk) then
		if(i_dval='1') then
			if (count<(((Wh)*(M)))) then	
				count	:=	count +1;
				v_valid_In(0)	:=	'0';
			else
				count:=	count;
				v_valid_In(0)	:=	'1';
			end if;			
			s_valid_InH	<=	v_valid_In;
			v_valid_In(2*(D-1) downto 1) := v_valid_In(2*(D-1)-1 downto 0);
		else
			s_valid_InH	<=(others=>'0');
		end if;
	end if;
end process;
-- ****************************************************
-- ************* 	VALID END		*******************
-- ****************************************************

-- Similarity Moduledeki XOR operations
DEEP:	for k in 0 to D-1 generate
			s_hamming_L(k)	<=	(Slide_Window_LL(k) xor Slide_Window_RL(2*k));
			s_hamming_H(k)	<=	(Slide_Window_LH(k) xor Slide_Window_RH(2*k));
		end generate DEEP;
		
--  Bottom Window		
DEEP_L:	for k in 0 to D-1 generate
			Sum0:	entity work.Num_of_ones
					generic map(
					W	=>	Wc
					)
					port map
					(
					i_clk		=>	i_clk,	
					i_rst		=>	i_rst,	
					i_data	=> s_hamming_L(k),		
					i_dval	=> s_valid_In(2*k),	
					o_dval	=>	s_valid_L(k),
					o_data	=>	s_phamming_L(k)		-- HD geliyor
					);
		end generate DEEP_L;		

-- 	Upper Window		
DEEP_H:for k in 0 to D-1 generate   -- 64 tane
			Sum1:	entity work.Num_of_ones
					generic map(
					W	=>	Wc
					)
					port map
					(
					i_clk		=>	i_clk,	
					i_rst		=>	i_rst,	
					i_data	=> s_hamming_H(k),		
					i_dval	=> s_valid_InH(2*k),	
					o_dval	=>	s_valid_H(k),
					o_data	=>	s_phamming_H(k)		-- HD geliyor
					);
				end generate DEEP_H;	
	  
-- Similarity Moduledeki toplama çıkarma işlemleri	  
WIN_L:for k in 0 to D-1 generate		-- 64 tane
			Suma:	entity work.Window_sum
						generic map(
						Wh	=>	Wh,
						M	=>	M,
						Wc	=>	Wc
						)
						port map
						(
						i_clk			=>	i_clk,	
						i_rst			=>	i_rst,	
						i_data_L		=> s_phamming_L(k),		-- HD Low
						i_data_H		=> s_phamming_H(k),		-- HD High
						i_dval		=> s_valid_L(k),	
						o_dval		=> s_valid_W(k),	
						o_data		=>	s_sum_W(k)
						);
	  end generate WIN_L;
	  
	  
CMP:for k in 0 to D-2 generate
			comparador:	entity work.Disp_Cmp
						generic map(
						Wh	=>	Wh,
						D	=>	D,
						Wc	=>	Wc
						)
						port map
						(
						i_data_C1	=>	Costo(k,1),
						i_data_D1	=>	dispa(k,1),
						i_data_C2	=> s_sum_W(k+1),
						i_data_D2	=> std_logic_vector(to_unsigned(k+1,log2(D)+1)),
						o_data_C		=> cmpCosto(k+1),	
						o_data_D		=> cmpdispa(k+1)
						);
	  end generate CMP;
	  
	  
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		Costo		<=		(others=>(others=>(others=>'0')));
		dispa		<=		(others=>(others=>(others=>'0')));
	elsif rising_edge(i_clk) then
		if (s_valid_W(0)='1') then
			Costo(0,0)	<=	s_sum_W(0);
			Costo(0,1)	<=	Costo(0,0);
			dispa(0,0)	<=	(others=>'0');
			dispa(0,1)	<=	dispa(0,0);
		end if;
		for i in 1 to D-2 loop
			if (s_valid_W(i)='1') then
				Costo(i,0)	<=	cmpCosto(i);
				Costo(i,1)	<=	Costo(i,0);		-- select best disparity için gerekli (R için) 2 delayi yapmış
				dispa(i,0)	<=	cmpdispa(i);
				dispa(i,1)	<=	dispa(i,0);
			end if;
		end loop;
	end if;
end process;	  
	  
	  
	  
CMPL:for k in 0 to D-2 generate
			comparador:	entity work.Disp_Cmp
						generic map(
						Wh	=>	Wh,
						D	=>	D,
						Wc	=>	Wc
						)
						port map
						(
						i_data_C1	=>	CostoL(k),
						i_data_D1	=>	dispaL(k),
						i_data_C2	=> s_sum_W(k+1),
						i_data_D2	=> std_logic_vector(to_unsigned(k+1,log2(D)+1)),
						o_data_C		=> cmpCostoL(k+1),	
						o_data_D		=> cmpdispaL(k+1)
						);
	  end generate CMPL;
	  
	  
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		CostoL		<=		(others=>(others=>'0'));
		dispaL		<=		(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if (s_valid_W(0)='1') then
			CostoL(0)	<=	s_sum_W(0);
			dispaL(0)	<=	(others=>'0');
		end if;
		for i in 1 to D-2 loop
			if (s_valid_W(i)='1') then
				CostoL(i)	<=	cmpCostoL(i);
				dispaL(i)	<=	cmpdispaL(i);
			end if;
		end loop;
	end if;
end process;	  
	  
process(i_clk,i_rst)
begin
	if (i_rst='0') then
		o_data_L	<=	(others=>'0');
		o_data_R	<=	(others=>'0');
		o_dval	<=	'0';
	elsif rising_edge(i_clk) then		
		o_data_R	<=	cmpdispa(D-1);
		o_data_L	<=	delay_reg(D-1);
		o_dval	<=	s_valid_W(D-1);
	end if;
end process;	


process(i_clk,i_rst)
begin
	if (i_rst='0') then		
		delay_reg <=	(others=>(others=>'0'));
	elsif rising_edge(i_clk) then
		if (s_valid_W(D-1)='1') then
			delay_reg(0) <=	cmpdispaL(D-1);
			delay_reg(1 to D-1) <=	delay_reg(0 to D-2);
		end if;
	end if;
end process;  

end RTL;