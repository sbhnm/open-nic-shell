set box_250_dir [file normalize .]
# read_verilog -quiet [glob -nocomplain -directory $box_250_dir "*.{v,vh}"]
# read_verilog -quiet -sv [glob -nocomplain -directory $box_250_dir "*.sv"]
# read_vhdl -quiet [glob -nocomplain -directory $box_250_dir "*.vhd"]
cd ${box_250_dir}/spmv_calc_kernel
source build.tcl
cd ${box_250_dir}

cd ${box_250_dir}/spmv_system_config
source build.tcl
cd ${box_250_dir}

