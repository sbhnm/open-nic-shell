
set hbm_0 [create_ip -name hbm -vendor xilinx.com -library ip -version 1.0 -module_name hbm_0 -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.USER_HBM_DENSITY {8GB} \
  CONFIG.USER_XSDB_INTF_EN {TRUE} \
] [get_ips hbm_0]

