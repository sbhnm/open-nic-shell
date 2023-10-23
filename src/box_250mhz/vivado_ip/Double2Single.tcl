
set Double2Single [create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name Double2Single -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.A_Precision_Type {Double} \
  CONFIG.C_A_Exponent_Width {11} \
  CONFIG.C_A_Fraction_Width {53} \
  CONFIG.C_Accum_Input_Msb {32} \
  CONFIG.C_Accum_Lsb {-31} \
  CONFIG.C_Accum_Msb {32} \
  CONFIG.C_Latency {4} \
  CONFIG.C_Mult_Usage {No_Usage} \
  CONFIG.C_Rate {1} \
  CONFIG.C_Result_Exponent_Width {8} \
  CONFIG.C_Result_Fraction_Width {24} \
  CONFIG.Operation_Type {Float_to_float} \
  CONFIG.Result_Precision_Type {Single} \
] [get_ips Double2Single]
