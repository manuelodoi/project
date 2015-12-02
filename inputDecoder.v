module inputDecoder(usrInput, value);
	input [7:0] usrInput; //keyboard
	output reg [2:0] value;
	
	parameter val1=8'h16,val2=8'h1E,val3=8'h26,val4=8'h25,
				 val5=8'h2E,val6=8'h36,val7=8'h3D,val8=8'h3E;
	
	parameter black =3'b000,blue =3'b001,green =3'b010,cyan =3'b011,red =3'b100,pink =3'b101,
				 yellow =3'b110,white =3'b111;
	
	always@(*)
	begin
		case(usrInput)
			val1: value <=black;
			val2: value <=blue; 
			val3: value <=green; 
			val4: value <=cyan; 
			val5: value <=red; 
			val6: value <=pink; 
			val7: value <=yellow; 
			val8: value <=white; 
			default: value <= 3'bxxx;
		endcase
	end
endmodule
