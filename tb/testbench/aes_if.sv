interface aes_if(input logic i_clk);
  logic         i_rst_n;
  logic         i_key_valid;
  logic         o_key_ready;
  logic [127:0] i_key;
  logic         i_data_valid;
  logic         o_data_ready;
  logic [127:0] i_plaintext;
  logic         o_cipher_valid;
  logic         i_cipher_ready;
  logic [127:0] o_ciphertext;

  clocking drv_cb @(posedge i_clk);
    default input #1step output #1step;
    input o_key_ready, o_data_ready, o_cipher_valid, o_ciphertext;
    output i_key_valid, i_key, i_data_valid, i_plaintext, i_cipher_ready;
  endclocking

  clocking mon_cb @(posedge i_clk);
    default input #1step;
    input i_rst_n, i_key_valid, o_key_ready, i_key;
    input i_data_valid, o_data_ready, i_plaintext;
    input o_cipher_valid, i_cipher_ready, o_ciphertext;
  endclocking
endinterface
