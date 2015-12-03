          
//this file contains modules that take level information and divide the clock frequency accordingly

//holds insantiations of rate divider, and LEDRtest module
module pixelRateDivider(Clock,out,light, level);
	input Clock;
	input [2:0] level;
	output out;
	output light;
	wire [3:0] Q;
	
	clkCounter cC(Clock,out, level);
	checkLight cL(out,light);	
endmodule

//this module takes level input (1-5) and implements the approriate resets/out assignments
module clkCounter(Clock,out, level);
	input Clock;
	input [2:0]level;
	output reg out;
	reg [29:0] counter = 30'd0;
	
	always@(posedge Clock)
	begin
		if(level==3'd1 && counter == 30'd100000000)
			counter <= 30'd0;
		else if (level==3'd2 && counter==30'd80000000)
			counter <= 30'd0;
		else if (level==3'd3 && counter==30'd60000000)
			counter <= 30'd0;
		else if (level==3'd4 && counter==30'd40000000)
			counter <= 30'd0;
		else if (level==3'd5 && counter==30'd20000000)
			counter <= 30'd0;
		else if (counter==30'd100000000)
			counter <= 30'd0;
		else
			counter = counter+1;
	end
	
	always@(*)
	begin
	case (level)
		3'd1 : out = (counter == 30'd100000000);
		3'd2 : out = (counter == 30'd80000000);
		3'd3 : out = (counter == 30'd60000000);
		3'd4 : out = (counter == 30'd40000000);
		3'd5 : out = (counter == 30'd20000000);
		default: out = (counter == 30'd100000000);
		endcase
	end
	
		
endmodule


//counter that is used several times throughout the design
module counterToFive(Clock, Enable, Reset, Q);
	input Clock,Enable,Reset;
	output reg [3:0] Q = 4'b0;
	
	always@(posedge Clock)
	begin
		if(Reset)
			Q<=4'b0;
		else if(Enable)
			Q<=Q+1;
	end
endmodule

//test module to make sure rate divider is working
module checkLight(in, out);
	input in;
	output reg out;
	
	always@(posedge in)
	begin
		out <= ~out;
	end
endmodule

//hex display module for testing
module hexDisplay(c,d);
	input [3:0] c;
	output reg [0:6] d;	 
	always@(*)
	begin
		case (c)   
			4'b0000 : d = 7'b0000001; //0
			4'b0001 : d = 7'b1001111; //1
			4'b0010 : d = 7'b0010010; //2
			4'b0011 : d = 7'b0000110; //3
			4'b0100 : d = 7'b1001100; //4
			4'b0101 : d = 7'b0100100; //5
			4'b0110 : d = 7'b0100000; //6
			4'b0111 : d = 7'b0001111; //7
			4'b1000 : d = 7'b0000000; //8
			4'b1001 : d = 7'b0001100; //9
			4'b1010 : d = 7'b0001000; //A
			4'b1011 : d = 7'b1100000; //b
			4'b1100 : d = 7'b0110001; //C
			4'b1101 : d = 7'b1000010; //d
			4'b1110 : d = 7'b0110000; //E
			4'b1111 : d = 7'b0111000; //F
			default : d = 7'b1111111; //No Display
		endcase
	  end
endmodule
