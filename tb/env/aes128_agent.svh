class aes128_agent extends uvm_agent;
    `uvm_component_utils(aes128_agent)
    aes_sequencer sqr;
    aes_driver drv;
    aes_input_monitor in_mon;
    aes_output_monitor out_mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        sqr = aes_sequencer::type_id::create("sqr", this);
        drv = aes_driver::type_id::create("drv", this);
        in_mon = aes_input_monitor::type_id::create("in_mon", this);
        out_mon = aes_output_monitor::type_id::create("out_mon", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
endclass
