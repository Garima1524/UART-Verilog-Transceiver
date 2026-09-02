`timescale 1ns / 1ps
module baud_generator #(
parameter clk_freq=50_000_000,
parameter baud_rate=9600)(
input clk,reset,sync_reset, output reg baud_tick,sample_tick);
localparam integer divisor= clk_freq/(baud_rate*16);
localparam integer counter_width = $clog2(divisor);
reg [counter_width-1:0] counter;
reg [3:0]sample_count;
always @(posedge clk) begin
if(reset||sync_reset) begin
counter<=0;
sample_count<=4'd0;
baud_tick<=1'b0;
sample_tick<=1'b0;
end else begin
sample_tick <= 1'b0;
baud_tick <= 1'b0; 
if(counter == divisor-1) begin
counter <= 0;
sample_tick<=1'b1;
if(sample_count==4'd15) begin
sample_count<=4'd0;
baud_tick<=1'b1;
end else begin
sample_count<=sample_count+1'b1;
end
end else begin
counter<=counter+1'd1;
end 
end
end
endmodule
