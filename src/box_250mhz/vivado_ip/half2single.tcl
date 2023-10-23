
set half2single [create_ip -name floating_point -vendor xilinx.com -library ip -version 7.1 -module_name half2single -dir ${ip_build_dir}]

# User Parameters
set_property -dict [list \
  CONFIG.A_Precision_Type {Half} \
  CONFIG.C_A_Exponent_Width {5} \
  CONFIG.C_A_Fraction_Width {11} \
  CONFIG.C_Accum_Input_Msb {15} \
  CONFIG.C_Accum_Lsb {-24} \
  CONFIG.C_Accum_Msb {32} \
  CONFIG.C_Latency {3} \
  CONFIG.C_Mult_Usage {No_Usage} \
  CONFIG.C_Rate {1} \
  CONFIG.C_Result_Exponent_Width {8} \
  CONFIG.C_Result_Fraction_Width {24} \
  CONFIG.Operation_Type {Float_to_float} \
  CONFIG.Result_Precision_Type {Single} \
] [get_ips half2single]
