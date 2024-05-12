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
    wire [PRE_REG_WIDTH:0] adder_out;
    wire [PRE_REG_WIDTH-1:0] adder_in1;
    wire [PRE_REG_WIDTH-1:0] adder_in2;

    fastadder#(128)fastadder1(adder_in1,adder_in2,adder_out);


    assign adder_in1 =  ((fsm_status == 0) ? fix_acc_buf[acc_reg_cs] :0 )|
                        ((fsm_status == 3) ? fix_acc_buf[of_reg_cs] :0 );
    assign adder_in2 = ((fsm_status == 0) ? acc_data :0 )|
                        ((fsm_status == 3) ? (buf_input_sign ? ({((128'h0) -1) & 64'h0 }) :(1<<PRE_REG_STEP)) :0 );
        
    wire [clogb2(DEPTH-1)-1:0] acc_reg_cs;
    wire [PRE_REG_WIDTH-1:0]    acc_data;
    reg [2*PRE_REG_WIDTH + clogb2(DEPTH-1)-1:0] fifi_data_out;

    assign clr_ready =  ((fsm_status==0)|(fsm_status==1));
    
    assign add_valid = add_pkt_stream.tvalid & add_pkt_stream.tready;

    assign acc_reg_cs = add_pkt_stream.tdata[PRE_REG_WIDTH+:clogb2(DEPTH-1)];
    assign acc_data = add_pkt_stream.tdata[PRE_REG_WIDTH-1:0];
    assign add_pkt_stream.tready = (fsm_status==0) | (fsm_status==1) ;
    assign res_pkt_stream.tvalid = fsm_status == 2;
    assign res_pkt_stream.tdata = {fix_acc_buf[max_acc_cs_predict],fix_acc_buf[max_acc_cs_predict-1],max_acc_cs_predict};
    
    reg [3:0] fsm_status;

    reg [clogb2(DEPTH-1)-1:0] of_reg_cs; // reg who overflow

    reg [PRE_REG_WIDTH-1:0] fix_acc_buf [DEPTH-1:0];
    
    reg [clogb2(DEPTH-1)-1 :0] max_acc_cs_predict;
    reg [clogb2(DEPTH-1)-1 :0] pos_neg_flag;
    reg buf_input_sign;    

    always @(posedge clk) begin
        if(~rstn)begin
            pos_neg_flag<=0;
            fsm_status<=0;
            max_acc_cs_predict <=0;
            of_reg_cs<=0;
            for(int i = 0;i<DEPTH;i++)begin
                fix_acc_buf[i]<=0;
            end
        end

        if(fsm_status == 0)begin //first init
            if(clr_valid & clr_ready)begin
                fsm_status <= 2;
            end
            if(add_pkt_stream.tvalid & add_pkt_stream.tready)begin
                max_acc_cs_predict <=acc_reg_cs;
                //write through
                fix_acc_buf[acc_reg_cs] <= acc_data;
                fsm_status <=1;
            end
        end
        else if(fsm_status == 1)begin 
            if(clr_valid & clr_ready)begin
                fsm_status<=2;
            end
            if(add_pkt_stream.tvalid & add_pkt_stream.tready) begin

                if(acc_reg_cs > max_acc_cs_predict)begin //来了一个绝对值大于当前可表示值的值，一定会溢出
                    buf_input_sign <= input_sign;
                    fsm_status<=5;
                    //write through
                    fix_acc_buf[acc_reg_cs] <= acc_data;
                    
                    of_reg_cs <= max_acc_cs_predict +1;
                    max_acc_cs_predict <= acc_reg_cs;
                end 

                else begin
                    buf_input_sign <= input_sign;
                    of_reg_cs <= acc_reg_cs+1;
                    // write after read
                    fix_acc_buf[acc_reg_cs] <= adder_out;
                    if(acc_reg_cs == max_acc_cs_predict) begin // 同阶，变号直接写入标志
                        pos_neg_flag <= adder_out[PRE_REG_WIDTH];
                    end
                    else if(adder_out[PRE_REG_WIDTH] & ~input_sign)begin//无符号数 正数 出现溢出，需要对下一个累加 
                        fsm_status <=3;
                    end
                    else if(~adder_out[PRE_REG_WIDTH] & input_sign)begin //无符号数 出现溢出， 就不用加了
                        fsm_status <=3;
                    end
                end
            end
        end
        else if(fsm_status==2)begin
            
            if(res_pkt_stream.tvalid & res_pkt_stream.tready) begin
                for(int i = 0;i<DEPTH;i++)begin
                    fix_acc_buf[i]<=0;
                end
                pos_neg_flag<=0;
                fsm_status<=0;
                max_acc_cs_predict <=0;
                of_reg_cs<=0;
            end
        end
        else if(fsm_status==3)begin
            // write after read
            fix_acc_buf[of_reg_cs] <= adder_out;
            if(adder_out[PRE_REG_WIDTH] & ~buf_input_sign)begin //加的正数 => 累加值为负，则不溢出 为正，则上溢
                if(of_reg_cs == max_acc_cs_predict & ~pos_neg_flag)begin // 累加值为正，则上溢 ，不变号
                    fsm_status <= 4;
                end
                else if(of_reg_cs == max_acc_cs_predict & pos_neg_flag)begin // 累加值为负，不溢出 ，可能变号
                    fsm_status <= 1;
                    pos_neg_flag <= adder_out[PRE_REG_WIDTH];
                end
                else if(of_reg_cs < max_acc_cs_predict )begin
                    of_reg_cs<=of_reg_cs + 1;
                    fsm_status<=3;
                end
            end
            if(~adder_out[PRE_REG_WIDTH] & buf_input_sign)begin //加的正数 => 累加值为负，则不溢出 为正，则上溢
                if(of_reg_cs == max_acc_cs_predict & pos_neg_flag)begin // 累加值为负，则下溢 ，不变号
                    fsm_status <= 4;
                end
                else if(of_reg_cs == max_acc_cs_predict & ~pos_neg_flag)begin // 累加值为负，不溢出 ，可能变号
                    fsm_status <= 1;
                    pos_neg_flag <= adder_out[PRE_REG_WIDTH];
                end
                else if(of_reg_cs < max_acc_cs_predict )begin
                    of_reg_cs<=of_reg_cs + 1;
                    fsm_status<=3;
                end
            end
        end
        else if(fsm_status == 4) begin //连续 累加溢出处理
            //write through
            fix_acc_buf[max_acc_cs_predict] <= buf_input_sign ? ({((128'h0) -1) & 64'h0 }) :0;

            max_acc_cs_predict<=max_acc_cs_predict+1;
            fsm_status<=1;

        end
        else if(fsm_status == 5) begin //不连续 累加溢出处理
            if(of_reg_cs == max_acc_cs_predict)begin//结束
                fsm_status<=1;
                pos_neg_flag <= buf_input_sign;
            end
            else begin
                //write through
                fix_acc_buf[of_reg_cs] <= buf_input_sign ? ({((128'h0) -1) & 64'h0 }) :0;
                of_reg_cs <= of_reg_cs +1;
            end
        end
    
    end
endmodule