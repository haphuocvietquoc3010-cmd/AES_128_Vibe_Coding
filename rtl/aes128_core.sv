module aes128_core (
    input  wire         i_clk,
    input  wire         i_rst_n,
    input  wire         i_key_valid,
    output wire         o_key_ready,
    input  wire [127:0] i_key,
    input  wire         i_data_valid,
    output wire         o_data_ready,
    input  wire [127:0] i_plaintext,
    output wire         o_cipher_valid,
    input  wire         i_cipher_ready,
    output wire [127:0] o_ciphertext
);
    wire key_start;
    wire key_expanding;
    wire key_schedule_valid;
    wire engine_busy;
    wire [1407:0] round_keys;

    assign o_key_ready = !key_expanding && !engine_busy && !o_cipher_valid;
    assign key_start = i_key_valid && o_key_ready;

    aes128_key_expand u_key_expand (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_start(key_start),
        .i_key(i_key),
        .o_expanding(key_expanding),
        .o_schedule_valid(key_schedule_valid),
        .o_round_keys(round_keys)
    );

    aes128_block_engine u_block_engine (
        .i_clk(i_clk),
        .i_rst_n(i_rst_n),
        .i_schedule_valid(key_schedule_valid),
        .i_round_keys(round_keys),
        .i_key_pending(i_key_valid),
        .i_data_valid(i_data_valid),
        .o_data_ready(o_data_ready),
        .i_plaintext(i_plaintext),
        .o_busy(engine_busy),
        .o_cipher_valid(o_cipher_valid),
        .i_cipher_ready(i_cipher_ready),
        .o_ciphertext(o_ciphertext)
    );
endmodule
