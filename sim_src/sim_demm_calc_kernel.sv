`include "pcie_spmv_macros.vh"
module sim_demm_calc_kernel #(
    
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
        rstn <=0;
        calc_begin <= 0;
        #10
        rstn <=1;
        #10
        calc_begin <= 1;
        #10
        calc_begin <= 0;
    end
    reg calc_begin;
    axi4 #(32,64,1) axi_A();
    axi4 #(32,64,1) axi_B();
    axi4 #(32,64,1) axi_Out();
    
    
    demm_calc_kernel # (
        .ISSUE_NUM(4)
    ) demm_calc_kernel(
        .clk(clk),
        .rstn(rstn),
        .M_num(512),
        .N_num(32),
        .K_num(32),
        
        .calc_begin(calc_begin),
        .calc_end(),
        .m_axi_A(axi_A),
        .m_axi_B(axi_B),
        .m_axi_Out(axi_Out)
        
    );

    axi_blk_ram axi_blk_ram_A(
        .clk(clk),
        .rstn(rstn),
        .axi_port(axi_A)
    );
    axi_blk_ram axi_blk_ram_B(
        .clk(clk),
        .rstn(rstn),
        .axi_port(axi_B)
    );
    axi_blk_ram axi_blk_ram_Out(
        .clk(clk),
        .rstn(rstn),
        .axi_port(axi_Out)
    );


endmodule