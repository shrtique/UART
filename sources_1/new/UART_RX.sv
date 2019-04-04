`timescale 1ns / 1ns

module UART_RX # (
  parameter         CLK_FREQ     = 100000000,
  parameter         BAUD_RATE    = 115200,
  parameter         OVERSAMPLING = 16

)(
  input  logic       i_clk,
  input  logic       i_aresetn,

  input  logic       i_rx_data,

  output logic [7:0] o_rx_data,
  output logic       o_rx_done
);


////INST
//
//signals
logic baud_tick;

BaudTickGen #(
  .CLK_FREQ     ( CLK_FREQ     ),
  .BAUD_RATE    ( BAUD_RATE    ),
  .OVERSAMPLING ( OVERSAMPLING )

) TX_BaudTickGen (
  .i_clk     ( i_clk     ),
  .i_aresetn ( i_aresetn ),
  
  .baud_tick ( baud_tick )
);
//
////INST


//SYNC INPUT DATA
//
//signals 
logic [0:1] reg_rx;

always_ff @ ( posedge i_clk ) begin
  if ( baud_tick ) begin
    reg_rx <= {i_rx_data, reg_rx[0]};
  end
end
//
//SYNC INPUT DATA


//FILTERING SPIKES
//
//signals



//
//FILTERING SPIKES

endmodule
