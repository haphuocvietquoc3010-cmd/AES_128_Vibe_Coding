class aes_pattern_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_pattern_sequence)
    function new(string name = "aes_pattern_sequence"); super.new(name); endfunction
    task body();
        int index;
        send(AES_KEY, '0);
        send(AES_DATA, '0);
        send(AES_DATA, {128{1'b1}});
        for (index = 0; index < 128; index++) begin
            send(AES_DATA, (128'b1 << index));
        end
    endtask
endclass
