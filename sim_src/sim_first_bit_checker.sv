module sim_first_bit_checker #(
    
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
    task  checker_data_req(
        logic [192-1:0] input_data
     );
        // $display("expect %d",input_data);
        
        wait(fixp_in_stream.tready);
        fixp_in_stream.tdata <= {input_data};

        // fixp_in_stream.tvalid <= ($random % 10 <5);
        fixp_in_stream.tvalid <= 1;
    endtask 
    int s_t = 0;
    always @(posedge clk) begin
        if(~rstn)begin
            fixp_in_stream.tvalid<=0;
            fixp_in_stream.tdata<=0;
        end
        else begin
            checker_data_req(1<<s_t);
            s_t <= s_t+1;
        end
        if (s_t == 192)begin
            $finish();
        end
    end

    stream # (192) fixp_in_stream();
    stream # (192 +clogb2(192-1) +1) fixp_out_stream();
    
    assign fixp_out_stream.tready = 1;

    first_bit_checker first_bit_checker(
        .clk(clk),
        .rstn(rstn),
        .fixp_in_stream(fixp_in_stream),
        .fixp_out_stream(fixp_out_stream)
    );

    wire [clogb2(192-1)-1:0] shift_info;
    wire [192-1:0] shift_data;
    wire nzero;
    assign nzero = fixp_out_stream.tdata[0];
    assign shift_info = fixp_out_stream.tdata[1+:clogb2(192-1)];
    assign shift_data = fixp_out_stream.tdata[1+clogb2(192-1)+:192];
    
    

    
endmodule