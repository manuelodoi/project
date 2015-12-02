module counter15Bit(Clock,Reset,aluOp,Enable,Qx,Qy,Q);
	input Clock,Reset,Enable;
	input [1:0] aluOp;
	output reg [14:0]Q=15'd0;
	output reg [7:0] Qx=8'd0;
	output reg [6:0] Qy=7'd0;
	reg [7:0] xLimit,xmLimit;
	
	//ALU Operations
	parameter [1:0] fullscreen=2'b00, canvas=2'b01, answer=2'b10;
	
	always@(*)
	begin
		case(aluOp)
			fullscreen: begin
				xLimit<=8'd160;
				xmLimit<=8'd159;
			end
			canvas: begin
				xLimit<=8'd115;
				xmLimit<=8'd114;
			end
			answer: begin
				xLimit<=8'd21;
				xmLimit<=8'd20;
			end
		endcase
	end
	
	always @(posedge Clock)
		begin
			if(~Enable)
				Q<=15'd0;
			else if(Enable) 
				Q<=Q+1;
		end
	always @(posedge Clock)
		begin
			if(~Enable)
				Qx<=8'd0;
			else if(Enable)begin
					Qx<=(Q % xLimit);
			end
		end
		
	always @(posedge Clock)
		begin
			if(~Enable)
				Qy<=7'd0;
			else if(Enable) begin
					if(Qx == xmLimit) Qy<=Qy+1;
			end
		end
	
	
endmodule
