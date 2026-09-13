`timescale 1ns / 1ps

// UART transmitter using an FSM
// Sends 8-bit data LSB first with one start bit and one stop bit
module uart_tx(
    input clk,reset,baud_tick,tx_start,
    input [7:0]tx_data,
    output reg tx,tx_done
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

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

        // UART line stays high when it is idle
        IDLE:
        begin
            tx<=1'b1;
            tx_done<=1'b0;

            // Store the data before transmission starts
            if(tx_start) begin
                tx_data_reg<=tx_data;
                bit_count<=3'b0;
                state<=START;
            end
        end

        // Start bit is always logic 0 and lasts for one baud period
        START:
        begin
            tx<=1'b0;

            if(baud_tick) begin
                state<=DATA;
            end
        end

        // Send the 8 data bits starting from bit 0 (LSB first)
        DATA:
        begin
            tx<=tx_data_reg[bit_count];

            // Change to the next data bit only at the baud boundary
            if(baud_tick) begin
                if(bit_count==3'd7) begin
                    state<=STOP;
                end
                else begin
                    bit_count<=bit_count+1'b1;
                end 
            end 
        end 

        // Stop bit is logic 1 and lasts for one baud period
        STOP:
        begin
            tx<=1'b1;

            if(baud_tick) begin
                // Transmission is complete after the stop bit
                tx_done<=1'b1;
                bit_count<=3'b000;
                state<=IDLE;
            end
        end

        // Return to a safe idle state if an invalid FSM state occurs
        default:
        begin
            state<=IDLE;
            tx<=1'b1;
            tx_done<=1'b0;
            tx_data_reg<=8'b0;
            bit_count<=3'b0;
        end

        endcase
    end
end

endmodule