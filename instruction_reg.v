//Instruction Register
// Inputs: Clock, Load Instruction Register, Instruction Register
// Output: Immediate/register, Opcode

module ins_reg(imed_reg, opcode, clk, loadIR, ins_reg);
output reg [3:0] imed_reg, opcode; //Imediate or register value and Opcode
input clk, loadIR; //Clock value and load instruction register
input [7:0] ins_reg; //Instruction register

always @ (posedge clk)
begin
	if (loadIR) //Load instruction register
	begin
		opcode = ins_reg[3:0]; //Set opcode value
		imed_reg = ins_reg[7:4]; //Set imediate value
	end
	else
	begin
		//DO NOTHING
	end
end


endmodule