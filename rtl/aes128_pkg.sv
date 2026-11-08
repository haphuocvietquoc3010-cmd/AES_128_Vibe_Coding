package aes128_pkg;
    localparam [2047:0] AES_SBOX = {
        128'h637c777bf26b6fc53001672bfed7ab76,
        128'hca82c97dfa5947f0add4a2af9ca472c0,
        128'hb7fd9326363ff7cc34a5e5f171d83115,
        128'h04c723c31896059a071280e2eb27b275,
        128'h09832c1a1b6e5aa0523bd6b329e32f84,
        128'h53d100ed20fcb15b6acbbe394a4c58cf,
        128'hd0efaafb434d338545f9027f503c9fa8,
        128'h51a3408f929d38f5bcb6da2110fff3d2,
        128'hcd0c13ec5f974417c4a77e3d645d1973,
        128'h60814fdc222a908846eeb814de5e0bdb,
        128'he0323a0a4906245cc2d3ac629195e479,
        128'he7c8376d8dd54ea96c56f4ea657aae08,
        128'hba78252e1ca6b4c6e8dd741f4bbd8b8a,
        128'h703eb5664803f60e613557b986c11d9e,
        128'he1f8981169d98e949b1e87e9ce5528df,
        128'h8ca1890dbfe6426841992d0fb054bb16
    };

    function automatic [7:0] aes_sbox(input [7:0] a);
        aes_sbox = AES_SBOX[(255-a)*8 +: 8];
    endfunction

    function automatic [7:0] xtime(input [7:0] a);
        xtime = {a[6:0], 1'b0} ^ (8'h1b & {8{a[7]}});
    endfunction

    function automatic [127:0] sub_bytes(input [127:0] s);
        integer n;
        begin
            for (n = 0; n < 16; n = n + 1) begin
                sub_bytes[127-8*n -: 8] = aes_sbox(s[127-8*n -: 8]);
            end
        end
    endfunction

    function automatic [127:0] shift_rows(input [127:0] s);
        integer r;
        integer c;
        integer src_c;
        begin
            for (r = 0; r < 4; r = r + 1) begin
                for (c = 0; c < 4; c = c + 1) begin
                    src_c = (c + r) % 4;
                    shift_rows[127-8*(4*c+r) -: 8] = s[127-8*(4*src_c+r) -: 8];
                end
            end
        end
    endfunction

    function automatic [127:0] mix_columns(input [127:0] s);
        reg [7:0] a0;
        reg [7:0] a1;
        reg [7:0] a2;
        reg [7:0] a3;
        integer c;
        begin
            for (c = 0; c < 4; c = c + 1) begin
                a0 = s[127-8*(4*c+0) -: 8];
                a1 = s[127-8*(4*c+1) -: 8];
                a2 = s[127-8*(4*c+2) -: 8];
                a3 = s[127-8*(4*c+3) -: 8];
                mix_columns[127-8*(4*c+0) -: 8] = xtime(a0) ^ (xtime(a1) ^ a1) ^ a2 ^ a3;
                mix_columns[127-8*(4*c+1) -: 8] = a0 ^ xtime(a1) ^ (xtime(a2) ^ a2) ^ a3;
                mix_columns[127-8*(4*c+2) -: 8] = a0 ^ a1 ^ xtime(a2) ^ (xtime(a3) ^ a3);
                mix_columns[127-8*(4*c+3) -: 8] = (xtime(a0) ^ a0) ^ a1 ^ a2 ^ xtime(a3);
            end
        end
    endfunction

    function automatic [127:0] aes_round(
        input [127:0] s,
        input [127:0] rk,
        input final_round
    );
        reg [127:0] transformed;
        begin
            transformed = shift_rows(sub_bytes(s));
            if (!final_round) begin
                transformed = mix_columns(transformed);
            end
            aes_round = transformed ^ rk;
        end
    endfunction

    function automatic [7:0] round_constant(input [3:0] n);
        begin
            case (n)
                4'd1: round_constant = 8'h01;
                4'd2: round_constant = 8'h02;
                4'd3: round_constant = 8'h04;
                4'd4: round_constant = 8'h08;
                4'd5: round_constant = 8'h10;
                4'd6: round_constant = 8'h20;
                4'd7: round_constant = 8'h40;
                4'd8: round_constant = 8'h80;
                4'd9: round_constant = 8'h1b;
                4'd10: round_constant = 8'h36;
                default: round_constant = 8'h00;
            endcase
        end
    endfunction

    function automatic [127:0] next_round_key(
        input [127:0] old_key,
        input [3:0] n
    );
        reg [31:0] w0;
        reg [31:0] w1;
        reg [31:0] w2;
        reg [31:0] w3;
        reg [31:0] temp;
        reg [31:0] nw0;
        reg [31:0] nw1;
        reg [31:0] nw2;
        reg [31:0] nw3;
        begin
            w0 = old_key[127:96];
            w1 = old_key[95:64];
            w2 = old_key[63:32];
            w3 = old_key[31:0];
            temp = {
                aes_sbox(w3[23:16]) ^ round_constant(n),
                aes_sbox(w3[15:8]),
                aes_sbox(w3[7:0]),
                aes_sbox(w3[31:24])
            };
            nw0 = w0 ^ temp;
            nw1 = w1 ^ nw0;
            nw2 = w2 ^ nw1;
            nw3 = w3 ^ nw2;
            next_round_key = {nw0, nw1, nw2, nw3};
        end
    endfunction
endpackage
