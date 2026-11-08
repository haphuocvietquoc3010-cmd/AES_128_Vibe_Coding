typedef enum {AES_KEY, AES_DATA} aes_op_e;
class aes_item extends uvm_sequence_item;
    rand aes_op_e op;
    rand bit [127:0] payload;
    rand int unsigned gap;
    constraint gap_c { gap inside {[0:3]}; }
    `uvm_object_utils_begin(aes_item)
        `uvm_field_enum(aes_op_e, op, UVM_ALL_ON)
        `uvm_field_int(payload, UVM_HEX)
        `uvm_field_int(gap, UVM_DEC)
    `uvm_object_utils_end
    function new(string name = "aes_item"); super.new(name); endfunction
endclass
class aes_observation extends uvm_object;
    aes_op_e op;
    bit reset_event;
    bit [127:0] payload;
    longint unsigned cycle;
    `uvm_object_utils(aes_observation)
    function new(string name = "aes_observation"); super.new(name); endfunction
endclass
class aes_expected extends uvm_object;
    bit [127:0] plaintext;
    bit [127:0] key;
    bit [127:0] ciphertext;
    int unsigned epoch;
    int unsigned sequence_id;
    longint unsigned accept_cycle;
    `uvm_object_utils(aes_expected)
    function new(string name = "aes_expected"); super.new(name); endfunction
endclass
