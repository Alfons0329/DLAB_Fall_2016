module plane(
	input PS2_Clk,
	input PS2_Din,
	input clk,
	input rst,
	output VGA_RED,
	output VGA_GREEN,
	output VGA_BLUE,
	output VGA_HSYNC,
	output VGA_VSYNC,
	output [7:0] bullet_sum
);

wire [9:0]getkeyval;

wire stateup,statedown,stateleft,statew,states,stated;
keyboard_module kbm(getkeyval,PS2_Clk,PS2_Din,clk,rst);
state state_module(
    stateleft,
    statedown,
    stateup,
	statew,
	states,
	stated,
    clk,
    rst,
    getkeyval
    );
	
reg [10:0]col;
reg [10:0]row;
reg [3:0] color;
reg R, G, B;


always @ (posedge clk)
begin
	col<=(col<1039)?col+1:0;
	row<=(row==665)?0:(col==1039)?row+1:row;
end

assign VGA_HSYNC= ~((col>=919)&(col<1039));
assign VGA_VSYNC= ~((row>=659)&(row<665));
//SYNC SIGNAL ends here
//colors
assign VGA_RED=R;
assign VGA_GREEN=G;
assign VGA_BLUE=B;

//game logic


parameter rbegin=23,rend=623,cbegin=104,cend=904;


reg [5:0] bullet_a,bullet_b;
reg [10:0] pa_row,pb_row;
wire [10:0] pa_col,pb_col;
wire [10:0] wau_row,wau_col,wad_row,wad_col;
wire [10:0] wbu_row,wbu_col,wbd_row,wbd_col;

parameter plane_halfrow=5,plane_halfcol=20;
parameter wing_halfrow=15,wing_halfcol=5;

assign pa_col=100;
assign pb_col=700;


//wing's position
assign wau_row=pa_row-13;
assign wad_row=pa_row+13;
assign wau_col=pa_col;
assign wad_col=pa_col;

assign wbu_row=pb_row-13;
assign wbd_row=pb_row+13;
assign wbu_col=pb_col;
assign wbd_col=pb_col;

//plane fyling logic

reg [25:0] halfsec_cnt;
always @(posedge clk,posedge rst)
begin
	if(rst)
	begin
		halfsec_cnt<=0;
	end
	else
	begin
		case(halfsec_cnt)
		25000000:halfsec_cnt<=0;
		default:halfsec_cnt<=halfsec_cnt+1;
		endcase
	end
end
//plane a
always @(posedge clk , posedge rst)
begin
	if(rst)
	begin
		pa_row<=rbegin+100;
	end
	else if(statew&&(pa_row-plane_halfrow>rbegin))
	begin
		if(halfsec_cnt==25000000)
			pa_row<=pa_row-20;
		else
			pa_row<=pa_row;
	end
	else if(states&&(pa_row+plane_halfrow<rend))
	begin
		if(halfsec_cnt==25000000)
			pa_row<=pa_row+20;
		else
			pa_row<=pa_row;
	end
	else
		pa_row<=pa_row;
end
//plane b
always @(posedge clk , posedge rst)
begin
	if(rst)
	begin
		pb_row<=rbegin+100;
	end
	else if(stateup&&(pb_row-plane_halfrow>rbegin))
	begin
		if(halfsec_cnt==25000000)
			pb_row<=pb_row-20;
		else
			pb_row<=pb_row;
	end
	else if(statedown&&(pb_row+plane_halfrow<rend))
	begin
		if(halfsec_cnt==25000000)
			pb_row<=pb_row+20;
		else
			pb_row<=pb_row;
	end
	else
		pb_row<=pb_row;
end

//bullet
parameter bullet_row=5,bullet_col=5;

reg bullet_alive_a;
reg bullet_alive_b;
reg [10:0] bullet_row_a;
reg [10:0] bullet_col_a;
reg [10:0] bullet_row_b;
reg [10:0] bullet_col_b;


always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		bullet_alive_a<=0;
	end
	else if(bullet_col_a>=pa_col&&bullet_col_a<=pb_col)
	begin
		bullet_alive_a<=1;
	end
	else
		bullet_alive_a<=0;
end

always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		bullet_alive_b<=0;
	end
	else if(bullet_col_b>=pa_col&&bullet_col_b<=pb_col)
	begin
		bullet_alive_b<=1;
	end
	else
		bullet_alive_b<=0;
end

//bullet a
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		bullet_row_a<=pa_row;
		bullet_col_a<=pa_col-5;
		bullet_a<=40;
	end
	else if(!bullet_alive_a && stated &&bullet_a)
	begin
		bullet_row_a<=bullet_row_a;
		bullet_col_a<=pa_col+50;
		bullet_a<=bullet_a-1;
	end
	else if(bullet_alive_a)
	begin
		if(halfsec_cnt==25000000)
		begin
			bullet_row_a<=bullet_row_a;
			bullet_col_a<=bullet_col_a+8;
			bullet_a<=bullet_a;
		end
		else
		begin
			bullet_row_a<=bullet_row_a;
			bullet_col_a<=bullet_col_a;
			bullet_a<=bullet_a;
		end
	end
	else
	begin
		bullet_row_a<=pa_row;
		bullet_col_a<=pa_col-5;
		bullet_a<=bullet_a;
	end
end

//bullet b
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		bullet_row_b<=pb_row;
		bullet_col_b<=pb_col+5;
		bullet_b<=40;
	end
	else if(!bullet_alive_b && stateleft && bullet_b)
	begin
		bullet_row_b<=bullet_row_b;
		bullet_col_b<=pb_col-50;
		bullet_b<=bullet_b-1;
	end
	else if(bullet_alive_b)
	begin
		if(halfsec_cnt==25000000)
		begin
			bullet_row_b<=bullet_row_b;
			bullet_col_b<=bullet_col_b-8;
			bullet_b<=bullet_b;
		end
		else
		begin
			bullet_row_b<=bullet_row_b;
			bullet_col_b<=bullet_col_b;
			bullet_b<=bullet_b;
		end
	end
	else
	begin
		bullet_row_b<=pb_row;
		bullet_col_b<=pb_col+5;
		bullet_b<=bullet_b;
	end
end


//plane alive
reg alive_a,alive_b;
parameter plane_rad=20;
//plane a
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		alive_a<=1;
	end
	else if(bullet_row_b>=pa_row-plane_rad 
	&& bullet_row_b<=pa_row+plane_rad
	&& bullet_col_b>=pa_col-plane_rad
	&& bullet_col_b<=pa_col+plane_rad)
	begin
		alive_a<=0;
	end
	else
		alive_a<=alive_a;
end
//plane b
always @(posedge clk, posedge rst)
begin
	if(rst)
	begin
		alive_b<=1;
	end
	else if(bullet_row_a>=pb_row-plane_rad 
	&& bullet_row_a<=pb_row+plane_rad
	&& bullet_col_a>=pb_col-plane_rad
	&& bullet_col_a<=pb_col+plane_rad)
	begin
		alive_b<=0;
	end
	else
		alive_b<=alive_b;
end

//
wire [99:0] alose;
wire [99:0] blose;
wire [99:0] equal;

assign alose[9:0]=10'b0000000000;
assign alose[19:10]=10'b0111111110;
assign alose[29:20]=10'b0100000010;
assign alose[39:30]=10'b0100000010;
assign alose[49:40]=10'b0111111110;
assign alose[59:50]=10'b0100000010;
assign alose[69:60]=10'b0100000010;
assign alose[79:70]=10'b0100000010;
assign alose[89:80]=10'b0000000000;
assign alose[99:90]=10'b0000000000;


assign blose[9:0]=10'b0000000000;
assign blose[19:10]=10'b0111111110;
assign blose[29:20]=10'b0100000010;
assign blose[39:30]=10'b0100000010;
assign blose[49:40]=10'b0011111110;
assign blose[59:50]=10'b0100000010;
assign blose[69:60]=10'b0100000010;
assign blose[79:70]=10'b0100000010;
assign blose[89:80]=10'b0111111110;
assign blose[99:90]=10'b0000000000;


assign equal[9:0]=10'b0000000000;
assign equal[19:10]=10'b0111111110;
assign equal[29:20]=10'b0000000000;
assign equal[39:30]=10'b0000000000;
assign equal[49:40]=10'b0000000000;
assign equal[59:50]=10'b0000000000;
assign equal[69:60]=10'b0000000000;
assign equal[79:70]=10'b0000000000;
assign equal[89:80]=10'b0111111110;
assign equal[99:90]=10'b0000000000;


always @(posedge clk or posedge rst)
begin
	if(rst)
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if(row-rbegin>=pa_row-plane_halfrow&&row-rbegin<=pa_row+plane_halfrow&&col-cbegin>=pa_col-plane_halfcol&&col-cbegin<=pa_col+plane_halfcol) //plane a
	begin
		R<=0;
		G<=0;
		B<=1;
	end
	else if(row-rbegin>=pb_row-plane_halfrow&&row-rbegin<=pb_row+plane_halfrow&&col-cbegin>=pb_col-plane_halfcol&&col-cbegin<=pb_col+plane_halfcol) //plane b
	begin
		R<=0;
		G<=0;
		B<=1;
	end
	else if((col-cbegin-wau_col<row-rbegin-wau_row)&&(row-rbegin>=wau_row-15)&&(row-rbegin<=wau_row+15)&&(col-cbegin>=wau_col-15)&&(col-cbegin<=wau_col+15)) //wau
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if((col-cbegin-wad_col>row-rbegin-wad_row)&&(row-rbegin>=wad_row-15)&&(row-rbegin<=wad_row+15)&&(col-cbegin>=wad_col-15)&&(col-cbegin<=wad_col+15)) //wad
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if((col-cbegin-wbu_col<row-rbegin-wbu_row)&&(row-rbegin>=wbu_row-15)&&(row-rbegin<=wbu_row+15)&&(col-cbegin>=wbu_col-15)&&(col-cbegin<=wbu_col+15)) //wbu
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if((col-cbegin-wbd_col>row-rbegin-wbd_row)&&(row-rbegin>=wbd_row-15)&&(row-rbegin<=wbd_row+15)&&(col-cbegin>=wbd_col-15)&&(col-cbegin<=wbd_col+15)) //wbd
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if(row-rbegin>=bullet_row_a-bullet_row 
	&& row-rbegin<=bullet_row_a+bullet_row 
	&& col-cbegin>=bullet_col_a-bullet_col 
	&& col-cbegin<=bullet_col_a+bullet_col  )
	begin
		R<=0;
		G<=0;
		B<=1;
	end
	else if(row-rbegin>=bullet_row_b-bullet_row 
	&& row-rbegin<=bullet_row_b+bullet_row 
	&& col-cbegin>=bullet_col_b-bullet_col 
	&& col-cbegin<=bullet_col_b+bullet_col  )
	begin
		R<=0;
		G<=0;
		B<=1;
	end
	else if(row>=200&&row<210&&col>=300&&col<310&&!alive_b&&(blose[(row-200)*(10)+(col-300)]))//LU of A
	begin
		R<=1;
		G<=1;
		B<=1;
	end
	else if(row>=200&&row<210&&col>=330&&col<340&&!alive_a&&(alose[(row-200)*(10)+(col-330)])) //LU of B
	begin
		R<=1;
		G<=1;
		B<=1;
	end
	else if(row>=200&&row<210&&col>=320&&col<330&&(!bullet_a)&&(!bullet_b)&&(equal[(row-200)*(10)+(col-320)])

	) //A=B
	begin
		R<=1;
		G<=1;
		B<=1;
	end
	else if(row>=rbegin&&row<=rend&&col>=cbegin&&col<=cend)
	begin
		R<=0;
		G<=1;
		B<=0;
	end
	else
	begin
		R<=0;
		G<=0;
		B<=0;
	end
end

assign bullet_sum=bullet_a+bullet_b;

endmodule
















