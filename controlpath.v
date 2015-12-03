//Control Path

`timescale 1ns/1ns

module controlPath (
inLevel,cReset,keyPressed, key2Pressed,
reset, clock, counterForRead, counterForInput, counterForGenerate, counterForDraws,start,dividerOut,
compare, enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet,
 enDivider, enAns5, enAns4, enAns3, enAns2, enAns1, plot, selStart, aluOp, selColour, selAns, LEDRtest, sel2color, fsEnable, ansEnable
);
	//State parameters
	parameter Sreset=5'd0, SresetDraw=5'd1, SgetLevel=5'd2, ScheckLevel=5'd3, SdrawStart=5'd4,
				 Sgenerate=5'd5, SpreRead=5'd6, SreadRandom=5'd7, SpauseRandom=5'd8, 
				 SdrawRandom=5'd9, SdrawBlack=5'd10, SpauseInput=5'd11, SstoreInput=5'd12, 
				 SdrawInput=5'd13, Sverify=5'd14, SdrawResult=5'd15, Swin=5'd16, Slose=5'd17,
				 SnextLevel=5'd18;
	
	parameter fullscreen=2'b00, canvas=2'b01, answer=2'b10;
	//Counter Max Values for Drawing
	parameter fsValue = 15'd19200, csValue = 15'd8050, asValue = 15'd357;
	
	//Colour Parameters
	parameter [2:0] Black = 3'b001, GameScreen = 3'b010, StartScreen = 3'b011, 
						 RandomGenerator = 3'b100, WinScreen = 3'b101,LoseScreen = 3'b110,
						 AnswerColor=3'b111;
	
	//Parameter for selStart
	parameter startM=3'd0, startC=3'd1,startA1=3'd2,startA2=3'd3,startA3=3'd4,startA4=3'd5,startA5=3'd6;
	
<<<<<<< HEAD
	input reset, clock, keyPressed; //reset, clock, input from keyboard
	input [2:0] inLevel;		//tells control what level user is on
   	input [3:0]counterForGenerate;	//counter for random number generator
   	input [3:0]counterForRead, counterForInput; //counters for 3-state loops in control path
	input [14:0]counterForDraws; //counter that notifies control when screen has been drawn completely
	input start, dividerOut, compare; //inputs that affect several state changes 
>>>>>>> origin/master
	
	//these outputs are enables for counters, registers, and other modules in the datapath
	output reg enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet,
	enDivider, enAns5, enAns4, enAns3, enAns2,enAns1, plot,cReset;
	
	//these outputs send info to datapath
	output reg [2:0]selStart;
	output reg [1:0]aluOp;
	output [4:0]LEDRtest;
	assign LEDRtest=currState;
	output reg [2:0]selColour, selAns;
	output reg sel2color, fsEnable, ansEnable;
	
	
	reg[4:0]currState;
	reg[4:0]nextState;
	
	//Next state logic
	always@(*)
		begin: state_table
		
		case(currState)
		
		//reset state allows user to start, and sets up random generator, also loads background screen
		Sreset: begin
			if (start)
				nextState<=SresetDraw;
			else 
				nextState<=Sreset;
		end
		
		//this is where the user is sent after completing a level
		//redraws the start screen, allows user to choose new level
		SresetDraw: begin
			if(counterForDraws < csValue)
				nextState<=SresetDraw;
			else
				nextState<=SgetLevel;
		end
			
		SgetLevel: begin
			if (start)
				nextState<=ScheckLevel;
			else if (reset)
				nextState<=Sreset;
			else
				nextState<=SgetLevel;
		end
			
		ScheckLevel: begin
			if(inLevel > 3'd5)
				nextState<=SgetLevel;
			else if(inLevel == 3'd0)
				nextState<=SgetLevel;
			else
				nextState<=SdrawStart;
		end
		
		SdrawStart: begin
			if(counterForDraws < fsValue)
				nextState<=SdrawStart;
			else
				nextState<=Sgenerate;
		end
		
		//Sgenerate is where random number sequence is generated, stored into register. This sequence
		//will be remembered in the register until the next time Sgenerate is entered
		Sgenerate: begin
			if(counterForGenerate<4'd3)
				nextState<=Sgenerate;
			else 
				nextState<=SpreRead;
		end
		
		//This 1 clock cycle state allows for the proper sequence to be read into the VGA
		SpreRead: begin
			nextState<=SreadRandom;
		end
		
		//This state occurs in a loop with the next two, 5 times per level. It reads out a 
		//3bit number from the random generator, which is read as a colour by the VGA.
		//The next two states pause for a set time, then draw the colour on the screen.
		SreadRandom: begin
			nextState<=SpauseRandom;
		end
			
		SpauseRandom: begin
			if(dividerOut==1'b1) begin
				if(counterForRead==5'd7)
					nextState<=SdrawBlack;
				else 
					nextState<=SdrawRandom;
			end
			else 
				nextState<=SpauseRandom;
		end
			
		SdrawRandom: begin
			if(counterForDraws<csValue)begin
				nextState<=SdrawRandom;
			end
			else
				nextState<=SreadRandom;				
		end
		
		SdrawBlack: begin
				nextState<=SpauseInput;				
		end
		
		//Similar to the 3 state loop above, but pauses until user input, not for a set time	
		SpauseInput: begin
			if(counterForInput<=5'd5) begin
				if(keyPressed==1'd1)
					nextState<=SstoreInput;
				else
					nextState<=SpauseInput;
			end
			else
				nextState<=Sverify;
		end
			
		SstoreInput: begin
			nextState<=SdrawInput;
		end
			
		SdrawInput: begin
			if(counterForDraws<asValue)begin
				nextState<=SdrawInput;
			end
			else 
				nextState<=SpauseInput;
		end
		
		//this state enables the compare module and allows it to check if the user has entered the correct input
		Sverify: begin
			nextState<=SdrawResult;
		end
			
		//the FSM already knows whether the input is correct: this state is where the correct exit screen is drawn,
		//and nextState is assigned to the correct final state
		SdrawResult: begin
			if(counterForDraws<csValue)
				nextState<=SdrawResult;
			else begin
				if(compare==1'd1)
					nextState<=Swin;
				else 
					nextState<=Slose;
			end
		end
		
		//To leave these states, the user must choose to go to next level (for win) or reset (for win or lose)
		Swin: begin
			if(key2Pressed)
				nextState<=SresetDraw;
			else if (reset)
				nextState<=SresetDraw;
			else 
				nextState<=Swin;
		end
			
		SnextLevel: begin
			nextState<=ScheckLevel;
		end
			
		Slose: begin
			if(key2Pressed)
				nextState<=SresetDraw;
			else 
				nextState<=Slose;
		end
		
		default: nextState <= Sreset;
			
		endcase
	end
	
	
	//Current state logic
	always@(*)
		begin:output_logic
		
		case(currState)
		
			Sreset: begin
				cReset <= 1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bxx;
				selColour <= 3'bxxx;
				enDivider <= 1'b0;
				enAns1 <= 1'b0;
				enAns2 <= 1'b0;
				enAns3 <= 1'b0;
				enAns4 <= 1'b0;
				enAns5 <= 1'b0;
				plot <= 1'b0;
				selAns<=3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'b1;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
				
			end
				
			SresetDraw: begin
				cReset <= 1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				selStart <= startC;
				aluOp <= canvas;
				selColour <= StartScreen;
				enDivider <= 1'b0;
				enAns1 <= 1'b0;
				enAns2 <= 1'b0;
				enAns3 <= 1'b0;
				enAns4 <= 1'b0;
				enAns5 <= 1'b0;
				plot <= 1'b1;
				selAns<=3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			SgetLevel: begin
				cReset<=1'b1;
				enLevel <= 1'b1;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bxx;
				selColour <= 3'bxxx;
				enDivider <= 1'bx;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
		
			ScheckLevel: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bx;
				selColour <= 3'bxxx;
				enDivider <= 1'bx;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SdrawStart: begin
				cReset <= 1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				selStart <= startM;
				aluOp <= fullscreen;
				selColour <= GameScreen;
				enDivider <= 1'b0;
				enAns1 <= 1'b0;
				enAns2 <= 1'b0;
				enAns3 <= 1'b0;
				enAns4 <= 1'b0;
				enAns5 <= 1'b0;
				plot <= 1'b1;
				selAns<=3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b1;
				ansEnable <=1'b0;
			end
		
			Sgenerate: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bx;
				selColour <= 3'bxxx;
				enDivider <= 1'bx;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b1;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b1;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SpreRead: begin
				cReset<=1'd0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bx;
				selColour <= 3'bxxx;
				enDivider <= 1'bx;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b0;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
		
			SreadRandom: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bx;
				selColour <= 3'bxxx;
				enDivider <= 1'b1;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b1;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b0;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			SpauseRandom: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bxxx;
				aluOp <= 2'bx;
				selColour <= 3'bxxx;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b0;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			SdrawRandom: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				selStart <= startC;
				aluOp <= canvas;
				selColour <= RandomGenerator;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b1;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b0;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SdrawBlack: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				selStart <= startC;
				aluOp <= canvas;
				selColour <= Black;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SpauseInput: begin
				cReset<=1'd0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bx;
				aluOp <= 2'bxx;
				selColour <= AnswerColor;
				enDivider <= 1'b0;
				enAns1 <= 1'b0;
				enAns2 <= 1'b0;
				enAns3 <= 1'b0;
				enAns4 <= 1'b0;
				enAns5 <= 1'b0;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SstoreInput: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= AnswerColor;
				aluOp <= 2'bxx;
				selColour <= 3'bxx;
				enDivider <= 1'b0;
				if(counterForInput==4'd1)
					enAns1 <= 1'b1;
				else
					enAns1 <= 1'b0;
				if(counterForInput==4'd2)
					enAns2 <= 1'b1;
				else
					enAns2 <= 1'b0;
				if(counterForInput==4'd3)
					enAns3 <= 1'b1;
				else
					enAns3 <= 1'b0;
				if(counterForInput==4'd4)
					enAns4 <= 1'b1;
				else
					enAns4 <= 1'b0;
				if(counterForInput==4'd5)
					enAns5 <= 1'b1;
				else
					enAns5 <= 1'b0;
				plot <= 1'b0;
				if(counterForInput==4'd1)
					selAns <= 3'd1;
				else if(counterForInput==4'd2)
					selAns <= 3'd2;
				else if(counterForInput==4'd3)
					selAns <= 3'd3;
				else if(counterForInput==4'd4)
					selAns <= 3'd4;
				else if(counterForInput==4'd5)
					selAns <= 3'd5;
				else
					selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			SdrawInput: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				if(counterForInput==4'd1)selStart <= startA1;
				else if(counterForInput == 3'd2) selStart <= startA2;
				else if(counterForInput == 3'd3) selStart <= startA3;
				else if(counterForInput == 3'd4) selStart <= startA4;
				else if(counterForInput == 3'd5) selStart <= startA5;
				else selStart<=3'dx;
				aluOp <= answer;
				selColour <= AnswerColor;
				enDivider <= 1'b0;
				enAns1 <= 1'b0;
				enAns2 <= 1'b0;
				enAns3 <= 1'b0;
				enAns4 <= 1'b0;
				enAns5 <= 1'b0;
				plot <= 1'b1;
				if(counterForInput==4'd1)
					selAns <= 3'd1;
				else if(counterForInput==4'd2)
					selAns <= 3'd2;
				else if(counterForInput==4'd3)
					selAns <= 3'd3;
				else if(counterForInput==4'd4)
					selAns <= 3'd4;
				else if(counterForInput==4'd5)
					selAns <= 3'd5;
				else
					selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b1;
			end
				
				
			Sverify: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'bx;
				aluOp <= 2'bxx;
				selColour <= 3'bxxx;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			SdrawResult: begin
				cReset<=1'b0;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b1;
				selStart <= startC;
				aluOp <= canvas;
				if(compare==1'b1)
					selColour <= WinScreen;
				else
					selColour<=LoseScreen;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b1;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			Swin: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'dx;
				aluOp <= 2'bxx;
				selColour <= 3'dx;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			Slose: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'dx;
				aluOp <= 2'bxx;
				selColour <= 3'dx;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
			
			default: begin
				cReset<=1'b1;
				enLevel <= 1'b0;	
				enDrawCount <= 1'b0;
				selStart <= 3'dx;
				aluOp <= 2'bxx;
				selColour <= 3'dx;
				enDivider <= 1'b0;
				enAns1 <= 1'bx;
				enAns2 <= 1'bx;
				enAns3 <= 1'bx;
				enAns4 <= 1'bx;
				enAns5 <= 1'bx;
				plot <= 1'b0;
				selAns <= 3'dx;
				enStoreRandom <= 1'b0;
				enRandomRead <= 1'b0;
				enRandomLoad1 <= 1'bx;
				enRandomSet <= 1'b0;
				sel2color<=1'b1;
				fsEnable <= 1'b0;
				ansEnable <=1'b0;
			end
				
			endcase
			
		end
		
		
	always@(posedge clock)
		begin
			currState<=nextState;
		end
		
endmodule


