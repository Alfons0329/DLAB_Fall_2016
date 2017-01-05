module frogger
(
    input rst,
    input clk,
    input PS2_Clk,
    input PS2_Din,
	output VGA_RED,
	output VGA_GREEN,
	output VGA_BLUE,
	output VGA_HSYNC,
	output VGA_VSYNC,
    output reg led6,
    output reg led5,
    output reg led4,
    output reg led3,
    output reg led2,
    output reg led1,
    output reg led0
);
//LED debug


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


//VGA colors
reg [10:0]col;
reg [10:0]row;
reg [3:0] color;//0:black  1:green   2:blue   3:yellow  4:white
reg R, G, B;

//VGA screen size from PDF
always @ (posedge clk)
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

//parameter
parameter row_begin=23,row_end=623,col_begin=104,col_end=904,frog_radius=25;

parameter seperation_line_width=2;
//seperation line up to down
parameter seperation_line_row1=row_begin+82;
parameter seperation_line_row2=row_begin+82+84*1;
parameter seperation_line_row3=row_begin+82+84*2;
parameter seperation_line_row4=row_begin+82+84*3;
parameter seperation_line_row5=row_begin+82+84*4;
parameter seperation_line_row6=row_begin+82+84*5;

//things moving counter
reg [25:0] onesec_counter;
parameter onesec_limitation=5000000;
always @(posedge rst or posedge clk)
begin
	if(rst)
	begin
		onesec_counter<=0;
	end
	else
	begin
		case(onesec_counter)
		onesec_limitation:onesec_counter<=0;
		default:onesec_counter<=onesec_counter+1;
		endcase
	end
end

//leaves moving
reg[10:0] leaf1_row,leaf1_col;
reg[10:0] leaf2_row,leaf2_col;
reg[10:0] leaf3_row,leaf3_col;
reg[10:0] leaf4_row,leaf4_col;
reg[10:0] leaf5_row,leaf5_col;
reg[10:0] leaf6_row,leaf6_col;
reg[10:0] leaf7_row,leaf7_col;
parameter leaf_radius=30,leaf_fracture=5;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        leaf1_row<=row_begin+seperation_line_row1+leaf_radius-5;//+5;
        leaf1_col<=col_begin+leaf_radius;
        
        leaf2_row<=row_begin+seperation_line_row1+leaf_radius-5;//+5;
        leaf2_col<=col_begin+3*leaf_radius+leaf_fracture;
        
        leaf3_row<=row_begin+seperation_line_row1+leaf_radius-5;//+5;
        leaf3_col<=col_begin+5*leaf_radius+leaf_fracture+300;
        
        leaf4_row<=row_begin+seperation_line_row1+leaf_radius-5;//+5;
        leaf4_col<=col_begin+7*leaf_radius+2*leaf_fracture+300;
        
        leaf5_row<=row_begin+seperation_line_row2+leaf_radius-5;//+5;
        leaf5_col<=col_begin+leaf_radius+300;
        
        leaf6_row<=row_begin+seperation_line_row2+leaf_radius-5;//+5;
        leaf6_col<=col_begin+3*leaf_radius+leaf_fracture+300;
        
        leaf7_row<=row_begin+seperation_line_row2+leaf_radius-5;//+5;
        leaf7_col<=col_begin+5*leaf_radius+2*leaf_fracture+300;
    end
    else if(onesec_counter==onesec_limitation)
    begin
        if(leaf1_col+leaf_radius>=col_end)
            leaf1_col<=col_begin;//+leaf_radius;
        else
            leaf1_col<=leaf1_col+8;
            
        if(leaf2_col+leaf_radius>=col_end)
            leaf2_col<=col_begin;//+3*leaf_radius+leaf_fracture;
        else
            leaf2_col<=leaf2_col+8;
            
        if(leaf3_col+leaf_radius>=col_end)
            leaf3_col<=col_begin;//+5*leaf_radius+leaf_fracture+500;
        else
            leaf3_col<=leaf3_col+8;
            
        if(leaf4_col+leaf_radius>=col_end)
            leaf4_col<=col_begin;//+7*leaf_radius+2*leaf_fracture+500;
        else
            leaf4_col<=leaf4_col+8;
            
        if(leaf5_col+leaf_radius<=col_begin)
            leaf5_col<=col_end;//+leaf_radius+500;
        else
            leaf5_col<=leaf5_col-8;
            
        if(leaf6_col+leaf_radius<=col_begin)
            leaf6_col<=col_end;//+3*leaf_radius+leaf_fracture+500;
        else
            leaf6_col<=leaf6_col-8;
            
        if(leaf7_col+leaf_radius<=col_begin)
            leaf7_col<=col_end;//+leaf_radius;
        else
            leaf7_col<=leaf7_col-8;       
    end
    else
    begin
        leaf1_row<=leaf1_row;
        leaf1_col<=leaf1_col;
                            
        leaf2_row<=leaf2_row;
        leaf2_col<=leaf2_col;
                            
        leaf3_row<=leaf3_row;
        leaf3_col<=leaf3_col;
                            
        leaf4_row<=leaf4_row;
        leaf4_col<=leaf4_col;
                            
        leaf5_row<=leaf5_row;
        leaf5_col<=leaf5_col;
                            
        leaf6_row<=leaf6_row;
        leaf6_col<=leaf6_col;
                            
        leaf7_row<=leaf7_row;
        leaf7_col<=leaf7_col;
    end                     
end




//cars moving
reg [10:0] car1_row,car1_col;
reg [10:0] car2_row,car2_col;
reg [10:0] car3_row,car3_col;
reg [10:0] car4_row,car4_col;
parameter car_half_row=30,car_half_col=80;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        car1_row<=seperation_line_row4+car_half_row+15;//+5;
        car1_col<=col_begin+car_half_col;
        
        car2_row<=seperation_line_row4+car_half_row+15;//+5;
        car2_col<=col_begin+3*car_half_col+100;
        
        car3_row<=seperation_line_row5+car_half_row+15;//+5;
        car3_col<=col_begin+car_half_col+300;
        
        car4_row<=seperation_line_row5+car_half_row+15;//+5;
        car4_col<=col_begin+3*car_half_col+500;
    end
    else if(onesec_counter==onesec_limitation) 
    begin
        if(car1_col-car_half_col<=col_begin)
            car1_col<=col_end;//+car_half_col;
        else
            car1_col<=car1_col-8;
            
        if(car2_col-car_half_col<=col_begin)
            car2_col<=col_end;//+3*car_half_col+100;
        else
            car2_col<=car2_col-8;
            
        if(car3_col+car_half_col>=col_end)
            car3_col<=col_begin;//+car_half_col+300;
        else
            car3_col<=car3_col+6;
        
        if(car4_col+car_half_col>=col_end)
            car4_col<=col_begin;//+3*car_half_col+500;
        else
            car4_col<=car4_col+6;
    end
    else
    begin
        car1_row<=car1_row;
        car1_col<=car1_col;
                            
        car2_row<=car2_row;
        car2_col<=car2_col;
                            
        car3_row<=car3_row;
        car3_col<=car3_col;
                            
        car4_row<=car4_row;
        car4_col<=car4_col;

    end
end


//train moving  
reg [10:0] train_row,train_col;
parameter train_half_row=30,train_half_col=125;
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        train_row<=seperation_line_row3+train_half_row+5;
        train_col<=col_begin+train_half_col;
    end
    else if(onesec_counter==onesec_limitation) 
    begin
        if(train_col+train_half_col>=col_end)
            train_col<=col_begin+train_half_col;
        else
            train_col<=train_col+6;
    end
    else
        train_col<=train_col;
end



//frog moving 
//up moving 80 pixels at a time 
// lr moving 10 pixels at a time
reg lose;
reg [10:0] frog_row,frog_col;
always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        frog_row<=row_end-frog_radius-10;
        frog_col<=col_end-frog_radius-100;
        lose<=0;
        led0<=0;
        led1<=0;
        led2<=0;
        led3<=0;
        led4<=0;
        led5<=0;
        led6<=0;
    end
    else if(((frog_col<=car3_col+car_half_col+frog_radius
    &&frog_col>=car3_col-car_half_col-frog_radius)
    ||(frog_col<=car4_col+car_half_col+frog_radius
    &&frog_col>=car4_col-car_half_col-frog_radius))
    &&(frog_row>=seperation_line_row5)
    &&(frog_row<=seperation_line_row6))//hit by the fucking red cars
    begin
        frog_row<=row_end-frog_radius-10;
        frog_col<=col_end-frog_radius-100;
        lose<=1;
    end
    else if(((frog_col<=car1_col+car_half_col+frog_radius
    &&frog_col>=car1_col-car_half_col-frog_radius)
    ||(frog_col<=car2_col+car_half_col+frog_radius
    &&frog_col>=car2_col-car_half_col-frog_radius))
    &&(frog_row>=seperation_line_row4)
    &&(frog_row<=seperation_line_row5)) //hit by the fucking yellow cars
    begin
        frog_row<=row_end-frog_radius-10;
        frog_col<=col_end-frog_radius-100;
        lose<=1;
    end
    else if((frog_col<=train_col+train_half_col+frog_radius
    &&frog_col>=train_col-train_half_col-frog_radius)
    &&(frog_row>=seperation_line_row3)
    &&(frog_row<=seperation_line_row4))//hit by the fucking train
    begin
        frog_row<=row_end-frog_radius-10;
        frog_col<=col_end-frog_radius-100;
        lose<=1;
    end
    else if(frog_row>=seperation_line_row1
    &&frog_row<=seperation_line_row2) //frog is on the leaf area
    begin
        led4<=1;
        led5<=1;
        if(frog_col-frog_radius>=leaf1_col-leaf_radius&&frog_col+frog_radius<=leaf1_col+leaf_radius)
        begin
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf1_row;
                frog_col<=leaf1_col;      
            end
        end
        else if(frog_col-frog_radius>=leaf2_col-leaf_radius-20&&frog_col+frog_radius<=leaf2_col+leaf_radius+20)
        begin                                              
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf2_row;
                frog_col<=leaf2_col;      
            end                         
        end                                                
        else if(frog_col-frog_radius>=leaf3_col-leaf_radius-20&&frog_col+frog_radius<=leaf3_col+leaf_radius+20)
        begin                                              
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf3_row;
                frog_col<=leaf3_col;      
            end                          
        end                                                
        else if(frog_col-frog_radius>=leaf4_col-leaf_radius-20&&frog_col+frog_radius<=leaf4_col+leaf_radius+20)
        begin                                              
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf4_row;
                frog_col<=leaf4_col;      
            end                           
        end
        else //frog swims and dies WTF
        begin
            frog_row<=row_end-frog_radius-10;
            frog_col<=col_end-frog_radius-80;
            
            led4<=0;
            led5<=0;
            lose<=1;
        end
    end
    else if(frog_row>=seperation_line_row2
    &&frog_row<=seperation_line_row3)
    begin
        if(frog_col-frog_radius>=leaf5_col-leaf_radius-20&&frog_col+frog_radius<=leaf5_col+leaf_radius+20)
        begin                                              
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf5_row;
                frog_col<=leaf5_col;      
            end                          
        end                                                
        else if(frog_col-frog_radius>=leaf6_col-leaf_radius-20&&frog_col+frog_radius<=leaf6_col+leaf_radius+20)
        begin                                              
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf6_row;
                frog_col<=leaf6_col;      
            end                           
        end                                                
        else if(frog_col-frog_radius>=leaf7_col-leaf_radius-20&&frog_col+frog_radius<=leaf7_col+leaf_radius+20)
        begin
             
            if(stateleft && !pushleft) //left is pressed DECODING L6B
            begin
                
                if(frog_col-frog_radius<=col_begin)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col-20;
            end
            else if(stateright && !pushright) //right is pressed DECODING L74
            begin
                if(frog_col+frog_radius>=col_end)
                    frog_col<=frog_col;
                else
                    frog_col<=frog_col+20;
            end
            else if(stateup && !pushup) //up os presseed DECODING L75
            begin
                if(frog_row-frog_radius<=row_begin)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row-80;
            end
            else if(statedown && !pushdown)
            begin
                if(frog_row+frog_radius>=row_end)
                    frog_row<=frog_row;
                else
                    frog_row<=frog_row+80;
            end
            else
            begin
                frog_row<=leaf7_row;
                frog_col<=leaf7_col;      
            end
        end
        else //frog swims and dies WTF
        begin
            frog_row<=row_end-frog_radius-10;
            frog_col<=col_end-frog_radius-80;
            
            led4<=0;
            led5<=0;
            lose<=1;
        end
       
    end
    else if(frog_row>=row_begin&&frog_row<=seperation_line_row1) //grass
    begin
        if(stateleft && !pushleft) //left is pressed DECODING L6B  
        begin
            
            if(frog_col-frog_radius<=col_begin)
                frog_col<=frog_col;
            else
                frog_col<=frog_col-20;
        end
        else if(stateright && !pushright) //right is pressed DECODING L74
        begin
            if(frog_col+frog_radius>=col_end)
                frog_col<=frog_col;
            else
                frog_col<=frog_col+20;
        end
        else if(statedown && !pushdown)
        begin
            if(frog_row+frog_radius>=row_end)
                frog_row<=frog_row;
            else
                frog_row<=frog_row+100;
        end
        else
        begin
            frog_row<=frog_row;
            frog_col<=frog_col;      
        end
    end
    else if(frog_col>=col_begin&&frog_col<=260&&frog_row>=row_begin&&frog_row<=seperation_line_row1) //win
    begin
        /*frog_row<=row_end-frog_radius-10;
        frog_col<=col_end-frog_radius-100; */
        led0<=1;
        led1<=1;
        led2<=1;
        led3<=1;
        led4<=1;
        led5<=1;
        led6<=1;
    end
    else //moving the fucking frog
    begin
        if(stateleft && !pushleft) //left is pressed DECODING L6B
        begin
            
            if(frog_col-frog_radius<=col_begin)
                frog_col<=frog_col;
            else
                frog_col<=frog_col-20;
        end
        else if(stateright && !pushright) //right is pressed DECODING L74
        begin
            if(frog_col+frog_radius>=col_end)
                frog_col<=frog_col;
            else
                frog_col<=frog_col+20;
        end
        else if(stateup && !pushup) //up os presseed DECODING L75
        begin
            if(frog_row-frog_radius<=row_begin)
                frog_row<=frog_row;
            else
                frog_row<=frog_row-100;
        end
        else if(statedown && !pushdown)
        begin
            if(frog_row+frog_radius>=row_end)
                frog_row<=frog_row;
            else
                frog_row<=frog_row+100;
        end
        else
        begin
            frog_row<=frog_row;
            frog_col<=frog_col;      
        end
    end

end

//Graphic drawing

always @(posedge clk )
begin
    //black half circle
    if(((row-80)*(row-80)+(col-200)*(col-200)<=60*60)&&(row<=seperation_line_row1-seperation_line_width))
    begin
        R<=0;
        G<=0;
        B<=0;
    end
    else if((row-frog_row)*(row-frog_row)+(col-frog_col)*(col-frog_col)<=frog_radius*frog_radius)//frog
    begin
        R<=1;
        G<=0;
        B<=1;
    end
    else if((row>=car3_row-car_half_row&&row<=car3_row+car_half_row&&col>=car3_col-car_half_col&&col<=car3_col+car_half_col)
    ||(row>=car4_row-car_half_row&&row<=car4_row+car_half_row&&col>=car4_col-car_half_col&&col<=car4_col+car_half_col)) //red cars
    begin
        R<=1;
        G<=0;
        B<=0;
    end
    else if((row>=car1_row-car_half_row&&row<=car1_row+car_half_row&&col>=car1_col-car_half_col&&col<=car1_col+car_half_col)
    ||(row>=car2_row-car_half_row&&row<=car2_row+car_half_row&&col>=car2_col-car_half_col&&col<=car2_col+car_half_col)) //yellow cars
    begin
        R<=1;
        G<=1;
        B<=0;
    end
    else if((row>=train_row-train_half_row&&row<=train_row+train_half_row&&col>=train_col-train_half_col&&col<=train_col+train_half_col)) //train
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    else if((row-leaf1_row)*(row-leaf1_row)+(col-leaf1_col)*(col-leaf1_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf2_row)*(row-leaf2_row)+(col-leaf2_col)*(col-leaf2_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf3_row)*(row-leaf3_row)+(col-leaf3_col)*(col-leaf3_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf4_row)*(row-leaf4_row)+(col-leaf4_col)*(col-leaf4_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf5_row)*(row-leaf5_row)+(col-leaf5_col)*(col-leaf5_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf6_row)*(row-leaf6_row)+(col-leaf6_col)*(col-leaf6_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    else if((row-leaf7_row)*(row-leaf7_row)+(col-leaf7_col)*(col-leaf7_col)<=leaf_radius*leaf_radius)//leaves
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    //seperation line 1
    else if(row>=seperation_line_row1-seperation_line_width&&row<=seperation_line_row1+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //seperation line 2
    else if(row>=seperation_line_row2-seperation_line_width&&row<=seperation_line_row2+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //seperation line 3
    else if(row>=seperation_line_row3-seperation_line_width&&row<=seperation_line_row3+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //seperation line 4
    else if(row>=seperation_line_row4-seperation_line_width&&row<=seperation_line_row4+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //seperation line 5
    else if(row>=seperation_line_row5-seperation_line_width&&row<=seperation_line_row5+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //seperation line 6
    else if(row>=seperation_line_row6-seperation_line_width&&row<=seperation_line_row6+seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=1;
        G<=1;
        B<=1;
    end
    //river
    else if(row>=seperation_line_row1-seperation_line_width&&row<=seperation_line_row3-seperation_line_width&&col>=col_begin&&col<=col_end)
    begin
        R<=0;
        G<=0;
        B<=1;
    end
    //green area 1 (down)
    else if(row>=seperation_line_row3+seperation_line_width&&row<=seperation_line_row4-seperation_line_width&&col>=col_begin&&col<=col_end) 
    begin
        R<=0;
        G<=1;
        B<=0;
    end
    //green area 2 (up)
    else if((row>=row_begin&&row<=seperation_line_row1-seperation_line_width&&col>=col_begin&&col<=col_end))
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


endmodule

