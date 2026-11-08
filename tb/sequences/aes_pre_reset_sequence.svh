class aes_pre_reset_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_pre_reset_sequence)
    function new(string name = "aes_pre_reset_sequence"); super.new(name); endfunction
    task body();
        send(AES_KEY, 128'h000102030405060708090a0b0c0d0e0f);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
    endtask
endclass
