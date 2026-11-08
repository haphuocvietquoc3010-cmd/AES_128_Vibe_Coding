class aes_input_monitor extends uvm_component;
    `uvm_component_utils(aes_input_monitor)
    virtual aes_if vif;
    uvm_analysis_port #(aes_observation) ap;
    aes_input_coverage coverage;
    longint unsigned cycle;
    bit reset_seen;
    function new(string name, uvm_component parent); super.new(name, parent); ap = new("ap", this); endfunction
    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual aes_if)::get(this, "", "vif", vif)) `uvm_fatal("NOVIF", "input monitor vif")
        coverage = new;
    endfunction
    function void publish(aes_op_e op, bit [127:0] value);
        aes_observation item = aes_observation::type_id::create("item");
        item.op = op;
        item.payload = value;
        item.cycle = cycle;
        ap.write(item);
        coverage.sample(op, value);
    endfunction
    task run_phase(uvm_phase phase);
        aes_observation item;
        forever begin
            @(vif.mon_cb);
            cycle++;
            if (!vif.mon_cb.i_rst_n) begin
                if (!reset_seen) begin
                    item = aes_observation::type_id::create("reset_item");
                    item.reset_event = 1;
                    item.cycle = cycle;
                    ap.write(item);
                end
                reset_seen = 1;
            end else begin
                reset_seen = 0;
                if (vif.mon_cb.i_key_valid && vif.mon_cb.o_key_ready) publish(AES_KEY, vif.mon_cb.i_key);
                if (vif.mon_cb.i_data_valid && vif.mon_cb.o_data_ready) publish(AES_DATA, vif.mon_cb.i_plaintext);
            end
        end
    endtask
endclass
