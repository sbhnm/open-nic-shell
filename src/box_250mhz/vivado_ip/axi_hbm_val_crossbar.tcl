
set axi_hbm_val_crossbar [create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name axi_hbm_val_crossbar -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.ADDR_WIDTH {48} \
  CONFIG.DATA_WIDTH {256} \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {4} \
] [get_ips axi_hbm_val_crossbar]

