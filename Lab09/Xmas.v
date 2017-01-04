`timescale 1ns / 1ps
module Xmas(
	output VGA_RED,
	output VGA_GREEN,
	output VGA_BLUE,
	output VGA_HSYNC,
	output VGA_VSYNC,
	input rst,
	input CLK
    );
reg [10:0]col;
reg [10:0]row;
reg [3:0] color;//0:black  1:green   2:blue   3:yellow  4:white
reg R, G, B;
//VGA screen size from PDF
always @ (posedge CLK)
begin
	col<=(col<1039)?col+1:0;
	row<=(row==665)?0:(col==1039)?row+1:row;
end
//SYNC SIGNAL
assign VGA_HSYNC= ~((col>=919)&(col<1039));
assign VGA_VSYNC= ~((row>=659)&(row<665));
//SYNC SIGNAL ends here
//colors
assign VGA_RED=R;
assign VGA_GREEN=G;
assign VGA_BLUE=B;
//colors end here
// VGA part ends here for vsync and hsync and colors


//halfsecond counter
reg [26:0] halfseccnt;
reg halfsec;
always@ (posedge CLK or posedge rst)
begin
	halfseccnt<=(rst)?0:(halfseccnt<12500000)?halfseccnt+1:0;
	halfsec<=(rst)?0:(halfseccnt==0)?~halfsec:halfsec;
end
//halfsecond counter ends here



//snow falls down A B C D from left to right, set the drop rate
reg [10:0] snowA, snowB, snowC, snowD;
always @(posedge halfsec or posedge rst)
begin
	snowA<=(rst==1)?650-350:(snowA<630)?snowA+5:650-350;
	snowB<=(rst==1)?650-550:(snowB<630)?snowB+5:650-550;
	snowC<=(rst==1)?650-250:(snowC<630)?snowC+5:650-250;
	snowD<=(rst==1)?650-450:(snowD<630)?snowD+5:650-450;
end
//snow part ends here

//black star placewise
reg [3:0] blackstarmovecounter;
always @(posedge halfsec or posedge rst)
begin
	if(rst)
		blackstarmovecounter<=0;
	else
	begin
		case(blackstarmovecounter)
		4:blackstarmovecounter<=0;
		default:blackstarmovecounter<=blackstarmovecounter+1;
		endcase
	end
end
reg [10:0] blackstar0row,blackstar1col; //set the centre at the reset part
always @(posedge halfsec or posedge rst)
begin
	if(rst)
	begin
		blackstar0row<=650-500;   // left up and down set row first
		blackstar1col<=1040-300;  // right left and right set col first
	end
	else
	begin
		case(blackstarmovecounter)
		0:begin blackstar0row<=blackstar0row+5; blackstar1col<=blackstar1col+5; end
		1:begin blackstar0row<=blackstar0row+5; blackstar1col<=blackstar1col+5; end
		2:begin blackstar0row<=blackstar0row-5; blackstar1col<=blackstar1col-5; end
		3:begin blackstar0row<=blackstar0row-5; blackstar1col<=blackstar1col-5; end
		default:begin blackstar0row<=blackstar0row; blackstar1col<=blackstar1col; end
		endcase
	end

end


//black star placewise here
//black star colourwise
reg [2:0] blackstarcolorcounter;
always @(posedge halfsec or posedge rst)
begin
	if(rst)
		blackstarcolorcounter<=0;
	else
	begin
		case(blackstarcolorcounter)
		2:blackstarcolorcounter<=0;
		default:blackstarcolorcounter<=blackstarcolorcounter+1;
		endcase
	end
end
reg blackstarR,blackstarG,blackstarB;
always @(posedge halfsec or posedge rst)
begin
	if(rst)
	begin
		blackstarR<=0;
		blackstarG<=0;
		blackstarB<=0;
	end
	else
	begin
		case(blackstarcolorcounter)
		0:begin blackstarR<=0; blackstarG<=0; blackstarB<=0; end
		1:begin blackstarR<=1; blackstarG<=0; blackstarB<=0; end
		2:begin blackstarR<=1; blackstarG<=1; blackstarB<=1; end
		default:begin blackstarR<=1; blackstarG<=1; blackstarB<=1; end
		endcase
	end
end

//black star all ends here (except graph in latter)
//picture except the black star
always @ (posedge CLK) 
begin
	if((col>=450-35)&&(col<450+35)&&(row>=500)&&(row<650))
	begin//root
		R<=0;
		G<=0;
		B<=0;
	end
	//tree stars stars here
	else if(((col-450-row+125>-2)&&(col-450-row+125<2)&&(col-450+row-125>-2)&&(col-450+row-125<2))||//shape limitation
	((col>=450-2)&&(col<450+2)&&(row>=125-20)&&(row<125+20))||//vertical rectangular
	((col>=450-20)&&(col<450+20)&&(row>=125-2)&&(row<125+2))||//horizontal rectangular
	((col>=450-3+125-row)&&(col<450+3-row+125)&&(row>=125-20)&&(row<125+20))||// shape of \ \
	((col>=450-3-125+row)&&(col<450+3+row-125)&&(row>=125-20)&&(row<125+20)))// shape of / /
	begin//star top centre row=125 col=450
		R<=1;
		G<=1;
		B<=halfsec;
	end	
	else if(((col-375-row+200>-2)&&(col-375-row+200<2)&&(col-375+row-200>-2)&&(col-375+row-200<2))||
	((col>=375-2)&&(col<375+2)&&(row>=200-20)&&(row<200+20))||
	((col>=375-20)&&(col<375+20)&&(row>=200-2)&&(row<200+2))||
	((col>=375-3+200-row)&&(col<375+3-row+200)&&(row>=200-20)&&(row<200+20))||
	((col>=375-3-200+row)&&(col<375+3+row-200)&&(row>=200-20)&&(row<200+20)))
	begin//star left up centre row=200 col=375
		R<=1; 
		G<=1;
		B<=halfsec;
	end	
	else if(((col-525-row+200>-2)&&(col-525-row+200<2)&&(col-525+row-200>-2)&&(col-525+row-200<2))||
	((col>=525-2)&&(col<525+2)&&(row>=200-20)&&(row<200+20))||
	((col>=525-20)&&(col<525+20)&&(row>=200-2)&&(row<200+2))||
	((col>=525-3+200-row)&&(col<525+3-row+200)&&(row>=200-20)&&(row<200+20))||
	((col>=525-3-200+row)&&(col<525+3+row-200)&&(row>=200-20)&&(row<200+20)))
	begin//star left up centre row=200 col=525
		R<=1;
		G<=1;
		B<=halfsec;
	end
	else if(((col-325-row+325>-2)&&(col-325-row+325<2)&&(col-325+row-325>-2)&&(col-325+row-325<2))||
	((col>=325-2)&&(col<325+2)&&(row>=325-20)&&(row<325+20))||
	((col>=325-20)&&(col<325+20)&&(row>=325-2)&&(row<325+2))||
	((col>=325-3+325-row)&&(col<325+3-row+325)&&(row>=325-20)&&(row<325+20))||
	((col>=325-3-325+row)&&(col<325+3+row-325)&&(row>=325-20)&&(row<325+20)))
	begin//star left middle centre row=325 col=325
		R<=1;
		G<=1;
		B<=halfsec;
	end
	else if(((col-575-row+325>-2)&&(col-575-row+325<2)&&(col-575+row-325>-2)&&(col-575+row-325<2))||//shape limitation
	((col>=575-2)&&(col<575+2)&&(row>=325-20)&&(row<325+20))||//vertical rectangular
	((col>=575-20)&&(col<575+20)&&(row>=325-2)&&(row<325+2))||//horizontal rectangular
	((col>=575-3+325-row)&&(col<575+3-row+325)&&(row>=325-20)&&(row<325+20))||// shape of \ \
	((col>=575-3-325+row)&&(col<575+3+row-325)&&(row>=325-20)&&(row<325+20)))// shape of / /
	begin//star right middle row=325 col=575
		R<=1;
		G<=1;
		B<=halfsec;
	end
	else if(((col-275-row+500>-2)&&(col-275-row+500<2)&&(col-275+row-500>-2)&&(col-275+row-500<2))||//shape limitation
	((col>=275-2)&&(col<275+2)&&(row>=500-20)&&(row<500+20))||//vertical rectangular
	((col>=275-20)&&(col<275+20)&&(row>=500-2)&&(row<500+2))||//horizontal rectangular
	((col>=275-3+500-row)&&(col<275+3-row+500)&&(row>=500-20)&&(row<500+20))||// shape of \ \
	((col>=275-3-500+row)&&(col<275+3+row-500)&&(row>=500-20)&&(row<500+20)))// shape of / /
	begin//star left bottom row=500 col=275
		R<=1;
		G<=1;
		B<=halfsec;
	end	
	else if(((col-625-row+500>-2)&&(col-625-row+500<2)&&(col-625+row-500>-2)&&(col-625+row-500<2))||//shape limitation
	((col>=625-2)&&(col<625+2)&&(row>=500-20)&&(row<500+20))||//vertical rectangular
	((col>=625-20)&&(col<625+20)&&(row>=500-2)&&(row<500+2))||//horizontal rectangular
	((col>=625-3+500-row)&&(col<625+3-row+500)&&(row>=500-20)&&(row<500+20))||// shape of \ \
	((col>=625-3-500+row)&&(col<625+3+row-500)&&(row>=500-20)&&(row<500+20)))// shape of / /
	begin//star right bottom row=500 col=625
		R<=1;
		G<=1;
		B<=halfsec;
	end
	//tree stars ends here
	//leaves starts here
	else if((col>=450-row+325)&&(col<450+row-325)&&(row>=325)&&(row<500))
	begin//leaf bottom
		R<=0;
		G<=1;
		B<=0;
	end
	else if((col>=450-row+200)&&(col<450+row-200)&&(row>=200)&&(row<325))
	begin//leaf middle
		R<=0;
		G<=1;
		B<=0;
	end
	else if((col>=450-row+125)&(col<450+row-125)&(row>=125)&(row<200))
	begin//leaf top
		R<=0;
		G<=1;
		B<=0;
	end
	//leaves ends here
	//snowflake starts here
	else if(((col>=175-2)&(col<175+2)&(row>=snowA-12)&(row<snowA+12))||
	((col>=175-12)&(col<175+12)&(row>=snowA-2)&(row<snowA+2))||
	((col>=175-3+snowA-row)&(col<175+3-row+snowA)&(row>=snowA-10)&(row<snowA+10))||
	((col>=175-3-snowA+row)&(col<175+3+row-snowA)&(row>=snowA-10)&(row<snowA+10)))
	begin//snowA
		R<=1;
		G<=1;
		B<=1;
	end
	else if(((col>=300-2)&(col<300+2)&(row>=snowB-12)&(row<snowB+12))||
	((col>=300-12)&(col<300+12)&(row>=snowB-2)&(row<snowB+2))||
	((col>=300-3+snowB-row)&(col<300+3-row+snowB)&(row>=snowB-10)&(row<snowB+10))||
	((col>=300-3-snowB+row)&(col<300+3+row-snowB)&(row>=snowB-10)&(row<snowB+10)))
	begin//snowB
		R<=1;
		G<=1;
		B<=1;
	end
	else if(((col>=600-2)&(col<600+2)&(row>=snowC-12)&(row<snowC+12))||
	((col>=600-12)&(col<600+12)&(row>=snowC-2)&(row<snowC+2))||
	((col>=600-3+snowC-row)&(col<600+3-row+snowC)&(row>=snowC-10)&(row<snowC+10))||
	((col>=600-3-snowC+row)&(col<600+3+row-snowC)&(row>=snowC-10)&(row<snowC+10)))
	begin//snowC
		R<=1;
		G<=1;
		B<=1;
	end
	else if(((col>=800-2)&(col<800+2)&(row>=snowD-12)&(row<snowD+12))||
	((col>=800-12)&(col<800+12)&(row>=snowD-2)&(row<snowD+2))||
	((col>=800-3+snowD-row)&(col<800+3-row+snowD)&(row>=snowD-10)&(row<snowD+10))||
	((col>=800-3-snowD+row)&(col<800+3+row-snowD)&(row>=snowD-10)&(row<snowD+10)))
	begin//snowD
		R<=1;
		G<=1;
		B<=1;
	end
	//snowflake ends here
	//black star graph area starts here
	else if(((col-225-row+blackstar0row>-2)&&(col-225-row+blackstar0row<2)&&(col-225+row-blackstar0row>-2)&&(col-225+row-blackstar0row<2))||//shape limitation
	((col>=225-2)&&(col<225+2)&&(row>=blackstar0row-20)&&(row<blackstar0row+20))||//vertical rectangular
	((col>=225-20)&&(col<225+20)&&(row>=blackstar0row-2)&&(row<blackstar0row+2))||//horizontal rectangular
	((col>=225-3+blackstar0row-row)&&(col<225+3-row+blackstar0row)&&(row>=blackstar0row-20)&&(row<blackstar0row+20))||// shape of \ \
	((col>=225-3-blackstar0row+row)&&(col<225+3+row-blackstar0row)&&(row>=blackstar0row-20)&&(row<blackstar0row+20)))// shape of / /
	begin//star top centre row=blackstar0row col=225
		R<=blackstarR;
		G<=blackstarG;
		B<=blackstarB;
	end
	else if(((col-blackstar1col-row+100>-2)&&(col-blackstar1col-row+100<2)&&(col-blackstar1col+row-100>-2)&&(col-blackstar1col+row-100<2))||//shape limitation
	((col>=blackstar1col-2)&&(col<blackstar1col+2)&&(row>=100-20)&&(row<100+20))||//vertical rectangular
	((col>=blackstar1col-20)&&(col<blackstar1col+20)&&(row>=100-2)&&(row<100+2))||//horizontal rectangular
	((col>=blackstar1col-3+100-row)&&(col<blackstar1col+3-row+100)&&(row>=100-20)&&(row<100+20))||// shape of \ \
	((col>=blackstar1col-3-100+row)&&(col<blackstar1col+3+row-100)&&(row>=100-20)&&(row<100+20)))// shape of / /
	begin//star top centre row=125 col=blackstar1col
		R<=blackstarR;
		G<=blackstarG;
		B<=blackstarB;
	end
	//black star colourwise ends here
	//BG
	else if ((col>0)&(col<900)&(row>=0)&(row<650))
	begin //back ground
		R<=0;
		G<=0;
		B<=1;
	end
	else //default
	begin
		R<=0;
		G<=0;
		B<=0;
	end	
end
endmodule
