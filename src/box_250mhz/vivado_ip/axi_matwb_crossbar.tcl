
set axi_matwb_crossbar [create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name axi_matwb_crossbar -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.ADDR_WIDTH {48} \
  CONFIG.DATA_WIDTH {256} \
  CONFIG.ID_WIDTH {2} \
  CONFIG.NUM_MI {1} \
  CONFIG.NUM_SI {3} \
] [get_ips axi_matwb_crossbar]

