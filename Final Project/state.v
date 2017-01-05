`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:13:08 12/31/2016 
// Design Name: 
// Module Name:    state 
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
module state(
    output reg stateleft,
    output reg stateright,
    output reg statedown,
    output reg stateup,
    input clk,
    input rst,
    input [9:0] Data
    );
    
always@(posedge clk, posedge rst) begin
    if(rst) stateleft <= 0;
    else begin
        case(Data)
        {2'b01,8'h6B}: stateleft <= 1;
        {2'b11,8'h6B}: stateleft <= 0;
        default: stateleft <= stateleft;
        endcase
    end
end

always@(posedge clk, posedge rst) begin
    if(rst) stateright <= 0;
    else begin
        case(Data)
        {2'b01,8'h74}: stateright <= 1;
        {2'b11,8'h74}: stateright <= 0;
        default: stateright <= stateright;
        endcase
    end
end
//getkeyvalue=={2'b01,8'h74}
always@(posedge clk, posedge rst) begin
    if(rst) stateup <= 0;
    else begin
        case(Data)
        {2'b01,8'h75}: stateup <= 1;
        {2'b11,8'h75}: stateup <= 0;
        default: stateup <= stateup;
        endcase
    end
end

always@(posedge clk, posedge rst) begin
    if(rst) statedown <= 0;
    else begin
        case(Data)
        {2'b01,8'h72}: statedown <= 1;
        {2'b11,8'h72}: statedown <= 0;
        default: statedown <= statedown;
        endcase
    end
end

endmodule
