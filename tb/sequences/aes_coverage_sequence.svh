class aes_coverage_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_coverage_sequence)
    function new(string name = "aes_coverage_sequence"); super.new(name); endfunction
    task body();
        send(AES_KEY, {128{1'b1}});
        send(AES_DATA, {128{1'b1}});
        send(AES_DATA, 128'h0123456789abcdef0011223344556677);
        send(AES_DATA, 128'hffeeddccbbaa99887766554433221100);
    endtask
endclass
