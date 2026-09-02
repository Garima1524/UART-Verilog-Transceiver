`timescale 1ns / 1ps
module uart_top#(
parameter clk_freq = 50_000_000,
parameter baud_rate = 9600
)
(input clk,reset,tx_start,input [7:0] tx_data,output tx,tx_done,output[7:0] rx_data, output rx_done);
wire baud_tick;
wire tx_wire;
wire sample_tick;
wire sync_reset;

baud_generator #(.clk_freq(clk_freq),.baud_rate(baud_rate))
baud_gen(
.clk(clk),
.reset(reset),
.baud_tick(baud_tick),
.sample_tick(sample_tick),
.sync_reset(sync_reset));

uart_tx transmitter(
.clk(clk),
.reset(reset),
.baud_tick(baud_tick),
.tx_start(tx_start),
.tx_data(tx_data),
.tx(tx_wire),
.tx_done(tx_done));

uart_rx receiver(
.clk(clk),
.reset(reset),
.sample_tick(sample_tick),
.rx(tx_wire),
.rx_data(rx_data),
.rx_done(rx_done),
.sync_reset(sync_reset));

assign tx=tx_wire;

endmodule
