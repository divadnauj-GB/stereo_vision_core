library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use   work.funciones_pkg.all;

--Entidad del Testbech
entity Stereo_Match_wrapper is
generic(
		D		:integer		:=	64;
		Wc		:integer		:= 7;	-- Tamaño de la ventana de Census_Transform
		Wh		:integer		:=	13;	--	Tamaño de la ventana de Hamming
		M		:integer		:= 450;	-- Ancho de la imagen
		N		:integer		:= 8;		--	Numero de bits del dato de entrada
		log2_D	:integer		:= 6 -- log2(D)
		);
port(
	i_clk			:in		std_logic;
	i_rst			:in		std_logic;
	i_dato_L		:in		std_logic_vector(7 downto 0);
	i_dato_R		:in		std_logic_vector(7 downto 0);
	i_dval			:in		std_logic;
	i_Tresh_LRCC	:in		std_logic_vector(log2_D downto 0);
	o_dval			:out	std_logic;
	o_dato			:out	std_logic_vector(log2_D downto 0)
	);
end entity Stereo_Match_wrapper;


architecture rtl of Stereo_Match_wrapper is 


-- A partir de aqui puede hacer las modificaciones que necesite
-- Declaracion de las señales que se emplearan para dar los estimulos
--al diseño que requieren comprobar.

begin


--Haga la instancia de su diseño aqui


UUT: entity work.stereo_match
	generic map(
				D		=> D,
				Wc		=> Wc,	-- Tamaño de la ventana de Census_Transform
				Wh		=> Wh,	--	Tamaño de la ventana de Hamming
				M		=> M,	-- Ancho de la imagen
				N		=> N		--	Numero de bits del dato de entrada
				)
	port map(
			i_clk		    	=>  i_clk, 
			i_rstn		    	=>  i_rst, 
			i_data_l	    	=>  i_dato_L, 
			i_data_r	    	=>  i_dato_R, 
			i_dval		    	=>  i_dval, 
			i_thresh_lrcc    	=>  i_Tresh_LRCC, 
			o_dval		    	=>  o_dval, 
			o_data		    	=>  o_dato);


end rtl;
		
