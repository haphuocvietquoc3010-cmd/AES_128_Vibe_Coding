module aes128_key_expand (
    input  wire          i_clk,
    input  wire          i_rst_n,
    input  wire          i_start,
    input  wire [127:0]  i_key,
    output reg           o_expanding,
    output reg           o_schedule_valid,
    output reg  [1407:0] o_round_keys
);
    import aes128_pkg::*;

    reg [127:0] key_work;
    reg [3:0] key_round;
    wire [127:0] generated_key;

    assign generated_key = next_round_key(key_work, key_round);

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            key_work <= 128'b0;
            key_round <= 4'b0;
            o_expanding <= 1'b0;
            o_schedule_valid <= 1'b0;
            o_round_keys <= 1408'b0;
        end else if (i_start) begin
            o_round_keys[1407 -: 128] <= i_key;
            key_work <= i_key;
            key_round <= 4'd1;
            o_expanding <= 1'b1;
            o_schedule_valid <= 1'b0;
        end else if (o_expanding) begin
            o_round_keys[1407-128*key_round -: 128] <= generated_key;
            key_work <= generated_key;
            if (key_round == 4'd10) begin
                key_round <= 4'b0;
                o_expanding <= 1'b0;
                o_schedule_valid <= 1'b1;
            end else begin
                key_round <= key_round + 1'b1;
            end
        end
    end
endmodule
