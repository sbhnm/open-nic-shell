//每行非零元的个数 和索引值序列分开存储。乒乓缓冲的axi总线不停，只负责存储value和index，换行操作由控制逻辑进行（停止喂数据并复位）
module top (
    
);
    axi_master_r #() axi_master_n_cols ();
    axi_master_r #() axi_master_col_index ();
    axi_master_r #() axi_master_col_values ();
    axi_master_r #() axi_master_x ();

    axi_master_w #() axi_master_y ();


    num2double #() num2double_x();
    num2double #() num2double_values();

    mul_acc_ip #() mul_acc_kernel();

    


endmodule