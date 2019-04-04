`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////


module tb_UART_data_gen (

  input  logic       i_clk,
  input  logic       i_aresetn,

  //connection w/ TX module
  input  logic       i_tx_done,
  output logic       o_tx_start,
  output logic [7:0] o_tx_data

);
///////////////
logic one_pulse;

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    o_tx_data  <= '0;
    o_tx_start <= 1'b0;
    one_pulse  <= 1'b1;
  end else begin
  	if ( ( i_tx_done ) && ( one_pulse ) ) begin
  	  o_tx_data  <= $urandom_range(255,0);;
  	  o_tx_start <= 1'b1;
      one_pulse  <= 1'b0;
  	end else begin
  	  o_tx_start <= 1'b0;
  	  one_pulse  <= 1'b1;
  	end  
  end
end	

//////////////////////////////////////////////////////////////////////////////////
endmodule
