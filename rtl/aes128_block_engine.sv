module aes128_block_engine (
    input  wire          i_clk,
    input  wire          i_rst_n,
    input  wire          i_schedule_valid,
    input  wire [1407:0] i_round_keys,
    input  wire          i_key_pending,
    input  wire          i_data_valid,
    output wire          o_data_ready,
    input  wire [127:0]  i_plaintext,
    output wire          o_busy,
    output reg           o_cipher_valid,
    input  wire          i_cipher_ready,
    output reg  [127:0]  o_ciphertext
);
    import aes128_pkg::*;

    reg [127:0] state_reg;
    reg [2:0] pass_count;
    reg busy;
    wire output_capacity;
    wire data_fire;
    wire [3:0] round_num;
    wire [127:0] rk1;
    wire [127:0] rk2;
    wire [127:0] r1;
    wire [127:0] r2;

    assign output_capacity = !o_cipher_valid || i_cipher_ready;
    assign data_fire = i_data_valid && o_data_ready;
    assign round_num = {pass_count, 1'b0} + 4'd1;
    assign rk1 = i_round_keys[1407-128*round_num -: 128];
    assign rk2 = i_round_keys[1407-128*(round_num+1'b1) -: 128];
    assign r1 = aes_round(state_reg, rk1, 1'b0);
    assign r2 = aes_round(r1, rk2, pass_count == 3'd4);
    assign o_busy = busy;
    assign o_data_ready = i_schedule_valid && !i_key_pending && output_capacity &&
                          (!busy || (pass_count == 3'd4));

    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
            state_reg <= 128'b0;
            pass_count <= 3'b0;
            busy <= 1'b0;
            o_cipher_valid <= 1'b0;
            o_ciphertext <= 128'b0;
        end else begin
            if (o_cipher_valid && i_cipher_ready) begin
                o_cipher_valid <= 1'b0;
            end

            if (busy) begin
                if (pass_count == 3'd4) begin
                    // Hold the final pass while an older output is stalled.
                    if (output_capacity) begin
                        o_ciphertext <= r2;
                        o_cipher_valid <= 1'b1;
                        if (data_fire) begin
                            state_reg <= i_plaintext ^ i_round_keys[1407 -: 128];
                            pass_count <= 3'b0;
                            busy <= 1'b1;
                        end else begin
                            busy <= 1'b0;
                            pass_count <= 3'b0;
                        end
                    end
                end else begin
                    state_reg <= r2;
                    pass_count <= pass_count + 1'b1;
                end
            end else if (data_fire) begin
                state_reg <= i_plaintext ^ i_round_keys[1407 -: 128];
                pass_count <= 3'b0;
                busy <= 1'b1;
            end
        end
    end
endmodule
