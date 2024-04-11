
    module get_chk_first_bit #(
        parameter  CHECK_WIDTH= 16
    ) (
        input logic [CHECK_WIDTH-1:0] chk_bits,
        output logic [clogb2(CHECK_WIDTH-1)-1:0] bits_pos,
        output logic bits_pos_find
    );
        wire [CHECK_WIDTH-1:0] chk_bits_re;
        wire [CHECK_WIDTH-1:0] chk_bits_re_n;
        logic [CHECK_WIDTH-1:0] chk_bits_re_one_hot;
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end     
    endfunction
        always @(*) begin
            bits_pos_find = (|chk_bits);
        end

        generate
            for (genvar i = 0; i < CHECK_WIDTH; i++) begin
                assign chk_bits_re[CHECK_WIDTH-1-i] =  chk_bits[i];
            end
        endgenerate
        assign chk_bits_re_n = bits_pos_find?((~chk_bits_re)+ 1):(~chk_bits_re);
        assign chk_bits_re_one_hot = (chk_bits_re_n & chk_bits_re) -1;
        
        always @(*) begin
                bits_pos = 0;
                for (int i = 0; i < CHECK_WIDTH; i++) begin
                    bits_pos =  bits_pos + chk_bits_re_one_hot[i];
                end
        
        end

    endmodule