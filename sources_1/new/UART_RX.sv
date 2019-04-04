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
  output logic       o_rx_done,
  output logic       o_rx_busy

);


////INST
//
//signals
logic baud_tick;

BaudTickGen # (
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
logic [0:1] sync_rx;

always_ff @ ( posedge i_clk ) begin
  //if ( baud_tick ) begin
    sync_rx <= {i_rx_data, sync_rx[0]};
  //end
end
//
//SYNC INPUT DATA



//FILTERING SPIKES
//
//signals
logic [0:2] filter_window;
logic       filtered_rx;

always_ff @ ( posedge i_clk ) begin
  if ( baud_tick ) begin
    filter_window <= {sync_rx[1], filter_window[0:1]};
  end 
end

//majority
always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    filtered_rx <= 1'b1;
  end else begin
    filtered_rx <= ( filter_window[0] & filter_window[1] ) | 
                   ( filter_window[0] & filter_window[2] ) | 
                   ( filter_window[1] & filter_window[2] );
  end
end
//
//FILTERING SPIKES



//FSM for receiver
//
//signals
typedef enum logic [1:0] {IDLE, START, DATA, STOP} statetype;
statetype state, nextstate;

logic [2:0] bit_counter, reg_bit_counter;
logic [3:0] samples_counter, reg_samples_counter;


always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    state <= IDLE;
  end else begin
    state <= nextstate;
  end	
end

logic       rx_done;
logic       rx_busy;
logic [7:0] rx_data;

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
  if ( ~i_aresetn ) begin
    o_rx_done           <= 1'b0;
    o_rx_busy           <= 1'b0;
    reg_bit_counter     <= '0;
    reg_samples_counter <= '0;
  end else begin
    o_rx_done           <= rx_done;
    o_rx_busy           <= rx_busy;
    reg_bit_counter     <= bit_counter;
    reg_samples_counter <= samples_counter;
  end	
end

always_ff @ ( posedge i_clk ) begin
  o_rx_data <= rx_data;
end

always_comb begin
  
  nextstate       = state;
  rx_data         = o_rx_data;
  rx_done         = 1'b0;
  rx_busy         = o_rx_busy;
  bit_counter     = reg_bit_counter;
  samples_counter = reg_samples_counter;

  case ( state)

    IDLE : begin
      if ( ( ~filtered_rx ) && ( baud_tick ) ) begin
      	rx_busy         = 1'b1;
      	samples_counter = reg_samples_counter + 1;
        nextstate       = START;
      end
    end
    
    START : begin
      if ( baud_tick ) begin

        if ( reg_samples_counter == 7 ) begin
          samples_counter = 0;
          bit_counter     = 0;
          nextstate       = DATA;
        end else begin
          samples_counter = reg_samples_counter + 1;
          nextstate = START;
        end

      end
    end
    
    DATA : begin
      if ( baud_tick ) begin

        if ( reg_samples_counter == 15 ) begin

          rx_data         = {filtered_rx, o_rx_data[7:1]};
          samples_counter = 0;

          if ( bit_counter == 7 ) begin
            nextstate = STOP;
          end else begin
            bit_counter = reg_bit_counter + 1;
            nextstate   = DATA;
          end

        end else begin
          samples_counter = reg_samples_counter + 1;
          nextstate       = DATA;
        end	

      end
    end

    STOP : begin
      if ( baud_tick ) begin
        if ( reg_samples_counter == 15 ) begin	
          rx_done         = 1'b1;
          rx_busy         = 1'b0;
          samples_counter = 0;
          nextstate = IDLE;
        end else begin
          samples_counter = reg_samples_counter + 1;
          nextstate       = STOP;
        end   
      end
    end
  endcase
end

//
//FSM for receiver
endmodule
