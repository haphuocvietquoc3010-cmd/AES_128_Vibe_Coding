class aes_base_test extends uvm_test;
    `uvm_component_utils(aes_base_test)

    aes_env env;
    virtual aes_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual aes_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "test vif")
        end
        env = aes_env::type_id::create("env", this);
    endfunction

    task drain();
        repeat (300) @(posedge vif.i_clk);
    endtask
endclass
