module sim_shift #(
    parameter SHIHT_WIDTH = 128
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
    stream #(clogb2(SHIHT_WIDTH-1) + SHIHT_WIDTH)  shift_data_stream();
    stream #(SHIHT_WIDTH)  data_out();
    assign data_out.tready =1;

    always #5 clk = ~clk;
    always @(posedge clk) begin
        clkcnt<=clkcnt+1;
    end

    initial begin
        rstn<=0;
        #200
        rstn<=1;
    end

    task  shift_data_req(
        logic [clogb2(SHIHT_WIDTH-1)-1:0] input_shift_len,
        logic [SHIHT_WIDTH-1:0] input_shift_data
     );
        // @(posedge clk);
        // $display("req %d",input_shift_len);
        $display("expect %d",input_shift_data << input_shift_len);
        
        wait(shift_data_stream.tready);
        shift_data_stream.tdata <= {input_shift_data,input_shift_len};

        shift_data_stream.tvalid <= ($random % 10 <5);
        // @(posedge clk);
        // shift_data_stream.tvalid<=0;
    endtask 

    int s_t = 0;
    always @(posedge clk) begin
        if(~rstn)begin
            shift_data_stream.tvalid<=0;
            shift_data_stream.tdata<=0;
        end
        else begin
            if(s_t<64)begin
                shift_data_req($random%63 + 64 ,$random);
                
                s_t<=s_t+1;
            end
            else begin
                $finish();
            end
            
        end
    end
    always @(posedge clk) begin
        if(data_out.tvalid)begin
            $display("--------------------out %d",data_out.tdata);
        end
    end

    left_shifter #(
        .SHIHT_WIDTH(SHIHT_WIDTH)
    )
    left_shifter(
        .clk(clk),
        .rstn(rstn),
        .data_shift_stream(shift_data_stream),
        .data_out(data_out)
    );

endmodule