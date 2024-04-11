module sim_acc_top #(
    
) (
);
        reg rstn;
    reg clk =1;
    reg [31:0] clkcnt=0;
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end     
    endfunction
    always #5 clk = ~clk;
    always @(posedge clk) begin
        clkcnt<=clkcnt+1;
    end

    initial begin
        rstn<=0;
        #200
        rstn<=1;
    end
    stream #(64) fp64_stream();
    stream #(64) fp64_sum_stream();
    fixp_acc_top fixp_acc_top(
        .clk(clk),
        .rstn(rstn),
        .fp64_stream(fp64_stream),
        .fp64_sum_stream(fp64_sum_stream),
        .clr_valid(0),
        .clr_ready()
        );
endmodule