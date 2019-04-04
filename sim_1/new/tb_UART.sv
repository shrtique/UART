`timescale 1ns / 1ns
///////////////////////////////////////////////////////////////////////


module tb_UART();

//parameters
`define HALF_PER 5

localparam CLK_FREQ     = 100000000;   
localparam BAUD_RATE    = 115200;  

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


//INST DATA GEN
//
//signals
logic       tx_done;
logic       start;
logic [7:0] data;

tb_UART_data_gen DATA_GEN (

  .i_clk      ( clk     ),
  .i_aresetn  ( resetn  ),

  .i_tx_done  ( tx_done ),
  .o_tx_start ( start   ),
  .o_tx_data  ( data    )

);
//
//INST DATA GEN


//INST TX
//
//signals
logic tx_data;
logic rx_busy;

UART_TX # (
  .CLK_FREQ     ( CLK_FREQ  ),
  .BAUD_RATE    ( BAUD_RATE ),
  .OVERSAMPLING ( 1         )

) UART_TX (
  
  .i_clk      ( clk     ),
  .i_aresetn  ( resetn  ),
  
  .i_rx_busy  ( rx_busy ),
  .i_tx_start ( start   ),
  .i_tx_data  ( data    ),

  .o_tx_data  ( tx_data ),
  .o_tx_done  ( tx_done )
);
//
//INST TX


//INST RX
//
//signals
logic [7:0] rx_data;
logic       rx_done;

UART_RX # (
  .CLK_FREQ     ( CLK_FREQ  ),
  .BAUD_RATE    ( BAUD_RATE ),
  .OVERSAMPLING ( 16        )

) UART_RX (
  .i_clk     ( clk     ),
  .i_aresetn ( resetn  ),

  .i_rx_data ( tx_data ),

  .o_rx_data ( rx_data ),
  .o_rx_done ( rx_done ),
  .o_rx_busy ( rx_busy )
);

//
//INST RX


///////////////////////////////////////////////////////////////////////
endmodule
