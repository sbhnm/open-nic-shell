//
//这个模块负责将累乘结果求和 采用流水线 Σ(a*b)
// localparam DATA_WIDTH = 32;
module add_sum#(
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
    output wire[DATA_WIDTH-1:0] data_sum;
    input wire clk;
    input wire rstn;
    
    reg [DATA_WIDTH-1:0] sum;
    

    wire add_inst_input_vaild;
    wire add_inst_input_ready;

    wire add_inst_output_vaild;
    wire add_inst_output_ready;

    wire mul_inst_input_vaild;
    wire mul_inst_input_ready;

    wire mul_inst_output_vaild;
    wire mul_inst_output_ready;

    wire [DATA_WIDTH-1:0] mul_res;
    wire [DATA_WIDTH-1:0] add_res;

    reg [3:0] pipe_state;

    // assign output_vaild = add_inst_output_vaild;
    assign data_sum = add_res;
    assign add_inst_output_ready = 1;
    add_fp32 add_inst (
        .clk(clk),
        .a(mul_res),
        .b(sum),
        .c(add_res),
        .input_vaild(add_inst_input_vaild),
        .input_ready(add_inst_input_ready),
        .output_vaild(add_inst_output_vaild),
        .output_ready(add_inst_output_ready)
    );

    mul_fp32 mul_inst(
        .a(a),
        .b(b),
        .c(mul_res),
        .clk(clk),

        .input_vaild(mul_inst_input_vaild),
        .input_ready(mul_inst_input_ready),
        .output_vaild(mul_inst_output_vaild),
        .output_ready(mul_inst_output_ready)

    );

    reg [4:0]add_cyc_left = 0;
    // wire input_ready;

    assign mul_inst_output_ready = add_inst_input_ready;

    assign input_ready = (pipe_state == 1 && add_cyc_left < MUL_CYC+1) | (pipe_state==0) | (pipe_state==3&&add_cyc_left==0);

    assign mul_inst_input_vaild = (pipe_state==0&&input_vaild)||(pipe_state==1&&input_vaild&&input_ready);

    assign add_inst_input_vaild = mul_inst_output_vaild;

    always @(posedge clk or negedge rstn) begin
        output_vaild <= add_inst_output_vaild;
        if(add_inst_output_vaild)begin
            sum<=add_res;
            
        end
    end
    always @(posedge clk or negedge rstn) begin
        if(~rstn)begin
            sum<=0;
            pipe_state<=0;
        end
        if(pipe_state==0)begin
            if(input_vaild)begin
                pipe_state<=2;
                add_cyc_left <= ADD_CYC + MUL_CYC;
            end
        end
        if(pipe_state==1)begin
            add_cyc_left <= add_cyc_left-1;
            if(add_inst_output_vaild)begin
                pipe_state<=0;
                if(input_vaild)begin
                    pipe_state<=2;
                    add_cyc_left <= ADD_CYC;
                end
            end
        end
        if(pipe_state==2)begin
            add_cyc_left <= add_cyc_left -1;
            if(mul_inst_output_vaild&~input_vaild)begin
                pipe_state<=1;
                add_cyc_left <= ADD_CYC;
                
            end
            if(mul_inst_output_vaild&input_vaild)begin
                pipe_state<=3;
            end
        end
        if(pipe_state==3)begin
            add_cyc_left <= add_cyc_left==0? 0 : add_cyc_left-1;
            if(add_inst_output_vaild)begin
                pipe_state<=2;
            end
            if(add_inst_output_vaild&&mul_inst_output_vaild)begin
                pipe_state<=1;
                add_cyc_left <= ADD_CYC;
            end
        end
    end
endmodule