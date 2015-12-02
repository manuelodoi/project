module verifyAns(fromRG,fromAns,result);
	input [14:0] fromRG,fromAns;
	output result;
	assign result = (fromRG == fromAns)? 1: 0;
endmodule
