module CONVCOR(
        clk,
        rst_n,
        in_valid,
        in_a,
        in_b,
        in_mode,
        out_valid,
        out
);
//in out
input              clk;
input    	   	   rst_n;
input              in_valid;
input signed  [15:0]    in_a;
input signed  [15:0]    in_b;
input              in_mode;
output  reg        out_valid;
output  reg  [35:0]  out;
//some need variables
reg signed [8:0] a0_r,a1_r,a2_r,b0_r,b1_r,b2_r;
reg signed [8:0] a0_i,a1_i,a2_i,b0_i,b1_i,b2_i;
reg signed [8:0] b0_ic,b1_ic,b2_ic;
reg  [35:0] out_tmp;
reg signed [17:0] out_r,out_i;
reg [3:0] step;
reg mode_tmp,in_finished;
//debug purpose
always@(posedge clk)
begin
	
	$display("Mode %d ,Step %d ,Out valid %d ,Invalid %d ,Infinish%d ,Out %d",mode_tmp,step,out_valid,in_valid,in_finished,out);
end
//load data
always@(posedge clk)
begin	
	if(in_valid)
	begin
		if(step==4'd1)
		begin
			a0_r={{1{in_a[15]}},in_a[15:8]};
			b0_r={{1{in_b[15]}},in_b[15:8]};
			a0_i={{1{in_a[7]}},in_a[7:0]};
			b0_i={{1{in_b[7]}},in_b[7:0]};
			b0_ic=~b0_i+1;			
		end
		
		if(step==4'd2)
		begin
			a1_r={{1{in_a[15]}},in_a[15:8]};
			b1_r={{1{in_b[15]}},in_b[15:8]};
			a1_i={{1{in_a[7]}},in_a[7:0]};
			b1_i={{1{in_b[7]}},in_b[7:0]};
			b1_ic=~b1_i+1;			
		end	
		
		if(step==4'd3)
		begin
			a2_r={{1{in_a[15]}},in_a[15:8]};
			b2_r={{1{in_b[15]}},in_b[15:8]};
			a2_i={{1{in_a[7]}},in_a[7:0]};
			b2_i={{1{in_b[7]}},in_b[7:0]};
			b2_ic=~b2_i+1;
		end
		else //default NO LATCH
			a0_r=a0_r;
			b0_r=b0_r;
			a1_r=a1_r;
			b1_r=b1_r;
			a2_r=a2_r;
			b2_r=b2_r;
			a0_i=a0_i;
			b0_i=b0_i;
			a1_i=a1_i;
			b1_i=b1_i;
			a2_i=a2_i;
			b2_i=b2_i;
			b0_ic=b0_ic;
			b1_ic=b1_ic;
			b2_ic=b2_ic;
		begin
		end
	end
	
	else  
	begin
		a0_r=a0_r;
		b0_r=b0_r;
		a1_r=a1_r;
		b1_r=b1_r;
		a2_r=a2_r;
		b2_r=b2_r;
		a0_i=a0_i;
		b0_i=b0_i;
		a1_i=a1_i;
		b1_i=b1_i;
		a2_i=a2_i;
		b2_i=b2_i;
		b0_ic=b0_ic;
		b1_ic=b1_ic;
		b2_ic=b2_ic;
	end
end
//step count
always@(posedge clk)
begin
	if(!rst_n)
		step=4'd0;
	else if(in_valid)
		step=step+4'd1;
	else if(in_finished)
		step=step+4'd1;
	else if(step>=4'd10) //all the procedure is done , ready to quit
		step=4'd0;
	else
		step=4'd0;
end
//mode storage
always@(posedge clk)
begin
	if(in_valid&&step==4'd1)
		mode_tmp=in_mode;
	else  //mode maintainence and default NO LATCH
		mode_tmp=mode_tmp;
end
//In finished implies the whole output part
always@(posedge clk)
begin
	if(!rst_n)
		in_finished=0;
	else if(in_valid&&step<4'd3)
		in_finished=0;
	else if(in_valid&&step==4'd3)  
	/*NOT 4 since if look from display 3 is the right point (if 4 will cause latency since the third data comes at 3rd time wave which sym)
	which symbolizes the end of data load when step (or namely clock wave) at 3rd is "READY TO FINISH"
	Hence , in finished should be raised at 3 rather than 4*/
	//there's no data in at step4, cannot conclude it to be in_finished!
		in_finished=1;
	else if(!in_valid&&!mode_tmp&&step==4'd9)
		in_finished=0;   //reset in_finished after out is finished
	else if(!in_valid&&mode_tmp&&step==4'd5)
		in_finished=0;   //reset in_finished after out_2 is finished   		
	else //default NO LATCH
		in_finished=in_finished;
end
//output manipulation 
always@(posedge clk)
begin
	if(!rst_n)
		out_valid=0;
	else if(!mode_tmp&&step==4'd9)
		out_valid=0;
	else if(mode_tmp&&step==4'd5)
		out_valid=0;
	else if(in_finished&&!in_valid)
		out_valid=1;
	else
		out_valid=out_valid;
end

//output calc
always@(posedge clk)
begin
	if(!rst_n)
		out=36'b0;
	else if(in_finished&&out_valid)
	begin
		if(!mode_tmp)
		begin
			if(step==4'd4)
			begin
				out_r=a0_r*b0_r-a0_i*b0_i;
				out_i=a0_r*b0_i+b0_r*a0_i;
			end		
			if(step==4'd5)
			begin
				out_r=(a0_r*b1_r-a0_i*b1_i)+(a1_r*b0_r-a1_i*b0_i);
				out_i=(a0_r*b1_i+b1_r*a0_i)+(a1_r*b0_i+b0_r*a1_i);
			end		
			if(step==4'd6)
			begin
				out_r=(a0_r*b2_r-a0_i*b2_i)+(a1_r*b1_r-a1_i*b1_i)+(a2_r*b0_r-a2_i*b0_i);
				out_i=(a0_r*b2_i+b2_r*a0_i)+(a1_r*b1_i+b1_r*a1_i)+(a2_r*b0_i+b0_r*a2_i);
			end		
			if(step==4'd7)
			begin
				out_r=(a1_r*b2_r-a1_i*b2_i)+(a2_r*b1_r-a2_i*b1_i);
				out_i=(a1_r*b2_i+b2_r*a1_i)+(a2_r*b1_i+b1_r*a2_i);
			end	
			if(step==4'd8)	
			begin
				out_r=(a2_r*b2_r-a2_i*b2_i);
				out_i=(a2_r*b2_i+a2_i*b2_r);	
			end
			
			
			out[35:18]=out_r;
			out[17:0]=out_i;			
		end
		
		if(mode_tmp)
		begin		
			out_r=(a0_r*b0_r+a1_r*b1_r+a2_r*b2_r)-(a0_i*b0_ic+a1_i*b1_ic+a2_i*b2_ic);
			out_i=(a0_r*b0_ic+b0_r*a0_i)+(a1_r*b1_ic+b1_r*a1_i)+(a2_r*b2_ic+b2_r*a2_i);		
			out[35:18]=out_r;
			out[17:0]=out_i;		
		end	
	end
	
	else
	out=36'b0;  //default NO LATCH

end
endmodule