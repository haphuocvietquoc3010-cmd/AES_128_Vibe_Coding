class aes_base_sequence extends uvm_sequence #(aes_item);
    `uvm_object_utils(aes_base_sequence)
    function new(string name = "aes_base_sequence"); super.new(name); endfunction
    task send(aes_op_e op, bit [127:0] payload, int unsigned gap = 0);
        aes_item req = aes_item::type_id::create("req");
        start_item(req);
        req.op = op;
        req.payload = payload;
        req.gap = gap;
        finish_item(req);
    endtask
endclass
