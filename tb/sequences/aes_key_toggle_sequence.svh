class aes_key_toggle_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_key_toggle_sequence)

    function new(string name = "aes_key_toggle_sequence");
        super.new(name);
    endfunction

    task body();
        send(AES_KEY, 128'h00000000000000000000000000000000);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
        send(AES_KEY, 128'hffffffffffffffffffffffffffffffff);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
        send(AES_KEY, 128'h00000000000000000000000000000000);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
    endtask
endclass
