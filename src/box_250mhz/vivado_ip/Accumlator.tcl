
set Accumlator [create_ip -name c_accum -vendor xilinx.com -library ip -version 12.0 -module_name Accumlator -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.Bypass {false} \
  CONFIG.CE {true} \
  CONFIG.Input_Width {64} \
  CONFIG.Latency {1} \
  CONFIG.SCLR {true} \
] [get_ips Accumlator]


