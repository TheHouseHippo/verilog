// Simple 3-bit ALU with Registers and Displays
// Author: Grey aka Vapurrmaid
// Version 1.0
//
// The ALU performs unsigned addition and subtraction
// Underflow is taken care of by driving to zero ex 3 - 4 = 0 
// Overflow cannot occur 
// Was tested/demonstrated on Altera Cyclone II FPGA

//////// Addition Modules ///////////////////////
module half_adder_2(x, y, Cout, s);
	input x, y;
	output Cout, s; 
	
	assign s = x ^ y;
	assign Cout = x & y;

endmodule

module full_adder_2(x, y, Cin, Cout, s);
	input x, y, Cin;
	output Cout, s;
	
	assign Cout = (x & y) | (x & Cin) | (y & Cin);
	assign s = (~x & ~y & Cin) | (~x & y & ~Cin) |
				  (x & y & Cin) | (x & ~y & ~Cin);

endmodule

module ripple3add(x, y, s);
	input [2:0] x;
	input [2:0] y;
	output [3:0] s;
	
	wire Cout0, Cout1;
	
	half_adder_2(x[0], y[0], Cout0, s[0]);
	full_adder_2(x[1], y[1], Cout0, Cout1, s[1]);
	full_adder_2(x[2], y[2], Cout1, s[3], s[2]);
	
endmodule


//////// Subtraction Modules /////////////////////
module half_sub_2(x, y, D, B);
	input x, y;
	output D, B;
	
	assign D = x ^ y;
	assign B = ~x & y;

endmodule

module full_sub_2(x, y, z, D, B);
	input x, y, z;
	output D, B;
	
	assign D = x ^ y ^ z;
	assign B = (~x & (y ^ z)) | (y & z);

endmodule

module ripple3sub(x, y, result);
	input [2:0] x;
	input [2:0] y;
	output reg [2:0] result;
	wire [2:0] b;
	wire [2:0] s;
	
	half_sub_2(x[0], y[0], s[0], b[0]);
	full_sub_2(x[1], y[1], b[0], s[1], b[1]);
	full_sub_2(x[2], y[2], b[1], s[2], b[2]);
	
	always @(x, y)
		if (b[2] == 1) begin
			result <= 3'b000;
		end else begin
			result <= s;
		end
		
endmodule


//////// 7-Seg Hex Display Modules ///////////////
module hexdisp_one_2(s, leds); 
// this module drives a 7-segment display, leds
// to display a 3-bit input, s
	input [2:0] s;
	output reg [0:6] leds;
	
	always @(s)
		case (s)
			3'b000: leds = 7'b0000001; //0
			3'b001: leds = 7'b1001111; //1
			3'b010: leds = 7'b0010010; //2
			3'b011: leds = 7'b0000110; //3
			3'b100: leds = 7'b1001100; //4
			3'b101: leds = 7'b0100100; //5
			3'b110: leds = 7'b0100000; //6
			3'b111: leds = 7'b0001111; //7
			default: leds = 7'bx;
		endcase

endmodule

module hexdisp_op(op, leds);
	input op;
	output reg [0:6] leds;
	
	always @(op)
		if (op == 0) begin
			leds = 7'b1111000; //displays +
		end else begin 
			leds = 7'b1111110; //displays -
		end

endmodule

module hexdisp_eq_2(leds);
	output [0:6] leds;
	
	assign leds = 7'b1110110; //displays =

endmodule

module hexdisp_two_2(num, hexd1, hexd2);
	// This module drives two 7-seg displays
	// to be able to display 0 through 15
	input [3:0] num;
	output reg [0:6] hexd1; //right digit
	output reg [0:6] hexd2; //left digit
	
	always @(num)
		case (num)
			4'b0000: begin //00
				hexd1 = 7'b0000001;
				hexd2 = 7'b0000001;
				end
			4'b0001: begin //01
				hexd1 = 7'b1001111;
				hexd2 = 7'b0000001;
				end
			4'b0010: begin //02 
				hexd1 = 7'b0010010;
				hexd2 = 7'b0000001;
				end
			4'b0011: begin //03 
				hexd1 = 7'b0000110;
				hexd2 = 7'b0000001;
				end
			4'b0100: begin //04 
				hexd1 = 7'b1001100;
				hexd2 = 7'b0000001;
				end
			4'b0101: begin //05
				hexd1 = 7'b0100100;
				hexd2 = 7'b0000001;
				end
			4'b0110: begin //06 
				hexd1 = 7'b0100000;
				hexd2 = 7'b0000001;
				end
			4'b0111: begin //07
				hexd1	= 7'b0001111;
				hexd2 = 7'b0000001;
				end
			4'b1000: begin //08
				hexd1 = 7'b0000000;
				hexd2 = 7'b0000001;
				end
			4'b1001: begin //09 
				hexd1 = 7'b0001100;
				hexd2 = 7'b0000001;
				end
			4'b1010: begin //10 
				hexd1 = 7'b0000001;
				hexd2 = 7'b1001111;
				end
			4'b1011: begin //11 
				hexd1 = 7'b1001111;
				hexd2 = 7'b1001111;
				end
			4'b1100: begin //12 
				hexd1 = 7'b0010010;
				hexd2 = 7'b1001111;
				end
			4'b1101: begin //13 
				hexd1 = 7'b0000110;
				hexd2 = 7'b1001111;
				end
			4'b1110: begin //14
				hexd1 = 7'b1001100;
				hexd2 = 7'b1001111;
				end
			4'b1111: begin //15
				hexd1 = 7'b0100100;
				hexd2 = 7'b1001111;
				end
			default: begin //00
				hexd1 = 7'bx;
				hexd2 = 7'bx;
				end
		endcase

endmodule

module hexturnoff (hex6, hex2);
// drives a 7-segment display off
	output [0:6] hex6;
	output [0:6] hex2;
	
	assign hex6 = 7'b1111111;
	assign hex2 = 7'b1111111;
	
endmodule


/////Register Modules//////////////////
module reg3_2(D, Clock, Resetn, Q);
// Standard FlipFlop with asynchronous reset
	input [2:0] D;
	input Clock, Resetn;
	output reg [2:0] Q;
	
	always @(posedge Clock or negedge Resetn)
		if (Resetn == 0) begin
			Q <= 3'b000;
		end else begin
			Q <= D;
		end
		
endmodule


//////////////////////ALU Main Modules/////////////////////////////////////

module operation(op, x, y, result);
	input op;      //opcode 0 = add, 1 = sub
	input [2:0] x;
	input [2:0] y;
	output reg [3:0] result;
	
	wire [3:0] addnum;
	wire [3:0] subnum;
	
	ripple3add(x, y, addnum);
	ripple3sub(x, y, subnum[2:0]);
	
	always @(op)
		if (op == 0) 
			result = addnum;
		else 
			result = subnum; 
			
endmodule

module alu3_add_sub(x, y, op, Clock, Resetn, leds1, ledsp, leds2, leds3, hexd1, hexd2, hex2, hex6);
	input [2:0] x; //3 bit number displays as x op y
	input [2:0] y; //3 bit number displays as x op y
	input op, Clock, Resetn; 
	
	output [0:6] leds1; //displays x
	output [0:6] ledsp; //displays + or -
	output [0:6] leds2; //displays y
	output [0:6] leds3; //displays =
	output [0:6] hexd1; //displays right bit 
	output [0:6] hexd2; //displays left bit
	output [0:6] hex6;  //being driven off
	output [0:6] hex2;  //being driven off
	
	wire [2:0] q1;       //q1 = x
	wire [2:0] q2;       //q2 = y
	wire [3:0] finalnum; // finalnum = x op y
	
	//Set up the registers
	hexturnoff(hex2, hex6);
	reg3_2(x, Clock, Resetn, q1);
	reg3_2(y, Clock, Resetn, q2);
	
	//Set up pre-op display    // NTS:
	hexdisp_one_2(q1, leds1);  // These  are In order 
	hexdisp_op(op, ledsp);     // from left to right 
	hexdisp_one_2(q2, leds2);  // for pin-assignments
	hexdisp_eq_2(leds3);
	
	//Perform Operation and display
	operation(op, q1, q2, finalnum);
	hexdisp_two_2(finalnum, hexd1, hexd2);

endmodule
