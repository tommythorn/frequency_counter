`default_nettype none
`timescale 1ns/1ps
module edge_detect (
    input wire              clk,
    input wire              signal,
    output wire             leading_edge_detect
    );

   reg [2:0] q;

   // q[1] & (q[1] != q[2])    ===
   // q[1] & (q[1] ^ q[2])     ===  // per definition of !=
   // q[1] ? (q[1] ^ q[2]) : 0 ===  // case analysis
   // q[1] ? (!q[2]) : 0       ===  // propagate knowledge
   // q[1] & !q[2]                  // simplify

   assign leading_edge_detect = !q[2] & q[1];
   always @(posedge clk) q <= {q[1:0],signal};
endmodule
