class aes_random_test extends aes_base_test;
    `uvm_component_utils(aes_random_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        uvm_config_db#(int unsigned)::set(this, "env.agent.drv", "output_stall_pct", 35);
        super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
        aes_random_sequence seq = aes_random_sequence::type_id::create("seq");
        phase.raise_objection(this);
        void'(seq.randomize());
        seq.start(env.agent.sqr);
        drain();
        phase.drop_objection(this);
    endtask
endclass
