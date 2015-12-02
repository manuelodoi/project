// Part 2 skeleton

module memory_game
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  LEDR,
		  HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,
		// The ports for PS/2 input
		PS2_DAT,
		PS2_CLK,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;
	output [9:0] LEDR;
	output [0:6] HEX0,HEX1,HEX2,HEX3,HEX4,HEX5;
	reg light;
	
	
	// Bidirectionals
	inout				PS2_CLK;
	inout				PS2_DAT;


	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour,colour1,colour2;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	
	//Create wire for PS/2 data and KeyPressed signal
	wire [7:0] usrAns;
	wire keyPressed;
	
	//Create an Instance of a PS/2 controller	
	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50				(CLOCK_50),
		.reset				(~KEY[0]),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(usrAns),
		.received_data_en	(keyPressed)
	);

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "game.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	pixelRateDivider prd1(CLOCK_50,dividerOut,LEDR[9], SW[2:0]);
	counterToFive ctf(CLOCK_50, enDivider, cReset, counterForRead);
	randomGenerate rg(CLOCK_50, enRandomSet, cReset, seqOut);
	mux2to1 muxColor1(sel2color,colour1,colour2,colour); 
	mux5to1 muxColor2(counterForRead,seqOut,colour2);
	hexDisplay hex0(counterForInput, HEX0);
	hexDisplay hex1({1'b0,allAns[2:0]}, HEX1);
	hexDisplay hex2({1'b0,allAns[5:3]}, HEX2);
	hexDisplay hex3({1'b0,allAns[8:6]}, HEX3);
	hexDisplay hex4({1'b0,allAns[11:9]}, HEX4);
	hexDisplay hex5({1'b0,allAns[14:12]}, HEX5);
	
	// for the VGA controller, in addition to any other functionality your design may require.
	reg [3:0] toh1,toh2, toh3,toh4,toh5;
	wire [3:0]counterForGenerate,countfr;
   wire [3:0]counterForRead, counterForInput;
	wire [14:0]counterForDraws,toCompare,seqOut,allAns;
	wire  dividerOut, compare,cReset;
	wire csEnable, fsEnable, ansEnable;
	wire enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet,
				   enDivider, enAns5, enAns4, enAns3, enAns2,enAns1;
   wire [2:0]selStart;
	wire [1:0]aluOp;
	wire [2:0]selColour, selAns;
    // Instanciate FSM control
	 controlPath c1(SW[2:0],cReset,~KEY[1], ~KEY[2],
~KEY[0], CLOCK_50, counterForRead, counterForInput, counterForGenerate, counterForDraws,~KEY[3],dividerOut,
compare, enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet, 
 enDivider, enAns5, enAns4, enAns3, enAns2, enAns1, writeEn, 
selStart, aluOp, selColour, selAns, LEDR[4:0], sel2color, fsEnable, ansEnable
);
    // Instanciate datapath
	dataPath d1(SW[9:7],SW[2:0],~KEY[1], ~KEY[2], cReset,toCompare,seqOut,allAns,
~KEY[0], CLOCK_50, countfr, counterForInput, counterForGenerate, counterForDraws,
compare, enStoreRandom, enRandomRead, enRandomLoad1, enLevel, enDrawCount, enRandomSet, 
 enDivider, enAns5, enAns4, enAns3, enAns2, enAns1,
selStart, aluOp, selColour,selAns,{y,x},colour1, csEnable, fsEnable, ansEnable);

endmodule
