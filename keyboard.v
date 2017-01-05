`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:51:46 12/30/2016 
// Design Name: 
// Module Name:    keyboard 
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
module keyboard_module(
	output reg [9:0] Key_Valve,
	input PS2_Clk,
	input PS2_Din,
	input clk,
	input rst
);

reg PS2_Clk_Tmp0,PS2_Clk_Tmp1,PS2_Clk_Tmp2,PS2_Clk_Tmp3;
wire nedge_PS2_Clk; /*PS2從機時鐘下降沿檢測標誌信號*/
reg [3:0] Cnt1;

always@(posedge clk, posedge rst) begin
	if(rst) begin
		PS2_Clk_Tmp0 <= 1'b0;
		PS2_Clk_Tmp1 <= 1'b0;
		PS2_Clk_Tmp2 <= 1'b0;
		PS2_Clk_Tmp3 <= 1'b0;
	end
	else begin
		PS2_Clk_Tmp0 <= PS2_Clk;
		PS2_Clk_Tmp1 <= PS2_Clk_Tmp0;
		PS2_Clk_Tmp2 <= PS2_Clk_Tmp1;
		PS2_Clk_Tmp3 <= PS2_Clk_Tmp2;
	end
end

/*-------獲取PS時鐘信號的下降沿*/
assign nedge_PS2_Clk = !PS2_Clk_Tmp0 & !PS2_Clk_Tmp1 & PS2_Clk_Tmp2 & PS2_Clk_Tmp3;
reg nedge_PS2_Clk_Shift;

/*PS2時鐘下降沿個數計數器*/

always@(posedge clk, posedge rst) begin
	if(rst)
		Cnt1 <= 4'd0;
	else if(Cnt1 == 4'd11)
		Cnt1 <= 4'd0;
	else if(nedge_PS2_Clk)
		Cnt1 <= Cnt1 + 1'b1;
	else
		Cnt1 <= Cnt1;
end

always@(posedge clk, posedge rst) begin
	if(rst)
		nedge_PS2_Clk_Shift <= 0;
	else
		nedge_PS2_Clk_Shift <= nedge_PS2_Clk;
end

/*讀取8位數據位*/
reg [7:0] Data_tmp;

always@(posedge clk, posedge rst) begin
	if(rst)
		Data_tmp <= 8'd0;
	else if(nedge_PS2_Clk_Shift) begin
		case(Cnt1)
		4'd2:Data_tmp[0] <= PS2_Din;
		4'd3:Data_tmp[1] <= PS2_Din;
		4'd4:Data_tmp[2] <= PS2_Din;
		4'd5:Data_tmp[3] <= PS2_Din;
		4'd6:Data_tmp[4] <= PS2_Din;
		4'd7:Data_tmp[5] <= PS2_Din;
		4'd8:Data_tmp[6] <= PS2_Din;
		4'd9:Data_tmp[7] <= PS2_Din;
		default:Data_tmp <= Data_tmp;
		endcase
	end
	else
		Data_tmp <= Data_tmp;
end

reg Break_r,Long_Code_r;

always@(posedge clk, posedge rst) begin
	if(rst) begin
		Break_r <= 1'b0;
		Key_Valve <= 10'd0;
		Long_Code_r <= 1'b0;
	end
	else if(Cnt1 == 4'd11) begin
		if(Data_tmp == 8'hE0) /*判斷是否為長碼*/
			Long_Code_r <= 1'b1; /*將長碼標誌置1*/
		else if(Data_tmp == 8'hF0) /*判斷是否為斷碼*/
			Break_r <= 1'b1; /*將斷碼標誌置1*/		
		else begin /*檢測到的數據為通碼*/
			Key_Valve <= {Break_r,Long_Code_r,Data_tmp};/*將長碼標誌、斷碼標誌和解碼到的按鍵碼輸出*/
			Long_Code_r <= 1'b0; /*清零長碼標誌*/
			Break_r <= 1'b0; /*清零斷碼標誌*/
		end
	end
	else begin
		Key_Valve <= Key_Valve;
		Break_r <= Break_r;
		Long_Code_r <= Long_Code_r;	
	end
end


endmodule
