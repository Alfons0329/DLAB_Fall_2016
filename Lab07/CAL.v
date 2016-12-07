`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:07:10 12/04/2016 
// Design Name: 
// Module Name:    CAL 
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
module CAL(
	clk,
	rst,
	sqrt,
	mul,
	add,
	sw0,
	sw1,
	sw2,
	sw3,
	out
    );
input clk,rst,sqrt,mul,add,sw3,sw2,sw1,sw0;
output reg [7:0] out;

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
//temp key-in
//IP
sqrt_IP mysqrt(.clk(clk),.x_in(tempstore),.x_out(sqrt_out));
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
