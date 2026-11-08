class aes_input_coverage;
    aes_op_e sampled_op;
    int sampled_class;
    covergroup cg;
        option.per_instance = 1;
        op: coverpoint sampled_op;
        data_class: coverpoint sampled_class { bins zero = {0}; bins ones = {1}; bins other = {2}; }
        op_x_class: cross op, data_class;
    endgroup
    function new(); cg = new; endfunction
    function void sample(aes_op_e op, bit [127:0] value);
        sampled_op = op;
        sampled_class = (value == '0) ? 0 : ((value == {128{1'b1}}) ? 1 : 2);
        cg.sample();
    endfunction
endclass
class aes_output_coverage;
    int sampled_stall;
    covergroup cg;
        option.per_instance = 1;
        stall: coverpoint sampled_stall {
            bins none = {0}; bins one = {1}; bins short = {[2:5]};
            bins mid_len = {[6:15]}; bins long_len = {[16:$]};
        }
    endgroup
    function new(); cg = new; endfunction
    function void sample(int stall); sampled_stall = stall; cg.sample(); endfunction
endclass
