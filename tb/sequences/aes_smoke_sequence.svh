class aes_smoke_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_smoke_sequence)
    function new(string name = "aes_smoke_sequence"); super.new(name); endfunction
    task body();
        send(AES_KEY, 128'h000102030405060708090a0b0c0d0e0f);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
        send(AES_DATA, 128'h00112233445566778899aabbccddeeff);
        send(AES_KEY, 128'h2b7e151628aed2a6abf7158809cf4f3c);
        send(AES_DATA, 128'h3243f6a8885a308d313198a2e0370734);
    endtask
endclass
