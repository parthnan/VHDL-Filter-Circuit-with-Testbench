library ieee;  
library modelsim_lib;
use ieee.std_logic_1164.all;
use modelsim_lib.util.all;

entity tb_filter is  
  generic(K: integer := 4;
          W: integer := 3);
end tb_filter;

architecture testbench of tb_filter is
  type mem is array(0 to 4) of std_logic_vector(K-1 downto 0);
  type test_vec_t is record
    key: std_logic_vector (3 downto 0);
    sw: std_logic_vector (9 downto 0);
  end record;
  type test_vec_array_t is array(natural range <>) of test_vec_t;
  constant input_table: test_vec_array_t :=
    (("1011", "0100000110"),
     ("0111", "0100000110"),
     ("1011", "0100001101"),
     ("0111", "0100001101"),
     ("1011", "0100001011"),
     ("0111", "0100001011"),
     ("1011", "0100000110"),
     ("0111", "0100000110"),
     ("1011", "0100001101"),
     ("0111", "0100001101"),
     ("1111", "0000000000"));
  constant period1: time := 20 ns;
  signal clk1: std_logic := '0';
  signal xrst1: std_logic;
  signal key: std_logic_vector(3 downto 0);
  signal sw: std_logic_vector(9 downto 0);
  signal filter_ram: mem;
  signal q: std_logic_vector(19 downto 0);

  component filter is
    port(
       CLOCK_50,RESET_N: in std_logic;
	   q: out std_logic_vector(19 downto 0);
	   KEY: in std_logic_vector(3 downto 0);
	   SW: in std_logic_vector(9 downto 0);
	   LEDR: out std_logic_vector (9 downto 0);
       HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: out std_logic_vector(6 downto 0));
  end component;

begin
  clock1: process
  begin
    wait for period1*0.25;
    clk1 <= not clk1;
    wait for period1*0.25;
  end process;

  stim1: process
  begin
    xrst1 <= '1';
    key <= (others => '1');
    sw <= (others => '0');
    wait for period1*2;
    xrst1 <= '0';
    wait for period1;
    xrst1 <= '1';
    wait for period1*5;
    for i in input_table'range loop
      key <= input_table(i).key;
      sw <= input_table(i).sw;
      wait for period1;
    end loop;
    key <= "1111";
    wait for period1*10;
    sw <= "1100000000";
    key <= "1110";
    wait for period1;
    key <= "1111";
    wait for period1;
    key <= "1110";
    wait for period1;
    key <= "1111";
    wait;
  end process;
    
  check: process
  begin
    init_signal_spy("tb_filter/filter1/ram1/ram_block","filter_ram",1);
    wait until key(0) = '0';
    wait for period1;
    wait until key(0) = '1';
    wait for period1*100;
    assert (q = "00101111111111111111") report "This data is different from correct answer!" severity failure;          
    wait for period1;
    assert (false) report "Simulation successfully completed!" severity failure;      
  end process;

  filter1: filter port map(CLOCK_50 => clk1,
                           RESET_N => xrst1,
                           q => q,
                           KEY => key,
                           SW => sw,
                           LEDR => open,
                           HEX0 => open,
                           HEX1 => open,
                           HEX2 => open,
                           HEX3 => open,
                           HEX4 => open,
                           HEX5 => open);

end testbench;

