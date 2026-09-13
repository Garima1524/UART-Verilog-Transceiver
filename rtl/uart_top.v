`timescale 1ns / 1ps

// Top-level UART module that connects the baud generator,
// transmitter, and receiver for full-duplex communication
module uart_top#(
parameter clk_freq = 50_000_000,
parameter baud_rate = 9600
)
(input clk,reset,tx_start,
input [7:0] tx_data,
output tx,tx_done,
output[7:0] rx_data, 
output rx_done);

wire baud_tick;
wire tx_wire;
wire sample_tick;
wire sync_reset;
wire frame_error;

// Baud generator provides the timing signals used by both TX and RX
baud_generator #(.clk_freq(clk_freq),.baud_rate(baud_rate))
baud_gen(
.clk(clk),
.reset(reset),
.baud_tick(baud_tick),
.sample_tick(sample_tick),
.sync_reset(sync_reset));

// Transmitter converts the parallel input data into serial UART data
uart_tx transmitter(
.clk(clk),
.reset(reset),
.baud_tick(baud_tick),
.tx_start(tx_start),
.tx_data(tx_data),
.tx(tx_wire),
.tx_done(tx_done));

// Receiver converts the serial data back into an 8-bit parallel value
// tx_wire is connected directly to RX for loopback operation
uart_rx receiver(
.clk(clk),
.reset(reset),
.sample_tick(sample_tick),
.rx(tx_wire),
.rx_data(rx_data),
.rx_done(rx_done),
.sync_reset(sync_reset),
.frame_error(frame_error));

// Connect the internal TX signal to the top-level output
assign tx=tx_wire;

endmodule