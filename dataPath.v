	module dataPath (usrAns, inLevel, keyPressed, key2Pressed, cReset, toCompare, compareR, allAns,
	Reset, Clock, counterForRead, counterForInput, counterForGenerate, counterForDraws,
	compare, enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet, 
	enDivider, enAns5, enAns4, enAns3, enAns2, enAns1,selStart,
	aluOp, selColour,selAns,address,colour, csEnable, fsEnable, ansEnable);
	input [2:0] selStart;
	input [2:0] inLevel; //This receives the level input;
	input [2:0] usrAns; //User's input for answers
	input Clock,Reset,cReset,keyPressed, key2Pressed;
	input  csEnable, fsEnable, ansEnable;
	//Enable signals from controlPath;
	input enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet,
	enDivider, enAns5, enAns4, enAns3, enAns2, enAns1;
	input [1:0]aluOp;
	input [2:0]selColour, selAns;
	input [14:0] compareR;
	output [3:0]counterForGenerate;
	output [3:0]counterForRead, counterForInput;
	output [14:0] counterForDraws;
	output [2:0] colour; //colour the VGA has to draw 
	output [14:0] address,toCompare,allAns; 	//address for VGA to draw @
	output compare;	//tells controlPath whether to draw & whether the user has lost or won
	
	
	//Internal Signals
	wire [14:0] fromDrawCounter,combAns;
	wire [2:0] black= 3'b000;
	wire [2:0] gScreen,sScreen,wScreen,lScreen,fromRG;
	wire wren = 1'b0;
	wire [2:0] fromRegLevel,data = 3'b000;
	wire [2:0] fromDecoder,fromAns1,fromAns2,fromAns3,fromAns4,fromAns5,ansColor;
	wire [7:0] fromRegX, Xpos;
	wire [6:0] fromRegY, Ypos;
	
	//Load MIF Files
	gamescreen mif1(fromDrawCounter,Clock,data,wren,gScreen);
	startscreen mif2(fromDrawCounter,Clock,data,wren,sScreen);
	win mif3(fromDrawCounter,Clock,data,wren,wScreen);
	lose mif4(fromDrawCounter,Clock,data,wren,lScreen);
	
	//Load Random Generator
	sequence_datapath dataRG(Clock,enRandomSet,enRandomLoad1,enStoreRandom,enRandomRead,
									 toCompare, fromRG);
	counter4Bit counterRG(Clock,Reset,enStoreRandom,counterForGenerate);
	
									 
	//Load User Answer Modules and Input Decoder
	inputDecoder colorDecoder(usrAns, fromDecoder); // Decodes keyboard input legend colour	
	reg3Bit regAns1(usrAns,Clock,Reset,enAns1,fromAns1);
	reg3Bit regAns2(usrAns,Clock,Reset,enAns2,fromAns2);
	reg3Bit regAns3(usrAns,Clock,Reset,enAns3,fromAns3);
	reg3Bit regAns4(usrAns,Clock,Reset,enAns4,fromAns4);
	reg3Bit regAns5(usrAns,Clock,Reset,enAns5,fromAns5);
	mux5to1_3Bit mux1(selAns,fromAns1,fromAns2,fromAns3,fromAns4,fromAns5,ansColor);
	
	assign combAns = {fromAns5,fromAns4,fromAns3,fromAns2,fromAns1};
	assign allAns = combAns;
	
	//Instantiate answer verification module
	verifyAns v1(compareR,combAns,compare);
	
	//Counters
	counter4Bit_sp counterReadRandom(Clock,cReset,enDivider,counterForRead);
	counter4Bit_sp counterInput(keyPressed,key2Pressed,1'b1,counterForInput);
	
	reg3Bit regL(inLevel,Clock,Reset,enLevel,fromRegLevel); //Stores level 
	multiStorage8Bit regx(Clock,selStart,fromRegX); //used to select the correct start coordinates for x
	multiStorage7Bit regy(Clock,selStart,fromRegY); // " " " y
	counter15Bit counter1(Clock,cReset,aluOp,enDrawCount, Xpos,Ypos,fromDrawCounter); //draw counter
	aluAddress alu1(Xpos, Ypos,fromRegX,fromRegY,aluOp,address); //sends address to VGA
	mux6to1_3Bit mux2(selColour,black,gScreen,sScreen,fromRG,wScreen,lScreen,ansColor,colour);
	
	assign counterForDraws = fromDrawCounter; //used for testing and loading mif files
	
endmodule

module multiStorage8Bit(Clock,selStart,Q);
	input Clock;
	input [2:0] selStart;
	output reg [7:0] Q;
	//Parameter for selStart
	parameter startC=3'd1,startA1=3'd2,startA2=3'd3,startA3=3'd4,startA4=3'd5,startA5=3'd6;
	//Start values for drawing answers;
	parameter ans1x = 8'd40,ans2x = 8'd64,ans3x = 8'd88,
				 ans4x = 8'd112,ans5x = 8'd136;
	//Start Values for X and Y in fullscreen and canvas mode;
	parameter fullscreenX = 8'd0, canvasX = 8'd2;
		
	always@(*)
	begin
		case(selStart)
		startC: Q<=canvasX;
		startA1: Q<=ans1x;
		startA2: Q<=ans2x;
		startA3: Q<=ans3x;
		startA4: Q<=ans4x;
		startA5: Q<=ans5x;
		default: Q<=8'b0;
		endcase
	end
endmodule

module multiStorage7Bit(Clock,selStart,Q);
	input Clock;
	input [2:0] selStart;
	output reg [6:0] Q;
	//Parameter for selStart
	parameter startC=3'd1,startA1=3'd2,startA2=3'd3,startA3=3'd4,startA4=3'd5,startA5=3'd6;
	//Start values for drawing answers;
	parameter ans1y=7'd97,ans2y=7'd97,ans3y=7'd97,ans4y=7'd97,ans5y=7'd97;
	//Start Values for X and Y in fullscreen and canvas mode;
	parameter fullscreenY = 7'd0, canvasY =7'd20;
		
	always@(*)
	begin
		case(selStart)
		startC: Q<=canvasY;
		startA1: Q<=ans1y;
		startA2: Q<=ans2y;
		startA3: Q<=ans3y;
		startA4: Q<=ans4y;
		startA5: Q<=ans5y;
		default: Q<=7'b0;
		endcase
	end
endmodule

module counter4Bit(Clock,Reset,Enable,Q);
	input Clock,Reset,Enable;
	output reg [3:0] Q = 4'b0;
	
	always@(posedge Clock)
	begin
		if(~Enable)
			Q <= 4'b0000;
		else if(Enable)
			Q <= Q+1;
	end
endmodule

//modified 4 bit counter, crucial for input and proper reseting of the FSM
module counter4Bit_sp(Clock,Reset,Enable,Q);
	input Clock,Reset,Enable;
	output reg [3:0] Q = 4'b0;
	always@(posedge Clock or posedge Reset)
	begin
		if(Reset)
			Q <= 4'b0000;

		 else if(Enable)
			Q <= Q+1;
		else 
			Q<=Q;
	end
endmodule

//various registers
module reg8Bit(D,Clock,Reset,Enable,Q);
	input Clock,Reset,Enable;
	input [7:0] D;
	output reg [7:0] Q=8'd0;
	
	always@(posedge Clock)
		if(Reset)
			Q <= 8'b00000000;
		else if(Enable)
			Q <= D;
endmodule

module reg7Bit(D,Clock,Reset,Enable,Q);
	input Clock,Reset,Enable;
	input [6:0] D;
	output reg [6:0] Q=8'd0;
	
	always@(posedge Clock)
		if(Reset)
			Q <= 7'b0000000;
		else if(Enable)
			Q <= D;
endmodule

module reg3Bit(D,Clock,Reset,Enable,Q);
	input Clock,Reset,Enable;
	input [2:0] D;
	output reg [2:0] Q;
	
	always@(posedge Clock)
		if(Reset)
			Q <= 3'b000;
		else if(Enable)
			Q <= D;
endmodule


//modified mux, chooses colors for answer based on input
module mux5to1_3Bit(selAns,Cans1,Cans2,Cans3,Cans4,Cans5,MUXout);
	input [2:0] selAns,Cans1,Cans2,Cans3,Cans4,Cans5;
	output reg [2:0] MUXout;
	
	//Colour Parameters
	parameter [2:0] Ans1=3'd1,Ans2=3'd2,Ans3=3'd3,Ans4=3'd4,Ans5=3'd5;
	always@(*)
	begin
		case(selAns)
			Ans1: begin
				MUXout <= Cans1;
			end
			Ans2: begin
				MUXout <= Cans2;
			end
			Ans3: begin
				MUXout <= Cans3;
			end
			Ans4: begin
				MUXout <= Cans4;
			end
			Ans5: begin
				MUXout <= Cans5;
			end
			default: MUXout = 3'b111;
		endcase
	end
endmodule	

//modified mux, chooses proper mif file to load based on colour choice from FSM
module mux6to1_3Bit(selColour,black,gScreen,sScreen,fromRG,wScreen,lScreen,ansColor,MUXout);
	input [2:0] selColour,black,gScreen,sScreen,fromRG,wScreen,lScreen,ansColor;
	output reg [2:0] MUXout;
	
	//Colour Parameters
	parameter [2:0] Black = 3'b001, GameScreen = 3'b010, StartScreen = 3'b011, 
						 RandomGenerator = 3'b100, WinScreen = 3'b101,LoseScreen = 3'b110,
						 AnswerColor=3'b111;
	always@(*)
	begin
		case(selColour)
			Black: begin //Black
				MUXout <= black;
			end
			GameScreen: begin //Main Game Screen
				MUXout <= gScreen;
			end
			StartScreen: begin //Where level is selected
				MUXout <= sScreen;
			end
			RandomGenerator: begin //Random Generator Values
				MUXout <= fromRG;
			end
			WinScreen: begin //Tells user he/she has won with further inst
				MUXout <= wScreen;
			end
			LoseScreen: begin ////Tells user he/she has won with further inst
				MUXout <= lScreen;
			end
			AnswerColor: begin ////Tells user he/she has won with further inst
				MUXout <= ansColor;
			end
			default: MUXout = black;
		endcase
	end
endmodule	
