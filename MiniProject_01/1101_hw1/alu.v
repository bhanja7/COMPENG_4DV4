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
reg signed [23:0] result_long; // wire
reg signed [23:0] accumulator; // register
reg signed [23:0] sum_long; // wire



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
    o_data_w = 1'b0;
    o_overflow_w = 1'b0;
    o_valid_w = 1'b0;
    result_long = 24'b0;
    sum_long = 24'b0;

    if(i_valid) begin
        o_valid_w = 1'b0;
        case(i_inst)
            3'b000: begin // ADD
                // overflow logic
                result_long = i_data_a + i_data_b;
                if(result_long[23:12] != {12{result_long[11]}}) begin
                    o_overflow_w = 1'b1;
                end else begin
                    o_overflow_w = 1'b0;     
                end

                // arithmetic logic
                o_data_w = i_data_a + i_data_b;
                o_valid_w = 1'b1;
            end

            3'b001: begin // SUBTRACT

                // overflow logic
                result_long = i_data_a - i_data_b;
                if(result_long[23:12] == {12{result_long[11]}}) begin
                    o_overflow_w = 1'b0;
                end else begin
                    o_overflow_w = 1'b1;     
                end

                // arithmetic logic
                o_data_w = i_data_a - i_data_b;
                o_valid_w = 1'b1;
            end

            3'b010: begin // MULTIPLY 

                // overflow logic
                result_long = ((i_data_a * i_data_b)); // Adding 2 ^ (5-1) and then truncate 5 LSBs for rounding fraction
		        result_long = {result_long[23:10], (result_long[9:0] + 5'd16)};
                
                if(result_long[23:17] != {7{result_long[16]}}) begin
                    o_overflow_w = 1'b1;

                end else begin
                    o_overflow_w = 1'b0;     
                end

                // arithmetic logic
                o_data_w = result_long[16:5];
                o_valid_w = 1'b1;
            end

            3'b011: begin // MAC

                // MAC logic
                result_long = ((i_data_a * i_data_b)); // Adding 2 ^ (5-1) and then truncate 5 LSBs for rounding fraction
		        result_long = {result_long[23:10], (result_long[9:0] + 5'd16)};
                sum_long = result_long[16:5] + accumulator;

                // overflow logic
                if((result_long[23:17] != {7{result_long[16]}})) begin
                    o_overflow_w = 1'b1;
                    $display("result, overflow!");
                end else if((sum_long[23:12] != {12{sum_long[11]}}))begin
                    o_overflow_w = 1'b1;    
                    $display("sum, overflow!"); 
                end else begin
                    o_overflow_w = 1'b0; 
                    $display("no overflow!"); 
                end

                // arithmetic logic
                o_data_w = sum_long[11:0];
                o_valid_w = 1'b1;
            end

            3'b100: begin // BITWISE XNOR
                o_overflow_w = 1'b0;

                o_data_w = ~(i_data_a ^ i_data_b);
                o_valid_w = 1'b1;
            
            end

            3'b101: begin // ReLU
                o_overflow_w = 1'b0;

                if(i_data_a[11]) begin
                    o_data_w = 12'b0;
                end else begin
                    o_data_w = i_data_a;
                end
                o_valid_w = 1'b1;

            end

            3'b110: begin // Mean
                o_overflow_w = 1'b0;
                
                o_data_w = ($signed(i_data_a) + $signed(i_data_b)) >>> 1;
                o_valid_w = 1'b1;

            end

            3'b111: begin // Absolute Max
                o_overflow_w = 1'b0;

                if(i_data_b[10:0] > i_data_a[10:0] ) begin
                    o_data_w = i_data_b;
                end else begin
                    o_data_w = i_data_a;
                end        
                o_valid_w = 1'b1;
            end

            default: begin
                o_data_w = 1'b0;
                o_overflow_w = 1'b0;
                o_valid_w = 1'b0;
                result_long = 24'b0;
                sum_long = 24'b0;
            end
        endcase
    end
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
        accumulator <= 24'b0;
    end else begin
        o_data_r <= o_data_w;
        o_overflow_r <= o_overflow_w;
        o_valid_r <= o_valid_w;

        if(i_inst == 3'b011) begin
            accumulator <= sum_long;            
        end else begin
            accumulator <= 24'b0;
        end
    end
end


endmodule
