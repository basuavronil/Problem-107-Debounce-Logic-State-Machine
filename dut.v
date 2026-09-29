// Switch Debouncer FSM using explicit if-else logic
module debouncer_fsm (
    input  wire clk,
    input  wire rst_n,
    input  wire sw_in,   // Raw, noisy mechanical switch input
    output reg  sw_out   // Debounced output
);

    // State Encoding (3-bit parameter encoding for Verilog compatibility)
    localparam S_0  = 3'b000; // Stable Low
    localparam S_L1 = 3'b001; // 1 cycle high
    localparam S_L2 = 3'b010; // 2 cycles high
    localparam S_L3 = 3'b011; // 3 cycles high
    localparam S_1  = 3'b100; // Stable High
    localparam S_H1 = 3'b101; // 1 cycle low
    localparam S_H2 = 3'b110; // 2 cycles low
    localparam S_H3 = 3'b111; // 3 cycles low

    reg [2:0] current_state, next_state;

    // 1. Sequential State Register (Active-Low Reset)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= S_0;
        else
            current_state <= next_state;
    end

    // 2. Next-State Combinational Logic (Using if-else inside case statements)
    always @(*) begin
        case (current_state)
            S_0: begin
                if (sw_in)
                    next_state = S_L1;
                else
                    next_state = S_0;
            end
            
            S_L1: begin
                if (sw_in)
                    next_state = S_L2;
                else
                    next_state = S_0;
            end
            
            S_L2: begin
                if (sw_in)
                    next_state = S_L3;
                else
                    next_state = S_0;
            end
            
            S_L3: begin
                if (sw_in)
                    next_state = S_1;
                else
                    next_state = S_0;
            end
            
            S_1: begin
                if (sw_in)
                    next_state = S_1;
                else
                    next_state = S_H1;
            end
            
            S_H1: begin
                if (sw_in)
                    next_state = S_1;
                else
                    next_state = S_H2;
            end
            
            S_H2: begin
                if (sw_in)
                    next_state = S_1;
                else
                    next_state = S_H3;
            end
            
            S_H3: begin
                if (sw_in)
                    next_state = S_1;
                else
                    next_state = S_0;
            end
            
            default: begin
                next_state = S_0;
            end
        endcase
    end

    // 3. Moore Output Logic (Using explicit if-else block)
    always @(*) begin
        if (current_state == S_1  || 
            current_state == S_H1 || 
            current_state == S_H2 || 
            current_state == S_H3) begin
            sw_out = 1'b1;
        end else begin
            sw_out = 1'b0;
        end
    end

endmodule
