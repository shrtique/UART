`timescale 1ns / 1ns


module BaudTickGen # (

  parameter         CLK_FREQ     = 100000000,
  parameter         BAUD_RATE    = 115200,
  parameter         OVERSAMPLING = 16,
  /////////
  parameter         INC_LIM      = int'(real'(CLK_FREQ)/ ( BAUD_RATE * OVERSAMPLING )),
  parameter         CNT_WIDTH    = $clog2(INC_LIM) 

)(

  input  logic i_clk,
  input  logic i_aresetn,

  output logic baud_tick

);


logic [CNT_WIDTH-1:0] counter;

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    counter   <= '0;
    baud_tick <= 1'b0;
  end else begin
    counter   <= ( counter == INC_LIM - 1 ) ? '0 : ( counter + 1 );
    baud_tick <= ( counter == INC_LIM - 1 ) ? 1'b1 : 1'b0;
  end
end


endmodule
