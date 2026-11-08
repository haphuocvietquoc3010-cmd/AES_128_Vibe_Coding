class aes_output_monitor extends uvm_component;
    `uvm_component_utils(aes_output_monitor)
    virtual aes_if vif;
    uvm_analysis_port #(aes_observation) ap;
    aes_output_coverage coverage;
    longint unsigned cycle;
    int stall_length;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual aes_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "output monitor vif")
        coverage = new;
    endfunction
    task run_phase(uvm_phase phase);
        aes_observation item;
        forever begin
            @(vif.mon_cb);
            cycle++;
            if (!vif.mon_cb.i_rst_n) stall_length = 0;
            else if (vif.mon_cb.o_cipher_valid && !vif.mon_cb.i_cipher_ready) stall_length++;
            else if (vif.mon_cb.o_cipher_valid && vif.mon_cb.i_cipher_ready) begin
                item = aes_observation::type_id::create("item");
                item.payload = vif.mon_cb.o_ciphertext;
                item.cycle = cycle;
                ap.write(item);
                coverage.sample(stall_length);
                stall_length = 0;
            end else stall_length = 0;
        end
    endtask
endclass
