class aes_env extends uvm_env;
    `uvm_component_utils(aes_env)
    aes128_agent agent;
    aes_scoreboard sb;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        agent = aes128_agent::type_id::create("agent", this);
        sb = aes_scoreboard::type_id::create("sb", this);
    endfunction
    function void connect_phase(uvm_phase phase);
        agent.in_mon.ap.connect(sb.input_imp);
        agent.out_mon.ap.connect(sb.output_imp);
    endfunction
endclass
