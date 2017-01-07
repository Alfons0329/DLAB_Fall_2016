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





//get the key value from keyboard module output and deal the press state
wire [9:0] get_key_value;
wire stateleft,stateright,statedown,stateup;
reg pushup,pushdown,pushleft,pushright;

keyboard_module mykeyboard_module(.rst(rst),.clk(clk),.PS2_Clk(PS2_Clk),.PS2_Din(PS2_Din),.Key_Valve(get_key_value));
state keyboard_state_module(stateleft,stateright,statedown,stateup,clk,rst,get_key_value);

//divisor ten
wire [15:0] ten;
assign ten=10;
//cheat enlarge 10 times
wire [10:0] cheat_row,cheat_col;

mod10 cheatmod10_row(.clk(clk),.dividend(row-165-rini),.divisor(ten),.quotient(cheat_row));
mod10 cheatmod10_col(.clk(clk),.dividend(col-230-cini),.divisor(ten),.quotient(cheat_col));
//fever enlarge 10 times
wire [10:0] fever_row,fever_col;

mod10 fevermod10_row(.clk(clk),.dividend(row),.divisor(ten),.quotient(fever_row));
mod10 fevermod10_col(.clk(clk),.dividend(col),.divisor(ten),.quotient(fever_col));

//number enlarge 10 times
wire [10:0] num_row , num_col;

mod10 numbermod10_row(.clk(clk),.dividend(row),.divisor(ten),.quotient(num_row));
mod10 numbermod10_col(.clk(clk),.dividend(col),.divisor(ten),.quotient(num_col));
/*wire [10:0] num_1row , num_1col;
wire [10:0] num_2row , num_2col;
wire [10:0] num_3row , num_3col;
wire [10:0] num_4row , num_4col;
wire [10:0] num_5row , num_5col;
wire [10:0] num_6row , num_6col;
wire [10:0] num_7row , num_7col;
wire [10:0] num_8row , num_8col;
wire [10:0] num_9row , num_9col;*/
//get the current score's sigit value


//keyboard state for only one press

reg [9:0] ball_row, ball_col;
reg [9:0] cursor_row_1, cursor_col_1;
wire [9:0] cursor_row_2, cursor_col_2;

wire [237:0] fever;
assign fever[34 * 1 - 1:34 * 0] = 34'b1111110111111011001101111110111110;
assign fever[34 * 2 - 1:34 * 1] = 34'b1100000110000011001101100000110011;
assign fever[34 * 3 - 1:34 * 2] = 34'b1100000110000011001101100000110011;
assign fever[34 * 4 - 1:34 * 3] = 34'b1111100111110011001101111100111110;
assign fever[34 * 5 - 1:34 * 4] = 34'b1100000110000011001101100000110011;
assign fever[34 * 6 - 1:34 * 5] = 34'b1100000110000001111001100000110011;
assign fever[34 * 7 - 1:34 * 6] = 34'b1100000111111000110001111110110011;

wire [244:0] cheat;
assign cheat[35 * 1 - 1:35 * 0] = 35'b11111100011000111111011001100111100;
assign cheat[35 * 2 - 1:35 * 1] = 35'b00110000111100000011011001101100110;
assign cheat[35 * 3 - 1:35 * 2] = 35'b00110001100110000011011001100000110;
assign cheat[35 * 4 - 1:35 * 3] = 35'b00110001111110011111011111100000110;
assign cheat[35 * 5 - 1:35 * 4] = 35'b00110001100110000011011001100000110;
assign cheat[35 * 6 - 1:35 * 5] = 35'b00110001100110000011011001101100110;
assign cheat[35 * 7 - 1:35 * 6] = 35'b00110001100110111111011001100111100;

wire [5:0] _0[0:6];   
assign _0[0] = 6'b011110;
assign _0[1] = 6'b110011;
assign _0[2] = 6'b110011;
assign _0[3] = 6'b110011;
assign _0[4] = 6'b110011;
assign _0[5] = 6'b110011;
assign _0[6] = 6'b011110;

wire [5:0] _1[0:6];
assign _1[0] = 6'b001100;
assign _1[1] = 6'b011100;
assign _1[2] = 6'b001100;
assign _1[3] = 6'b001100;
assign _1[4] = 6'b001100;
assign _1[5] = 6'b001100;
assign _1[6] = 6'b011110;

wire [5:0] _2[0:6];
assign _2[0] = 6'b011110;
assign _2[1] = 6'b110011;
assign _2[2] = 6'b000011;
assign _2[3] = 6'b001110;
assign _2[4] = 6'b011000;
assign _2[5] = 6'b110000;
assign _2[6] = 6'b111111;

wire [5:0] _3[0:6];
assign _3[0] = 6'b011110;
assign _3[1] = 6'b110011;
assign _3[2] = 6'b000011;
assign _3[3] = 6'b001110;
assign _3[4] = 6'b000011;
assign _3[5] = 6'b110011;
assign _3[6] = 6'b011110;
 
wire [5:0] _4[0:6];   
assign _4[0] = 6'b110011;
assign _4[1] = 6'b110011;
assign _4[2] = 6'b110011;
assign _4[3] = 6'b110011;
assign _4[4] = 6'b011111;
assign _4[5] = 6'b000011;
assign _4[6] = 6'b000011;

wire [5:0] _5[0:6];   
assign _5[0] = 6'b111111;
assign _5[1] = 6'b110000;
assign _5[2] = 6'b111110;
assign _5[3] = 6'b000011;
assign _5[4] = 6'b000011;
assign _5[5] = 6'b110011;
assign _5[6] = 6'b011110;

wire [5:0] _6[0:6];
assign _6[0] = 6'b011110;
assign _6[1] = 6'b110011;
assign _6[2] = 6'b110000;
assign _6[3] = 6'b111110;
assign _6[4] = 6'b110011;
assign _6[5] = 6'b110011;
assign _6[6] = 6'b011110;

wire [5:0] _7[0:6];   
assign _7[0] = 6'b111111;
assign _7[1] = 6'b000011;
assign _7[2] = 6'b000110;
assign _7[3] = 6'b001100;
assign _7[4] = 6'b001100;
assign _7[5] = 6'b001100;
assign _7[6] = 6'b001100;

wire [5:0] _8[0:6];   
assign _8[0] = 6'b011110;
assign _8[1] = 6'b110011;
assign _8[2] = 6'b110011;
assign _8[3] = 6'b011110;
assign _8[4] = 6'b110011;
assign _8[5] = 6'b110011;
assign _8[6] = 6'b011110;

wire [5:0] _9[0:6];   
assign _9[0] = 6'b011110;
assign _9[1] = 6'b110011;
assign _9[2] = 6'b110011;
assign _9[3] = 6'b011111;
assign _9[4] = 6'b000011;
assign _9[5] = 6'b110011;
assign _9[6] = 6'b011110;


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
//keyboard state ends here


//1p
//rst rini + 500, cini + 400
//thickness 10+10, 50+50

//2p
//rst rini + 100, cini + 400

reg [2:0] ball_color;
//ball (square)
//radius 5

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
  else if(sw_cheat && ball_col < cursor_col_1)//cheat go left
  begin
    if(cursor_col_1 - ball_col < 20)cursor_col_1 <= ball_col;
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
    if(ball_col - cursor_col_1 < 20)cursor_col_1 <= ball_col;
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
//graphic drawing
always @(posedge clk)
begin
	if((col>=ball_col-10)&&(col<=ball_col+10)&&(row>=ball_row-10)&&(row<=ball_row+10))
	begin
		R<=1;
		G<=0;
		B<=0;
	end
  //cheat
  //165 ,230|-----------------------|
  //        |                       |
  //        |                       |
  //        |                       |
  //        |                       |
  //        |-----------------------|                       
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
  else if(sw_cheat&&(row>=rini+165)&&(row<rini+235)&&(col>=cini+250)&&(col<cini+600)&&(cheat[cheat_row*35+cheat_col]))
  begin
    R<=~sw_r;
    G<=~sw_g;
    B<=~sw_b;
  
  end
  /*else if((row>=rini+165)&&(row<rini+235)&&(col>=cini+230)&&(col<cini+570))
  begin
    R<=0;
    G<=0;
    B<=1;  
  end*/
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
//fever time ??
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