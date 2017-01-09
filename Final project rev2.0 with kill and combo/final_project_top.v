module final_project_top
(
	clk,
	rst,
	left,
	right,
  sw_cheat,/*sw3*/
  sw_r,/*sw2*/
  sw_g,/*sw1*/
  sw_b,/*sw0*/
	PS2_Clk,
	PS2_Din,
	VGA_RED,
	VGA_BLUE,
	VGA_GREEN,
	VGA_VSYNC,
	VGA_HSYNC
);
input clk,rst,left,right,sw_cheat,sw_r,sw_g,sw_b,PS2_Clk,PS2_Din;
output  VGA_RED,VGA_BLUE,VGA_GREEN,VGA_VSYNC,VGA_HSYNC;

//colorwise
reg [10:0]col;
reg [10:0]row;
reg [3:0] color;//0:black  1:green   2:blue   3:yellow  4:white
reg R, G, B;


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

//get the key value from keyboard module output and deal the press state
wire [9:0] get_key_value;
wire stateleft,stateright,statedown,stateup,killer;
reg pushup,pushdown,pushleft,pushright;

keyboard_module mykeyboard_module(.rst(rst),.clk(clk),.PS2_Clk(PS2_Clk),.PS2_Din(PS2_Din),.Key_Valve(get_key_value));
state keyboard_state_module(stateleft,stateright,statedown,stateup,killer,clk,rst,get_key_value);

//divisor ten
wire [15:0] ten;
assign ten=10;
//cheat enlarge 10 times
wire [10:0] cheat_row,cheat_col;

mod10 cheatmod10_row(.clk(clk),.dividend(row-165-rini),.divisor(ten),.quotient(cheat_row));
mod10 cheatmod10_col(.clk(clk),.dividend(col-230-cini),.divisor(ten),.quotient(cheat_col));
//fever enlarge 10 times
wire [10:0] fever_row,fever_col;

mod10 fevermod10_row(.clk(clk),.dividend(row-370-rini),.divisor(ten),.quotient(fever_row));
mod10 fevermod10_col(.clk(clk),.dividend(col-230-cini),.divisor(ten),.quotient(fever_col));

//number enlarge 10 times
wire [10:0] num_row , num_col_ten , num_col_one;

mod10 numbermod10_row(.clk(clk),.dividend(row-270-rini),.divisor(ten),.quotient(num_row));
mod10 numbermod10_num_col_ten(.clk(clk),.dividend(col),.divisor(ten),.quotient(num_col_ten));
mod10 numbermod10_num_col_one(.clk(clk),.dividend(col),.divisor(ten),.quotient(num_col_one));

//combo deci and combo digi
wire [10:0] combo_ten,combo_one;
mod10 combomod10(.clk(clk),.dividend(combo),.divisor(ten),.quotient(combo_ten),.fractional(combo_one));

//keyboard state for only one press

reg [9:0] ball_row, ball_col;
reg [9:0] cursor_row_1, cursor_col_1;//player position
wire [9:0] cursor_row_2, cursor_col_2;//CPU position

//graphs
wire [244:0] fever;
assign fever[35 * 1 - 1:35 * 0] = 35'b001111101111110110011011111101111110;
assign fever[35 * 2 - 1:35 * 1] = 35'b011001100000110110011000001100000110;
assign fever[35 * 3 - 1:35 * 2] = 35'b011001100000110110011000001100000110;
assign fever[35 * 4 - 1:35 * 3] = 35'b001111100111110110011001111100111110;
assign fever[35 * 5 - 1:35 * 4] = 35'b011001100000110110011000001100000110;
assign fever[35 * 6 - 1:35 * 5] = 35'b011001100000110011110000001100000110;
assign fever[35 * 7 - 1:35 * 6] = 35'b011001101111110001100011111100000110;

wire [244:0] cheat;
assign cheat[35 * 1 - 1:35 * 0] = 35'b11111100011000111111011001100111100;
assign cheat[35 * 2 - 1:35 * 1] = 35'b00110000111100000011011001101100110;
assign cheat[35 * 3 - 1:35 * 2] = 35'b00110001100110000011011001100000110;
assign cheat[35 * 4 - 1:35 * 3] = 35'b00110001111110011111011111100000110;
assign cheat[35 * 5 - 1:35 * 4] = 35'b00110001100110000011011001100000110;
assign cheat[35 * 6 - 1:35 * 5] = 35'b00110001100110000011011001101100110;
assign cheat[35 * 7 - 1:35 * 6] = 35'b00110001100110111111011001100111100;

wire [71:0] num_0;
wire [71:0] num_1;
wire [71:0] num_2;
wire [71:0] num_3;
wire [71:0] num_4;
wire [71:0] num_5;
wire [71:0] num_6;
wire [71:0] num_7;
wire [71:0] num_8;
wire [71:0] num_9;

assign num_0[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_0[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_0[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_0[ 4 * 8 - 1: 3 * 8]= 8'b01100110;
assign num_0[ 5 * 8 - 1: 4 * 8]= 8'b01100110;
assign num_0[ 6 * 8 - 1: 5 * 8]= 8'b01100110;
assign num_0[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_0[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_0[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_1[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_1[ 2 * 8 - 1: 1 * 8]= 8'b00011000;
assign num_1[ 3 * 8 - 1: 2 * 8]= 8'b00011100;
assign num_1[ 4 * 8 - 1: 3 * 8]= 8'b00011000;
assign num_1[ 5 * 8 - 1: 4 * 8]= 8'b00011000;
assign num_1[ 6 * 8 - 1: 5 * 8]= 8'b00011000;
assign num_1[ 7 * 8 - 1: 6 * 8]= 8'b00011000;
assign num_1[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_1[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_2[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_2[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_2[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_2[ 4 * 8 - 1: 3 * 8]= 8'b00110000;
assign num_2[ 5 * 8 - 1: 4 * 8]= 8'b00011100;
assign num_2[ 6 * 8 - 1: 5 * 8]= 8'b00000110;
assign num_2[ 7 * 8 - 1: 6 * 8]= 8'b00000011;
assign num_2[ 8 * 8 - 1: 7 * 8]= 8'b01111110;
assign num_2[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_3[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_3[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_3[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_3[ 4 * 8 - 1: 3 * 8]= 8'b01100000;
assign num_3[ 5 * 8 - 1: 4 * 8]= 8'b00111100;
assign num_3[ 6 * 8 - 1: 5 * 8]= 8'b01100000;
assign num_3[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_3[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_3[ 9 * 8 - 1: 8 * 8]= 8'b00000000;
 
assign num_4[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_4[ 2 * 8 - 1: 1 * 8]= 8'b01100110;
assign num_4[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_4[ 4 * 8 - 1: 3 * 8]= 8'b01100110;
assign num_4[ 5 * 8 - 1: 4 * 8]= 8'b01100110;
assign num_4[ 6 * 8 - 1: 5 * 8]= 8'b01111100;
assign num_4[ 7 * 8 - 1: 6 * 8]= 8'b01100000;
assign num_4[ 8 * 8 - 1: 7 * 8]= 8'b01100000;
assign num_4[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_5[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_5[ 2 * 8 - 1: 1 * 8]= 8'b01111110;
assign num_5[ 3 * 8 - 1: 2 * 8]= 8'b00000110;
assign num_5[ 4 * 8 - 1: 3 * 8]= 8'b00111110;
assign num_5[ 5 * 8 - 1: 4 * 8]= 8'b01100000;
assign num_5[ 6 * 8 - 1: 5 * 8]= 8'b01100000;
assign num_5[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_5[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_5[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_6[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_6[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_6[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_6[ 4 * 8 - 1: 3 * 8]= 8'b00000110;
assign num_6[ 5 * 8 - 1: 4 * 8]= 8'b00111110;
assign num_6[ 6 * 8 - 1: 5 * 8]= 8'b01100110;
assign num_6[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_6[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_6[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_7[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_7[ 2 * 8 - 1: 1 * 8]= 8'b01111110;
assign num_7[ 3 * 8 - 1: 2 * 8]= 8'b01100000;
assign num_7[ 4 * 8 - 1: 3 * 8]= 8'b00110000;
assign num_7[ 5 * 8 - 1: 4 * 8]= 8'b00011000;
assign num_7[ 6 * 8 - 1: 5 * 8]= 8'b00011000;
assign num_7[ 7 * 8 - 1: 6 * 8]= 8'b00011000;
assign num_7[ 8 * 8 - 1: 7 * 8]= 8'b00011000;
assign num_7[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_8[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_8[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_8[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_8[ 4 * 8 - 1: 3 * 8]= 8'b01100110;
assign num_8[ 5 * 8 - 1: 4 * 8]= 8'b00111100;
assign num_8[ 6 * 8 - 1: 5 * 8]= 8'b01100110;
assign num_8[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_8[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_8[ 9 * 8 - 1: 8 * 8]= 8'b00000000;

assign num_9[ 1 * 8 - 1: 0 * 8]= 8'b00000000;
assign num_9[ 2 * 8 - 1: 1 * 8]= 8'b00111100;
assign num_9[ 3 * 8 - 1: 2 * 8]= 8'b01100110;
assign num_9[ 4 * 8 - 1: 3 * 8]= 8'b01100110;
assign num_9[ 5 * 8 - 1: 4 * 8]= 8'b01111100;
assign num_9[ 6 * 8 - 1: 5 * 8]= 8'b01100000;
assign num_9[ 7 * 8 - 1: 6 * 8]= 8'b01100110;
assign num_9[ 8 * 8 - 1: 7 * 8]= 8'b00111100;
assign num_9[ 9 * 8 - 1: 8 * 8]= 8'b00000000;



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
  //else if(sw_cheat && ball_col < cursor_col_1)pushleft <= 1;
	else if(!stateleft) pushleft <= 0;
	else pushleft <= pushleft;
end

always@(posedge clk, posedge rst) 
begin
	if(rst) pushright <= 0;
	else if(stateright) pushright <= 1;
  //else if(sw_cheat && ball_col > cursor_col_1)pushright <= 1;
	else if(!stateright) pushright <= 0;
	else pushright <= pushright;
end

//1p
//rst rini + 500, cini + 400
//2p
//rst rini + 100, cini + 400
//thickness 10+10, 50+50
reg [2:0] ball_color;
//ball round
//radius 10

assign cursor_row_2 = rini + 100;
assign cursor_col_2 = ball_col;

//flying direction flag
reg [1:0] flying_dir_flag;


//combo sped up
reg [25:0] pointone_limitation;
reg [25:0] pointone_counter;
reg [8:0] combo;

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		cursor_row_1 <= rini + 550;
		cursor_col_1 <= cini + 400;
	end
	else if (stateleft)
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
	else if (stateright)
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
	else if(sw_cheat && ball_col < cursor_col_1)//cheat go left
	begin
			if(cursor_col_1 - ball_col < 20)
				cursor_col_1 <= ball_col;
			else if(cursor_col_1-50<=cini)
				cursor_col_1<=cursor_col_1;
			else
			begin
				case(pointone_counter)
				pointone_limitation:cursor_col_1<=cursor_col_1-5;
				default:cursor_col_1<=cursor_col_1;
				endcase		
			end
		end
	else if(sw_cheat && ball_col > cursor_col_1)//cheat go right
	begin
		if(ball_col - cursor_col_1 < 20)
			cursor_col_1 <= ball_col;
		else if(cursor_col_1+50>=cend)
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

//ball direction module and reflecting
//1 clock difference of pre_win and win for win debouncing XDD
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
//ball and pad color changing // with halfsecond counter

reg [26:0] oneseccnt;
reg onesec,onesec2;
always@ (posedge clk or posedge rst)
begin
	oneseccnt<=(rst)?0:(oneseccnt<12500000)?oneseccnt+1:0;
	onesec<=(rst)?0:(oneseccnt==0)?~onesec:onesec;
	onesec2<=(rst)?0:(oneseccnt==0)?~onesec2:onesec2;
end

//graphic drawing
always @(posedge clk)
begin
	if(((row-ball_row)*(row-ball_row)+(col-ball_col)*(col-ball_col))<100) // ball
	begin
		R<=1;
		G<=0;
		B<=0;
	end
	else if(killer&&(((row-ball_row)*(row-ball_row)+(col-ball_col)*(col-ball_col))<100)) // force killing ball  the ball is yellow
	begin
		R<=1;
		G<=1;
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
	else if(sw_cheat&&(row>=rini+165)&&(row<rini+235)&&(col>=cini+250)&&(col<cini+600)&&(cheat[cheat_row*35+cheat_col])) //cheat
	begin
		R<=~sw_r;
		G<=~sw_g;
		B<=~sw_b;
		
	end
	else if((row>=rini+270)&&(row<rini+360)&&(col>=cini+250)&&(col<cini+330))//combo_ten
	begin
		case(combo_ten)
			0:
			begin
				if(num_0[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			1:
			begin
				if(num_0[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			2:
			begin
				if(num_2[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			3:
			begin
				if(num_3[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			4:
			begin
				if(num_4[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			5:
			begin
				if(num_5[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			6:
			begin
			if(num_6[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			7:
			begin
			if(num_7[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			8:
			begin
			if(num_8[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			9:
			begin
			if(num_9[num_row*8+num_col_ten])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			default:
			begin
				R<=sw_r;
				G<=sw_g;
				B<=sw_b;
			end
		endcase
	end
	else if((row>=rini+270)&&(row<rini+360)&&(col>=cini+520)&&(col<cini+600))//combo_one
	begin
		case(combo_one)
			0:
			begin
				if(num_0[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			1:
			begin
				if(num_0[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			2:
			begin
				if(num_2[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			3:
			begin
				if(num_3[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			4:
			begin
				if(num_4[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			5:
			begin
				if(num_5[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			6:
			begin
			if(num_6[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			7:
			begin
			if(num_7[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			8:
			begin
			if(num_8[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			9:
			begin
			if(num_9[num_row*8+num_col_one])
				begin
					R<=~sw_r;
					G<=~sw_g;
					B<=~sw_b;
				end
				else
				begin
					R<=sw_r;
					G<=sw_g;
					B<=sw_b;
				end
			end
			default:
			begin
				R<=sw_r;
				G<=sw_g;
				B<=sw_b;
			end
		endcase
	end
	else if(fever&&(row>=rini+370)&&(row<rini+440)&&(col>=cini+250)&&(col<cini+600)&&(fever[fever_row*35+fever_col])) //fever
	begin
		R<=~sw_r;
		G<=~sw_g;
		B<=~sw_b;
		
	end
	else if((col>=cini)&(col<=cend)&(row>=rini)&(row<=rend))
	begin //back ground
		R<=sw_r;
		G<=sw_g;
		B<=sw_b;
	end
	else
	begin
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
	else if(killer)
	begin
		pointone_limitation<=10000; //for force killing ball
	end
	else 
	begin
		if(combo>=0&&combo<3)
			pointone_limitation<=500000;
		else if(combo>=3&&combo<6)
			pointone_limitation<=450000;
		else if(combo>=6&&combo<9)
			pointone_limitation<=400000;
		else if(combo>=9&&combo<12)
			pointone_limitation<=350000;
		else if(combo>=12&&combo<15)
			pointone_limitation<=300000;
		else if(combo>=15&&combo<18)
			pointone_limitation<=250000;
		else if(combo>=18&&combo<21)
			pointone_limitation<=200000;
		else if(combo>=21&&combo<24)
			pointone_limitation<=150000;
		else if(combo>=24&&combo<27)
			pointone_limitation<=100000;
		else if(combo>=27&&combo<30)
			pointone_limitation<=50000;
    else
      pointone_limitation<=5000;
	end
end
//pointone_limitation and pointone_counter
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
//fever time 
wire fever_time;
assign fever_time = (combo>=30) ? 1:0;

always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		combo<=0;
	end
	else if(pre_win&&!win)
	begin
		case(combo)
			98:combo<=98;
			default: 
			begin 
			if(!fever_time) 
				combo<=combo+1; 
			else 
				combo<=combo+2;  
			end
		endcase
	end
	else if(lose)
	begin
		combo<=0;
	end
	else
		combo<=combo;
end

endmodule