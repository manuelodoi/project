`timescale 1ns/1ns

//This file contains components of the random number generator 

//modified register that stores correct sequence
module sequenceReg (enable, random, clock, sequenceIn, toCompareOut);
	input enable;
	input clock;
	input random;
	output reg [14:0] sequenceIn;
	output [14:0] toCompareOut;
	assign toCompareOut=sequenceIn;
	always@(posedge clock)
	begin
		if (enable) begin
			sequenceIn[14]=random;
			sequenceIn = sequenceIn >> 1;             	
			end
		else sequenceIn<=sequenceIn;
	end
endmodule

//module reads out 15 bit sequence in 3 bit groups, representing colour
module readOut3bit (sequenceIn, clock, enable, out);
	input [14:0] sequenceIn;
	input clock;
	input enable;
	output reg [2:0] out;
	reg [14:0] toBeRead;

	always @ (posedge clock)
   begin
      if(~enable) begin
			out<=3'b000;
			toBeRead<=sequenceIn;
		end
		else if(enable) begin
			out<=toBeRead[2:0];
			toBeRead<=toBeRead >> 3;
			toBeRead[14]<=1'b1;
		end
		else out<=out;
	end
endmodule

//seven segment decoder used for testing
module decoder7segment (inputs, outwire);	
	input [3:0] inputs;
	output reg [6:0] outwire;		
	always@(*)	
		begin
			case (inputs)
				4'b0000 : outwire = 7'b1000000;
				4'b0001 : outwire = 7'b1111001;
				4'b0010 : outwire = 7'b0100100;
				4'b0011 : outwire = 7'b0110000;
				4'b0100 : outwire = 7'b0011001;
				4'b0101 : outwire = 7'b0010010;
				4'b0110 : outwire = 7'b0000010;
				4'b0111 : outwire = 7'b1111000;
				4'b1000 : outwire = 7'b0000000;
				4'b1001 : outwire = 7'b0011000;
				4'b1010 : outwire = 7'b0001000;
				4'b1011 : outwire = 7'b0000011;
				4'b1100 : outwire = 7'b1000110;
				4'b1101 : outwire = 7'b0100001;
				4'b1110 : outwire = 7'b0000110;
				4'b1111 : outwire = 7'b0001110;
				default : outwire = 7'b1111111;
			endcase
		end
endmodule



//this is the module that actually generates random output
module lfsr_6bit(clk, data);
input clk;
output reg [5:0] data = 6'h3f;
 
reg [5:0] data_next;

always @(*) begin
//as you can see, the bits are xor'd together, and change on the clock edge.
//this module is never reset after it starts running, so every run it will produce different numbers
  data_next[5] = data[5]^data[2];
  data_next[4] = data[4]^data[1];
  data_next[3] = data[3]^data[0];
  data_next[2] = data[2]^data_next[4];
  data_next[1] = data[1]^data_next[3];
  data_next[0] = data[0]^data_next[2];
end

always @(posedge clk)
  //if(!rst_n)
    //data <= 5'h1f;
  //else
    data <= data_next;

endmodule

//module that ouputs random sequence to the register
module randomGenerate(Clock, Enable, Reset, out);
	input Clock,Enable,Reset;
	output reg [14:0] out;
	reg [3:0] counter = 4'd0;
	wire [5:0] data;
	
	//lfsr instantiation
	lfsr_6bit lfsr1(Clock, data);
	
	always@(posedge Clock)
	begin
		if(Reset) counter<=4'd0;
		else if(Enable) 
			if(counter<4'd3)
				counter <= counter +1;
			else counter<=4'd0;
	end
	
	always@(posedge Clock)
	begin
		if(counter == 4'd1) out[4:0] <= data[4:0];
		else if(counter == 4'd2) out[9:5] <= data[4:0];
		else if(counter == 4'd3) out[14:10] <= data[4:0];
	end
	
endmodule

//muxes relating to colour selection
module mux2to1(sel,one,two,colour);
	input sel;
	input [2:0] one,two;
	output [2:0] colour;
	
	assign colour = (sel)? one: two;
endmodule

module mux5to1(sel,in,colour);
	input [3:0] sel;
	input [14:0] in;
	output reg [2:0] colour;
	
	always@(*)
	begin
		case(sel)
			4'd1: colour<=in[2:0];
			4'd2: colour<=in[5:3];
			4'd3: colour<=in[8:6];
			4'd4: colour<=in[11:9];
			4'd5: colour<=in[14:12];
			default: colour<=3'd0;
		endcase
	end
endmodule
