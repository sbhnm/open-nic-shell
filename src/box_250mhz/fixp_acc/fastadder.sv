`include "interface.vh"    
module fastadder #(parameter PRE_REG_WIDTH = 128) (
        input wire [PRE_REG_WIDTH-1:0] a,
        input wire [PRE_REG_WIDTH-1:0] b,
        output wire [PRE_REG_WIDTH :0] c 
        );
        // (* USE_DSP="yes" *)
        assign c = {1'b0,a} + {1'b0,b};
//        wire [PRE_REG_WIDTH/2 :0] lsb_d_1;
//        wire [PRE_REG_WIDTH/2 :0] lsb_d_2;
//        wire [PRE_REG_WIDTH/2 :0] lsb_d_3;
        
        //assign lsb_d_3 = {1'b0,a[0+:PRE_REG_WIDTH/2] }+ {1'b0,b[0+:PRE_REG_WIDTH/2]};
        //assign lsb_d_1[0+:PRE_REG_WIDTH/2+1] = {1'b0,a[PRE_REG_WIDTH/2+:PRE_REG_WIDTH/2]} + {1'b0,b[PRE_REG_WIDTH/2+:PRE_REG_WIDTH/2]};
        //assign lsb_d_2[0+:PRE_REG_WIDTH/2+1] = {1'b0,a[PRE_REG_WIDTH/2+:PRE_REG_WIDTH/2]} + {1'b0,b[PRE_REG_WIDTH/2+:PRE_REG_WIDTH/2]} + 1;
        
        //assign c = {(lsb_d_3[PRE_REG_WIDTH/2]?lsb_d_2:lsb_d_1),lsb_d_3[0+:PRE_REG_WIDTH/2]};
//        assign c = {(PRE_REG_WIDTH+1)'b0};
//assign c = 1;
        // wire C_OUT_0;
        // wire C_OUT_1;
        // wire C_OUT_2;
        // // wire C_OUT_3;
        
        // fixp_adder fixp_adder_0 (
        // .A(a[0+:64]),          // input wire [31 : 0] A
        // .B(b[0+:64]),          // input wire [31 : 0] B
        // .C_IN(0),    // input wire C_IN
        // .C_OUT(C_OUT_0),  // output wire C_OUT
        // .S(c[0+:64])          // output wire [31 : 0] S
        // );

        // `KEEP wire [63:0] tmp_1;
        // `KEEP wire [63:0] tmp_2;
        // fixp_adder fixp_adder_1 (
        // .A(a[64+:64]),          // input wire [31 : 0] A
        // .B(b[64+:64]),          // input wire [31 : 0] B
        // .C_IN(0),    // input wire C_IN
        // .C_OUT(C_OUT_1),  // output wire C_OUT
        // .S(tmp_1)          // output wire [31 : 0] S
        // );
        // fixp_adder fixp_adder_2 (
        // .A(a[64+:64]),          // input wire [31 : 0] A
        // .B(b[64+:64]),          // input wire [31 : 0] B
        // .C_IN(1),    // input wire C_IN
        // .C_OUT(C_OUT_2),  // output wire C_OUT
        // .S(tmp_2)          // output wire [31 : 0] S
        // );

        // assign c[128] = C_OUT_0? C_OUT_2 :C_OUT_1;
        // assign c[64+:64] =  C_OUT_0? tmp_2 :tmp_1;
    endmodule 