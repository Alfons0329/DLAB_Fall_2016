module IMPOR(in,mode,in_valid,clk,rst_n,out,out_valid,ready);
input [2:0] in,mode;
input in_valid,clk,rst_n;
output reg [2:0]out;
output reg out_valid,ready;
reg [3:0]mode_tmp;
reg [2:0] a0,a1,a2,a3,a4,a5,a6,a7,a8;
reg [4:0] step,out_cnt;

always@(posedge clk or negedge rst_n) //IO
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
	end
	else if(in_valid&&mode_tmp==8)
	case(step)
		0:a0<=in;
		1:a1<=in;
		2:a2<=in;
		3:a3<=in;
		4:a4<=in;
		5:a5<=in;
		6:a6<=in;
		7:a7<=in;
		8:a8<=in;
		default: //default NO LATCH
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
		end
	endcase
	
	else if(mode_tmp>=1&&mode_tmp<=7) //Matrix operation
	begin
		case(mode_tmp)
		1:
		begin
			a0<=a2;
			a3<=a5;
			a6<=a8;
			a2<=a0;
			a5<=a3;
			a8<=a6;
		end
		2:
		begin
			a0<=a6;
			a1<=a7;
			a2<=a8;
			a6<=a0;
			a7<=a1;
			a8<=a2;
		end
		3:
		begin
			a0<=a2;
			a1<=a5;
			a2<=a8;
			a5<=a7;
			a8<=a6;
			a7<=a3;
			a6<=a0;
			a3<=a1;
		end
		4:
		begin
			a0<=a6;
			a1<=a3;
			a2<=a0;
			a5<=a1;
			a8<=a2;
			a7<=a5;
			a6<=a8;
			a3<=a7;
		end
		5:
		begin
			if(a0==7) a0<=7;
			else a0<=a0+1;
			
			if(a3==7) a3<=7;
			else a3<=a3+1;
			
			if(a6==7) a6<=7;
			else a6<=a6+1;
		end
		6:
		begin
			if(a1==7) a1<=7;
			else a1<=a1+1;

			if(a4==7) a4<=7;
			else a4<=a4+1;
			
			if(a7==7) a7<=7;
			else a7<=a7+1;
		end
		7:
		begin
			if(a2==7) a2<=7;
			else a2<=a2+1;
			
			if(a5==7) a5<=7;
			else a5<=a5+1;
			
			if(a8==7) a8<=7;
			else a8<=a8+1;
		end
		default //default NO LATCH
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
		end
		endcase
	end
	
	else //default NO LATCH
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
	end
end

always@(posedge clk or negedge rst_n) // clock count step (ascually only for input)
begin
	if(!rst_n)
		step<=0;
	else if(!out_cnt&&in_valid) //input(include mode input) in progress
		step<=step+1;
	else
		step<=0; //default NO LATCH
end
//ready manipulation
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		ready<=0;
	else if(!out_valid) //mode1~7(include the default one:8 while input is in progress) will let ready=1 to let data in
		ready<=1;
	else if(!out_valid&&!mode_tmp) //reach mode 0 , ready to output
		ready<=0;
	else
		ready<=0;
		
end
//mode storage manipulation
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		mode_tmp<=8;
	else if(out_cnt>=10) //mode_tmp to default 8 (since we do operation between 1~7)
		mode_tmp<=8;
	else if(mode) //mode in (do operations and save the mode)
		mode_tmp<=mode;
	else if(!mode) //mode in (MODE TERMINATION)
		mode_tmp<=mode;
	else if(!mode_tmp)
		mode_tmp<=mode_tmp;
	
	else //neet to be 8 (since if in 03 GATE, it will be x ans further affect out_cnt,out valid,causing error
		// also for the purpose which wants default to be NO LATCH
		//should be the lowest priority, or will cause mode_tmp change to 0 when still in mode input (matrix manipulation)
		mode_tmp<=8; 
		
end

//out_valid manipulation
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		out_valid<=0;
	else if(out_cnt>=1&&out_cnt<=9) //only the output part (which means out_valid between1~9 will set out_valid=1)
		out_valid<=1;
	else
		out_valid<=0; //default NO LATCH
end
//output manipulation
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		out<=0;
	else if(mode_tmp) //in the input part, out_cnt should be 0(include the mode being 1~8)
		out_cnt<=0;
	else if(!mode_tmp&&out_cnt==0) //if we reach the mode==0 and out_cnt is still==0 , that means output will now in progress
		out_cnt<=1;
	else if(out_cnt>=1&&out_cnt<=10) //output in progress
	begin
		
		case(out_cnt)
		1:
		begin
			out<=a0;
			out_cnt<=out_cnt+1;
		end
		2:
		begin
			out<=a1;
			out_cnt<=out_cnt+1;
		end
		3:
		begin
			out<=a2;
			out_cnt<=out_cnt+1;
		end
		4:
		begin
			out<=a3;
			out_cnt<=out_cnt+1;
		end
		5:
		begin
			out<=a4;
			out_cnt<=out_cnt+1;
		end
		6:
		begin
			out<=a5;
			out_cnt<=out_cnt+1;
		end
		7:
		begin
			out<=a6;
			out_cnt<=out_cnt+1;
		end
		8:
		begin
			out<=a7;
			out_cnt<=out_cnt+1;
		end
		9:
		begin
			out<=a8;
			out_cnt<=out_cnt+1;
		end
		default:
		begin
			out<=0;
			out_cnt<=0;
		end
		
		endcase
	end
	else //default NO LATCH
	out<=0;
end
endmodule
