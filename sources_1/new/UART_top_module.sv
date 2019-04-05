`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////

module UART_top_module # (

  parameter         CLK_FREQ     = 100000000,
  parameter         BAUD_RATE    = 115200,
  parameter         OVERSAMPLING = 16

)(	

  input  logic       i_clk,      //system clk
  input  logic       i_aresetn,  //system aresetn

  //RX INTERFACE
  input  logic       i_rx_data,  //serial data from transmiiter

  output logic [7:0] o_rx_data,  //received data
  output logic       o_rx_done,  //done if data is received
  output logic       o_rx_busy,  //busy while receiving
  ////////////////////////////

  //TX INTERFACE
  input  logic       i_rx_busy,  //for checking if receiver is ready
  input  logic       i_tx_start, //command to start a transmittion
  input  logic [7:0] i_tx_data,  //data for transmitting

  output logic       o_tx_data,  //serial data to receiver
  output logic       o_tx_done   //done if data is transmitted
  ////////////////////////////
);


//INST RX
//
UART_RX # (
  .CLK_FREQ     ( CLK_FREQ     ),
  .BAUD_RATE    ( BAUD_RATE    ),
  .OVERSAMPLING ( OVERSAMPLING )

) UART_RX (
  .i_clk     ( i_clk     ),
  .i_aresetn ( i_aresetn ),

  .i_rx_data ( i_rx_data ),

  .o_rx_data ( o_rx_data ),
  .o_rx_done ( o_rx_done ),
  .o_rx_busy ( o_rx_busy )
);
//
//INST RX


//INST TX
//
UART_TX # (
  .CLK_FREQ     ( CLK_FREQ  ),
  .BAUD_RATE    ( BAUD_RATE ),
  .OVERSAMPLING ( 1         )

) UART_TX (
  
  .i_clk      ( i_clk      ),
  .i_aresetn  ( i_aresetn  ),
  
  .i_rx_busy  ( i_rx_busy  ),
  .i_tx_start ( i_tx_start ),
  .i_tx_data  ( i_tx_data  ),

  .o_tx_data  ( o_tx_data  ),
  .o_tx_done  ( o_tx_done  )
);
//
//INST TX

//////////////////////////////////////////////////////////////////////////////////
endmodule
