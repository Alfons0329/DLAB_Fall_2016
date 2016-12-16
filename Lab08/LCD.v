`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:10 12/04/2016 
// Design Name: 
// Module Name:   LCD
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
module LCD(
	clk,
	rst,
	sqrt,
	mul,
	add,
	sw0,
	sw1,
	sw2,
	sw3,
	out,
    LCD_E,
    LCD_RS,
    LCD_RW,
    SF_D11, //DB7
    SF_D10, //DB6
    SF_D9, //DB5
    SF_D8 //DB4
    );
input clk,rst,sqrt,mul,add,sw3,sw2,sw1,sw0;

output reg [7:0] out;
output wire SF_D11,SF_D10,SF_D9,SF_D8,LCD_E,LCD_RS,LCD_RW;


reg [23:0] press_count;
reg [7:0] tempstore;
reg [2:0] mode;
reg is_pressed,after_rst;
wire [4:0] sqrt_out;

//N:mul E:add W:sqrt following are debouncing system
parameter delay=999;

reg [delay:0] s_register_east;
reg [delay:0] s_register_north;
reg [delay:0] s_register_west;

reg btn_east_triggered;
reg btn_north_triggered;
reg btn_west_triggered;

reg btn_east_pre_state;
reg btn_north_pre_state;
reg btn_west_pre_state;

//LCD things
integer  LCD_counter;
integer  LCD_move_counter; //for moving the fucking character
reg [19:0] LCD_ex_counter;
reg [4:0] LCD_ini_step,cur_hundred,cur_deci,cur_digi,last_hundred,last_deci,last_digi;
reg [3:0] LCD_address_up,LCD_address_down;

//Current ans = XXX circular queue
reg [7:0] current [0:19];
//Lase answer = XXX circular queue
reg [7:0] last [0:19];
//sqrt IP
sqrt_IP mysqrt(.clk(clk),.x_in(tempstore),.x_out(sqrt_out));


//Modular IP and modular register for out;
wire[6:0] hundred;
wire[4:0] ten;
wire[9:0] mod100_rem,mod100_rem_last;
wire[3:0] hun,hun_last,tenth,tenth_last,ger,ger_last;

assign hundred=100;
assign ten=10;
//Modular IP to get hundred ,decimal and digit ends here
mod10 curmod10(.clk(clk),.dividend(mod100_rem),.divisor(ten),.quotient(tenth)/*ten */,.fractional(ger)/*ger*/);
mod100 curmod100(.clk(clk),.dividend(out),.divisor(hundred),.quotient(hun)/*hundred*/,.fractional(mod100_rem));

mod10 lastmod10_dec(.clk(clk),.dividend(mod100_rem_last),.divisor(ten),.quotient(tenth_last)/*ten */,.fractional(ger_last)/*ger*/);
mod100 lastmod100(.clk(clk),.dividend(tempstore),.divisor(hundred),.quotient(hun_last)/*hundred*/,.fractional(mod100_rem_last));

//Another LCD module
LCD_module my_LCD_module(.clk(clk),.reset(rst),
.row_A({current[0],current[1],current[2],current[3],current[4],current[5],current[6],current[7],current[8],current[9],current[10],current[11],current[12],current[13],current[14],current[15]}),
.row_B({last[0],last[1],last[2],last[3],last[4],last[5],last[6],last[7],last[8],last[9],last[10],last[11],last[12],last[13],last[14],last[15]}),
.LCD_E(LCD_E),.LCD_RS(LCD_RS),.LCD_RW(LCD_RW),.LCD_D({SF_D11,SF_D10,SF_D9,SF_D8}));

//LCD display ends here

always@(posedge clk or posedge rst)
begin
	if(rst)
	begin
		mode<=0;
		is_pressed<=0;
        press_count<=0;
	end
	else if(btn_east_triggered && !btn_east_pre_state)
	begin
		/*tempstore<=tempstore+{0,0,0,0,sw3,sw2,sw1,sw0};
		out<=tempstore;*/
		//out<=out+{sw3,sw2,sw1,sw0};
		mode<=1;
		is_pressed<=1;
        press_count<=press_count+1;
	end
	else if(btn_north_triggered && !btn_north_pre_state)
	begin
		mode<=2;
		/*tempstore<=tempstore*{0,0,0,0,sw3,sw2,sw1,sw0};
		out<=tempstore;*/
		//out<=out*{sw3,sw2,sw1,sw0};
		is_pressed<=1;
		press_count<=press_count+1;
	end
	else if(btn_west_triggered && !btn_west_pre_state)
	begin
		mode<=3;
		is_pressed<=1;
		press_count<=press_count+1;
	end
	else
	begin
		mode<=mode;
		is_pressed<=0;
		press_count<=press_count;
	end
end
//calculation
always @(posedge clk)
begin
	case(mode)
	0:begin 
        tempstore<={0,0,0,0,sw3,sw2,sw1,sw0}; 
        out<=0; 
      end
	1:begin  
        if(is_pressed&&press_count>1)tempstore<=out; 
        else if(press_count==1) out<=tempstore+{0,0,0,0,sw3,sw2,sw1,sw0}; 
        else out<=tempstore+{0,0,0,0,sw3,sw2,sw1,sw0}; 
      end
	2:begin  
        if(is_pressed&&press_count>1)tempstore<=out; 
        else if(press_count==1) out<=tempstore*{0,0,0,0,sw3,sw2,sw1,sw0}; 
        else out<=tempstore*{0,0,0,0,sw3,sw2,sw1,sw0}; 
      end
	3:begin /*if(is_pressed)tempstore<=out; else if(after_rst) tempstore<=tempstore; else*/ 
        if(is_pressed&&press_count>1)tempstore<=out;
        else out<=sqrt_out;  
      end
	default: begin tempstore<=tempstore; out<=out; end
	endcase
end
//LCD logic----------------------------------------------------------------//
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        LCD_counter<=0;
		current[0]<=8'b01000011; //C
        current[1]<=8'b01110101; //u
        current[2]<=8'b01110010; //r
        current[3]<=8'b01110010; //r
        current[4]<=8'b01100101; //e
        current[5]<=8'b01101110; //n
        current[6]<=8'b01110100; //t
        current[7]<=8'b00100000; //space
        current[8]<=8'b01100001; //a
        current[9]<=8'b01101110; //n
        current[10]<=8'b01110011; //s
        current[11]<=8'b01110111; //w
        current[12]<=8'b01100101; //e
        current[13]<=8'b01110010; //r
        current[14]<=8'b00100000; //space
        current[15]<=8'b00111101; //=
        current[16]<=8'b00100000; //space
        current[17]<=8'b00110000; //0
        current[18]<=8'b00110000; //0
        current[19]<=8'b00110000; //0
		cur_hundred<=17;
		cur_deci<=18;
		cur_digi<=19;
		
		last[0]<=8'b01001100; //L
        last[1]<=8'b01100001; //a
        last[2]<=8'b01110011; //s
        last[3]<=8'b01110100; //t
        last[4]<=8'b00100000; //space
        last[5]<=8'b01100001; //a
        last[6]<=8'b01101110; //n
        last[7]<=8'b01110011; //s
        last[8]<=8'b01110111; //w
        last[9]<=8'b01100101; //e
        last[10]<=8'b01110010; //r
        last[11]<=8'b00100000; //space
        last[12]<=8'b00111101; //=
        last[13]<=8'b00100000; //space
        last[14]<=8'b00110000; //0
        last[15]<=8'b00110000; //0
        last[16]<=8'b00110000; //0
        last[17]<=8'b00100000; //space
        last[18]<=8'b00100000; //space
        last[19]<=8'b00100000; //space
		last_hundred<=14;
		last_deci<=15;
		last_digi<=16;
    end
	else if(LCD_move_counter==30000000) //Moving data every 30000000 cycle
    begin//moving
        current[0]<=current[1]; 
		current[1]<=current[2]; 
		current[2]<=current[3]; 
		current[3]<=current[4]; 
		current[4]<=current[5]; 
		current[5]<=current[6]; 
		current[6]<=current[7]; 
		current[7]<=current[8]; 
		current[8]<=current[9]; 
		current[9]<=current[10];
		current[10]<=current[11];
		current[11]<=current[12];
		current[12]<=current[13];
		current[13]<=current[14];
		current[14]<=current[15];
		current[15]<=current[16];
		current[16]<=current[17];
		current[17]<=current[18];
		current[18]<=current[19];
		current[19]<=current[0];
		
		case(cur_hundred)
			0:cur_hundred<=19;
			default:cur_hundred<=cur_hundred-1;
		endcase
		
		case(cur_deci)
			0:cur_deci<=19;
			default:cur_deci<=cur_deci-1;
		endcase
		
		case(cur_digi)
			0:cur_digi<=19;
			default:cur_digi<=cur_digi-1;
		endcase

		last[0]<=last[19]; 
		last[1]<=last[0]; 
		last[2]<=last[1]; 
		last[3]<=last[2]; 
		last[4]<=last[3]; 
		last[5]<=last[4]; 
		last[6]<=last[5]; 
		last[7]<=last[6]; 
		last[8]<=last[7]; 
		last[9]<=last[8];
		last[10]<=last[9];
		last[11]<=last[10];
		last[12]<=last[11];
		last[13]<=last[12];
		last[14]<=last[13];
		last[15]<=last[14];
		last[16]<=last[15];
		last[17]<=last[16];
		last[18]<=last[17];
		last[19]<=last[18];
		
		case(last_hundred)
			19:last_hundred<=0;
			default:last_hundred<=last_hundred+1;
		endcase
		
		case(last_deci)
			19:last_deci<=0;
			default:last_deci<=last_deci+1;
		endcase
		
		case(last_digi)
			19:last_digi<=0;
			default:last_digi<=last_digi+1;
		endcase
    end
    else
    begin
		/*current[cur_digi]<={0,0,1,1,ger};
        current[cur_deci]<={0,0,1,1,tenth};
		current[cur_hundred]<={0,0,1,1,hun};
		
		last[last_digi]<={0,0,1,1,ger_last};
        last[last_deci]<={0,0,1,1,tenth_last};
		last[last_hundred]<={0,0,1,1,hun_last};*/
		case(ger) //‹ä			
			0:current[cur_digi]<=8'b00110000;
			1:current[cur_digi]<=8'b00110001;
			2:current[cur_digi]<=8'b00110010;
			3:current[cur_digi]<=8'b00110011;
			4:current[cur_digi]<=8'b00110100;
			5:current[cur_digi]<=8'b00110101;
			6:current[cur_digi]<=8'b00110110;
			7:current[cur_digi]<=8'b00110111;
			8:current[cur_digi]<=8'b00111000;
			9:current[cur_digi]<=8'b00111001;
			default:current[19]<=current[19];
        endcase
        case(tenth) //ä			
			0:current[cur_deci]<=8'b00110000;
			1:current[cur_deci]<=8'b00110001;
			2:current[cur_deci]<=8'b00110010;
			3:current[cur_deci]<=8'b00110011;
			4:current[cur_deci]<=8'b00110100;
			5:current[cur_deci]<=8'b00110101;
			6:current[cur_deci]<=8'b00110110;
			7:current[cur_deci]<=8'b00110111;
			8:current[cur_deci]<=8'b00111000;
			9:current[cur_deci]<=8'b00111001;
			default:current[18]<=current[18];
        endcase
		
        case(hun) //¾ä			
			0:current[cur_hundred]<=8'b00110000;
			1:current[cur_hundred]<=8'b00110001;
			2:current[cur_hundred]<=8'b00110010;
			3:current[cur_hundred]<=8'b00110011;
			4:current[cur_hundred]<=8'b00110100;
			5:current[cur_hundred]<=8'b00110101;
			6:current[cur_hundred]<=8'b00110110;
			7:current[cur_hundred]<=8'b00110111;
			8:current[cur_hundred]<=8'b00111000;
			9:current[cur_hundred]<=8'b00111001;
			default:current[17]<=current[17];
		endcase
		
		
		case(ger_last) //‹ä			
			0:last[last_digi]<=8'b00110000;
			1:last[last_digi]<=8'b00110001;
			2:last[last_digi]<=8'b00110010;
			3:last[last_digi]<=8'b00110011;
			4:last[last_digi]<=8'b00110100;
			5:last[last_digi]<=8'b00110101;
			6:last[last_digi]<=8'b00110110;
			7:last[last_digi]<=8'b00110111;
			8:last[last_digi]<=8'b00111000;
			9:last[last_digi]<=8'b00111001;
			default:last[16]<=last[16];
        endcase
        case(tenth_last) //ä			
			0:last[last_deci]<=8'b00110000;
			1:last[last_deci]<=8'b00110001;
			2:last[last_deci]<=8'b00110010;
			3:last[last_deci]<=8'b00110011;
			4:last[last_deci]<=8'b00110100;
			5:last[last_deci]<=8'b00110101;
			6:last[last_deci]<=8'b00110110;
			7:last[last_deci]<=8'b00110111;
			8:last[last_deci]<=8'b00111000;
			9:last[last_deci]<=8'b00111001;
			default:last[15]<=last[15];
        endcase
		
        case(hun_last) //¾ä			
			0:last[last_hundred]<=8'b00110000;
			1:last[last_hundred]<=8'b00110001;
			2:last[last_hundred]<=8'b00110010;
			3:last[last_hundred]<=8'b00110011;
			4:last[last_hundred]<=8'b00110100;
			5:last[last_hundred]<=8'b00110101;
			6:last[last_hundred]<=8'b00110110;
			7:last[last_hundred]<=8'b00110111;
			8:last[last_hundred]<=8'b00111000;
			9:last[last_hundred]<=8'b00111001;
			default:last[14]<=last[14];
		endcase
	end
end
//LCD moving counter
always@(posedge clk or posedge rst)
begin
	if(rst)
		LCD_move_counter<=0;
	else
	begin
		case(LCD_move_counter)
			30000000:LCD_move_counter<=0;
			default: LCD_move_counter<=LCD_move_counter+1;
		endcase
	end

end
//For Debouncing
always @(posedge clk or posedge rst)
begin
    if(rst)
        begin
            s_register_east<=1000'b0;
			s_register_north<=1000'b0;
            s_register_west<=1000'b0;
			
            btn_east_triggered<=0;
			btn_north_triggered<=0;
            btn_west_triggered<=0;
            
			btn_east_pre_state<=0;
			btn_north_pre_state<=0;
            btn_west_pre_state<=0;
        end
    else
        begin
            s_register_east<={s_register_east[delay-1:0],add};
			s_register_north<={s_register_north[delay-1:0],mul};
            s_register_west<={s_register_west[delay-1:0],sqrt};
			
            btn_east_pre_state<=btn_east_triggered;
			btn_north_pre_state<=btn_north_triggered;
            btn_west_pre_state<=btn_west_triggered;
			
            btn_east_triggered<=(s_register_east==1)?1:0;
			btn_north_triggered<=(s_register_north==1)?1:0;
            btn_west_triggered<=(s_register_west==1)?1:0;
        end
end
endmodule
