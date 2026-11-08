class aes_throughput_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_throughput_sequence)
    function new(string name = "aes_throughput_sequence"); super.new(name); endfunction
    task body();
        int index;
        send(AES_KEY, 128'h000102030405060708090a0b0c0d0e0f);
        for (index = 0; index < 40; index++) begin
            send(AES_DATA, index);
        end
    endtask
endclass
