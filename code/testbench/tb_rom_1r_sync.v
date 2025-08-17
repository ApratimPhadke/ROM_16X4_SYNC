`timescale 1ns/1ps
`default_nettype none

module tb_rom_1r_sync;
    // Parameters must match DUT
    localparam integer DEPTH      = 16;
    localparam integer DATA_WIDTH = 4;
    localparam integer ADDR_WIDTH = 4;

    reg  clk;
    reg  enable;
    reg  [ADDR_WIDTH-1:0] addr;
    wire [DATA_WIDTH-1:0] dout;

    // Instantiate the DUT
    rom_1r_sync #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .enable(enable),
        .addr(addr),
        .dout(dout)
    );

    // Clock: 10ns period (100 MHz)
    always #5 clk = ~clk;

    // Reference ROM contents for checking
    reg [DATA_WIDTH-1:0] expected [0:DEPTH-1];

    integer i;
    integer fails;

    initial begin
        $dumpfile("rom_1r_sync_tb.vcd");  // for GTKWave
        $dumpvars(0, tb_rom_1r_sync);

        // Init clock and inputs
        clk    = 0;
        enable = 1;
        addr   = 0;
        fails  = 0;

        // Load expected values (must match DUT init block)
        expected[ 0] = 4'hA;
        expected[ 1] = 4'h1;
        expected[ 2] = 4'hC;
        expected[ 3] = 4'hE;
        expected[ 4] = 4'h0;
        expected[ 5] = 4'h5;
        expected[ 6] = 4'h2;
        expected[ 7] = 4'hF;
        expected[ 8] = 4'h7;
        expected[ 9] = 4'h9;
        expected[10] = 4'h3;
        expected[11] = 4'hB;
        expected[12] = 4'h8;
        expected[13] = 4'h4;
        expected[14] = 4'hD;
        expected[15] = 4'h6;

        // Wait for reset settle
        @(posedge clk);

        // Pipeline warm-up: apply addr=0
        addr <= 0;
        @(posedge clk); // dout gets memory[0] here

        // Sweep through all addresses
        for (i = 1; i < DEPTH; i = i + 1) begin
            // Check previous cycle output
            if (dout !== expected[i-1]) begin
                $display("FAIL: addr=%0d expected=%h got=%h at t=%0t",
                         i-1, expected[i-1], dout, $time);
                fails = fails + 1;
            end else begin
                $display("PASS: addr=%0d value=%h", i-1, dout);
            end

            // Next address
            addr <= i[ADDR_WIDTH-1:0];
            @(posedge clk);
        end

        // Final check for addr=15
        if (dout !== expected[15]) begin
            $display("FAIL: addr=15 expected=%h got=%h at t=%0t",
                     expected[15], dout, $time);
            fails = fails + 1;
        end else begin
            $display("PASS: addr=15 value=%h", dout);
        end

        // Final report
        if (fails == 0) begin
            $display("RESULT: ALL TESTS PASSED");
        end else begin
            $display("RESULT: %0d TEST(S) FAILED", fails);
            $fatal(1);
        end

        $finish;
    end
endmodule

`default_nettype wire
