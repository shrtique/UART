`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////



module tb_UART_result_checker(

  input  logic       i_clk,
  input  logic       i_aresetn,

  input  logic       i_tx_start,
  input  logic [7:0] i_tx_data,

  input  logic       i_rx_done,
  input  logic [7:0] i_rx_data

);

logic [7:0] tx_data;
logic [7:0] rx_data;

logic       tx_rdy;
logic       rx_rdy;
logic       checked, reg_checked;

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    tx_data <= '0;
    tx_rdy  <= 1'b0;
  end else begin

    if ( i_tx_start ) begin
      tx_data <= i_tx_data;
      tx_rdy  <= 1'b1;
    end

    if ( reg_checked ) begin
      tx_rdy <= 1'b0;
    end

  end
end

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    rx_data <= '0;
    rx_rdy  <= 1'b0;
  end else begin
    if ( i_rx_done ) begin
      rx_data <= i_rx_data;
      rx_rdy  <= 1'b1;
    end

    if ( reg_checked ) begin
      rx_rdy <= 1'b0;
    end

  end
end


always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    reg_checked <= 1'b0;
  end else begin
  	reg_checked <= checked;
  end
end

int i = 0;
always_comb begin
  checked = 1'b0;
  if ( tx_rdy & rx_rdy ) begin
  	
    if ( tx_data == rx_data ) begin
      $write( "Test_%0d: TX: 0x%h; RX: 0x%h; WELL DONE \n", i, tx_data, rx_data );
    end else begin
      $write( "Test_%0d: TX: 0x%h; RX: 0x%h; FAILD BITCH \n", i, tx_data, rx_data );
    end
    checked = 1'b1;
    i = i + 1;
  end
end

//////////////////////////////////////////////////////////////////////////////////
endmodule
