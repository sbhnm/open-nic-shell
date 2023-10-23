set spmv_system_config [file normalize .]

read_verilog -quiet [glob -nocomplain -directory $spmv_system_config "*.{v,vh}"]
read_verilog -quiet -sv [glob -nocomplain -directory $spmv_system_config "*.sv"]
read_vhdl -quiet [glob -nocomplain -directory $spmv_system_config "*.vhd"]