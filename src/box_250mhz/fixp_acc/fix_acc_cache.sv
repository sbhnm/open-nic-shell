module fix_acc_cache #(
    parameter DEPTH = 32,
    parameter PRE_REG_WIDTH = 128 
) (
    input wire clk,
    input wire set_zero,
    input wire rstn,
    
    input wire w_req,
    input wire [PRE_REG_WIDTH-1:0] w_data,
    input wire [clogb2(DEPTH-1)-1:0] w_addr,
    output wire w_ready,
    
    output wire req_hit,
    input wire r_req,
    output wire [PRE_REG_WIDTH-1:0] r_data,
    input wire [clogb2(DEPTH-1)-1:0] r_addr
    
);


    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    
    
    assign w_ready = fsm_status==0;
    reg [clogb2(DEPTH-1)-1:0] req_cs;
    reg [clogb2(DEPTH-1)-1:0] now_fix_reg_cs;
    reg fixdatabuf_wea;
    reg [clogb2(DEPTH-1)-1:0]fixdatabuf_addra;
    reg [PRE_REG_WIDTH-1:0] fixdatabuf_dina;
    wire [PRE_REG_WIDTH-1:0] fixdatabuf_douta;
    reg [PRE_REG_WIDTH-1:0] now_fix_reg_data;
    reg [3-1:0] rw_cnt;
    reg [3 :0] fsm_status;
    assign req_hit  = r_addr == now_fix_reg_cs;
    assign  r_data = now_fix_reg_data;

    reg [DEPTH-1 :0] w_map;

    reg dirty_flag;
    reg first_flag;
    always @(posedge clk) begin
        if(~rstn | set_zero)begin
            now_fix_reg_cs<=0;
            now_fix_reg_data<=0;
            fsm_status<=0;
            dirty_flag<=0;
            first_flag<=1;

             w_map<=0;
        end

        else begin
            if(fsm_status==0)begin

                fixdatabuf_wea<=0;
                if( r_req & req_hit &w_req)begin
                    now_fix_reg_data<= w_data;
                    dirty_flag<=1;
                end
                else if(r_req & ~req_hit)begin //读未命中
                    
                    if(w_map[r_addr]==0 &dirty_flag)begin
                        fsm_status <= 3;
                        fixdatabuf_wea <= 1;
                        now_fix_reg_cs<=r_addr;
                        now_fix_reg_data<=0;
                        fixdatabuf_addra <= now_fix_reg_cs;
                        //w_map[now_fix_reg_cs] <=1;
                        fixdatabuf_dina <= now_fix_reg_data;
                    end
                    else if(dirty_flag)begin
                        fsm_status <= 1;
                        fixdatabuf_wea <= 1;
                        req_cs <= r_addr; 
                        fixdatabuf_addra <= now_fix_reg_cs;
                        //w_map[now_fix_reg_cs] <=1;
                        fixdatabuf_dina <= now_fix_reg_data;
                        rw_cnt<= 2;         
                    end
                     
                    else begin
                        fixdatabuf_addra<=r_addr;
                        rw_cnt<= 1;         
                        fsm_status<=2;
                    end
                     
                end
                else if(w_req & ~r_req)begin  //只写
                    if(w_addr == now_fix_reg_cs|first_flag)begin
                        now_fix_reg_cs <= w_addr;
                        now_fix_reg_data<= w_data;
                        dirty_flag<=1;
                    end
                    fixdatabuf_wea <= 1;
                    fixdatabuf_addra<=w_addr;
                    fixdatabuf_dina<=w_data;
                    w_map[w_addr]<=1;
                    // if()begin
                    //     now_fix_reg_data<= w_data;
                    //     dirty_flag<=1;
                    // end
                end
                
            end
            else if(fsm_status ==1) begin
                
                fixdatabuf_wea <= 0;
                // fixdatabuf_addra <= req_cs; 
                rw_cnt<=  rw_cnt -1; 
                if(rw_cnt==0)begin
                    now_fix_reg_cs<= fixdatabuf_addra;
                    now_fix_reg_data <=fixdatabuf_douta;
                    dirty_flag <=0;
                    fsm_status<=0;
                end    
            end
            else if(fsm_status==2)begin
                rw_cnt <= rw_cnt-1;
                if(rw_cnt==0)begin
                    now_fix_reg_cs<= fixdatabuf_addra;
                    now_fix_reg_data <=fixdatabuf_douta;
                    dirty_flag <=0;
                    fsm_status<=0;
                end
            end
            else if(fsm_status==3)begin
                fixdatabuf_wea<=0;
                fsm_status<=1;

            end

        end

    end
    fixdatabuf fixdatabuf (
    .clka(clk),            // input wire clka
    .rsta(~rstn |set_zero),            // input wire rsta
    .wea(fixdatabuf_wea),              // input wire [0 : 0] wea
    .addra(fixdatabuf_addra),          // input wire [4 : 0] addra
    .dina(fixdatabuf_dina),            // input wire [127 : 0] dina
    .douta(fixdatabuf_douta),          // output wire [127 : 0] douta
    .rsta_busy( )  // output wire rsta_busy
    );
endmodule