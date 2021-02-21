`default_nettype none
`timescale 1ns/1ps

module seg7 (
    input wire [3:0] counter,
    output reg [6:0] segments
);

        always @(*) begin
        case(counter)
            //                7654321
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111100;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1100111;
            default:
                segments = 7'b0000000;
        endcase
    end

endmodule


module seven_segment (
    input wire          clk,
    input wire          reset,
    input wire          load,
    input wire [3:0]    ten_count,
    input wire [3:0]    unit_count,
    output wire [6:0]   segments,
    output reg          digit
);

   reg [3:0]            ten_count_r, unit_count_r;
   wire [3:0]           decode = digit ? ten_count_r : unit_count_r;

   always @(posedge clk)
     if (reset)
       {ten_count_r, unit_count_r} <= 0;
     else if (load)
       {ten_count_r, unit_count_r} <= {ten_count, unit_count};

   always @(posedge clk)
     if (reset)
       digit <= 0;
     else
       digit <= !digit;

   seg7 seg7_inst(decode, segments);
endmodule
