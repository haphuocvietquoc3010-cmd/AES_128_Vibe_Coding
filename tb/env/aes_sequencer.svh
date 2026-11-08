class aes_sequencer extends uvm_sequencer #(aes_item);
    `uvm_component_utils(aes_sequencer)
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
endclass
