
`timescale 1ns/10ps
`define CLK_PERIOD  4.0

module PATTERN(
	clk,
	circle1,
	circle2,
	in,
	in_valid,
	rst_n,
	out,
	out_valid
);
input [5:0] out; //receive TA's output
input out_valid; //receive TA's out_valid

output reg [4:0] in;//give TA data
output reg [2:0] circle1,circle2; //give to TA totation's data
output reg in_valid,clk,rst_n; //give TA in_valid clk and rst_n

reg [2:0] cir1_rot,cir2_rot; //save rotation data ,and circle data for execution
reg zero;
parameter PATTERN_NUM = 1001;
parameter CLK_POD = `CLK_PERIOD; //DONT FORGET '`'

integer lat,total_lat;
//save circle data for execution
integer pattern_cnt,i,j,seed;
integer cir1_tmp[0:7],cir2_tmp[0:7],result_tmp[0:7],result_tmp2[0:7],cir1_tmp2[0:7],cir2_tmp2[0:7],sort_tmp,out_cnt;

//initialize total latancey to be 0
initial begin 
	total_lat=0;
end
//clock regulations
initial begin
	clk=0;
	 //for every 4ns , clk change to opposite
	forever #CLK_POD clk=~clk;
end
//major execution, judge 
initial begin
	in<='dx;
	circle1='dx;
	in_valid<='bx;
	rst_n<=1;
	zero<=0;
	#2 //negedge rst_n
	rst_n=0;

	#4
	rst_n=1;
	check_out;
	check_out_valid;
	
	//check if TA'S output is reset right 
	
	
	in_valid='b0;
	@(negedge clk);
	for(pattern_cnt=0;pattern_cnt<PATTERN_NUM;pattern_cnt=pattern_cnt+1)
	begin
		
		for(i=0;i<8;i=i+1) //generating the circle1's data
		begin
			cir1_tmp[i]={$random()}%32;
		end
		
		for(i=0;i<8;i=i+1) //generating the circle2's data
		begin
			cir2_tmp[i]={$random()}%32;
		end
		
		cir1_rot={$random()}%8;
		cir2_rot={$random()}%8;
		
		@(negedge clk); //Fit the clock
		in_valid<='b1; //give TA data
		for(i=0;i<8;i=i+1)
		begin
			if(!i) //generating rotation data at first
			begin
				circle1<=cir1_rot;
				circle2<=cir2_rot;
			end
			in<=cir1_tmp[i];
			check_out_valid;
			@(negedge clk); //Fit the clock
			
		end
		
		for(i=0;i<8;i=i+1)
		begin
			in<=cir2_tmp[i];
			check_out_valid;
			@(negedge clk); //Fit the clock
		end
		
		in_valid =0;
		in='dx; //generating data is now end
		
		circle1_rotate; //execution
		circle2_rotate; //execution
		add_sort; //execution
		
		@(negedge clk);
		wait_out;
		check_ans;
		
	end
	
	@(negedge clk); //Fit the clock
	$display("\033[0;33m======================================================================\033[m");
	$display("\033[1;35m           ij1PXqSur,                \033[m");
	$display("\033[1;35m        ,i:,        :7:         \033[0;32m CONGRATULATION!! \033[m");
	$display("\033[1;35m      i7i         5.   i2r    \033[0;32m You pass all pattern!! \033[m"); 
	$display("\033[1;35m     L.          :. :    r7  \033[m");
	$display("\033[1;35m   .q      v7             i  \033[0;32m \033[m"); 
	$display("\033[1;35m   M       M              .:   .i.    \033[m"); 
	$display("\033[1;35m  iX                 j@;   :  :  : .  \033[m"); 
	$display("\033[1;35m  Y7                 ,@@   J ..   ::i \033[m"); 
	$display("\033[1;35m  r7            @Bu        JB7  :iii. \033[m"); 
	$display("\033[1;35m   @            .@@         .B  r:    \033[m");
	$display("\033[1;35m   uE               ,   T    8  u     \033[m");
	$display("\033[1;35m    Pu              U  :B   Fi :v     \033[m");
	$display("\033[1;35m     rEi             iU    S:  N      \033[m");
	$display("\033[1;35m       USv,             :7   F.      \033[m"); 
	$display("\033[1;35m         .,:irLr,      .    J:       \033[m"); 
	$display("\033[1;35m          .::irvrrL7      .S.        \033[m"); 
	$display("\033[1;35m        ,ui        i:     :r         \033[m"); 
	$display("\033[1;35m       r5     :           7:         \033[m"); 
	$display("\033[1;35m      iu    :.B,.         2 \033[0;35m LNSQu.   ML      vB;    :MF.    HB. @M \033[m");
	$display("\033[1;35m    :r    .:  j          r. \033[0;35m M@iiX@; @:B    :@q@@   OOMBQ    K@  Bk \033[m");
	$display("\033[1;35m   ,u:i:.i::.i.         vi  \033[0;35m BB  0B  @::@   P@:  Y .@0   V   5B  @I \033[m");
	$display("\033[1;35m    .:i    ,r,         1r   \033[0;35m MBM5;  qB  Ju   N5.     '@Ei    B@ .BH \033[m");
	$display("\033[1;35m         ,rv         ;1,    \033[0;35m BX    .@qi8BM: u  :@u :u  :F@          \033[m"); 
	$display("\033[1;35m .::.,.J          .rv:      \033[0;35m 7N    JL   iL.  Jv;,   LYru:    rU  5M \033[m"); 
	$display("\033[1;35m .r.;:.i..     .::.                  \033[m"); 
	$display("\033[0;33m======================================================================\033[m");
	@(negedge clk); //Fit the clock
	$finish;
end
task circle1_rotate;
	for(i=0;i<8;i=i+1)
	begin
		
		if(i+cir1_rot>7)
		begin	
			cir1_tmp2[i+cir1_rot-8]=cir1_tmp[i];
		end
		
		else
		begin
			cir1_tmp2[i+cir1_rot]=cir1_tmp[i];
		end
		
	end
endtask

task circle2_rotate;
begin

	for(i=0;i<8;i=i+1)
	begin
		
		if(i+cir2_rot>7)
		begin
			cir2_tmp2[i+cir2_rot-8]=cir2_tmp[i];
		end
		
		else
		begin
			cir2_tmp2[i+cir2_rot]=cir2_tmp[i];
		end
		
	end
	
end
endtask

task add_sort;
begin

	for(i=0;i<8;i=i+1) //add 2 circles together
	begin
	
		result_tmp[i]=cir1_tmp2[i]+cir2_tmp2[i];
		//$display("Result tmp is now %d = %d + %d",result_tmp[i],cir1_tmp2[i],cir2_tmp2[i]);
	end
	
	for(i=7;i>0;i=i-1)
	begin	
		for(j=0;j<i;j=j+1)
		begin
			if(result_tmp[j]>result_tmp[j+1])
			begin
				sort_tmp=result_tmp[j];
				result_tmp[j]=result_tmp[j+1];
				result_tmp[j+1]=sort_tmp;
			end
		end
	end
	
	/*$display("After sort ");
	for(i=0;i<8;i=i+1) //add 2 circles together
	begin
		$display("Result tmp is now %d",result_tmp[i]);
	end*/
	
end
endtask

task check_out_valid;
begin

	if(out_valid !== 1'b0) begin
		$display("");
		$display("=================================================");
		$display("  Out_valid should be reset !!!!    >_< >_< >_<  ");
		$display("=================================================");
		$display("");
		@(negedge clk);
		$finish;
	end
	
end
endtask

task check_out;
begin
	if(out !== 1'b0) begin
		$display("");
		$display("=================================================");
		$display("  Output should be reset !!!!    >_< >_< >_<     ");
		$display("=================================================");
		$display("");
		@(negedge clk);
		$finish;
	end
	
end
endtask


task wait_out;
begin

	lat = 0;
	while(!(out_valid === 1'b1)) begin
		if(lat >=100) begin
			$display("");
			$display("=================================================");
			$display("  Latency too much !!!!    @_@ @_@ @_@           ");
			$display("=================================================");
			$display("");
			@(negedge clk);
			$finish;
		end
		lat = lat + 1;
		total_lat=total_lat+1;
		@(negedge clk);
	end
	
end
endtask

task check_ans;
begin
	out_cnt=0;
	while(out_valid===1'b1)
	begin
		if(out_cnt<8&&out!==result_tmp[out_cnt])
		begin
			$display("=================================================");
			$display("  Failed!!  PATTERN %4d is wrong :( :( Q_Q T_T   ", pattern_cnt+1);
			$display("  ans is %d      your ans is %d          ", result_tmp[i],out);
			$display("QQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQQ");
			$display("=================================================");
			$display("");	
			@(negedge clk); //Fit the clock
			$finish;
			//exit pattern if anyting is WA
		end
		
		out_cnt=out_cnt+1;
		
		@(posedge clk);
		if(out_cnt>8)
		begin
			$display("");
			$display("Out_valid is MORE than 8 cycle WTF!");
			$display("");
			@(negedge clk);
			$finish;
		end
		
		@(negedge clk);
		
	end
	
	if(out_cnt<8)
	begin
		$display("");
		$display("Out_valid is LESS than 8 cycle WTF!");
		$display("");
		@(negedge clk);
		$finish;
	end
	else if(out_cnt==8)
	begin
		$display("Pass pattern %d",pattern_cnt+1);
	end
end
endtask

endmodule