library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use   work.funciones_pkg.all;
USE std.textio.ALL;  -- libreria para simulacion con archivos

--Entidad del Testbech
entity Stereo_Match_tb is
	generic(
		D		:integer		:=	48;
		Wc		:integer		:= 7;	-- Tamaño de la ventana de Census_Transform
		Wh		:integer		:=	13;	--	Tamaño de la ventana de Hamming
		M		:integer		:= 384;	-- Ancho de la imagen
		N		:integer		:= 8		--	Numero de bits del dato de entrada
		);
end entity Stereo_Match_tb;


architecture rtl of Stereo_Match_tb is 
--declaracion de objetos para trabajar con archivos de texto   
FILE vector_Datos_left_image		: TEXT OPEN READ_MODE is "input_vector_left_image.txt";
FILE vector_Datos_right_image		: TEXT OPEN READ_MODE is "input_vector_right_image.txt";
FILE vector_Valid_i		: TEXT OPEN READ_MODE is "input_vector_valid.txt";

FILE vector_Datos_o		: TEXT OPEN WRITE_MODE is "output_vector_data.txt";
FILE vector_Valid_o		: TEXT OPEN WRITE_MODE is "output_vector_valid.txt";

-- A partir de aqui puede hacer las modificaciones que necesite
-- Declaracion de las señales que se emplearan para dar los estimulos
--al diseño que requieren comprobar.

signal si_clk			:std_logic :='0';					
signal si_rst			:std_logic :='0';					
signal si_dato_L		:std_logic_vector(7 downto 0) :=(others=>'0');		
signal si_dato_R		:std_logic_vector(7 downto 0) :=(others=>'0');	
signal si_dval			:std_logic :='0';				
signal si_Tresh_LRCC	:std_logic_vector(log2(D) downto 0) := std_logic_vector(to_unsigned(8,log2(D)+1));--"1111";	
signal so_dval			:std_logic;				
signal so_dato			:std_logic_vector(log2(D) downto 0);			


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
			i_clk		    	=>  si_clk, 
			i_rstn		    	=>  si_rst, 
			i_data_l	    	=>  si_dato_L, 
			i_data_r	    	=>  si_dato_R, 
			i_dval		    	=>  si_dval, 
			i_thresh_lrcc    	=>  si_Tresh_LRCC, 
			o_dval		    	=>  so_dval, 
			o_data		    	=>  so_dato);

--Generacion de la señal de reloj			
	process
	begin
	si_clk	<=	not si_clk;
	wait for 10 ns;
	end process;

--cuando arranca la simulacion se debe reiniciar
--el diseño para que funcione adecuadamente, es el 
--equivalente a encender la TARJETA.
	process
	begin
	si_rst	<=	'0';
	wait for 500 ns;
	si_rst	<=	'1';
	wait;
	end process;
	
	

	
--Este es el proceso de generacion de estímulos a partir de archivos 
--de texto donde se encuentran los valores que deben ser 
--puestos en el modulo para comprobar el funcionamiento.
	process
		variable		Vect_Line_Data_in_L		:line;
		variable		Vect_Line_Data_in_R		:line;

		variable		Vect_Line_Valid_in		:line;
		
		variable		Vect_Line_Data_out		:line;
		
		variable		Vect_Line_Valid_out		:line;
		variable		data_i_L			:integer;
		variable		data_i_R			:integer;
		variable		valid_i			:integer;
		variable		data_o			:integer;
		variable		valid_o			:integer;
		variable		valid_vi		:std_logic_vector(0 downto 0);
		variable		valid_vo		:std_logic_vector(0 downto 0);
	begin
		wait for 600 ns;
		wait until falling_edge(si_clk);	
			while not endfile (vector_Datos_left_image) loop
				readline(vector_Datos_left_image, Vect_Line_Data_in_L);
				read(Vect_Line_Data_in_L,data_i_L);

				readline(vector_Datos_right_image, Vect_Line_Data_in_R);
				read(Vect_Line_Data_in_R,data_i_R);
				
				readline(vector_Valid_i, Vect_Line_Valid_in);
				read(Vect_Line_Valid_in,valid_i);

				si_Dato_L			<=	std_logic_vector(to_unsigned(data_i_L,8));
				si_Dato_R			<=	std_logic_vector(to_unsigned(data_i_R,8));

				valid_vi			:=	std_logic_vector(to_unsigned(valid_i,1));
				si_dval			<=	valid_vi(0);
				wait until falling_edge(si_clk);			
				data_o				:=	to_integer(unsigned(so_Dato));
				valid_vo(0)			:=	so_dval;
				valid_o				:=	to_integer(unsigned(valid_vo));
				write(Vect_Line_Data_out,data_o);
				writeline(vector_Datos_o, Vect_Line_Data_out);
				
				write(Vect_Line_valid_out,valid_o);
				writeline(vector_valid_o, Vect_Line_valid_out);
			end loop;
		report " simulation Ends " severity failure;
		wait;
	end process;
end rtl;
		
