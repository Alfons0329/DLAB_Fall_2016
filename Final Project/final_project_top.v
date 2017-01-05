<<<<<<< HEAD:Final Project/final_project_top.v
module final_project_top
(
	clk,
	rst,
	left,
	right,
	PS2_Clk,
	PS2_Din,
	VGA_RED,
	VGA_BLUE,
	VGA_GREEN,
	VGA_VSYNC,
	VGA_HSYNC
);
input clk,rst,left,right,PS2_Clk,PS2_Din;
output  VGA_RED,VGA_BLUE,VGA_GREEN,VGA_VSYNC,VGA_HSYNC;

//get the key value from keyboard module output and deal the press state
wire stateleft,stateright,statedown,stateup;
reg pushup,pushdown,pushleft,pushright;
wire [9:0] get_key_value;
keyboard_module mykeyboard_module(.rst(rst),.clk(clk),.PS2_Clk(PS2_Clk),.PS2_Din(PS2_Din),.Key_Valve(get_key_value));
state keyboard_state_module(stateleft,stateright,statedown,stateup,clk,rst,get_key_value);
//keyboard state for only one press
always@(posedge clk, posedge rst) 
begin
	if(rst) pushup <= 0;
	else if(stateup) pushup <= 1;
	else if(!stateup) pushup <= 0;
	else pushup <= pushup;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushdown <= 0;
	else if(statedown) pushdown <= 1;
	else if(!statedown) pushdown <= 0;
	else pushdown <= pushdown;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushleft <= 0;
	else if(stateleft) pushleft <= 1;
	else if(!stateleft) pushleft <= 0;
	else pushleft <= pushleft;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushright <= 0;
	else if(stateright) pushright <= 1;
	else if(!stateright) pushright <= 0;
	else pushright <= pushright;
end
//keyboard state ends here


reg [10:0]col;
reg [10:0]row;
reg [3:0] color;//0:black  1:green   2:blue   3:yellow  4:white
reg R, G, B;
//Debouncing 
parameter delay=999;

reg [delay:0] s_register_east;
reg [delay:0] s_register_west;

reg btn_east_triggered;
reg btn_west_triggered;

reg btn_east_pre_state;
reg btn_west_pre_state;

//VGA screen size from PDF

parameter rini = 23, cini = 104, rend = 623, cend = 904;

always @(posedge clk)
begin
	col<=(col<1039)?col+1:0;
	row<=(row==665)?0:(col==1039)?row+1:row;
end
//SYNC SIGNAL
assign VGA_HSYNC= ~((col>=919)&(col<1039));
assign VGA_VSYNC= ~((row>=659)&(row<665));
//colors
assign VGA_RED=R;
assign VGA_GREEN=G;
assign VGA_BLUE=B;
//colors end here
reg [9:0] cursor_row_1, cursor_col_1;
//1p
//rst rini + 500, cini + 400
//thickness 10+10, 50+50

wire [9:0] cursor_row_2, cursor_col_2;
//2p
//rst rini + 100, cini + 400

reg [9:0] ball_row, ball_col;
reg [2:0] ball_color;
//ball (square)
//radius 5

assign cursor_row_2 = rini + 100;
assign cursor_col_2 = ball_col;


//flying direction flag
reg [1:0] flying_dir_flag;


//combo sped up
reg [25:0] pointone_limitation,combo;
reg [25:0] pointone_counter;


always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		cursor_row_1 <= rini + 500;
		cursor_col_1 <= cini + 400;
	end
	else if (stateleft)//stateleft /* !pushleft*/)
	begin
		if(cursor_col_1-50<=cini)
			cursor_col_1<=cursor_col_1;
		else
		begin
			case(pointone_counter)
			pointone_limitation:cursor_col_1<=cursor_col_1-5;
			default:cursor_col_1<=cursor_col_1;
			endcase		
		end
	end
	else if (stateright)//stateright /*!pushleft*/)
	begin
		if(cursor_col_1+50>=cend)
			cursor_col_1<=cursor_col_1;
		else
		begin
			case(pointone_counter)
			pointone_limitation:cursor_col_1<=cursor_col_1+5;
			default:cursor_col_1<=cursor_col_1;
			endcase
		end	
	end
	else
	begin
		cursor_col_1<=cursor_col_1;
	end
end
//halsecond counter of btn press
/*reg [25:0] left_counter,right_counter; //for count up to 25000000 which is half second
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		left_counter<=0;
		right_counter<=0;
	end
	//left btn is pressed
	else if(left)
	begin
		case(left_counter)
		500000:left_counter<=0;
		default:left_counter<=left_counter+1;
		endcase
	end
	else if(right)
	begin
		case(right_counter)
		500000:right_counter<=0;
		default:right_counter<=right_counter+1;
		endcase
	end
	else
	begin
		left_counter<=0;
		right_counter<=0;
	end
end

//pad control module
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		cursor_row_1 <= rini + 500;
		cursor_col_1 <= cini + 400;
	end
	else if (left_counter==500000)
	begin
		if(cursor_col_1-50<=cini)
			cursor_col_1<=cursor_col_1;
		else
			cursor_col_1<=cursor_col_1-10;
	end
	else if (right_counter==500000)
	begin
		if(cursor_col_1+50>=cend)
			cursor_col_1<=cursor_col_1;
		else
			cursor_col_1<=cursor_col_1+10;
	end
	else
	begin
		cursor_col_1<=cursor_col_1;
	end
end*/

//ball direction module and reflecting
reg lose,win,pre_win;
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pre_win<=0;
	end
	else
	begin
		case(win)
		1:pre_win<=1;
		default:pre_win<=0;
		endcase
	end
		
end
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		flying_dir_flag <= 3;
		lose<=0;
		win<=0;
	end
	else
	begin
		if(ball_row-10 <= rini + 102)
		begin
			case(flying_dir_flag)
			0:flying_dir_flag <= 3;
			1:flying_dir_flag <= 2;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_col-10 <= cini)
		begin
			case(flying_dir_flag)
			1:flying_dir_flag <= 0;
			2:flying_dir_flag <= 3;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_col+10 >= cend)
		begin
			case(flying_dir_flag)
			0:flying_dir_flag <= 1;
			3:flying_dir_flag <= 2;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_row+10 >= rend - 102)
		begin
			//gotcha
			if(ball_col >= cursor_col_1 - 60 && ball_col <= cursor_col_1 + 60)
			begin
				case(flying_dir_flag)
				3:flying_dir_flag <= 0;
				2:flying_dir_flag <= 1;
				default:flying_dir_flag <= flying_dir_flag;
				endcase
				
				win<=1;
			end
			//ng
			else
			begin
				flying_dir_flag <= flying_dir_flag;
				lose<=1;
			end
		end
		else
		begin
			flying_dir_flag <= flying_dir_flag;
			lose<=0;
			win<=0;
		end
	end
end

//pad and ball colorwise
//ball and pad color changing
//halfsecond counter
reg [26:0] oneseccnt;
reg onesec,onesec2;
always@ (posedge clk or posedge rst)
begin
	oneseccnt<=(rst)?0:(oneseccnt<12500000)?oneseccnt+1:0;
	onesec<=(rst)?0:(oneseccnt==0)?~onesec:onesec;
	onesec2<=(rst)?0:(oneseccnt==0)?~onesec2:onesec2;
end

always @(posedge clk)
begin
	if((col>=ball_col-10)&&(col<=ball_col+10)&&(row>=ball_row-10)&&(row<=ball_row+10))
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if((col>=cursor_col_1-50)&&(col<=cursor_col_1+50)&&(row>=cursor_row_1-10)&&(row<=cursor_row_1+10)) //player's pad color
	begin
		R<=onesec2;
		G<=1;
		B<=onesec;
	end
	else if((col>=cursor_col_2-50)&&(col<=cursor_col_2+50)&&(row>=cursor_row_2-10)&&(row<=cursor_row_2+10)) //CPU's pad color
	begin
		R<=~onesec2;
		G<=~onesec;
		B<=1;
	end
	else if ((col>0)&(col<900)&(row>=0)&(row<650))
	begin //back ground
		R<=0;
		G<=0;
		B<=0;
	end

end

//ball flying 0.1sec counter for 0.1sec move A PIXEL

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pointone_limitation<=500000;
	end
	else
	begin
		if(combo>=0&&combo<4)
			pointone_limitation<=500000;
		else if(combo>=4&&combo<9)
			pointone_limitation<=450000;
		else if(combo>=9&&combo<15)
			pointone_limitation<=400000;
		else if(combo>=15&&combo<23)
			pointone_limitation<=350000;
		else if(combo>=23&&combo<30)
			pointone_limitation<=300000;
		else if(combo>=30&&combo<35)
			pointone_limitation<=250000;
		else if(combo>=35&&combo<40)
			pointone_limitation<=200000;
		else if(combo>=40&&combo<45)
			pointone_limitation<=150000;
		else if(combo>=45&&combo<50)
			pointone_limitation<=100000;
		else
			pointone_limitation<=50000;
	end

end

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pointone_counter<=0;
	end
	else
	begin
		case(pointone_counter)
		pointone_limitation:pointone_counter<=0;
		default:pointone_counter<=pointone_counter+1;
		endcase
	end
end

//ball flying module
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		ball_row <= rini + 100 + 20;
		ball_col <= cini + 400;
	end
	else if(lose)
	begin
		ball_row <= rini + 100 + 20;
	end
	else
	begin
		case(flying_dir_flag)
		0:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row-1;
				ball_col<=ball_col+1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
		end
		1:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row-1;
				ball_col<=ball_col-1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end		
		end
		2:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row+1;
				ball_col<=ball_col-1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
		end
		3:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row+1;
				ball_col<=ball_col+1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
			
		end
		default:
		begin
			ball_row<=ball_row;
			ball_col<=ball_col;
		end
		endcase
	end
end


always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		combo<=0;
	end
	else if(pre_win&&!win)
	begin
		combo<=combo+1;
	end
	else if(lose)
	begin
		combo<=0;
	end
	else
		combo<=combo;
end

=======
module final_project_top
(
	clk,
	rst,
	left,
	right,
	PS2_Clk,
	PS2_Din,
	VGA_RED,
	VGA_BLUE,
	VGA_GREEN,
	VGA_VSYNC,
	VGA_HSYNC
);
input clk,rst,left,right,PS2_Clk,PS2_Din;
output  VGA_RED,VGA_BLUE,VGA_GREEN,VGA_VSYNC,VGA_HSYNC;

//get the key value from keyboard module output and deal the press state
wire stateleft,stateright,statedown,stateup;
reg pushup,pushdown,pushleft,pushright;
wire [9:0] get_key_value;
keyboard_module mykeyboard_module(.rst(rst),.clk(clk),.PS2_Clk(PS2_Clk),.PS2_Din(PS2_Din),.Key_Valve(get_key_value));
state keyboard_state_module(stateleft,stateright,statedown,stateup,clk,rst,get_key_value);
//keyboard state for only one press
always@(posedge clk, posedge rst) 
begin
	if(rst) pushup <= 0;
	else if(stateup) pushup <= 1;
	else if(!stateup) pushup <= 0;
	else pushup <= pushup;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushdown <= 0;
	else if(statedown) pushdown <= 1;
	else if(!statedown) pushdown <= 0;
	else pushdown <= pushdown;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushleft <= 0;
	else if(stateleft) pushleft <= 1;
	else if(!stateleft) pushleft <= 0;
	else pushleft <= pushleft;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushright <= 0;
	else if(stateright) pushright <= 1;
	else if(!stateright) pushright <= 0;
	else pushright <= pushright;
end
//keyboard state ends here


reg [10:0]col;
reg [10:0]row;
reg [3:0] color;//0:black  1:green   2:blue   3:yellow  4:white
reg R, G, B;
//Debouncing 
parameter delay=999;

reg [delay:0] s_register_east;
reg [delay:0] s_register_west;

reg btn_east_triggered;
reg btn_west_triggered;

reg btn_east_pre_state;
reg btn_west_pre_state;

//VGA screen size from PDF

parameter rini = 23, cini = 104, rend = 623, cend = 904;

always @(posedge clk)
begin
	col<=(col<1039)?col+1:0;
	row<=(row==665)?0:(col==1039)?row+1:row;
end
//SYNC SIGNAL
assign VGA_HSYNC= ~((col>=919)&(col<1039));
assign VGA_VSYNC= ~((row>=659)&(row<665));
//colors
assign VGA_RED=R;
assign VGA_GREEN=G;
assign VGA_BLUE=B;
//colors end here
reg [9:0] cursor_row_1, cursor_col_1;
//1p
//rst rini + 500, cini + 400
//thickness 10+10, 50+50

wire [9:0] cursor_row_2, cursor_col_2;
//2p
//rst rini + 100, cini + 400

reg [9:0] ball_row, ball_col;
reg [2:0] ball_color;
//ball (square)
//radius 5

assign cursor_row_2 = rini + 100;
assign cursor_col_2 = ball_col;


//flying direction flag
reg [1:0] flying_dir_flag;


//combo sped up
reg [25:0] pointone_limitation,combo;
reg [25:0] pointone_counter;


always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		cursor_row_1 <= rini + 500;
		cursor_col_1 <= cini + 400;
	end
	else if (stateleft)//stateleft /* !pushleft*/)
	begin
		if(cursor_col_1-50<=cini)
			cursor_col_1<=cursor_col_1;
		else
		begin
			case(pointone_counter)
			pointone_limitation:cursor_col_1<=cursor_col_1-5;
			default:cursor_col_1<=cursor_col_1;
			endcase		
		end
	end
	else if (stateright)//stateright /*!pushleft*/)
	begin
		if(cursor_col_1+50>=cend)
			cursor_col_1<=cursor_col_1;
		else
		begin
			case(pointone_counter)
			pointone_limitation:cursor_col_1<=cursor_col_1+5;
			default:cursor_col_1<=cursor_col_1;
			endcase
		end	
	end
	else
	begin
		cursor_col_1<=cursor_col_1;
	end
end
//halsecond counter of btn press
/*reg [25:0] left_counter,right_counter; //for count up to 25000000 which is half second
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		left_counter<=0;
		right_counter<=0;
	end
	//left btn is pressed
	else if(left)
	begin
		case(left_counter)
		500000:left_counter<=0;
		default:left_counter<=left_counter+1;
		endcase
	end
	else if(right)
	begin
		case(right_counter)
		500000:right_counter<=0;
		default:right_counter<=right_counter+1;
		endcase
	end
	else
	begin
		left_counter<=0;
		right_counter<=0;
	end
end

//pad control module
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		cursor_row_1 <= rini + 500;
		cursor_col_1 <= cini + 400;
	end
	else if (left_counter==500000)
	begin
		if(cursor_col_1-50<=cini)
			cursor_col_1<=cursor_col_1;
		else
			cursor_col_1<=cursor_col_1-10;
	end
	else if (right_counter==500000)
	begin
		if(cursor_col_1+50>=cend)
			cursor_col_1<=cursor_col_1;
		else
			cursor_col_1<=cursor_col_1+10;
	end
	else
	begin
		cursor_col_1<=cursor_col_1;
	end
end*/

//ball direction module and reflecting
reg lose,win,pre_win;
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pre_win<=0;
	end
	else
	begin
		case(win)
		1:pre_win<=1;
		default:pre_win<=0;
		endcase
	end
		
end
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		flying_dir_flag <= 3;
		lose<=0;
		win<=0;
	end
	else
	begin
		if(ball_row-10 <= rini + 102)
		begin
			case(flying_dir_flag)
			0:flying_dir_flag <= 3;
			1:flying_dir_flag <= 2;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_col-10 <= cini)
		begin
			case(flying_dir_flag)
			1:flying_dir_flag <= 0;
			2:flying_dir_flag <= 3;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_col+10 >= cend)
		begin
			case(flying_dir_flag)
			0:flying_dir_flag <= 1;
			3:flying_dir_flag <= 2;
			default:flying_dir_flag <= flying_dir_flag;
			endcase
		end
		else if(ball_row+10 >= rend - 102)
		begin
			//gotcha
			if(ball_col >= cursor_col_1 - 60 && ball_col <= cursor_col_1 + 60)
			begin
				case(flying_dir_flag)
				3:flying_dir_flag <= 0;
				2:flying_dir_flag <= 1;
				default:flying_dir_flag <= flying_dir_flag;
				endcase
				
				win<=1;
			end
			//ng
			else
			begin
				flying_dir_flag <= flying_dir_flag;
				lose<=1;
			end
		end
		else
		begin
			flying_dir_flag <= flying_dir_flag;
			lose<=0;
			win<=0;
		end
	end
end

//pad and ball colorwise
//ball and pad color changing
//halfsecond counter
reg [26:0] oneseccnt;
reg onesec,onesec2;
always@ (posedge clk or posedge rst)
begin
	oneseccnt<=(rst)?0:(oneseccnt<12500000)?oneseccnt+1:0;
	onesec<=(rst)?0:(oneseccnt==0)?~onesec:onesec;
	onesec2<=(rst)?0:(oneseccnt==0)?~onesec2:onesec2;
end

always @(posedge clk)
begin
	if((col>=ball_col-10)&&(col<=ball_col+10)&&(row>=ball_row-10)&&(row<=ball_row+10))
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if((col>=cursor_col_1-50)&&(col<=cursor_col_1+50)&&(row>=cursor_row_1-10)&&(row<=cursor_row_1+10)) //player's pad color
	begin
		R<=onesec2;
		G<=1;
		B<=onesec;
	end
	else if((col>=cursor_col_2-50)&&(col<=cursor_col_2+50)&&(row>=cursor_row_2-10)&&(row<=cursor_row_2+10)) //CPU's pad color
	begin
		R<=~onesec2;
		G<=~onesec;
		B<=1;
	end
	else if ((col>0)&(col<900)&(row>=0)&(row<650))
	begin //back ground
		R<=0;
		G<=0;
		B<=0;
	end

end

//ball flying 0.1sec counter for 0.1sec move A PIXEL

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pointone_limitation<=500000;
	end
	else
	begin
		if(combo>=0&&combo<4)
			pointone_limitation<=500000;
		else if(combo>=4&&combo<9)
			pointone_limitation<=450000;
		else if(combo>=9&&combo<15)
			pointone_limitation<=400000;
		else if(combo>=15&&combo<23)
			pointone_limitation<=350000;
		else if(combo>=23&&combo<30)
			pointone_limitation<=300000;
		else if(combo>=30&&combo<35)
			pointone_limitation<=250000;
		else if(combo>=35&&combo<40)
			pointone_limitation<=200000;
		else if(combo>=40&&combo<45)
			pointone_limitation<=150000;
		else if(combo>=45&&combo<50)
			pointone_limitation<=100000;
		else
			pointone_limitation<=50000;
	end

end

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		pointone_counter<=0;
	end
	else
	begin
		case(pointone_counter)
		pointone_limitation:pointone_counter<=0;
		default:pointone_counter<=pointone_counter+1;
		endcase
	end
end

//ball flying module
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		ball_row <= rini + 100 + 20;
		ball_col <= cini + 400;
	end
	else if(lose)
	begin
		ball_row <= rini + 100 + 20;
	end
	else
	begin
		case(flying_dir_flag)
		0:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row-1;
				ball_col<=ball_col+1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
		end
		1:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row-1;
				ball_col<=ball_col-1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end		
		end
		2:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row+1;
				ball_col<=ball_col-1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
		end
		3:
		begin
			if(pointone_counter==pointone_limitation)
			begin
				ball_row<=ball_row+1;
				ball_col<=ball_col+1;
			end
			else
			begin
				ball_row<=ball_row;
				ball_col<=ball_col;
			end
			
		end
		default:
		begin
			ball_row<=ball_row;
			ball_col<=ball_col;
		end
		endcase
	end
end


always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		combo<=0;
	end
	else if(pre_win&&!win)
	begin
		combo<=combo+1;
	end
	else if(lose)
	begin
		combo<=0;
	end
	else
		combo<=combo;
end

>>>>>>> origin/master:final_project_top.v
endmodule