module UART_TX # (
  parameter         CLK_FREQ     = 100000000,
  parameter         BAUD_RATE    = 115200,
  parameter         OVERSAMPLING = 1 //should be 1 for TX

)(
  
  input  logic       i_clk,
  input  logic       i_aresetn,

  input  logic       i_tx_start,
  input  logic [7:0] i_tx_data,

  output logic       o_tx_data,
  output logic       o_tx_done
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


////FSM
//
//signals
typedef enum logic [1:0] {IDLE, START, DATA, STOP} statetype;
statetype state, nextstate;

logic       tx_data;
logic       tx_done;

logic [7:0] data_shifter, reg_data_shifter;
logic [3:0] bit_cnt, reg_bit_cnt;
//

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
    if ( ~i_aresetn ) begin
      state <= IDLE;
    end else begin
      state <= nextstate;
    end	
end
//

always_ff @ ( posedge i_clk, negedge i_aresetn ) begin
    if ( ~i_aresetn ) begin
      o_tx_data   <= 1'b1;
      o_tx_done   <= 1'b0;
      reg_bit_cnt <= '0;
    end else begin
      o_tx_data   <= tx_data;
      o_tx_done   <= tx_done;
      reg_bit_cnt <= bit_cnt;
    end	
end

always_ff @ ( posedge i_clk ) begin
  reg_data_shifter <= data_shifter;
end
//

always_comb begin
  nextstate    = state;
  tx_data      = o_tx_data;
  tx_done      = 1'b0;
  data_shifter = reg_data_shifter;
  bit_cnt      = reg_bit_cnt;
  case ( state )

    IDLE : begin

      if ( ( i_tx_start ) && ( baud_tick ) ) begin
      	tx_data      = 1'b0;
      	data_shifter = i_tx_data;
        nextstate    = START;
      end

    end

    START : begin
      if ( baud_tick ) begin
      	tx_data      = reg_data_shifter[0];

        data_shifter = {1'b0, reg_data_shifter[7:1]};
       
        nextstate    = DATA;
      end
    end

    DATA : begin
      if ( baud_tick ) begin

      	if ( reg_bit_cnt == 7 ) begin
          tx_data   = 1'b1;
          bit_cnt   = '0;
          nextstate = STOP;
        end else begin
          tx_data      = reg_data_shifter[0];

          data_shifter = {1'b0, reg_data_shifter[7:1]};
        
          bit_cnt      = reg_bit_cnt + 1;
          
          nextstate    = DATA;
        end
      	
      end
    end

    STOP : begin
      if ( baud_tick ) begin
        tx_done   = 1'b1;
        nextstate = IDLE;
      end
    end

    default : nextstate = IDLE;
  endcase
end
//
////FSM


endmodule
