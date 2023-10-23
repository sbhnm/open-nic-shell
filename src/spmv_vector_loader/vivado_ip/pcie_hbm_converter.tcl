set pcie_hbm_converter [create_ip -name axi_dwidth_converter -vendor xilinx.com -library ip -version 2.1 -module_name pcie_hbm_converter -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.ADDR_WIDTH {64} \
  CONFIG.MI_DATA_WIDTH {256} \
  CONFIG.SI_DATA_WIDTH {512} \
] [get_ips pcie_hbm_converter]

