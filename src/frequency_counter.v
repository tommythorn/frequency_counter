`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

   // Dynamic configuration
   reg [BITS-1:0]           update_period;
   always @(posedge clk)
     if (reset)
       update_period = UPDATE_PERIOD;
     else if (period_load)
       update_period = period;

   // states
   localparam STATE_COUNT  = 0;
   localparam STATE_TENS   = 1;
   localparam STATE_UNITS  = 2;

   wire                     leading_edge_detect;
   edge_detect edge_detect_inst(clk, signal, leading_edge_detect);

   reg [2:0]                state;
   reg [BITS-1:0]           countdown;
   reg [6:0]                count;
   reg [3:0]                count_tens;
   reg                      load_display;

   seven_segment seven_segment_inst(clk, reset, load_display, count_tens, count[3:0], segments, digit);

   always @(posedge clk) begin
        if (reset) begin
           state <= STATE_COUNT;
           countdown <= update_period;
           count <= 0;
           count_tens <= 0;
           load_display <= 0;
        end else begin
            case (state)
                STATE_COUNT: begin
                    // count edges and clock cycles
                   count_tens <= 0;
                   load_display <= 0;

                   count <= count + leading_edge_detect;
                   countdown <= countdown - 1;
                   if (countdown == 1) begin
                      countdown <= update_period;
                      state <= STATE_TENS;
                   end
                end

                STATE_TENS: begin
                   if (count >= 10) begin
                      count <= count - 10;
                      count_tens <= count_tens + 1;
                   end else begin
                      state <= STATE_UNITS;
                      load_display <= 1;
                   end
                end

                STATE_UNITS: begin
                    // what is left in edge counter is units
                    // update the display
                   load_display <= 0;

                    // go back to counting
                   state <= STATE_COUNT;
                   count <= 0;
                end

                default:
                    state           <= STATE_COUNT;

            endcase
        end
    end

endmodule
