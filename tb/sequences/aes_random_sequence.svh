class aes_random_sequence extends aes_base_sequence;
    `uvm_object_utils(aes_random_sequence)
    rand int unsigned count;
    constraint count_c { count inside {[24:64]}; }
    function new(string name = "aes_random_sequence"); super.new(name); endfunction
    task body();
        bit [127:0] value;
        send(AES_KEY, {$urandom, $urandom, $urandom, $urandom});
        repeat (count) begin
            value = {$urandom, $urandom, $urandom, $urandom};
            send(AES_DATA, value, $urandom_range(0, 2));
        end
    endtask
endclass
