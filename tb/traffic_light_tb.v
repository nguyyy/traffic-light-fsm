`timescale 1ns/1ps

module traffic_light_tb;

    localparam GREEN_T = 5;
    localparam YELLOW_T = 2;
    localparam RED = 2'b00, YELLOW = 2'b01, GREEN = 2'b10;

    reg clk = 0;
    reg rst = 1;
    wire [1:0] ns, ew;
    integer errors = 0;

    //device under test

    traffic_light #(.GREEN_TICKS(GREEN_T), .YELLOW_TICKS(YELLOW_T)) dut 
    (
        .clk(clk),
        .rst(rst),
        .ns_light(ns),
        .ew_light(ew)
    );

    always #5 clk = ~clk;

    //check light timing

    task expect_for(input [1:0] exp_ns, input [1:0] exp_ew, input integer n);
        integer i;
        begin
            for(i = 0; i < n; i = i + 1) begin
                if(ns !== exp_ns || ew !== exp_ew) begin
                    $display("failure t=%0t: ns%b ew=%b, expected ns=%b ew=%b", $time, ns, ew, exp_ns, exp_ew);
                    errors = errors + 1;
                end
                if(ns != RED && ew != RED) begin
                    $display("faliure t=%0t: both roads moving!", $time);
                    errors = errors + 1;
                @(posedge clk); #1;
                end
                @(posedge clk); #1;
            end
        end
    endtask
    

    initial begin
        $dumpfile("traffic_light_tb.vcd");
        $dumpvars(0, traffic_light_tb);

        // reset for 2 cycles, release post clock edge
        repeat (2) @(posedge clk); 
        #1 rst = 0;

        repeat (2) begin
            expect_for(GREEN, RED, GREEN_T);
            expect_for(YELLOW, RED, YELLOW_T);
            expect_for(RED, GREEN, GREEN_T);
            expect_for(RED, YELLOW, YELLOW_T);
        end

        //mid cycle reset = ns green
        expect_for(GREEN, RED, 2);
        rst = 1; @(posedge clk); #1 rst = 0;
        expect_for(GREEN, RED, GREEN_T);

        if(errors == 0) $display ("pass: all checks passed");
        else $display("fail: %0d errors", errors);
        $finish;
    end
endmodule


