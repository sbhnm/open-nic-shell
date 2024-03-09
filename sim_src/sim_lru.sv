`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/31 18:12:00
// Design Name: 
// Module Name: sim_Multi_Kernel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_lru #(
    parameter int CONF_NUM_KERNEL = 32'h1,
    parameter integer TAGS_WIDTH = 48,
    
    parameter integer DATA_WIDTH=64,

    parameter integer CACHE_SIZE=512,

    parameter integer CACHE_DEPTH=8
)(
    
    );
    reg rstn;
    reg clk =1;
    reg [31:0] clkcnt=0;
    always #5 clk = ~clk;
    always @(posedge clk) begin
        clkcnt<=clkcnt+1;
    end

    initial begin
        rstn <=1;
        #200
        rstn <=0;

        #200
        rstn <=1;
      
    end
    task req_data(int addr);
        @(posedge clk);
        fontend_addr_stream.tdata=  addr;
        fontend_addr_stream.tvalid= 1;
        #10
        fontend_addr_stream.tvalid=0;
        // fontend_addr_stream.tdata=0;
        wait(fontend_data_stream.tvalid & fontend_data_stream.tready);
    endtask
    stream #(TAGS_WIDTH)  fontend_addr_stream();
    stream #(DATA_WIDTH)  fontend_data_stream();
    stream #(TAGS_WIDTH)  backend_addr_stream();
    stream #(CACHE_SIZE)  backend_data_stream();
    // initial begin
    //     fontend_data_stream.tready = 1;
    // end

    always @(posedge clk) begin
        if(~rstn)begin
           fontend_data_stream.tready<=1; 
        end
        if(fontend_data_stream.tready & fontend_data_stream.tvalid) begin
            fontend_data_stream.tready<=0;
        end
        else if(fontend_addr_stream.tready & fontend_addr_stream.tvalid)begin
            fontend_data_stream.tready<=1;
        end
    end
    initial begin
        backend_addr_stream.tready = 1;
    end
    initial begin
        fontend_addr_stream.tvalid=0;
        fontend_addr_stream.tdata=0;
        #300
        wait(rstn);
        #20
        req_data(0);
        req_data(1);

        req_data(1);
        req_data(0);

        req_data(2);
        req_data(3);
        req_data(4);
        req_data(5);
        req_data(6);
        req_data(7);
        
        req_data(1);
        req_data(0);
        req_data(3);
        

    end
    read_ram read_ram(
        .clk(clk),
        .rstn(rstn),
        .req_addr_stream(backend_addr_stream),
        .bak_data_stream(backend_data_stream)
    );
    lru_way lru_way(
        .clk(clk),
        .rstn(rstn),

        .fontend_addr_stream(fontend_addr_stream),
        .fontend_data_stream(fontend_data_stream),
        .backend_addr_stream(backend_addr_stream),
        .backend_data_stream(backend_data_stream)
        
    );


endmodule