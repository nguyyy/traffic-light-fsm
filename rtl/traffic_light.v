`timescale 1ns/ps

// two road traffic control system via moore fsm
// ns: north-south, ew: east-west

module traffic_light #(
    parameter GREEN_TICKS = 8, parameter YELLOW_TICKS = 3
) (
    input wire clk;
    input wire rst;
    //lights
    output reg [1:0] ns_light;
    output reg [1:0] ew_light
);
    //light coloring
    localparam RED      = 2'b00;
    localparam YELLOW   = 2'b01;
    localparam GREEN    = 2'b10;

    // state encodingg
    localparam S_NS_GREEN   = 2'd0;
    localparam S_NS_YELLOW  = 2'd1;
    localparam S_EW_GREEN   = 2'd2;
    localparam S_EW_YELLOW  = 2'd3;

    reg [1:0] state, next_state;
    reg [7:0] timer;

    wire [7:0] duration = ( state == S_NS_GREEN || state == S_EW_GREEN)
                            ? GREEN_TICKS[7:0] : YELLOW_TICKS[7:0];
    wire done = (timer == duration - 1);

    //state regs
    always @(posedge clk) begin
        if(rst) begin
            state <= S_NS_GREEN;
            timer <= 8'd0;
        end else if(done) begin
            state <= next_state;
            timer <= 8'd0;
        end else begin
            timer <= timer + 8'd1;
        end
    end

    //next state logic
    always @(*) begin
        case (state)
            S_NS_GREEN:     next_state = S_NS_YELLOW;
            S_NS_YELLOW:    next_state = S_EW_GREEN ;
            S_EW_GREEN:     next_state = S_EW_YELLOW;
            S_EW_YELLOW:    next_state = S_NS_GREEN ;
            default:        next_state = S_NS_GREEN ;
        endcase
    end

    //outputs  
    always

