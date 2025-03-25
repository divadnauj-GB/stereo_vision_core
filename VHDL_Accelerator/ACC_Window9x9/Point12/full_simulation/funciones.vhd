-- Library Clause(s) (optional)
-- Use Clause(s) (optional)
library ieee;
use ieee.std_logic_1164.all;
use 	ieee.numeric_std.all;

package funciones is

	function log2( i : integer) return integer;
	
end funciones;

package body funciones is

function log2( i : integer) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 0; 
  begin					
    while temp > 1 loop
      ret_val := ret_val + 1;
      temp    := temp / 2;     
    end loop;
  	
    return ret_val;
  end function;

end funciones;