set sim_blk_ram [create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name sim_blk_ram -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.AXI_ID_Width {2} \
  CONFIG.EN_SAFETY_CKT {false} \
  CONFIG.Interface_Type {AXI4} \
  CONFIG.Write_Depth_A {2048} \
  CONFIG.Write_Width_A {256} \
] [get_ips sim_blk_ram]
