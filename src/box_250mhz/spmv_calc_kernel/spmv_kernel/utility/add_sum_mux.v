module add_sum_mux#(
parameter integer DATA_WIDTH	= 32,
parameter integer MUL_CYC	= 1,
parameter integer ADD_CYC	= 1
)(
    a,
    b,
    input_vaild,
    input_ready,
    output_vaild,
    data_sum,

    clk,
    rstn
    
);
    input wire[DATA_WIDTH-1:0] a;
    input wire[DATA_WIDTH-1:0] b;
    input wire  input_vaild;
    output wire input_ready;
    output reg output_vaild;
    output wire[DATA_WIDTH *2 -1:0] data_sum;
    
    input wire clk;
    input wire rstn;
    
    wire output_vaild_0;
    wire output_vaild_1;
    reg mod_cs=0;

    wire input_ready_0;
    wire input_ready_1;

    assign input_ready = (input_ready_0&mod_cs==0)|(input_ready_1&mod_cs==1);
    

    reg [DATA_WIDTH-1:0] res0,res1;

    assign data_sum = {res0,res1};
    
    wire [DATA_WIDTH-1:0] data_sum_0,data_sum_1;
    add_sum add_sum_0(
        .a(a),
        .b(b),
        .input_vaild(input_vaild &(mod_cs==0)),
        .input_ready(input_ready_0),
        .output_vaild(output_vaild_0),
        .data_sum(data_sum_0),
        .clk(clk),
        .rstn(rstn)

    );
    add_sum add_sum_1(
        .a(a),
        .b(b),
        .input_vaild(input_vaild &(mod_cs==1)),
        .input_ready(input_ready_1),
        .output_vaild(output_vaild_0),
        .data_sum(data_sum_0),
        .clk(clk),
        .rstn(rstn)
    );
    always @(posedge clk or negedge rstn) begin
        if(~rstn)begin
            mod_cs<=0;
        end
        if(output_vaild_0)begin
            res0<=data_sum_0;
        end
        if(output_vaild_1)begin
            res1<=data_sum_1;
        end
        if(input_vaild)begin
            mod_cs<=mod_cs+1;
        end
    end


endmodule