`timescale 1ns / 1ps
module uart_tx(input clk,reset,baud_tick,tx_start,input [7:0]tx_data,output reg tx,tx_done);
localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

reg [1:0] state;
reg [7:0] tx_data_reg;
reg [2:0] bit_count;

always @(posedge clk) begin
if(reset) begin
state<=IDLE;
tx_data_reg<=8'b0;
bit_count<=3'b0;
tx<=1'b1;
tx_done<=1'b0;
end else begin
case(state)
IDLE:
begin
tx<=1'b1;
tx_done<=1'b0;
if(tx_start) begin
tx_data_reg<=tx_data;
bit_count<=3'b0;
state<=START;
end
end
START:
begin
tx<=1'b0;
if(baud_tick) begin
state<=DATA;
end
end
DATA:
begin
tx<= tx_data_reg[bit_count];
if(baud_tick) begin
if(bit_count==3'd7) begin
state<=STOP;
end
else begin
bit_count<=bit_count+1'b1;
end 
end 
end 
STOP:
begin
tx<=1'b1;
if(baud_tick) begin
tx_done<=1'b1;
bit_count<=3'b000;
state<=IDLE;
end
end
default:
begin
state<= IDLE;
tx<= 1'b1;
tx_done<= 1'b0;
tx_data_reg<= 8'b0;
bit_count<= 3'b0;
end
endcase
end
end
endmodule
