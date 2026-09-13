`timescale 1ns / 1ps

// UART receiver using 16x oversampling
// Receives 8-bit data LSB first with one start bit and one stop bit
module uart_rx(
    input clk,reset,sample_tick,rx,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg sync_reset,
    output reg frame_error
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [3:0] sample_count;
reg [2:0] bit_count;
reg [7:0] rx_data_reg;

// Two flip-flops synchronize the asynchronous RX signal to the system clock
reg rx_sync1,rx_sync2;

// Synchronize RX before using it in the receiver FSM
always @(posedge clk) begin
    if(reset)begin
        rx_sync1<=1'b1;
        rx_sync2<=1'b1;
    end else begin
        rx_sync1<=rx;
        rx_sync2<=rx_sync1;
    end
end

always @(posedge clk) begin
    if(reset) begin
        state<=IDLE;
        bit_count<=3'b000;
        sample_count<=4'd0;
        rx_data_reg<=8'b00000000;
        rx_data<=8'b00000000;
        rx_done<=1'b0;
        sync_reset<=1'b0;
        frame_error<=1'b0;
    end else begin
        sync_reset<=1'b0;

        case(state)

        // Wait for the RX line to go low, indicating a start bit
        IDLE:
        begin
            rx_done<=1'b0;

            if(rx_sync2==1'b0)
            begin
                bit_count<=3'b000;
                sample_count<=4'd0;
                rx_data_reg<=8'b00000000;
                frame_error<=1'b0;

                // Restart the baud generator so sampling starts from the detected start bit
                sync_reset<=1'b1;
                state<=START;
            end
        end

        // Check the middle of the start bit before accepting the frame
        START:
        begin
            if(sample_tick) begin

                // 8 sample ticks = half of the 16x oversampling period
                // This places the check near the center of the start bit
                if(sample_count==4'd7) begin
                    sample_count<=4'd0;

                    if(rx_sync2==1'b0) begin
                        state<=DATA;
                    end else begin
                        // False start detected, return to idle
                        state<=IDLE;
                    end
                end else begin
                    sample_count<=sample_count+1'b1;
                end
            end
        end

        // Sample one data bit every 16 sample ticks
        DATA:
        begin
            if(sample_tick) begin
                if(sample_count==4'd15) begin
                    sample_count<=4'd0;

                    // Store received bits LSB first
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

        // Check the stop bit and transfer the received byte to rx_data
        STOP:
        begin 
            if(sample_tick) begin 
                if(sample_count==4'd15) begin
                    sample_count<=4'd0;

                    // Stop bit should be logic 1 for a valid UART frame
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

        // Return to a safe idle state if an invalid FSM state occurs
        default:
        begin
            state<=IDLE;
            bit_count<=3'b000;
            sample_count<=4'd0;
            rx_data_reg<=8'b00000000;
            rx_data<=8'b00000000;
            rx_done<=1'b0;
            sync_reset<=1'b0;
            frame_error<=1'b0;
        end

        endcase 
    end
end

endmodule