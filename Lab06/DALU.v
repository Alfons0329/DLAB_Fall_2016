`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:57:24 11/17/2016 
// Design Name: 
// Module Name:    DLAU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module DALU(
    // Input signals
	clk,
	rst,
	in_valid,
	instruction,
  // Output signals
  out_valid,
  out
    );
input [18:0] instruction;
input clk,rst,in_valid;

output reg [15:0] out;
output reg out_valid;

reg signed [15:0] spart,tpart,lpart;  //t i together

reg [4:0] mode_tmp;
reg [1:0] current_state,next_state;

//FSM
parameter idle=0,getinput=1,ex=2,sendout=3;

always@(posedge clk)
begin
	if(rst)current_state<=idle;
	else current_state<=next_state;
end

always@(*)
begin
	case(current_state)
		idle:next_state=getinput;		
		getinput:if(in_valid)next_state=sendout;
			else next_state=getinput;
		sendout:next_state=idle;
		default:next_state=idle;
	endcase
end
//input and mode
always@(posedge clk)
begin
	if(rst)
	begin
		spart<=0;
		tpart<=0;
		lpart<=0;
		mode_tmp<=0;
	end
	else if(current_state==getinput&&in_valid)
	begin
		case(instruction[18:16])
		0:
		begin
			case(instruction[3:0])
			0:begin mode_tmp<=1; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]}; end
			1:begin mode_tmp<=2; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]}; end
			2:begin mode_tmp<=3; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]}; end
			3:begin mode_tmp<=4; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]}; end
			4:begin mode_tmp<=5; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]}; end
			default
			begin
				spart<=spart;
				tpart<=tpart;
				lpart<=lpart;
				mode_tmp<=mode_tmp;
			end
			endcase
		end
		1:
		begin 
			mode_tmp<=6; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]};
			lpart<={{12{instruction[3]}},instruction[3:0]}; 
		end
		2:
		begin 
			mode_tmp<=7; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{10{instruction[9]}},instruction[9:4]};
			lpart<={{12{instruction[3]}},instruction[3:0]}; 
		end
		3:begin mode_tmp<=8; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{6{instruction[9]}},instruction[9:0]}; end
		4:begin mode_tmp<=9; spart<={{10{instruction[15]}},instruction[15:10]}; tpart<={{6{instruction[9]}},instruction[9:0]}; end
		default
		begin
			spart<=spart;
			tpart<=tpart;
			lpart<=lpart;
			mode_tmp<=mode_tmp;
		end
		endcase
	
	end
	else
	begin
		spart<=spart;
		tpart<=tpart;
		lpart<=lpart;
		mode_tmp<=mode_tmp;
	end
end
//out_valid
always@(posedge clk)
begin
	if(rst)
		out_valid<=0;
	else if(current_state==sendout)
		out_valid<=1;
	else
		out_valid<=0;
end
//output
always@(posedge clk)
begin
	if(rst)
		out<=0;
	else if(current_state==sendout)
	begin
		case(mode_tmp)
		1: out<=spart&tpart;
		2: out<=spart|tpart;
		3: out<=spart^tpart;
		4: out<=spart+tpart;
		5: out<=spart-tpart;
		6: out<=spart*tpart*lpart;
		7: out<=(spart+tpart+lpart)*(spart+tpart+lpart);
		8: out<=spart+tpart;
	    9: out<=spart-tpart;
		default:out<=0;
		endcase
	end
	else
		out<=0;

end

endmodule
