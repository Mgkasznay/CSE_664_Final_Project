//Program Counter 
//Inputs: Clock, Increment Program counter bit, load program counter bit, and select program counter value
//Output: Instruction Memory address

module prog_count (ins_mem, clk, incPC, loadPC, altPC);
output reg [3:0] ins_mem; //Instrcution memory address value
input [7:0] altPC; //Alternate program counter
input clk, incPC, loadPC; //Clock and indicator bits for which progam counter to use
always @ (posedge clk)
begin
	if (loadPC) //Load selected program counter
	begin
		ins_mem = altPC[3:0];
	end
	else if (incPC) //Increament program counter
	begin
		ins_mem = ins_mem + 1;
	end
	else //Niether increament or load program counter
	begin
		//DO NOTHING
	end
end
endmodule
