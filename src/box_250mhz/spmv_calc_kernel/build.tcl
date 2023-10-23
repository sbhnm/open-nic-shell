
set spmv_calc_kernel [file normalize .]

read_verilog -quiet [glob -nocomplain -directory $spmv_calc_kernel "*.{v,vh}"]
read_verilog -quiet -sv [glob -nocomplain -directory $spmv_calc_kernel "*.sv"]
read_vhdl -quiet [glob -nocomplain -directory $spmv_calc_kernel "*.vhd"]

read_verilog -quiet [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel "*.{v,vh}"]
read_verilog -quiet -sv [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel "*.sv"]
read_vhdl -quiet [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel "*.vhd"]

read_verilog -quiet [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel/utility "*.{v,vh}"]
read_verilog -quiet -sv [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel/utility "*.sv"]
read_vhdl -quiet [glob -nocomplain -directory ${spmv_calc_kernel}/spmv_kernel/utility "*.vhd"]