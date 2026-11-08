class aes_driver extends uvm_driver #(aes_item);
    `uvm_component_utils(aes_driver)
    virtual aes_if vif;
    int unsigned output_stall_pct;
    bit directed_stalls;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual aes_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "driver vif")
        end
        void'(uvm_config_db#(int unsigned)::get(this, "", "output_stall_pct", output_stall_pct));
        void'(uvm_config_db#(bit)::get(this, "", "directed_stalls", directed_stalls));
    endfunction
    task drive_ready();
        int cycle;
        forever begin
            @(vif.drv_cb);
            if (!vif.i_rst_n) begin
                cycle = 0;
                vif.drv_cb.i_cipher_ready <= 0;
            end else if (directed_stalls) begin
                cycle++;
                vif.drv_cb.i_cipher_ready <= !((cycle <= 40) || ((cycle >= 43) && (cycle <= 52)));
            end else begin
                vif.drv_cb.i_cipher_ready <= ($urandom_range(99) >= output_stall_pct);
            end
        end
    endtask
    task drive_requests();
        aes_item req;
        bit accepted;
        vif.i_key_valid = 0;
        vif.i_data_valid = 0;
        vif.i_key = '0;
        vif.i_plaintext = '0;
        forever begin
            seq_item_port.get_next_item(req);
            repeat (req.gap) @(vif.drv_cb);
            accepted = 0;
            while (!accepted) begin
                while (!vif.i_rst_n) @(negedge vif.i_clk);
                @(negedge vif.i_clk);
                if (req.op == AES_KEY) begin
                    vif.i_key = req.payload;
                    vif.i_key_valid = 1;
                end else begin
                    vif.i_plaintext = req.payload;
                    vif.i_data_valid = 1;
                end
                do begin
                    @(posedge vif.i_clk);
                    if (!vif.i_rst_n) begin
                        @(negedge vif.i_clk);
                        vif.i_key_valid = 0;
                        vif.i_data_valid = 0;
                    end else begin
                        accepted = (req.op == AES_KEY) ? vif.o_key_ready : vif.o_data_ready;
                    end
                end while (!accepted && vif.i_rst_n);
            end
            @(negedge vif.i_clk);
            if (req.op == AES_KEY) vif.i_key_valid = 0;
            else vif.i_data_valid = 0;
            seq_item_port.item_done();
        end
    endtask
    task run_phase(uvm_phase phase);
        fork
            drive_ready();
            drive_requests();
        join
    endtask
endclass
