`timescale 1ns/1ns

//This module has all the controls and registers regarding the random number generator
module sequence_datapath (clock, enRandomSet, enRandomLoad1, enStoreRandom, enRandomRead,
								  toCompare, readOut);

	input clock;
	input enRandomSet, enRandomLoad1, enStoreRandom, enRandomRead; //some enables for registers, counters
	wire randomWire;
	wire [14:0] sequenceWire; //goes to reader module
	output [14:0]toCompare; //goes to compare module
	output [2:0]readOut; //goes to VGA
	
	generateRandoms randoms(.reset(enRandomSet), .clock(clock), .out(randomWire), .load1(enRandomLoad1));
	sequenceReg sequenceReg1 (.enable(enStoreRandom), .random(randomWire), .clock(clock), .sequenceIn(sequenceWire), .toCompareOut(toCompare));
	readOut3bit read1(.sequenceIn(sequenceWire), .clock(clock), .enable(enRandomRead), .out(readOut));

endmodule

//modified 15 bit register that reads in 1 bit at a time from the random generator
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


//this module generates random numbers using a sequence of shift registers. The ouputs of registers 3 and 4 are XOR'd together
//then used as the input for register 1, and also used as the out portion of the module.
module generateRandoms(reset, clock, out, load1);
	input reset;
	input clock;
	input load1; //this is activated ONLY at Sreset, needed to start generation process (without it, out will always be 0)
	output out;
	 
	wire w1to2, w2to3, w3to4, w4toXOR, XORtoIn;
	//series of shift registers connected together		
	shiftReg SR1(.reset(reset), .clock(clock), .in(XORtoIn), .out(w1to2));
	shiftReg SR2(.reset(reset), .clock(clock), .in(w1to2), .out(w2to3));
	shiftReg SR3(.reset(reset), .clock(clock), .in(w2to3), .out(w3to4), .load(load1));
	shiftReg SR4(.reset(reset), .clock(clock), .in(w3to4), .out(w4toXOR));


	assign XORtoIn = (w4toXOR ^ w3to4);
	assign out = w4toXOR;
endmodule
 
module shiftReg(reset, clock, in, out, load);
	input reset;
	input clock;
	input in;
	input load;
	output reg out;
	always@(posedge clock)
   begin
		if(load==1'b1)
			out<=load;
		else if(~reset)
			out<=1'b0;
		else
         out<=in;
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

module lfsr_6bit(clk, data);
input clk;
output reg [5:0] data = 6'h3f;
 
reg [5:0] data_next;

always @(*) begin
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

module randomGenerate(Clock, Enable, Reset, out);
	input Clock,Enable,Reset;
	output reg [14:0] out;
	reg [3:0] counter = 4'd0;
	wire [5:0] data;
	
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
