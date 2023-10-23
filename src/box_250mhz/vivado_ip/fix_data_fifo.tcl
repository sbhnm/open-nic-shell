
set fix_data_fifo [create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name fix_data_fifo -dir ${ip_build_dir}]

# User Parameters
set_property CONFIG.TDATA_NUM_BYTES {8} [get_ips fix_data_fifo]

