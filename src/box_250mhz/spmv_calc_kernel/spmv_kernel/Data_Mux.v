module Data_Mux#()
(
    input wire clk,
    input wire rstn,

    input wire [2:0] Ctrl_sig_Yi,
    

    input wire input_valid,
    input wire [63:0] input_data,
    output wire input_ready,

    output wire output_valid,
    output wire [63:0] output_data,
    input wire output_ready
);
    reg [63:0] Buffer;
    
    reg [3:0] DataNum;

    wire full;
    assign full =   (Ctrl_sig_Yi == 2)? DataNum == 1:0|
                    (Ctrl_sig_Yi == 1)? DataNum == 2:0|
                    (Ctrl_sig_Yi == 0)? DataNum == 4:0;

    
    assign input_ready = ~full;

    assign output_valid = output_ready & full;


    assign output_data = Buffer;

    always @(posedge clk ) begin
        if(~rstn)begin
            DataNum<=0;
        end
        else if(input_valid & ~full)begin
            DataNum<=DataNum+1;
        end
        else if(input_valid & full)begin
            DataNum<=DataNum;
        end
        else if(output_valid)begin
            DataNum<=0;
        end
    end


    always @(posedge clk ) begin
        if(input_valid & ~full)begin
            if(Ctrl_sig_Yi == 2)begin
                Buffer[63:0]<= input_data[63:0];
            end
            else if(Ctrl_sig_Yi ==1)begin

                Buffer <= {input_data[31:0],Buffer[63:32]};
            end
            else if(Ctrl_sig_Yi == 0)begin
                Buffer <= {input_data[15:0],Buffer[63:48]};
            end
        end
    end


    

endmodule