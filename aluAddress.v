          

//this module takes the changes from the draw counter and adds them to the appropriate start x and y coordinates 
//then sends these modified coordinates to the VGA
//Also takes input regarding correct starting positions from control

module aluAddress(Xpos, Ypos, startX, startY, aluOp, out);

	input [7:0] startX, Xpos;
	input [6:0] startY, Ypos;
	input [1:0] aluOp;
	output [14:0] out;
	reg [7:0] x;
	reg [6:0] y;
	
	//ALU Operations
	parameter [1:0] fullscreen=2'b00, canvas=2'b01, answer=2'b10;
	
	/*Division and Modulus values
	fsValue = 160 | csValue = 115 | asValue = 18
	*/
	
	always@(*)
	begin
		if(aluOp == fullscreen) //120 x 160
		begin
			x <= (startX + (Xpos)) - 1'b1;
			y <= (startY + (Ypos)) ;
		end
		else if (aluOp == canvas) //70 x 115 
		begin
			x <= startX + (Xpos);
			y <= startY + (Ypos);
		end
		else if (aluOp == answer) //21 x 17
		begin
			x <= startX + (Xpos);
			y <= startY + (Ypos);
		end
		else
			begin
			x <= 8'bxxxxxxxx;
			y <= 7'bxxxxxxx;
		end
	end
	
	assign out = {y,x};
endmodule
