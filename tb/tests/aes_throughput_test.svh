class aes_throughput_test extends aes_base_test;
    `uvm_component_utils(aes_throughput_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        uvm_config_db#(bit)::set(this, "env.sb", "performance_mode", 1);
        super.build_phase(phase);
    endfunction
    task run_phase(uvm_phase phase);
        aes_throughput_sequence seq = aes_throughput_sequence::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agent.sqr);
        drain();
        phase.drop_objection(this);
    endtask
endclass
