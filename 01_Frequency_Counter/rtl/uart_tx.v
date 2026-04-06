

module uart_tx (
    input  wire       clk,
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output reg        tx_out,
    output reg        tx_busy
);

    parameter CLKS_PER_BIT = 434; // 50 MHz / 115200 baud

    reg [3:0]  bit_index;
    reg [9:0]  clock_count;
    reg [9:0]  shift_reg;     // 1 start bit, 8 data bits, 1 stop bit
    reg [1:0]  state;

    localparam IDLE = 0, TX = 1;

    initial begin
        tx_out = 1;
        tx_busy = 0;
        state = IDLE;
    end

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                tx_out <= 1;
                tx_busy <= 0;
                clock_count <= 0;
                bit_index <= 0;
                
                if (tx_start) begin
                    // Load data: Stop bit (1), Data, Start bit (0)
                    shift_reg <= {1'b1, tx_data, 1'b0};
                    tx_busy   <= 1;
                    state     <= TX;
                end
            end
            
            TX: begin
                tx_out <= shift_reg[0];
                
                if (clock_count < CLKS_PER_BIT - 1) begin
                    clock_count <= clock_count + 1;
                end else begin
                    clock_count <= 0;
                    if (bit_index < 9) begin
                        bit_index <= bit_index + 1;
                        shift_reg <= {1'b1, shift_reg[9:1]}; // Shift right
                    end else begin
                        state <= IDLE;
                    end
                end
            end
        endcase
    end
endmodule
