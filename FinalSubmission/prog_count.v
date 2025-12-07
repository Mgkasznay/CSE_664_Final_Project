//Program Counter 
//Inputs: Clock, Increment Program counter bit, load program counter bit, and select program counter value
//Output: Instruction Memory address

module prog_count (ins_mem, clk, incPC, loadPC, PCinput);
output reg [3:0] ins_mem; //Instrcution memory address value
input [7:0] PCinput; //Selected program counter
input clk, incPC, loadPC; //Clock and indicator bits for which progam counter to use

initial begin
	ins_mem = 4'b0000;
end

always @ (posedge clk)
begin
	if (loadPC) //Load selected program counter
	begin
		ins_mem <= PCinput[3:0];
	end
	else if (incPC) //Increament program counter
	begin
		ins_mem <= ins_mem + 1;
	end
	else //Neither increment or load program counter
	begin
		//DO NOTHING
	end
end
endmodule
