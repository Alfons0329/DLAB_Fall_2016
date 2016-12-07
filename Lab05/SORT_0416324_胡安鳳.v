module SORT(
  // Input signals
  clk,
  rst_n,
  in_valid1,
  in_valid2,
  in,
  mode,
  op,
  // Output signals
  out_valid,
  out
);
//---------------------------------------------------------------------
//   INPUT AND OUTPUT DECLARATION                         
//---------------------------------------------------------------------
input mode,in_valid1,in_valid2,clk,rst_n;
input [1:0]op;
input [4:0]in;
output reg [4:0]out;
output reg out_valid;

//---------------------------------------------------------------------
// PARAMETER DECLARATION
//---------------------------------------------------------------------
parameter idle=0,getinput=1,ex=2,sendout=3;
//---------------------------------------------------------------------
//   WIRE AND REG DECLARATION                             
//---------------------------------------------------------------------
reg [4:0] a0,a1,a2,a3,a4,a5,a6,a7,a8,a9;
reg [3:0] out_cnt,size;
reg [1:0] current_state,next_state;
reg mode_tmp;
//---------------------------------------------------------------------
//   Finite-State Mechine                                          
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)current_state<=idle;
	else current_state<=next_state;
end

always@(*)
begin
	case(current_state)
		idle:next_state=getinput;		
		getinput:if(in_valid1&&op==2)next_state=sendout;
			else next_state=getinput;
		sendout:if(out_cnt==9)next_state=idle;
			else next_state=sendout;
		default:next_state=idle;
	endcase
end
//---------------------------------------------------------------------
//   Design Description                                          
//---------------------------------------------------------------------
//input and execution
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		a0<=0;
		a1<=0;
		a2<=0;
		a3<=0;
		a4<=0;
		a5<=0;
		a6<=0;
		a7<=0;
		a8<=0;
		a9<=0;
		size<=0;
		out<=0;
	end
	else if(current_state==idle)
	begin
		a0<=0;
		a1<=0;
		a2<=0;
		a3<=0;
		a4<=0;
		a5<=0;
		a6<=0;
		a7<=0;
		a8<=0;
		a9<=0;
		size<=0;
		out<=0;
	end
	else if(current_state==getinput&&in_valid1)
	begin
		if(!mode_tmp) //stack
		begin
			if(op==1) //push
			begin				
				case(size)
				0:begin a0<=in; size<=size+1; end
				1:begin a1<=in; size<=size+1; end
				2:begin a2<=in; size<=size+1; end
				3:begin a3<=in; size<=size+1; end
				4:begin a4<=in; size<=size+1; end
				5:begin a5<=in; size<=size+1; end
				6:begin a6<=in; size<=size+1; end
				7:begin a7<=in; size<=size+1; end
				8:begin a8<=in; size<=size+1; end
				9:begin a9<=in; size<=size+1;  end
				default:
				a9<=a9;
				endcase
			end
			
			else if(op==0)//pop
			begin
				case(size)
				1 :begin a0<=0; size<=size-1; end
				2 :begin a1<=0; size<=size-1; end
				3 :begin a2<=0; size<=size-1; end
				4 :begin a3<=0; size<=size-1; end
				5 :begin a4<=0; size<=size-1; end
				6 :begin a5<=0; size<=size-1; end
				7 :begin a6<=0; size<=size-1; end
				8 :begin a7<=0; size<=size-1; end
				9 :begin a8<=0; size<=size-1; end
				10:begin a9<=0; size<=size-1; end
				default:
				a9<=0;
				endcase
			end
			else //nothing
			begin
				a0<=a0;
				a1<=a1;
				a2<=a2;
				a3<=a3;
				a4<=a4;
				a5<=a5;
				a6<=a6;
				a7<=a7;
				a8<=a8;
				a9<=a9;
			end
		end
		
		else //queue
		begin
			if(op==1) //push
			begin	
				case(size)
				0:begin a0<=in; size<=size+1; end
				1:begin a1<=in; size<=size+1; end
				2:begin a2<=in; size<=size+1; end
				3:begin a3<=in; size<=size+1; end
				4:begin a4<=in; size<=size+1; end
				5:begin a5<=in; size<=size+1; end
				6:begin a6<=in; size<=size+1; end
				7:begin a7<=in; size<=size+1; end
				8:begin a8<=in; size<=size+1; end
				9:begin a9<=in; size<=size+1; end
				default:
				a9<=a9;
				endcase
			end
			
			else if(op==0) //dequeue
			begin
				a0<=a1; a1<=a2; a2<=a3; a3<=a4; a4<=a5; a5<=a6; a6<=a7; a7<=a8; a8<=a9; a9<=0;
				size<=size-1;
			end	

			else
			begin
				a0<=a0;
				a1<=a1;
				a2<=a2;
				a3<=a3;
				a4<=a4;
				a5<=a5;
				a6<=a6;
				a7<=a7;
				a8<=a8;
				a9<=a9;
			end			
		end
	end

	else if(current_state==sendout)
	begin
		if(a0>=a1&&a0>=a2&&a0>=a3&&a0>=a4&&a0>=a5&&a0>=a6&&a0>=a7&&a0>=a8&&a0>=a9)
		begin
			out<=a0; a0<=0;
		end
		else if(a1>=a0&&a1>=a2&&a1>=a3&&a1>=a4&&a1>=a5&&a1>=a6&&a1>=a7&&a1>=a8&&a1>=a9)
		begin
			out<=a1; a1<=0;
		end
		else if(a2>=a0&&a2>=a1&&a2>=a3&&a2>=a4&&a2>=a5&&a2>=a6&&a2>=a7&&a2>=a8&&a2>=a9)
		begin
			out<=a2; a2<=0;
		end
		else if(a3>=a0&&a3>=a1&&a3>=a2&&a3>=a4&&a3>=a5&&a3>=a6&&a3>=a7&&a3>=a8&&a3>=a9)
		begin
			out<=a3; a3<=0;
		end
		else if(a4>=a0&&a4>=a1&&a4>=a2&&a4>=a3&&a4>=a5&&a4>=a6&&a4>=a7&&a4>=a8&&a4>=a9)
		begin
			out<=a4; a4<=0;
		end
		else if(a5>=a0&&a5>=a1&&a5>=a2&&a5>=a3&&a5>=a4&&a5>=a6&&a5>=a7&&a5>=a8&&a5>=a9)
		begin
			out<=a5; a5<=0;
		end
		else if(a6>=a0&&a6>=a1&&a6>=a2&&a6>=a3&&a6>=a4&&a6>=a5&&a6>=a7&&a6>=a8&&a6>=a9)
		begin
			out<=a6; a6<=0;
		end
		else if(a7>=a0&&a7>=a1&&a7>=a2&&a7>=a3&&a7>=a4&&a7>=a5&&a7>=a6&&a7>=a8&&a7>=a9)
		begin
			out<=a7; a7<=0;
		end
		else if(a8>=a0&&a8>=a1&&a8>=a2&&a8>=a3&&a8>=a4&&a8>=a5&&a8>=a6&&a8>=a7&&a8>=a9)
		begin
			out<=a8; a8<=0;
		end
		else if(a9>=a0&&a9>=a1&&a9>=a2&&a9>=a3&&a9>=a4&&a9>=a5&&a9>=a6&&a9>=a7&&a9>=a8)
		begin
			out<=a9; a9<=0;
		end
		else
		begin
			case(out_cnt)
			0:out<=a0;
			1:out<=a1;
			2:out<=a2;
			3:out<=a3;
			4:out<=a4;
			5:out<=a5;
			6:out<=a6;
			7:out<=a7;
			8:out<=a8;
			9:out<=a9;
			default: out<=0;
			endcase
		end
	end
	
	else
	begin
		a0<=a0;
		a1<=a1;
		a2<=a2;
		a3<=a3;
		a4<=a4;
		a5<=a5;
		a6<=a6;
		a7<=a7;
		a8<=a8;
		a9<=a9;
		out<=0;
	end
		
end

//mode storage
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		mode_tmp<=0;
	else if(in_valid2)
		mode_tmp<=mode;
	else
		mode_tmp<=mode_tmp;
end

//out_valid
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		out_valid=0;
	else if(current_state==sendout)
		out_valid=1;
	else
		out_valid=0;
end
//out_cnt
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		out_cnt<=0;
	else if(current_state==sendout)
	begin
		case(out_cnt)
		9: out_cnt<=0;
		default:begin out_cnt<=out_cnt+1;end
		endcase
	end
	else
		out_cnt<=0;
end
endmodule