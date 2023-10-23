
set Fix2Double [create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name Fix2Double -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.A_Precision_Type {Custom} \
  CONFIG.C_A_Exponent_Width {32} \
  CONFIG.C_A_Fraction_Width {32} \
  CONFIG.C_Accum_Input_Msb {32} \
  CONFIG.C_Accum_Lsb {-31} \
  CONFIG.C_Accum_Msb {32} \
  CONFIG.C_Latency {8} \
  CONFIG.C_Mult_Usage {No_Usage} \
  CONFIG.C_Rate {1} \
  CONFIG.C_Result_Exponent_Width {11} \
  CONFIG.C_Result_Fraction_Width {53} \
  CONFIG.Operation_Type {Fixed_to_float} \
  CONFIG.Result_Precision_Type {Double} \
] [get_ips Fix2Double]

