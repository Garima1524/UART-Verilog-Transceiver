`timescale 1ns / 1ps
module uart_rx(input clk,reset,sample_tick,rx,output reg [7:0] rx_data,output reg rx_done, output reg sync_reset);
localparam IDLE= 2'b00;
localparam START= 2'b01;
localparam DATA= 2'b10;
localparam STOP= 2'b11;

reg [1:0] state;
reg [3:0] sample_count;
reg [2:0] bit_count;
reg [7:0] rx_data_reg;
reg rx_sync1,rx_sync2;
reg rx_sync2_reg;
reg frame_error;

always @(posedge clk) begin
if(reset)begin
rx_sync1<=1'b1;
rx_sync2<=1'b1;
rx_sync2_reg<=1'b1;
end else begin
rx_sync1<=rx;
rx_sync2<=rx_sync1;
rx_sync2_reg<=rx_sync2;
end
end
wire start_edge=(rx_sync2_reg==1'b1)&&(rx_sync2==1'b0);
always @(posedge clk) begin
if(reset) begin
state<=IDLE;
bit_count<=3'b000;
sample_count <= 4'd0;
rx_data_reg<=8'b00000000;
rx_data<=8'b00000000;
rx_done<=1'b0;
sync_reset<=1'b0;
frame_error<=1'b0;
end else begin
sync_reset <= 1'b0; 
case(state)
IDLE:
begin
rx_done<=1'b0;
if(rx_sync2==1'b0)
begin
bit_count<=3'b000;
sample_count <= 4'd0;
rx_data_reg<=8'b00000000;
sync_reset<=1'b1;
state<=START;
end
end
START:
begin
if(sample_tick) begin
if(sample_count==4'd7) begin
sample_count<=4'd0;
if(rx_sync2==1'b0) begin
state<=DATA;
end else begin
state<=IDLE;
end
end else begin
sample_count<=sample_count+1'b1;
end
end
end 
DATA:
begin
if(sample_tick) begin
if(sample_count==4'd15) begin
sample_count<=4'd0;
rx_data_reg[bit_count]<=rx_sync2;
if(bit_count==3'd7) begin
state<=STOP;
end else begin
bit_count<=bit_count+1'b1;
end
end else begin
sample_count<=sample_count+1'b1;
end
end 
end
STOP:
begin 
if (sample_tick) begin 
if(sample_count==4'd15) begin
sample_count<=4'd0;
if(rx_sync2==1'b1) begin 
rx_data<=rx_data_reg;
rx_done<=1'b1;
frame_error<=1'b0;
end else begin
frame_error<=1'b1;
end 
bit_count<=3'd0;
state<=IDLE;
end else begin
sample_count<=sample_count+1'b1;
end
end
end
default:
begin
state <= IDLE;
bit_count <= 3'b000;
sample_count <= 4'd0;
rx_data_reg <= 8'b00000000;
rx_data <= 8'b00000000;
rx_done <= 1'b0;
sync_reset<=1'b0;
frame_error<=1'b0;
end
endcase 
end
end
endmodule
