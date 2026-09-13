`timescale 1ns / 1ps 
 
// Self-checking testbench for UART TX/RX loopback.
// Sends multiple test patterns and compares received data with the transmitted data.
module uart_top_tb; 
 
reg clk; 
reg reset; 
reg tx_start; 
reg [7:0] tx_data; 
 
wire tx; 
wire tx_done; 
wire [7:0] rx_data; 
wire rx_done; 
 
// Test patterns used to check different bit combinations.
reg [7:0] test_bytes [0:6]; 
 
integer i; 
integer pass_count; 
integer fail_count; 
integer timeout; 
 
uart_top #(.clk_freq(160),.baud_rate(1)) uut  
(.clk(clk), 
.reset(reset), 
.tx_start(tx_start), 
.tx_data(tx_data), 
.tx(tx), 
.tx_done(tx_done), 
.rx_data(rx_data), 
.rx_done(rx_done) 
); 
 
// Generate a 10 ns clock period.
always #5 clk = ~clk; 
 
initial begin 

        // Test patterns covering common corner cases.
        test_bytes[0] = 8'b0000_0000; // All zeros 
        test_bytes[1] = 8'b1111_1111; // All ones 
        test_bytes[2] = 8'b0101_0101; // Alternating bits 
        test_bytes[3] = 8'b1010_1010; // Inverse alternating 
        test_bytes[4] = 8'b0000_0001; // LSB = 1 
        test_bytes[5] = 8'b1000_0000; // MSB = 1 
        test_bytes[6] = 8'b1010_0011; // Arbitrary pattern 
 
        // Initialize all testbench inputs and counters.
        clk = 1'b0; 
        reset = 1'b1; 
        tx_start = 1'b0; 
        tx_data = 8'b0000_0000; 
 
        pass_count = 0; 
        fail_count = 0; 
 
        // Apply reset before starting the tests.
        repeat(5) @(posedge clk); 
        reset = 1'b0; 
        repeat(5) @(posedge clk); 
 
        $display("        UART TEST START"); 
 
        // Send and verify each test pattern.
        for (i = 0; i < 7; i = i + 1) begin 
 
            // Leave an idle gap between frames so the receiver can return to IDLE.
            repeat(200) @(posedge clk); 
 
            // Apply the current test byte and start transmission.
            @(posedge clk); 
            tx_data = test_bytes[i]; 
            tx_start = 1'b1; 
 
            $display("Sending byte %0d: %b at %0t", i, tx_data, $time); 
 
            // Keep tx_start high for two clock cycles.
            repeat(2) @(posedge clk); 
            tx_start = 1'b0; 
 
            // Wait for the receiver to finish, with a timeout to avoid an infinite loop.
            timeout = 0; 
            while ((rx_done != 1'b1) && (timeout < 50000)) begin 
                @(posedge clk); 
                timeout = timeout + 1; 
            end 
 
            if (timeout >= 50000) begin 
                $display("TIMEOUT [%0d]: Expected %b, rx_done never arrived", i, test_bytes[i]); 
                fail_count = fail_count + 1; 
            end else begin 
                #1; 

                // Compare the received byte with the original transmitted byte.
                if (rx_data === test_bytes[i]) begin 
                    $display("PASS [%0d]: Sent %b, Received %b at %0t", i, test_bytes[i], rx_data, $time); 
                    pass_count = pass_count + 1; 
                end else begin 
                    $display("FAIL [%0d]: Sent %b, Received %b at %0t", i, test_bytes[i], rx_data, $time); 
                    fail_count = fail_count + 1; 
                end 
            end 
 
            // Wait for rx_done to clear before starting the next test.
            @(posedge clk); 
        end 
 
        // Display the final verification results.
        $display("UART TEST COMPLETE"); 
        $display("Total Tests : %0d", pass_count + fail_count); 
        $display("Passed      : %0d", pass_count); 
        $display("Failed      : %0d", fail_count); 
 
        if (fail_count == 0) 
            $display("RESULT : PASS"); 
        else 
            $display("RESULT : FAIL"); 

        #100; 
        $finish; 
end 
 
endmodule