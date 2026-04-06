
module top_555_freq (
    input  wire clk,        // ticking at 50 MHz (50 million times a second)
    input  wire sig_555,    // The incoming square wave from the 555 Timer (must be safely stepped down to 3.3V!)
    input  wire rst_btn,    // A physical button to reset the counter (Active-High: 1 means pressed)
    output wire uart_txd    // The wire sending serial data out to the PC
);

    // ─────────────────────────────────────────────────────────────────
    // 1. The 2-Flip-Flop Synchroniser (Clock Domain Crossing)
    // ─────────────────────────────────────────────────────────────────
    // The 555 timer and the FPGA run on completely separate, unsynchronised clocks. 
    // If the FPGA tries to read the 555 signal at the exact moment it is changing from 
    // 0 to 1, the FPGA can get confused (a state called metastability).
    // To fix this, we pass the signal through two "Flip-Flops" (memory registers) 
    // to safely lock it into the FPGA's 50 MHz time zone.
    
    reg s0, s1;
    always @(posedge clk) begin
        s0 <= sig_555;      // First catch of the incoming signal
        s1 <= s0;           // Second catch to ensure it is stable
    end
    
    // Edge Detection: We only want to trigger an event when the wave goes from LOW to HIGH.
    // If the current stable state (s0) is 1, AND the previous state (s1) was 0, a rising edge just happened!
    wire rising_edge = s0 & ~s1;


    // ─────────────────────────────────────────────────────────────────
    // 2. The Period Counter (The Stopwatch)
    // ─────────────────────────────────────────────────────────────────
    // This section counts how many 50 MHz clock ticks happen between two rising edges 
    // of the 555 timer. By knowing the number of ticks, the PC can calculate the exact frequency.
    
    reg [31:0] count;           // A 32-bit counter capable of counting up to ~4 billion
    reg [31:0] period_latch;    // A register to "freeze" and hold the final count to be transmitted
    reg        valid;           // A flag that goes HIGH for 1 clock cycle to say "New data is ready!"

    always @(posedge clk) begin
        valid <= 0; // Default state: no new data
        
        if (rst_btn) begin            // If the user presses the reset button...
            count        <= 0;        // Reset the stopwatch to 0
            period_latch <= 0;        // Clear the saved period
            
        end else if (rising_edge) begin // If the 555 timer just completed a full cycle...
            if (count != 0) begin
                period_latch <= count;  // Save the final count before we restart
                valid        <= 1;      // Signal to the UART module: "Start transmitting!"
            end
            count <= 1;                 // Restart the stopwatch for the next cycle
            
        end else begin                  
            count <= count + 1;         // If waiting for the cycle to end, just keep counting up
        end
    end


    // ─────────────────────────────────────────────────────────────────
    // 3. UART Instantiation (Hooking up the transmitter)
    // ─────────────────────────────────────────────────────────────────
    // We instantiate (plug in) the separate uart_tx module here, much like 
    // plugging a pre-built chip into a breadboard.
    
    reg        tx_start;    // Tell the UART module to start sending a byte
    reg  [7:0] tx_data;     // The 8-bit character we want to send
    wire       tx_busy;     // The UART module tells us when it is busy sending

    uart_tx my_uart (
        .clk(clk),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_out(uart_txd),
        .tx_busy(tx_busy)
    );


    // ─────────────────────────────────────────────────────────────────
    // 4. The Hex-to-ASCII State Machine
    // ─────────────────────────────────────────────────────────────────
    // The UART can only send text characters. This state machine takes the 32-bit binary 
    // number from our stopwatch and chops it into 8 distinct Hexadecimal characters (0-9, A-F).
    
    reg [3:0]  tx_state = 0;   // Keeps track of which character we are currently sending
    reg [31:0] tx_shift;       // A temporary register to hold our count while we chop it up
    reg [3:0]  nibble;         // A 4-bit chunk of data (represents one hex character)

    always @(posedge clk) begin
        tx_start <= 0; // Default state: don't start a new transmission yet

        // State 0: Idle / Wait for data
        if (valid && tx_state == 0) begin
            tx_shift <= period_latch;   // Grab the newly finished count
            tx_state <= 1;              // Move to the first transmission state
        end 
        
        // States 1 through 8: Send the 8 Hexadecimal digits
        else if (tx_state >= 1 && tx_state <= 8 && !tx_busy && !tx_start) begin
            nibble = tx_shift[31:28];   // Grab the top 4 bits (the most significant hex digit)
            
            // Convert the 4-bit number into an actual ASCII text character
            if (nibble < 10) 
                tx_data <= nibble + 8'h30; // Numbers 0-9 correspond to ASCII hex 30-39
            else 
                tx_data <= nibble + 8'h37; // Letters A-F correspond to ASCII hex 41-46
                
            tx_start <= 1;                      // Tell the UART to send this character
            tx_shift <= {tx_shift[27:0], 4'h0}; // Shift all bits left by 4 to line up the next digit
            tx_state <= tx_state + 1;           // Move to the next state
        end 
        
        // State 9: Send Carriage Return ('\r')
        else if (tx_state == 9 && !tx_busy && !tx_start) begin
            tx_data  <= 8'h0D; // ASCII code for Carriage Return
            tx_start <= 1;
            tx_state <= 10;
        end 
        
        // State 10: Send Newline ('\n')
        else if (tx_state == 10 && !tx_busy && !tx_start) begin
            tx_data  <= 8'h0A; // ASCII code for Newline
            tx_start <= 1;
            tx_state <= 0;     // Done! Return to idle and wait for the next 555 timer cycle
        end
    end

endmodule
