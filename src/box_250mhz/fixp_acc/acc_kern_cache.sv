module acc_kern_cache #(
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
    (* keep="TRUE" *)
    output wire add_valid,
    (* keep="TRUE" *)
    stream.master res_pkt_stream

);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    reg [3:0] fsm_status;
    reg [3:0] rd_status;
    
    wire [PRE_REG_WIDTH:0] adder_out;
    wire [PRE_REG_WIDTH-1:0] adder_in1;
    wire [PRE_REG_WIDTH-1:0] adder_in2;
    wire [clogb2(DEPTH-1)-1:0] acc_reg_cs;
    wire [PRE_REG_WIDTH-1:0]    acc_data;
    reg [2*PRE_REG_WIDTH-1:0] fifo_data_out;
    wire w_ready;
    wire [clogb2(DEPTH-1)-1:0] w_addr;
    wire  w_req;
    logic [PRE_REG_WIDTH-1:0] w_data;
    wire req_hit;
    wire [PRE_REG_WIDTH-1:0] r_data;
    reg r_req;
    wire [clogb2(DEPTH-1)-1:0] r_addr;

    fastadder#(128)fastadder1(adder_in1,adder_in2,adder_out);


    // assign adder_in1 =  ((fsm_status == 0) ? fix_acc_buf[acc_reg_cs] :0 )|
    //                     ((fsm_status == 3) ? fix_acc_buf[of_reg_cs] :0 );

    assign adder_in1 = r_data;
    assign acc_data = add_pkt_stream.tdata[PRE_REG_WIDTH-1:0];
    assign adder_in2 = ((fsm_status == 1) ? acc_data :0 )|
                        ((fsm_status == 3) ? (buf_input_sign ? (ff_00) :(1<<PRE_REG_STEP)) :0 );
        

    assign clr_ready =  ((fsm_status==0)|(fsm_status==1));
    
    assign add_valid = add_pkt_stream.tvalid & add_pkt_stream.tready;

    assign acc_reg_cs = add_pkt_stream.tdata[PRE_REG_WIDTH+:clogb2(DEPTH-1)];
    
    assign add_pkt_stream.tready = ((fsm_status==0) | (fsm_status==1)) & wait_cache_flag ==0 & w_ready &~(clr_valid & clr_ready);
    assign res_pkt_stream.tvalid = fsm_status == 2 & rd_status ==2;
    
    


    assign res_pkt_stream.tdata = {pos_neg_flag,fifo_data_out,max_acc_cs_predict_out};
    
    

    reg [clogb2(DEPTH-1)-1:0] of_reg_cs; // reg who overflow

    // reg [PRE_REG_WIDTH-1:0] fix_acc_buf [DEPTH-1:0];
    reg [clogb2(DEPTH-1)-1 :0] max_acc_cs_predict_out;
    reg [clogb2(DEPTH-1)-1 :0] max_acc_cs_predict;
    reg   pos_neg_flag;
    reg buf_input_sign;    
    reg wait_cache_flag;
    wire set_zero;
    assign set_zero = fsm_status==2&rd_status==2& res_pkt_stream.tvalid & res_pkt_stream.tready;

    // reg [PRE_REG_WIDTH-1:0] r_data;



    
    assign r_addr =  ((fsm_status == 1) ? acc_reg_cs :0 )|
                ((fsm_status == 3) ? of_reg_cs :0 ) |
                (fsm_status == 2 & rd_status==0 ? max_acc_cs_predict:0)|
                (fsm_status == 2 & rd_status==1 ? max_acc_cs_predict-1:0);

    always @(posedge clk) begin

        
        if(~rstn)begin
            pos_neg_flag<=0;
            wait_cache_flag<=0;
            fsm_status<=0;
            max_acc_cs_predict <=0;
            of_reg_cs<=0;
            fifo_data_out<=0;
            // for(int i = 0;i<DEPTH;i++)begin
            //     fix_acc_buf[i]<=0;
            // end
        end

        if(fsm_status == 0)begin //first init
            if(clr_valid & clr_ready)begin
                fsm_status <= 2;
            end
            else if(add_pkt_stream.tvalid & add_pkt_stream.tready)begin
                max_acc_cs_predict <=acc_reg_cs;
                pos_neg_flag <=input_sign;
                //write through
                // fix_acc_buf[acc_reg_cs] <= acc_data;

                fsm_status <=1;
            end
        end
        else if(fsm_status == 1)begin 
            if(clr_valid & clr_ready)begin
                fsm_status<=2;
                rd_status<=0;
                fifo_data_out<=0;
            end
            else if(add_pkt_stream.tvalid & add_pkt_stream.tready | wait_cache_flag) begin
                if(acc_reg_cs > max_acc_cs_predict)begin //来了一个绝对值大于当前可表示值的值，一定会溢出
                        buf_input_sign <= input_sign;
                        fsm_status<=5;
                        //write through
                        // fix_acc_buf[acc_reg_cs] <= acc_data;
                        
                        of_reg_cs <= max_acc_cs_predict +1;
                        max_acc_cs_predict <= acc_reg_cs;
                    end
                else if(req_hit) begin
                    wait_cache_flag <=0;
                    
                    buf_input_sign <= input_sign;
                    of_reg_cs <= acc_reg_cs + 1;
                    // write after read
                    // fix_acc_buf[acc_reg_cs] <= adder_out;
                    
                    if(adder_out[PRE_REG_WIDTH] & ~input_sign  & ~pos_neg_flag )begin//无符号数 正数 出现溢出，需要对下一个累加 
                        fsm_status <=3;
                    end
                    else if(~adder_out[PRE_REG_WIDTH] & input_sign  & pos_neg_flag)begin //无符号数 fushu 出现溢出， 
                        fsm_status <=3;
                    end 
                    else if(max_acc_cs_predict ==acc_reg_cs )begin //bu tong hao bu yi chu
                         pos_neg_flag <= adder_out[PRE_REG_WIDTH ] ^(input_sign ^ pos_neg_flag);
                    end
                end
                else begin
                    wait_cache_flag <=1;
                end
                
            end
        end
        else if(fsm_status==2)begin
            if(rd_status == 0)begin
                if(req_hit)begin
                    // fifo_data_out[0+:PRE_REG_WIDTH] <=r_data;
                    fifo_data_out[PRE_REG_WIDTH+:PRE_REG_WIDTH] <=(~pos_neg_flag)? r_data:(~r_data+1);
                    max_acc_cs_predict_out <= max_acc_cs_predict;
                    rd_status<=1;
                end
            end
            if(rd_status == 1)begin
                if(req_hit)begin
                    fifo_data_out[0+:PRE_REG_WIDTH] <= (~pos_neg_flag)? r_data:(~r_data+1);
                    // fifo_data_out[PRE_REG_WIDTH+:PRE_REG_WIDTH] <=r_data;
                    rd_status<=2;
                end
            end
            if(rd_status ==2 & res_pkt_stream.tvalid & res_pkt_stream.tready)begin
                // for(int i = 0;i<DEPTH;i++)begin
                //     fix_acc_buf[i]<=0;
                // end
                pos_neg_flag<=0;
                fsm_status<=0;
                max_acc_cs_predict <=0;
                of_reg_cs<=0;
            end
        end
        else if(fsm_status==3)begin
            // write after read
            if(of_reg_cs > max_acc_cs_predict & w_ready)begin
                max_acc_cs_predict <= of_reg_cs;
                fsm_status <=1;
            end
            else if(req_hit) begin

                wait_cache_flag <=0;
                if ( adder_out[PRE_REG_WIDTH] & ~buf_input_sign &  ~pos_neg_flag)begin 
                    of_reg_cs <= of_reg_cs+1; 
                end
                else if(~adder_out[PRE_REG_WIDTH] & buf_input_sign & pos_neg_flag)begin
                    of_reg_cs <= of_reg_cs+1;
                end

                else begin 
                    fsm_status <= 1;
                    if(max_acc_cs_predict ==of_reg_cs)begin //bu tong hao bu yi chu
                        pos_neg_flag <= adder_out[PRE_REG_WIDTH ] ^(buf_input_sign ^ pos_neg_flag);
                    end 
                end

            end
            else begin
                wait_cache_flag <=1;
                // r_req<=1;
            end
        end

        else if(fsm_status == 5) begin //不连续 累加溢出处理
            if(of_reg_cs == max_acc_cs_predict)begin//结束
                fsm_status<=1;
                pos_neg_flag <= buf_input_sign;
            end
            else begin
                //write through
                if(w_ready)begin
                    // fix_acc_buf[of_reg_cs] <= buf_input_sign ? ({((128'h0) -1) & 64'h0 }) :0;
                    of_reg_cs <= of_reg_cs +1;
                end

            end
        end
    
    end
    //assign 
    fix_acc_cache fix_acc_cache(
        .clk(clk),
        .rstn(rstn),
        .set_zero(set_zero),

        .w_ready(w_ready),
        .w_addr(w_addr),
        .w_req(w_req),
        .w_data(w_data),

        .req_hit(req_hit),
        .r_req(r_req),
        .r_data(r_data),
        .r_addr(r_addr)

    );
    wire [PRE_REG_WIDTH-1:0] ff_00;
    generate for (genvar i = 0; i < PRE_REG_WIDTH; i++) begin
        assign ff_00[i] = (i>PRE_REG_STEP-1);
    end
    endgenerate
    assign w_addr = (fsm_status == 0 ?acc_reg_cs:0)|
                    (fsm_status == 1 ?acc_reg_cs:0)|
                    (fsm_status == 3 ?of_reg_cs:0)|
                    (fsm_status == 5 ?of_reg_cs:0);

    assign w_data = (fsm_status == 0 ?acc_data:0 )|
                    (fsm_status == 1 ? (acc_reg_cs > max_acc_cs_predict ? (pos_neg_flag ?  acc_data -1 : acc_data) :adder_out):0 )|
                    ((fsm_status == 3 & ~(of_reg_cs > max_acc_cs_predict))? adder_out :0)|
                    ((fsm_status == 3 & (of_reg_cs > max_acc_cs_predict))? (pos_neg_flag ? ff_00 : 1<<PRE_REG_STEP) :0)|
                    (fsm_status == 5 ? (pos_neg_flag? ff_00:(0)):0 );
    assign w_req = (fsm_status == 0 & add_pkt_stream.tvalid & add_pkt_stream.tready) |
            (fsm_status == 1 & (add_pkt_stream.tvalid & add_pkt_stream.tready | wait_cache_flag) &(acc_reg_cs > max_acc_cs_predict))|
            (fsm_status == 1 & (add_pkt_stream.tvalid & add_pkt_stream.tready | wait_cache_flag) &req_hit) |
            (fsm_status==3 & req_hit & ~( of_reg_cs > max_acc_cs_predict)) |
            (fsm_status==3 & w_ready& ( of_reg_cs > max_acc_cs_predict)) |
            (fsm_status == 5 & of_reg_cs <max_acc_cs_predict & w_ready );
    assign r_req = (fsm_status == 1 & (wait_cache_flag | req_hit) & ~(acc_reg_cs > max_acc_cs_predict) ) |
                    (fsm_status ==  3 & ~(of_reg_cs > max_acc_cs_predict))|
                    (fsm_status ==  2);

endmodule

