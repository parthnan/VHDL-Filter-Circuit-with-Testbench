# Digital Filter Circuit in VHDL
Project on Implementation of simple State transition to create a Digital Filter circuit. Input and output are 20 bit numbers, entered by hand on an FPGA board(or via the simulator, using testbench "tb_filter.vhd"). State transition diagram as shown:

![alt text](https://raw.githubusercontent.com/parthnan/VHDL-Filter-Circuit-with-Testbench/master/trans.png)

Examples of input and output sequences are as below:
If initial state is S1 then,		1111 0110 0101 1001 -> 0111 1111 0101 1101
If initial state is S4 then,		1111 0110 0101 1001 -> 1111 1111 0101 1101

An Example test run of the circuit,using the testbench :

Stage1) Saving the 20 bit input. The testbench "tb_filter.vhd" specifies an input of 0110 1101 1011 0110 1101 , one bit per clock cycle. This is stored in the "RAM" of the circuit (file 5-テスト格納.png)

![alt text](https://raw.githubusercontent.com/parthnan/VHDL-Filter-Circuit-with-Testbench/master/5-テスト格納.png)

Stage2) Outputting the 20 bit output , one bit by one bit. Final answer on the rightmost flank = 0010 1111 1111 1111 1111
 (file 5-テスト出力.png)

![alt text](https://raw.githubusercontent.com/parthnan/VHDL-Filter-Circuit-with-Testbench/master/5-テスト出力.png)



