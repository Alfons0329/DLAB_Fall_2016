
module keyboard_module(
	output reg [9:0] Key_Valve,
	input PS2_Clk,
	input PS2_Din,
	input clk,
	input rst
);

reg PS2_Clk_Tmp0,PS2_Clk_Tmp1,PS2_Clk_Tmp2,PS2_Clk_Tmp3;
wire nedge_PS2_Clk;
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


assign nedge_PS2_Clk = !PS2_Clk_Tmp0 & !PS2_Clk_Tmp1 & PS2_Clk_Tmp2 & PS2_Clk_Tmp3;
reg nedge_PS2_Clk_Shift;



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

reg Break_r,long_r;

always@(posedge clk, posedge rst) begin
	if(rst) begin
		Break_r <= 1'b0;
		Key_Valve <= 10'd0;
		long_r <= 1'b0;
	end
	else if(Cnt1 == 4'd11) begin
		if(Data_tmp == 8'hE0)
			long_r <= 1'b1; 
		else if(Data_tmp == 8'hF0) 
			Break_r <= 1'b1; 		
		else begin 
			Key_Valve <= {Break_r,long_r,Data_tmp};
			long_r <= 1'b0;
			Break_r <= 1'b0;
		end
	end
	else begin
		Key_Valve <= Key_Valve;
		Break_r <= Break_r;
		long_r <= long_r;	
	end
end


endmodule
