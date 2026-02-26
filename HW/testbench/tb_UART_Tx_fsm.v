`timescale 1ns / 1ps

module tb_UART_Tx_fsm;
    // Testbench signals
    reg clk;
    reg rst;
    reg tx_start;
    reg [7:0] to_tx;
    wire tx_out;
    wire busy;

    // Instantiate the Design Under Test (DUT)
    UART_Tx_fsm u_UART_Tx_fsm (
        .tx_start(tx_start),
        .to_tx(to_tx),
        .clk(clk),
        .rst(rst),
        .tx_out(tx_out),
        .busy(busy)
    );

    // Clock Generation
    // 16MHz clock generation (period = 62.5ns)
    always #31.25 clk = ~clk;

    // Stimulus Generation
    initial begin
        // Initialize all signals
        clk = 0;
        rst = 1;
        tx_start = 0;
        to_tx = 8'b0;

        // Apply reset for a short period
        #100 rst = 0;

        // Monitor key signals for debugging
        $monitor("Time=%0t ns, rst=%b, clk=%b, tx_start=%b, to_tx=%h, busy=%b, tx_out=%b",
                 $time, rst, clk, tx_start, to_tx, busy, tx_out);

        // --- Test Case 1: Send a single byte (8'h55) ---
        #50;
        $display("-----------------------------------------");
        $display("Sending byte: 8'h55");
        to_tx = 8'h55;
        tx_start = 1;

        // Wait for one clock cycle to let FSM capture the start signal
        @(posedge clk);
        tx_start = 0;

        // Wait until transmission is complete
        // The total time for 11 bits (1 start, 8 data, 1 parity, 1 stop)
        // is 11 * 1667 clock cycles, which is 11 * (1/9600 s) ~= 1.146 ms
        #1146000; // Wait slightly longer to ensure completion
        $display("Transmission of 8'h55 completed.");
        #100;

        // --- Test Case 2: Send another byte (8'hAA) immediately after ---
        $display("-----------------------------------------");
        $display("Sending byte: 8'hAA");
        to_tx = 8'hAA;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        #1146000;
        $display("Transmission of 8'hAA completed.");
        #100;

        // --- Test Case 3: Send a third byte with a short delay ---
        $display("-----------------------------------------");
        $display("Sending byte: 8'hF0");
        #500;
        to_tx = 8'hF0;
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        #1146000;
        $display("Transmission of 8'hF0 completed.");
        #1000;
        $display("-----------------------------------------");
        $display("Simulation finished.");

        // End of simulation
        $finish;
    end
endmodule
