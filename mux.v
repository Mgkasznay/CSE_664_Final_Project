module mux (out, a, b, sel);
output reg [7:0] out;
input [7:0] a, b;
input sel;
always @ (a,b,sel)
begin
	if (sel)
	begin
		out = a;
	end
	else
	begin
		out = b;
	end
end
endmodule