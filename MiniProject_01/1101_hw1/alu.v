module alu (
    input               i_clk,
    input               i_rst_n,
    input               i_valid,
    input signed [11:0] i_data_a,
    input signed [11:0] i_data_b,
    input        [2:0]  i_inst,
    output              o_valid,
    output       [11:0] o_data,
    output              o_overflow
);
    
// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
reg  [11:0] o_data_w, o_data_r;
reg         o_valid_w, o_valid_r;
reg         o_overflow_w, o_overflow_r;
// ---- Add your own wires and registers here if needed ---- //
reg signed [23:0] overflow_result; // wire
ref signed [11:0] accumulator; // register



// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
assign o_valid = o_valid_r;
assign o_data = o_data_r;
assign o_overflow = o_overflow_r;
// ---- Add your own wire data assignments here if needed ---- //




// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your combinational block design here ---- //
always@(*) begin
    o_data_w = ;
    o_overflow_w = ;
    o_valid_w = ;
    overflow_result = ;
    case(i_inst)
        3'b000: begin // ADD

            // overflow logic
            overflow_result = i_data_a + i_data_b;
            if(overflow_result[23:12] != {12{overflow_result[11]}}) begin
                o_overflow_w = 1'b1;
            end else begin
                o_overflow_w = 1'b0;     
            end

            // arithmetic logic
            o_data_w = i_data_a + i_data_b;
        end

        3'b001: begin // SUBTRACT

            // overflow logic
            overflow_result = i_data_a - i_data_b;
            if(overflow_result[23:12] != {12{overflow_result[11]}}) begin
                o_overflow_w = 1'b1;
            end else begin
                o_overflow_w = 1'b0;     
            end

            // arithmetic logic
            o_data_w = i_data_a - i_data_b;
        end

        3'b010: begin // MULTIPLY 

            // overflow logic
            overflow_result = ((i_data_a * i_data_b) + 5'd16) >>> 5; // Adding 2 ^ (5-1) and then truncate 5 LSBs for rounding fraction
            
            if(overflow_result[23:12] != {12{overflow_result[11]}}) begin
                o_overflow_w = 1'b1;
            end else begin
                o_overflow_w = 1'b0;     
            end

            // arithmetic logic
            o_data_w = overflow_result;
        end

        3'b011: begin // MAC

            // arithmetic logic
            o_data_w = i_data_a * i_data_b;

            // overflow logic
            overflow_result = i_data_a * i_data_b;
            if(overflow_result[23:12] != {12{overflow_result[11]}}) begin
                o_overflow_w = 1'b1;
            end else begin
                o_overflow_w = 1'b0;     
            end
        end

    endcase
end




// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_data_r <= 0;
        o_overflow_r <= 0;
        o_valid_r <= 0;
        accumulator <= 12'b0;
    end else begin
        o_data_r <= o_data_w;
        o_overflow_r <= o_overflow_w;
        o_valid_r <= o_valid_w;
    end
end


endmodule
