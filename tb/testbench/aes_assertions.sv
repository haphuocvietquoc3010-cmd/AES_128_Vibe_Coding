module aes_assertions(
  input logic i_clk, i_rst_n,
  input logic i_key_valid, o_key_ready,
  input logic i_data_valid, o_data_ready,
  input logic o_cipher_valid, i_cipher_ready,
  input logic [127:0] o_ciphertext
);
  property p_output_stable_when_stalled;
    @(posedge i_clk) disable iff(!i_rst_n)
      o_cipher_valid && !i_cipher_ready |=> o_cipher_valid && $stable(o_ciphertext);
  endproperty
  a_output_stable_when_stalled: assert property(p_output_stable_when_stalled);

  property p_key_excludes_input;
    @(posedge i_clk) disable iff(!i_rst_n) i_key_valid && o_key_ready |-> !o_data_ready;
  endproperty
  a_key_excludes_input: assert property(p_key_excludes_input);

  property p_no_input_during_key_accept;
    @(posedge i_clk) disable iff(!i_rst_n) i_key_valid && o_key_ready |-> !(i_data_valid && o_data_ready);
  endproperty
  a_no_input_during_key_accept: assert property(p_no_input_during_key_accept);

  property p_reset_clears_output;
    @(posedge i_clk) !i_rst_n |-> !o_cipher_valid;
  endproperty
  a_reset_clears_output: assert property(p_reset_clears_output);
endmodule
