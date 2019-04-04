`timescale 1ns / 1ns
///////////////////////////////////////////////////////////////////////


module tb_BaudTickGen();

//parameters
`define HALF_PER 5

localparam CLK_FREQ     = 100000000;   
localparam BAUD_RATE    = 115200;   
localparam OVERSAMPLING = 16;


//signals
logic clk;
logic resetn;


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



//inst 

BaudTickGen #(
  .CLK_FREQ     ( CLK_FREQ     ),
  .BAUD_RATE    ( BAUD_RATE    ),
  .OVERSAMPLING ( OVERSAMPLING )

) UUT_BaudTickGen (
  .i_clk     ( clk    ),
  .i_aresetn ( resetn ),
  
  .baud_tick (  )
);

endmodule
