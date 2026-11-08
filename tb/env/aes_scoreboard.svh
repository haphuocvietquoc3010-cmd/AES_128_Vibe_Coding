`uvm_analysis_imp_decl(_input)
`uvm_analysis_imp_decl(_output)

class aes_scoreboard extends uvm_component;
    `uvm_component_utils(aes_scoreboard)
    uvm_analysis_imp_input #(aes_observation, aes_scoreboard) input_imp;
    uvm_analysis_imp_output #(aes_observation, aes_scoreboard) output_imp;
    aes_expected pending[$];
    bit [127:0] active_key;
    bit have_key;
    bit performance_mode;
    int unsigned epoch;
    int unsigned next_id;
    int unsigned accepted;
    int unsigned transferred;
    int unsigned max_ii;
    longint unsigned last_accept;
    function new(string name, uvm_component parent);
        super.new(name, parent);
        input_imp = new("input_imp", this);
        output_imp = new("output_imp", this);
    endfunction
    function void build_phase(uvm_phase phase);
        void'(uvm_config_db#(bit)::get(this, "", "performance_mode", performance_mode));
    endfunction
    function void write_input(aes_observation item);
        aes_expected expected;
        int unsigned delta;
        if (item.reset_event) begin
            pending.delete();
            have_key = 0;
            last_accept = 0;
            return;
        end
        if (item.op == AES_KEY) begin
            active_key = item.payload;
            have_key = 1;
            epoch++;
            last_accept = 0;
            return;
        end
        if (!have_key) begin
            `uvm_error("DATA_NO_KEY", "plaintext accepted before key")
            return;
        end
        expected = aes_expected::type_id::create("expected");
        expected.plaintext = item.payload;
        expected.key = active_key;
        expected.epoch = epoch;
        expected.sequence_id = next_id++;
        expected.accept_cycle = item.cycle;
        expected.ciphertext = aes128_encrypt(expected.plaintext, expected.key);
        pending.push_back(expected);
        accepted++;
        if (last_accept != 0) begin
            delta = item.cycle - last_accept;
            if (delta > max_ii) max_ii = delta;
            if (performance_mode && (delta > 6)) `uvm_error("II", $sformatf("II %0d exceeds 6", delta))
        end
        last_accept = item.cycle;
    endfunction
    function void write_output(aes_observation item);
        aes_expected expected;
        if (pending.size() == 0) begin
            `uvm_error("UNEXPECTED_OUTPUT", "output with empty queue")
            return;
        end
        expected = pending.pop_front();
        transferred++;
        if (item.payload !== expected.ciphertext) begin
            `uvm_error("MISMATCH", $sformatf("id=%0d expected=%032h actual=%032h",
                expected.sequence_id, expected.ciphertext, item.payload))
        end
    endfunction
    function void report_phase(uvm_phase phase);
        if (pending.size() != 0) `uvm_error("MISSING_OUTPUT", $sformatf("%0d remain", pending.size()))
        `uvm_info("AES_SUMMARY", $sformatf("accepted=%0d transferred=%0d max_II=%0d",
            accepted, transferred, max_ii), UVM_NONE)
    endfunction
endclass
