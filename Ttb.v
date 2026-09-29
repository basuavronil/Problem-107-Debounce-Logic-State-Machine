`timescale 1ns/1ps

module tb_debouncer_fsm;

    // Testbench Signals
    reg  clk;
    reg  rst_n;
    reg  sw_in;
    wire sw_out;

    // Instantiate the DUT
    debouncer_fsm uut (
        .clk(clk),
        .rst_n(rst_n),
        .sw_in(sw_in),
        .sw_out(sw_out)
    );

    // Clock Generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    // Monitor and Waveform Dump Setup
    initial begin
        // Dump VCD file for GTKWave visualization
        $dumpfile("debouncer_fsm.vcd");
        $dumpvars(0, tb_debouncer_fsm);

        // Monitor state, input, and output transitions dynamically in console
        $monitor("TIME=%0t ns | rst_n=%b | sw_in=%b | sw_out=%b | state=%b", 
                  $time, rst_n, sw_in, sw_out, uut.current_state);
    end

    // Stimulus Sequence
    initial begin
        // Initialize Signals
        clk   = 0;
        rst_n = 0;
        sw_in = 0;

        // Apply Reset
        #15;
        rst_n = 1;
        #10;

        $display("\n--- TEST 1: Switch Bouncing (3 cycles HIGH - should stay LOW) ---");
        sw_in = 1; #30; // 3 cycles High
        sw_in = 0; #20; // Glitch back to 0 before cycle 4
        
        $display("\n--- TEST 2: Valid Press (4+ cycles HIGH - output should switch to HIGH) ---");
        sw_in = 1; #50; // 5 cycles High (Stability achieved)

        $display("\n--- TEST 3: Switch Release Bouncing (2 cycles LOW - should stay HIGH) ---");
        sw_in = 0; #20; // 2 cycles Low
        sw_in = 1; #20; // Glitch back to 1 before cycle 4

        $display("\n--- TEST 4: Valid Release (4+ cycles LOW - output should switch to LOW) ---");
        sw_in = 0; #50; // 5 cycles Low (Stability achieved)

        $display("\n--- Simulation Complete ---");
        #20;
        $finish;
    end

endmodule
