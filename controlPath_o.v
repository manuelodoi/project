module controlPath(LOADX_KEY,PLOT_KEY,BLACK_KEY,Clock,Resetn_Key,counter,
		enCount,enRegX,enRegY,enColor,enALU,Reset,Plot,SelectPath,enBlackCount);
//  Some of the states:
//  RESET_S : reset state
//  LOADX_S : load X input into register
//  LOADY_S : load Y and start plotting
//  DRAW_S : Complete drawing of the box
//  PAUSE_S : Pauses FSM awaiting user input
//  BLACK_S : CHANGES the entire screen to black
//
//  Some of the control signals
//  
	input LOADX_KEY,PLOT_KEY,BLACK_KEY,Clock,Resetn_Key;
	input [14:0] counter;
	output reg enCount,enRegX,enRegY,enColor,enALU,Reset,Plot,SelectPath,enBlackCount;
	reg [2:0] PresentState, NextState;

	parameter on = 1'b1, off = 1'b0, dnc = 1'bx;
	parameter [14:0] totalScreenPixels = 160*120;
	parameter [2:0] RESET_S = 3'b000,LOADX_S = 3'b001, LOADY_S = 3'b010, DRAW_S = 3'b011,
						 PAUSE_S = 3'b100, BLACK_S = 3'b101;

	//  Part of the State table
   always @(*)
	begin: state_table
		case (PresentState)
			RESET_S: // RESET All registers
				begin
					if(!BLACK_KEY) NextState <= BLACK_S;
					else if(!LOADX_KEY) NextState <= LOADX_S;
					else NextState <= RESET_S;
				end
			LOADX_S: // Load register X
				NextState <= PAUSE_S;
			LOADY_S: // Load register Y and start plotting
				NextState <= DRAW_S;
			DRAW_S: // Complete drawing box
				begin
					if(counter < 15)
						NextState <= DRAW_S;
					else
						NextState <= RESET_S;
				end
			PAUSE_S: // Hold current status awaitinguser input
				begin
					if(!Resetn_Key) NextState <= RESET_S;
					else if(!PLOT_KEY) NextState <= LOADY_S;
					else NextState <= PAUSE_S;
				end
			BLACK_S: // Clear entire screen to black
            begin
					if(counter < (totalScreenPixels-1))
						NextState <= BLACK_S;
					else
						NextState <= RESET_S;
				end
			default:  NextState <= RESET_S;
		endcase
	end // state_table
	
	always@(posedge Clock)
	begin
		PresentState <= NextState;
	end
	
	

   // Part of the Output logic

    always @(*)
    begin: output_logic
        case (PresentState)
          // In each state a value to all control signals
			 RESET_S: //Clear all registers and set output to zero
				begin
					Reset = on;
					enCount = dnc;
					enRegX = dnc;
					enRegY = dnc;
					enColor = dnc;
					enALU = off;
					Plot = off;
					SelectPath = on;
					enBlackCount = off;
				end
			 LOADX_S: //Load Input values for X and color into their respective registers
				begin
					Reset = off;
					enCount = off;
					enRegX = on;
					enRegY = off;
					enColor = on;
					enALU = off;
					Plot = off;
					SelectPath = on;
					enBlackCount = off;
				end
			 LOADY_S: //Load Input value for Y into their respective register & start plotting
				begin
					Reset = off;
					enCount = off;
					enRegX = off;
					enRegY = on;
					enColor = off;
					enALU = on;
					Plot = on;
					SelectPath = on;
					enBlackCount = off;
				end
          DRAW_S: // Complete drawing
            begin
					Reset = off;
					enCount = on;
					enRegX = off;
					enRegY = off;
					enColor = off;
					enALU = on;
					Plot = on;
					SelectPath = on;
					enBlackCount = off;
            end
          PAUSE_S: // Pause & Await user input
            begin
					Reset = off;
					enCount = off;
					enRegX = off;
					enRegY = off;
					enColor = off;
					enALU = off;
					Plot = off;
					SelectPath = on;
					enBlackCount = off;
            end
			 BLACK_S: // Clear entire screen to Black
            begin
					Reset = off;
					enCount = off;
					enRegX = off;
					enRegY = off;
					enColor = off;
					enALU = off;
					Plot = off;
					SelectPath = off;
					enBlackCount = on;
            end
			 default:     
            begin
					Reset = on;
					enCount = dnc;
					enRegX = dnc;
					enRegY = dnc;
					enColor = dnc;
					enALU = off;
					Plot = off;
					SelectPath = on;
					enBlackCount = off;
            end
        endcase
    end // output_logic
endmodule