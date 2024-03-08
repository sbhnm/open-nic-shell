module Data_DeMux #(
    parameter  SLAVE_WIDTH =256,
    parameter  MASTER_WIDTH =64
) (
    input wire [SLAVE_WIDTH -1: 0] s_data,
    output wire s_ready,
    input wire s_valid,

    output wire [MASTER_WIDTH -1: 0] m_data,
    input wire m_ready,
    output wire m_valid,
    
    input clk,
    input rstn
);
    assign s_ready = (now_prt >= SLAVE_WIDTH / MASTER_WIDTH) & rstn;
    reg [7:0] now_prt;
    reg [SLAVE_WIDTH-1:0] Data_Buffer;
    assign m_data = Data_Buffer[now_prt*MASTER_WIDTH+:MASTER_WIDTH];
    always @(posedge clk ) begin
        if(~rstn)begin
            Data_Buffer<=0;
        end
        else begin
            if(s_ready & s_valid)begin
                Data_Buffer<=s_data;
            end
        end
    end
    assign m_valid = now_prt<SLAVE_WIDTH / MASTER_WIDTH & m_ready;
    // always @(posedge clk ) begin
    //     if(~rstn)begin
    //         m_valid<=0;
    //     end
    //     else begin
    //         if(now_prt<SLAVE_WIDTH / MASTER_WIDTH & ~m_valid)begin
    //             m_valid <= 1;
    //         end
    //         else if(m_valid& m_ready)begin
    //             m_valid<=0;
    //         end
    //     end
    // end
    always @(posedge clk ) begin
        if(~rstn)begin
           now_prt<=8'b1111_1111; 
        end
        else begin
            if(s_ready & s_valid)begin
                now_prt<=0;
            end
            else if(m_ready & m_valid)begin
                now_prt<=now_prt+1;
            end
        end
    end

endmodule