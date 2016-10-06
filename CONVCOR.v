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
reg invalid_tmp,mode_tmp;
integer load_cnt=0,out_cnt=0,phase=0;

always@(posedge clk)
begin
	invalid_tmp=in_valid;	
	if(in_valid)
	begin
		$display("mode is %d",mode_tmp);
		if(load_cnt==0)
		begin
			mode_tmp=in_mode;
			a0_r={{1{in_a[15]}},in_a[15:8]};
			b0_r={{1{in_b[15]}},in_b[15:8]};
			a0_i={{1{in_a[7]}},in_a[7:0]};
			b0_i={{1{in_b[7]}},in_b[7:0]};
			b0_ic=~b0_i+1;
			phase=phase+1;				
		end
		
		if(load_cnt==1)
		begin
			a1_r={{1{in_a[15]}},in_a[15:8]};
			b1_r={{1{in_b[15]}},in_b[15:8]};
			a1_i={{1{in_a[7]}},in_a[7:0]};
			b1_i={{1{in_b[7]}},in_b[7:0]};
			b1_ic=~b1_i+1;
			phase=phase+1;			
		end
		
		if(load_cnt==2)
		begin
			a2_r={{1{in_a[15]}},in_a[15:8]};
			b2_r={{1{in_b[15]}},in_b[15:8]};
			a2_i={{1{in_a[7]}},in_a[7:0]};
			b2_i={{1{in_b[7]}},in_b[7:0]};
			b2_ic=~b2_i+1;
			phase=phase+1;
		end
		load_cnt=load_cnt+1;
		out_cnt=0;
	end
end
//output
always@(posedge clk)
begin
	if(!rst_n)
	begin
		out=0;
		out_valid=0;	
		out_cnt=0;
		phase=0;
	end
	if(phase>2)
	begin
		if(!mode_tmp)
		begin
			if(out_cnt==0)
			begin
				out_r=a0_r*b0_r-a0_i*b0_i;
				out_i=a0_r*b0_i+b0_r*a0_i;
			end
		
			if(out_cnt==1)
			begin
				out_r=(a0_r*b1_r-a0_i*b1_i)+(a1_r*b0_r-a1_i*b0_i);
				out_i=(a0_r*b1_i+b1_r*a0_i)+(a1_r*b0_i+b0_r*a1_i);
			end
		
			if(out_cnt==2)
			begin
				out_r=(a0_r*b2_r-a0_i*b2_i)+(a1_r*b1_r-a1_i*b1_i)+(a2_r*b0_r-a2_i*b0_i);
				out_i=(a0_r*b2_i+b2_r*a0_i)+(a1_r*b1_i+b1_r*a1_i)+(a2_r*b0_i+b0_r*a2_i);
			end
		
			if(out_cnt==3)
			begin
				out_r=(a1_r*b2_r-a1_i*b2_i)+(a2_r*b1_r-a2_i*b1_i);
				out_i=(a1_r*b2_i+b2_r*a1_i)+(a2_r*b1_i+b1_r*a2_i);
			end
		
			if(out_cnt==4)	
			begin
				out_r=(a2_r*b2_r-a2_i*b2_i);
				out_i=(a2_r*b2_i+a2_i*b2_r);
			end
			
			if(out_cnt>=5)//finished output status , reset out and out_valid and the phase for input counting
			begin
				out=0;
				out_valid=0;
				phase=0;
			end
			else
			begin
				out_cnt=out_cnt+1;//still in output status out_cnt should increase
				out[35:18]=out_r;//{{2{out_r[15]}},out_r};
				out[17:0]=out_i;//{{2{out_i[15]}},out_i};
				out_valid=1;
			end	
			
		end
		
		if(mode_tmp)
		begin		
			out_r=(a0_r*b0_r+a1_r*b1_r+a2_r*b2_r)-(a0_i*b0_ic+a1_i*b1_ic+a2_i*b2_ic);
			out_i=(a0_r*b0_ic+b0_r*a0_i)+(a1_r*b1_ic+b1_r*a1_i)+(a2_r*b2_ic+b2_r*a2_i);		
			out[35:18]=out_r;//{{2{out_r[15]}},out_r};
			out[17:0]=out_i;//{{2{out_i[15]}},out_i};
			out_valid=1;			
			phase=phase+1;
			if(phase>=5)
			begin
				out_valid=0;
				out=0;
				phase=0;
			end
		end
		load_cnt=0;// stop input , go output		
	end

end
endmodule






