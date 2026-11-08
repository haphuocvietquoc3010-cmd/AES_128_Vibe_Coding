`timescale 1ns/1ps
module tb_top;
  import uvm_pkg::*;
  import aes_ref_pkg::*;
  import aes_uvm_pkg::*;

  logic i_clk=0;
  always #2.5 i_clk=~i_clk;
  aes_if vif(i_clk);

  aes128_core dut(
    .i_clk(i_clk), .i_rst_n(vif.i_rst_n),
    .i_key_valid(vif.i_key_valid), .o_key_ready(vif.o_key_ready), .i_key(vif.i_key),
    .i_data_valid(vif.i_data_valid), .o_data_ready(vif.o_data_ready), .i_plaintext(vif.i_plaintext),
    .o_cipher_valid(vif.o_cipher_valid), .i_cipher_ready(vif.i_cipher_ready), .o_ciphertext(vif.o_ciphertext)
  );

  aes_assertions assertions(
    .i_clk(i_clk), .i_rst_n(vif.i_rst_n),
    .i_key_valid(vif.i_key_valid), .o_key_ready(vif.o_key_ready),
    .i_data_valid(vif.i_data_valid), .o_data_ready(vif.o_data_ready),
    .o_cipher_valid(vif.o_cipher_valid), .i_cipher_ready(vif.i_cipher_ready), .o_ciphertext(vif.o_ciphertext)
  );

  initial begin
    vif.i_rst_n=0; vif.i_key_valid=0; vif.i_key='0; vif.i_data_valid=0; vif.i_plaintext='0; vif.i_cipher_ready=0;
    if(aes128_encrypt(128'h00112233445566778899aabbccddeeff,
                      128'h000102030405060708090a0b0c0d0e0f)
       !==128'h69c4e0d86a7b0430d8cdb78070b4c55a)
      $fatal(1,"Independent AES reference model failed NIST/FIPS-197 KAT");
    #12; vif.i_rst_n=1;
  end

  initial begin
    uvm_config_db#(virtual aes_if)::set(null,"*","vif",vif);
    // UVM 1.1d interprets this argument in simulator precision units (1 ps here).
    uvm_top.set_timeout(100_000_000,1);
    run_test();
  end

  initial begin
    #120us;
    $fatal(1,"TB watchdog expired at 120 us");
  end
endmodule
