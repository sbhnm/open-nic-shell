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
        fixp64_stream.tdata<=0;

        rstn<=0;
        #200
        rstn<=1;
    end

    stream #(64) fixp64_stream();

    task  fix_data_req(
        logic [31:0] int_data,
        logic [31:0] tail_data
     );
        
        wait(fixp64_stream.tready);
        fixp64_stream.tdata <= {int_data,tail_data};

        fixp64_stream.tvalid <= ($random % 10 <5);

        // @(posedge clk);
        // shift_data_stream.tvalid<=0;
    endtask 


    
    always @(posedge clk) begin
        if(~rstn)begin
            fixp64_stream.tvalid <=0;

        end
        else begin
            fix_data_req($random % 5000000,$random % 500 + 500);
        end
    end
    
    Fix2Double Fix2Double (
    .aclk(clk),  
    .aresetn(rstn),                                 // input wire aclk
    .s_axis_a_tvalid(fixp64_stream.tvalid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(fixp64_stream.tready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(fixp64_stream.tdata),              // input wire [63 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(fp64_stream.tvalid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(fp64_stream.tready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(fp64_stream.tdata)    // output wire [63 : 0] m_axis_result_tdata
    );

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