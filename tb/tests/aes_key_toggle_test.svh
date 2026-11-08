class aes_key_toggle_test extends aes_base_test;
    `uvm_component_utils(aes_key_toggle_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        aes_key_toggle_sequence seq;
        seq = aes_key_toggle_sequence::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sqr);
        drain();
        phase.drop_objection(this);
    endtask
endclass
