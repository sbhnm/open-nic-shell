module Timer (
    output reg [63:0] Time_Use,
    input wire begin_sig,
    input wire end_sig,
    input wire clk,
    input wire rstn
);
    reg begin_sig_ff;
    reg end_sig_ff;
    reg [2:0] status;
    always @(posedge clk ) begin
        if(~rstn)begin
            begin_sig_ff<=0;
            end_sig_ff<=0;
        end
        else begin
            begin_sig_ff<=begin_sig;
            end_sig_ff<=end_sig;
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            status<=0;
        end
        else begin
            if(status ==0)begin
                if(begin_sig & ~begin_sig_ff)begin
                    status <=1;
                end
            end
            if(status==1)begin
                if(end_sig & ~end_sig_ff)begin
                    status <=0;
                end
            end
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            Time_Use<=0;
        end
        else if(status==1)begin
            Time_Use<=Time_Use+1;
        end
    end
endmodule