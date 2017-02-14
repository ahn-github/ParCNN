/* 
kernels dut_1:
  #1
      /[3][3][3][3]
     / [3][3][3][3]
    /  [3][3][3][3]
   /   [3][3][3][3] z_dim = 1
  /               / 
  [1][1][2][2]   /
  [1][1][2][2]  /
  [2][2][1][1] /
  [2][2][1][1]/  z_dim = 0

  #2
      /[4][4][4][4]
     / [4][4][4][4]
    /  [4][4][4][4]
   /   [4][4][4][4]
  /               / 
  [2][2][3][3]   /
  [2][2][3][3]  /
  [2][2][3][3] /
  [2][2][3][3]/

windows:
  cycle 1:
      /[15][14][13][12]
     / [11][10][9 ][8 ]
    /  [7 ][6 ][5 ][4 ]
   /   [3 ][2 ][1 ][0 ]
  /                   /
  [15][14][13][12]   /
  [11][10][9 ][8 ]  /
  [7 ][6 ][5 ][4 ] /
  [3 ][2 ][1 ][0 ]/


  cycle 2:
      /[16][15][14][13]
     / [12][11][10][9 ]
    /  [8 ][7 ][6 ][5 ]
   /   [4 ][3 ][2 ][1 ]
  /                   /
  [16][15][14][13]   /
  [12][11][10][9 ]  /
  [8 ][7 ][6 ][5 ] /
  [4 ][3 ][2 ][1 ]/


pixels_out for dut_1:
             window 1  | window 2
                       | 
  kernel 1     1260    |   1428 
            -----------+----------
  kernel 2     1732    |   1964
                       |

*/

`timescale 1 ps / 1 ps
module dense_25D_tb();

parameter NUM_TREES = 2;
parameter Z_DEPTH_1 = 4;
parameter Z_DEPTH_2 = 2;
parameter P_SR_DEPTH = 4;
parameter NUM_SR_ROWS = 4;
parameter MA_TREE_SIZE = 16;

reg clock;
reg reset;

reg [7:0] pixel_in;

wire [8*NUM_TREES*MA_TREE_SIZE*Z_DEPTH_1-1:0] kernel_1;
wire [8*NUM_TREES*MA_TREE_SIZE*Z_DEPTH_2-1:0] kernel_2;

wire [32*NUM_TREES-1:0] pixel_out_1;
wire [32*NUM_TREES-1:0] pixel_out_2;

// assign kernels
// see comment at top for kernel or window orientation,
assign kernel_1 = { 
/* kernel 2 z=3 */ 8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
/* kernel 1 z=3 */ 8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
/* kernel 2 z=2 */ 8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
/* kernel 1 z=2 */ 8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
/* kernel 2 z=1 */ 8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
/* kernel 1 z=1 */ 8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
/* kernel 2 z=0 */ 8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
/* kernel 1 z=0 */ 8'd2, 8'd2, 8'd1, 8'd1,
                   8'd2, 8'd2, 8'd1, 8'd1,
                   8'd1, 8'd1, 8'd2, 8'd2,
                   8'd1, 8'd1, 8'd2, 8'd2
                  };

assign kernel_2 = { 
/* kernel 2 z=1 */ 8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
                   8'd4, 8'd4, 8'd4, 8'd4,
/* kernel 1 z=1 */ 8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
                   8'd3, 8'd3, 8'd3, 8'd3,
/* kernel 2 z=0 */ 8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
                   8'd3, 8'd3, 8'd2, 8'd2,
/* kernel 1 z=0 */ 8'd2, 8'd2, 8'd1, 8'd1,
                   8'd2, 8'd2, 8'd1, 8'd1,
                   8'd1, 8'd1, 8'd2, 8'd2,
                   8'd1, 8'd1, 8'd2, 8'd2
                  };


// DUT
dense_25D #(
  .NUM_TREES(NUM_TREES),
  .Z_DEPTH(Z_DEPTH_1),
  .P_SR_DEPTH(P_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS),
  .MA_TREE_SIZE(MA_TREE_SIZE)
)
dut_1(
  .clock(clock),
  .reset(reset),
  .pixel_vector_in({pixel_in, pixel_in, pixel_in, pixel_in}),
  .kernel(kernel_1),
  .pixel_vector_out(pixel_out_1)
);

dense_25D #(
  .NUM_TREES(NUM_TREES),
  .Z_DEPTH(Z_DEPTH_2),
  .P_SR_DEPTH(P_SR_DEPTH),
  .NUM_SR_ROWS(NUM_SR_ROWS),
  .MA_TREE_SIZE(MA_TREE_SIZE)
)
dut_2(
  .clock(clock),
  .reset(reset),
  .pixel_vector_in({pixel_in, pixel_in}),
  .kernel(kernel_2),
  .pixel_vector_out(pixel_out_2)
);

// pixel_in counter
always@(posedge clock or negedge reset) begin
  if(reset == 1'b0) 
    pixel_in <= 8'd0;
  else
    pixel_in <= pixel_in + 8'd1;
end

always begin
  #5 clock <= ~clock;
end

initial begin
  clock = 1'b1;
  reset = 1'b1;
  
  #10 reset = 1'b0;
  #10 reset = 1'b1;

  #160 // wait 16 clock cycles for dense_sr 
  #50 // wait 5 clock cycles for mult_adder tree
  #20 // wait 2 clock cycles for Z dim adder tree
  
  // check output
  $display("Testing Device #1 Z dimension = 4");
  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out_1[31:0]);
  $display("Tree 1 pixel_out = %d", pixel_out_1[31:0]);
  if( pixel_out_1[31:0] == 32'd1260) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out_1[63:32]);
  $display("Tree 2 pixel_out = %d", pixel_out_1[63:32]);
  if( pixel_out_1[63:32] == 32'd1732) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #10
  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out_1[31:0]);
  $display("Tree 1 pixel_out = %d", pixel_out_1[31:0]);
  if( pixel_out_1[31:0] == 32'd1428) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out_1[63:32]);
  $display("Tree 2 pixel_out = %d", pixel_out_1[63:32]);
  if( pixel_out_1[63:32] == 32'd1964) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #50 // arbitrary delay
  // reset counter to test next convolution
  #10 reset = 1'b0;
  #10 reset = 1'b1;
  #160 // wait 16 clock cycles for dense_sr
  #50 // wiat 5 clock cycles for mult_adder tree
  #10 // wait 1 clock cycle for Z dim adder tree 
  // test device 2
  $display("Testing Device #2 Z dimension = 2");
  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out_2[31:0]);
  $display("Tree 1 pixel_out = %d", pixel_out_2[31:0]);
  if( pixel_out_2[31:0] == 32'd540) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out_2[63:32]);
  $display("Tree 2 pixel_out = %d", pixel_out_2[63:32]);
  if( pixel_out_2[63:32] == 32'd772) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else

  #10
  $display($time);
  $display("Tree 1 pixel_out = %h", pixel_out_2[31:0]);
  $display("Tree 1 pixel_out = %d", pixel_out_2[31:0]);
  if( pixel_out_2[31:0] == 32'd612) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else
  $display($time);
  $display("Tree 2 pixel_out = %h", pixel_out_2[63:32]);
  $display("Tree 2 pixel_out = %d", pixel_out_2[63:32]);
  if( pixel_out_2[63:32] == 32'd876) begin
    $display("Pass!");
  end else begin
    $display("Fail!");
  end // end if/else



  #500
  $stop;
end

endmodule