`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module tb_UART_result_checker(

  input  logic       i_clk,
  input  logic       i_aresetn,

  input  logic [7:0] i_tx_start,
  input  logic       i_tx_data,

  input  logic       i_rx_done,
  input  logic [7:0] i_rx_data

);

logic [7:0] tx_data;
logic [7:0] rx_data;

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    tx_data <= '0;
  end else begin
    if ( i_tx_start ) begin
      tx_data <= i_tx_start;
    end
  end
end

always begin
  if ( i_rx_done ) begin
  end
end

//////////////////////////////////////////////////////////////////////////////////
endmodule
