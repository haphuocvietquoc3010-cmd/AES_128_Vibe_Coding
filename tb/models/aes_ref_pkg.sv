package aes_ref_pkg;
  // Independent black-box oracle: no RTL package or DUT internal dependency.
  function automatic [7:0] gf_mul(input [7:0] a, input [7:0] b);
    reg [7:0] x, y, p;
    integer i;
    begin
      x=a; y=b; p=0;
      for (i=0;i<8;i=i+1) begin
        if (y[0]) p = p ^ x;
        x = x[7] ? ((x << 1) ^ 8'h1b) : (x << 1);
        y = y >> 1;
      end
      gf_mul=p;
    end
  endfunction

  function automatic [7:0] gf_pow254(input [7:0] a);
    reg [7:0] result, base;
    integer e;
    begin
      result=8'h01; base=a; e=254;
      while (e != 0) begin
        if (e & 1) result=gf_mul(result,base);
        base=gf_mul(base,base); e=e>>1;
      end
      gf_pow254=result;
    end
  endfunction

  function automatic [7:0] rotl8(input [7:0] x, input integer n);
    rotl8 = (x << n) | (x >> (8-n));
  endfunction

  function automatic [7:0] sbox(input [7:0] x);
    reg [7:0] y;
    begin
      y = (x==0) ? 0 : gf_pow254(x);
      sbox = y ^ rotl8(y,1) ^ rotl8(y,2) ^ rotl8(y,3) ^ rotl8(y,4) ^ 8'h63;
    end
  endfunction

  function automatic [7:0] rcon(input integer round);
    reg [7:0] v;
    integer i;
    begin
      v=8'h01;
      for (i=1;i<round;i=i+1) v=gf_mul(v,8'h02);
      rcon=v;
    end
  endfunction

  function automatic [127:0] next_round_key(input [127:0] key, input integer round);
    reg [31:0] w0,w1,w2,w3,t,n0,n1,n2,n3;
    begin
      w0=key[127:96]; w1=key[95:64]; w2=key[63:32]; w3=key[31:0];
      t={sbox(w3[23:16]),sbox(w3[15:8]),sbox(w3[7:0]),sbox(w3[31:24])};
      t[31:24]=t[31:24]^rcon(round);
      n0=w0^t; n1=w1^n0; n2=w2^n1; n3=w3^n2;
      next_round_key={n0,n1,n2,n3};
    end
  endfunction

  function automatic [127:0] aes128_encrypt(input [127:0] plaintext, input [127:0] key);
    reg [7:0] st[0:15];
    reg [7:0] sb[0:15];
    reg [7:0] sh[0:15];
    reg [7:0] mx[0:15];
    reg [127:0] rk;
    reg [127:0] result;
    integer i,r,c,row,src;
    begin
      rk=key;
      for(i=0;i<16;i=i+1) st[i]=plaintext[127-8*i -: 8]^rk[127-8*i -: 8];
      for(r=1;r<=10;r=r+1) begin
        rk=next_round_key(rk,r);
        for(i=0;i<16;i=i+1) sb[i]=sbox(st[i]);
        for(c=0;c<4;c=c+1)
          for(row=0;row<4;row=row+1) begin
            src=4*((c+row)%4)+row;
            sh[4*c+row]=sb[src];
          end
        if(r<10) begin
          for(c=0;c<4;c=c+1) begin
            mx[4*c+0]=gf_mul(sh[4*c+0],2)^gf_mul(sh[4*c+1],3)^sh[4*c+2]^sh[4*c+3];
            mx[4*c+1]=sh[4*c+0]^gf_mul(sh[4*c+1],2)^gf_mul(sh[4*c+2],3)^sh[4*c+3];
            mx[4*c+2]=sh[4*c+0]^sh[4*c+1]^gf_mul(sh[4*c+2],2)^gf_mul(sh[4*c+3],3);
            mx[4*c+3]=gf_mul(sh[4*c+0],3)^sh[4*c+1]^sh[4*c+2]^gf_mul(sh[4*c+3],2);
          end
          for(i=0;i<16;i=i+1) st[i]=mx[i]^rk[127-8*i -: 8];
        end else begin
          for(i=0;i<16;i=i+1) st[i]=sh[i]^rk[127-8*i -: 8];
        end
      end
      result='0;
      for(i=0;i<16;i=i+1) result[127-8*i -: 8]=st[i];
      aes128_encrypt=result;
    end
  endfunction
endpackage
