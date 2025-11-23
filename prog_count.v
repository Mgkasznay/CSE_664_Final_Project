module prog_count (ins_mem, clk, clb, incPC, loadPC, selPC);
output reg [7:0] ins_mem;
input [7:0] selPC;
input clk, clb, incPC, loadPC;
always @ (posedge clk)
begin
	if (loadPC)
	begin
		ins_mem = selPC;
	end
	else if (incPC)
	begin
		ins_mem = ins_mem + 1;
	end
	else
	begin
		//DO NOTHING
	end
end
endmodule