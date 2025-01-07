library ieee;
use	ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;
use   work.funciones_pkg.all;

entity stereo_match is
generic(
		D		:integer		:=	48;
		Wc		:integer		:= 7;	-- Tamaño de la ventana de Census_Transform
		Wh		:integer		:=	29;	--	Tamaño de la ventana de Hamming
		M		:integer		:= 640;	-- Ancho de la imagen
		N		:integer		:= 8		--	Numero de bits del dato de entrada
		);
port(
	i_clk			:in		std_logic;
	i_rstn			:in		std_logic;
	i_data_l		:in		std_logic_vector(7 downto 0);
	i_data_r		:in		std_logic_vector(7 downto 0);
	i_dval			:in		std_logic;
	i_thresh_lrcc	:in		std_logic_vector(log2(D) downto 0);
	o_dval			:out	std_logic;
	o_data			:out	std_logic_vector(log2(D) downto 0)
	);
end entity stereo_match;


architecture RTL of stereo_match is
signal	s_val_census_lefth		:std_logic;
signal	s_data_census_left_L	:std_logic_vector(Wc**2/2-1 downto 0);
signal	s_data_census_left_H	:std_logic_vector(Wc**2/2-1 downto 0);

signal	s_val_census_Rigth		:std_logic;
signal	s_data_census_Rigth_L	:std_logic_vector(Wc**2/2-1 downto 0);
signal	s_data_census_Rigth_H	:std_logic_vector(Wc**2/2-1 downto 0);

signal	s_val_census			:std_logic;

signal	s_val_SHD				:std_logic;
signal	s_Disp_L				:std_logic_vector(log2(D) downto 0);
signal	s_Disp_R				:std_logic_vector(log2(D) downto 0);





begin


Census_Left:	entity work.Census_Transform
				generic map
				(
				Wc	=> Wc,	
				Wh	=> Wh,
				M	=> M,
				N	=> N
				)
				port map
				(
				i_clk		=>	i_clk,
				i_rst	    =>	i_rstn,
				i_data	    =>	i_data_l,
				i_dval	    =>	i_dval,
				o_dval		=>	s_val_census_lefth,
				o_data_L    =>	s_data_census_left_L,
				o_data_H    =>	s_data_census_left_H
				);          

				
Census_Rigth:	entity work.Census_Transform
				generic map
				(
				Wc	=> Wc,	
				Wh	=> Wh,
				M	=> M,
				N	=> N
				)
				port map
				(
				i_clk		=>	i_clk,
				i_rst	    =>	i_rstn,
				i_data	    =>	i_data_r,
				i_dval	    =>	i_dval,
				o_dval		=>	s_val_census_Rigth,
				o_data_L    =>	s_data_census_Rigth_L,
				o_data_H    =>	s_data_census_Rigth_H
				); 

s_val_census	<=	s_val_census_Rigth and s_val_census_lefth;				
				
SHD:			entity work.SHD 
				generic map
				(Wh	=>	Wh,
				 M	=>	M,
				 D	=>	D,
				 Wc	=>	Wc
				)
				port map
				(
				i_clk			=>	i_clk,			
				i_rst			=>	i_rstn,			
				i_data_LL		=> 	s_data_census_left_L,		
				i_data_LH		=> 	s_data_census_left_H,	
				i_data_RL		=> 	s_data_census_Rigth_L,	
				i_data_RH		=>	s_data_census_Rigth_H,
				i_dval			=>	s_val_census,
				o_dval			=> 	s_val_SHD,
				o_data_L		=> 	s_Disp_L,
				o_data_R		=> 	s_Disp_R
				);

LRCC:			entity work.LRCC 
				generic map
				(
				 D		=>	D
				)
				port map
				(
				i_clk				=>	i_clk,			
				i_rst				=>	i_rstn,			
				i_data_L			=> 	s_Disp_L,		
				i_data_R			=> 	s_Disp_R,	
				i_dval				=> 	s_val_SHD,	
				i_Tresh				=>	i_thresh_lrcc,
				o_dval				=>	o_dval,
				o_data_LRCC			=> 	o_data
				);

end RTL;