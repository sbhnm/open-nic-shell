module acc_kern #(
    parameter DEPTH = 32,
    parameter PRE_REG_WIDTH = 128,
    parameter PRE_REG_STEP = 64
) (
    input wire clk,
    input wire rstn,
    input wire input_sign,
    stream.slave add_pkt_stream,
    
    input wire clr_valid,
    output wire clr_ready,
    output wire add_valid,
    stream.master res_pkt_stream
    

);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    
    //assign clr_ready =  (fsm_status==0)&(~(add_pkt_stream.tvalid & add_pkt_stream.tready)) & ~fifi_data_out_full;
    assign clr_ready =  (fsm_status==0) & ~fifi_data_out_full;
    wire [clogb2(DEPTH-1)-1:0] acc_reg_cs;
    wire [PRE_REG_WIDTH-1:0]    acc_data;
    
    wire [PRE_REG_WIDTH:0]    tmp_acc;
    wire [PRE_REG_WIDTH:0]    of_tmp_acc;

    
    wire [PRE_REG_WIDTH -1 : 0] adder_A;
    wire [PRE_REG_WIDTH -1 : 0] adder_B;
    wire [PRE_REG_WIDTH   : 0] adder_C;
    assign of_tmp_acc = adder_C;
    assign tmp_acc = adder_C;
    
    assign adder_A = (fsm_status==0 & ~input_sign) ? fix_acc_buf_p[acc_reg_cs] :0|
                    (fsm_status==0 & input_sign) ? fix_acc_buf_n[acc_reg_cs] :0|
                    (fsm_status==1) ? fix_acc_buf_p[of_reg_cs_p+1] :0|
                    (fsm_status==2) ? fix_acc_buf_n[of_reg_cs_n+1] :0;
    assign adder_B = (fsm_status==0) ? acc_data :(1<<PRE_REG_STEP);
    assign add_valid = add_pkt_stream.tvalid & add_pkt_stream.tready;
    fastadder#(128)fastadder1(adder_A,adder_B,adder_C);



    // fastadder#(128)fastadder1(fix_acc_buf[of_reg_cs+1],(1<<PRE_REG_STEP),of_tmp_acc);

    //assign tmp_acc = fix_acc_buf[acc_reg_cs] + acc_data;
    // fastadder#(128)fastadder2(fix_acc_buf[of_reg_cs],acc_data,tmp_acc);
    // assign tmp_acc = 1 + acc_data;

    assign acc_reg_cs = add_pkt_stream.tdata[PRE_REG_WIDTH+:clogb2(DEPTH-1)];
    assign acc_data = add_pkt_stream.tdata[PRE_REG_WIDTH-1:0];
    assign add_pkt_stream.tready = (fsm_status==0);
    
    reg [3:0] fsm_status;

    reg [clogb2(DEPTH-1)-1:0] of_reg_cs_p; // reg who overflow
    reg [clogb2(DEPTH-1)-1:0] of_reg_cs_n; // reg who overflow

    reg [PRE_REG_WIDTH-1:0] fix_acc_buf_p [DEPTH-1:0];
    reg [PRE_REG_WIDTH-1:0] fix_acc_buf_n [DEPTH-1:0];
    



    reg [clogb2(DEPTH-1)-1 :0] max_acc_cs_p;
    reg [clogb2(DEPTH-1)-1 :0] max_acc_cs_n;
    

    wire fifi_data_out_full;
    wire fifi_data_out_empty;
    wire [2*PRE_REG_WIDTH + clogb2(DEPTH-1)-1:0] fifi_data_out_dout;
    assign res_pkt_stream.tdata = fifi_data_out_dout;
    // Fifo #(
    //     .DATA_WIDTH(2*PRE_REG_WIDTH + clogb2(DEPTH-1)),
    //     .DEPTH(1)
    // )fifi_data_out(
    //     .clk(clk),
    //     .rst(~rstn),
    //     .wr_en(clr_ready & clr_valid),
    //     .data_in({fix_acc_buf[max_acc_cs],fix_acc_buf[max_acc_cs-1],max_acc_cs}), //
    //     .rd_en(res_pkt_stream.tvalid & res_pkt_stream.tready),
    //     .data_out(fifi_data_out_dout),
    //     .full(fifi_data_out_full),
    //     .empty(fifi_data_out_empty)
    // );
    reg [2*PRE_REG_WIDTH + clogb2(DEPTH-1)-1:0] buf_data;
    reg [2:0] rd_state;
    assign fifi_data_out_full = rd_state==1;
    assign fifi_data_out_empty = rd_state==0;
    assign fifi_data_out_dout = buf_data;
    always @(posedge clk) begin
        if(~rstn)begin
            rd_state<=0;
        end
        else begin
            if(rd_state == 0)begin
                if(clr_ready & clr_valid)begin
                    rd_state<=1;
                    buf_data<={fix_acc_buf_p[max_acc_cs_p],fix_acc_buf_n[max_acc_cs_n],max_acc_cs_p};
                end
            end
            else if(rd_state ==1)begin
                
                if(res_pkt_stream.tvalid & res_pkt_stream.tready)begin
                    rd_state<=0;
                end
            end
        end
        
    end
    assign res_pkt_stream.tvalid = res_pkt_stream.tready & ~fifi_data_out_empty;
    
    always @(posedge clk) begin
        if(~rstn)begin
            for(int i = 0;i<DEPTH;i++)begin
                fix_acc_buf_p[i]<=0;
                fix_acc_buf_n[i]<=0;
            end
            fsm_status<=0;
            max_acc_cs_p<=0;
            max_acc_cs_n<=0;
            

            of_reg_cs_p<=0;
            of_reg_cs_n<=0;
        end
        else begin
            if(fsm_status==0)begin
                if(add_pkt_stream.tvalid & add_pkt_stream.tready)begin
                    if(~input_sign)begin
                        fix_acc_buf_p[acc_reg_cs] <= tmp_acc;
                        max_acc_cs_p <= (max_acc_cs_p > acc_reg_cs)? max_acc_cs_p:acc_reg_cs;
                        if(tmp_acc[PRE_REG_WIDTH])begin //发生溢出
                            fsm_status <=1;
                            of_reg_cs_p <= acc_reg_cs;
                        end
                    end
                    else if(input_sign)begin
                        fix_acc_buf_n[acc_reg_cs] <= tmp_acc;
                        max_acc_cs_n <= (max_acc_cs_n > acc_reg_cs)? max_acc_cs_n:acc_reg_cs;
                        if(tmp_acc[PRE_REG_WIDTH])begin //发生溢出
                            fsm_status <=2;
                            of_reg_cs_n <= acc_reg_cs;
                        end
                    end
                    end

                end
                if(clr_ready & clr_valid)begin
                    fsm_status<=0;
                    max_acc_cs_p<=0;
                    max_acc_cs_n<=0;

                    for(int i = 0;i<DEPTH;i++)begin
                        fix_acc_buf_p[i]<=0;
                        fix_acc_buf_n[i]<=0;
                        
                    end
                    of_reg_cs_p<=0;
                    of_reg_cs_n<=0;
                    
                end
            end
            if(fsm_status == 1)begin
                if(of_tmp_acc[PRE_REG_WIDTH])begin //还溢出
                    fsm_status<=1;
                    fix_acc_buf_p[of_reg_cs_p+1] <= of_tmp_acc;
                    max_acc_cs_p <= (max_acc_cs_p > of_reg_cs_p+1)? max_acc_cs_p:of_reg_cs_p+1;
                    of_reg_cs_p<=of_reg_cs_p+1;
                end
                else begin
                    fsm_status<=0;
                    fix_acc_buf_p[of_reg_cs_p+1] <= of_tmp_acc;
                    max_acc_cs_p <= (max_acc_cs_p > of_reg_cs_p+1)? max_acc_cs_p:of_reg_cs_p+1;
                end
            end
            if(fsm_status == 2)begin
                if(of_tmp_acc[PRE_REG_WIDTH])begin //还溢出
                    fsm_status<=2;
                    fix_acc_buf_n[of_reg_cs_n+1] <= of_tmp_acc;
                    max_acc_cs_n <= (max_acc_cs_n > of_reg_cs_n+1)? max_acc_cs_n:of_reg_cs_n+1;
                    of_reg_cs_n<=of_reg_cs_n+1;
                end
                else begin
                    fsm_status<=0;
                    fix_acc_buf_n[of_reg_cs_n+1] <= of_tmp_acc;
                    max_acc_cs_n <= (max_acc_cs_n > of_reg_cs_n+1)? max_acc_cs_n:of_reg_cs_n+1;
                end
            end
        end
    // reg [DEPTH-1:0] neg_carry [31:0];
    // reg [clogb2(DEPTH-1)-1:0] max_neg_carry;
    // reg [clogb2(DEPTH-1)-1:0] max_pos_carry;
    // always @(posedge clk) begin
    //     if(~rstn)begin
    //         for(int i = 0;i<DEPTH;i++)begin
    //             neg_carry[i]<=0;
    //         end
    //         max_neg_carry <=0;
    //         max_pos_carry<=0;
    //     end
    //     if(add_pkt_stream.tvalid & add_pkt_stream.tready) begin
    //         if(input_sign)begin
    //             neg_carry[acc_reg_cs] <= neg_carry[acc_reg_cs]+1;
    //             max_neg_carry <= max_neg_carry > acc_reg_cs ? max_neg_carry : acc_reg_cs;
    //         end
    //         else begin
    //             max_pos_carry <= max_pos_carry > acc_reg_cs ? max_pos_carry : acc_reg_cs;
    //         end
    //     end
    // end

endmodule