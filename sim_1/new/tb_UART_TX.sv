`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.04.2019 10:56:57
// Design Name: 
// Module Name: tb_UART_TX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_UART_TX();

//parameters
`define HALF_PER 5

localparam CLK_FREQ     = 100000000;   
localparam BAUD_RATE    = 115200;   
localparam OVERSAMPLING = 1;

//signals
logic clk;
logic resetn;
logic change;

initial begin
  clk <= 1'b0;

  forever begin
  	#(`HALF_PER);
    clk = ~clk;
  end
end

initial begin
  resetn <= 0;
  
  #10;
  @(negedge clk) resetn = 1;
end

initial begin
  change = 0;	
  #50;
  change = 1; 	
end

//SIMPLE DATA GENERATOR
//signals
logic [7:0] data;
logic       start;

always_ff @ ( posedge clk, negedge resetn ) begin
  if ( ~resetn ) begin
    data  <= '0;
    start <= 1'b0;
  end else begin
    data <= 8'hDE;
    start <= 1'b1;
      if ( change ) begin
        data <= 8'hAD;
      end
  end
end



UART_TX # (
  .CLK_FREQ     ( CLK_FREQ     ),
  .BAUD_RATE    ( BAUD_RATE    ),
  .OVERSAMPLING ( OVERSAMPLING )

) UUT_UART_TX (
  
  .i_clk      ( clk    ),
  .i_aresetn  ( resetn ),

  .i_tx_start ( start  ),
  .i_tx_data  ( data   ),

  .o_tx_data  (  ),
  .o_tx_done  (  )
);

endmodule
