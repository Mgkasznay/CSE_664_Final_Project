//Mux
//Inputs: selection bit, input A, input B
//Output: selected value

module mux (out, a, b, sel);
output reg [7:0] out; //8 bit selected value
input [7:0] a, b; //8 bit inputs
input sel; //Input selection bit
always @ (a,b,sel)
begin
	if (sel) //If sel is true output is A
	begin
		out = a;
	end
	else //If sel is false output is B
	begin
		out = b;
	end
end
endmodule
