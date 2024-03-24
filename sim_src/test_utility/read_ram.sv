module read_ram #(
    parameter integer ADDR_WIDTH = 48,
    
    parameter integer DATA_WIDTH=64,

    parameter integer read_time = 16

) (
    input wire clk,
    input wire rstn,

    stream.slave   req_addr_stream,
    stream.master   bak_data_stream

);
    logic [31:0] req_addr = 0;
    task get_req_addr();
        req_addr_stream.tready=1;
        wait(req_addr_stream.tvalid);
        req_addr_stream.tready=0;
        req_addr = req_addr_stream.tdata;
        
        for (int i = 0; i < read_time; i++) begin
            @(posedge clk);
        end
        
        wait(clk&bak_data_stream.tready);
        bak_data_stream.tvalid=1;
        bak_data_stream.tdata=req_addr;
        wait(~clk);
        wait(clk);
        bak_data_stream.tvalid=0;
    endtask
    logic read_lock;
    always @(posedge clk) begin
        if(~rstn) begin
            read_lock=0;
            bak_data_stream.tdata=0;
        end
        else if(~read_lock)begin
            read_lock = 1;
            get_req_addr();
            read_lock=0;
        end
    end
endmodule