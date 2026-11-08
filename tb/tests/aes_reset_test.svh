class aes_reset_test extends aes_base_test;
    `uvm_component_utils(aes_reset_test)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    task run_phase(uvm_phase phase);
        aes_pre_reset_sequence pre = aes_pre_reset_sequence::type_id::create("pre");
        aes_smoke_sequence post = aes_smoke_sequence::type_id::create("post");
        phase.raise_objection(this);
        pre.start(env.agent.sqr);
        repeat (2) @(negedge vif.i_clk);
        vif.i_rst_n = 0;
        repeat (2) @(negedge vif.i_clk);
        vif.i_rst_n = 1;
        repeat (2) @(posedge vif.i_clk);
        post.start(env.agent.sqr);
        drain();
        phase.drop_objection(this);
    endtask
endclass
