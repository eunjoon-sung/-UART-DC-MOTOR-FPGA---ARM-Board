`timescale 1ns / 1ps

module tb_UART_top;
    reg clk_50mhz; // Main system clock
    reg rst;
    reg rx_in;
    wire tx_out;
    wire [7:0] rx_data;
    wire INA;
    wire INB;
    
    // DUT (Design Under Test) instantiation
    UART_top u_UART_top(
        .clk_in(clk_50mhz), // The UART module now receives the 50 MHz clock
        .rx_in(rx_in),
        .tx_out(tx_out),
        .rst(rst),
        .INA(INA),
        .INB(INB)
    );

    // System Clock Generation (50 MHz, period 20 ns)
    initial clk_50mhz = 0;
    always #10 clk_50mhz = ~ clk_50mhz; // 50MHz -> 주기 20ns, 절반 주기 10ns
    
    
    // Parameters for calculation
    parameter BAUD_RATE = 9600;
    parameter TIME_PER_BIT_NS = (1667 * 62.5);

    // VCD dump setup
    initial begin
        $dumpfile("tb_UART_top.vcd");
        $dumpvars(0, tb_UART_top);
    end

    // Test sequence
    initial begin
        // 1. Initial Reset
        $display("--- Starting Initial Reset ---");
        rst = 1; rx_in = 1;
        #1000;
        rst = 0;
        #1000;
        $display("--- Reset Complete ---");

        // 2. READ TEST
        $display("--- Starting READ Command Test ---");
        rx_in = 0; #(TIME_PER_BIT_NS); // 1. Start bit
        rx_in = 1; #(TIME_PER_BIT_NS); // 2. R/W bit (1 = READ)
        rx_in = 0; #(TIME_PER_BIT_NS); // 3. Address bit 0
        rx_in = 0; #(TIME_PER_BIT_NS); // 4. Address bit 1
        rx_in = 0; #(TIME_PER_BIT_NS); // 5. Address bit 2
        rx_in = 0; #(TIME_PER_BIT_NS); // 6. Data bit 0
        rx_in = 0; #(TIME_PER_BIT_NS); // 7. Data bit 1
        rx_in = 0; #(TIME_PER_BIT_NS); // 8. Data bit 2
        rx_in = 1; #(TIME_PER_BIT_NS); // 9. Data bit 3
        rx_in = 0; #(TIME_PER_BIT_NS); // 10. Parity bit (intentionally a parity error)
        rx_in = 1; #(TIME_PER_BIT_NS); // 11. Stop bit
        #(TIME_PER_BIT_NS * 4);

        // 3. WRITE TEST
        $display("--- Starting WRITE Command Test ---");
        rx_in = 0; #(TIME_PER_BIT_NS); // 1. Start bit
        rx_in = 1; #(TIME_PER_BIT_NS); // 2. R/W bit (0 = WRITE)
        rx_in = 0; #(TIME_PER_BIT_NS); // 3. Address bit 0
        rx_in = 0; #(TIME_PER_BIT_NS); // 4. Address bit 1
        rx_in = 0; #(TIME_PER_BIT_NS); // 5. Address bit 2
        rx_in = 0; #(TIME_PER_BIT_NS); // 6. Data bit 0
        rx_in = 0; #(TIME_PER_BIT_NS); // 7. Data bit 1
        rx_in = 1; #(TIME_PER_BIT_NS); // 8. Data bit 2
        rx_in = 1; #(TIME_PER_BIT_NS); // 9. Data bit 3
        rx_in = 1; #(TIME_PER_BIT_NS); // 10. Parity bit (intentionally a parity error)
        rx_in = 1; #(TIME_PER_BIT_NS); // 11. Stop bit
        #(TIME_PER_BIT_NS * 4);
        
        $display("--- Simulation Finished ---");
        #20000;
        $finish;
    end
endmodule
