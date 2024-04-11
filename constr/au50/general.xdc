# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************

set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 63.8 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]




create_pblock {pblock_gnblk2[0].spmv_clc_krnl_1}
add_cells_to_pblock [get_pblocks {pblock_gnblk2[0].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[0].spmv_calc_kernel}]]
resize_pblock [get_pblocks {pblock_gnblk2[0].spmv_clc_krnl_1}] -add {CLOCKREGION_X0Y4:CLOCKREGION_X1Y7}
create_pblock {pblock_gnblk2[1].spmv_clc_krnl_1}
add_cells_to_pblock [get_pblocks {pblock_gnblk2[1].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[1].spmv_calc_kernel}]]
resize_pblock [get_pblocks {pblock_gnblk2[1].spmv_clc_krnl_1}] -add {CLOCKREGION_X2Y4:CLOCKREGION_X3Y7}
create_pblock {pblock_gnblk2[2].spmv_clc_krnl_1}
add_cells_to_pblock [get_pblocks {pblock_gnblk2[2].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[2].spmv_calc_kernel}]]
resize_pblock [get_pblocks {pblock_gnblk2[2].spmv_clc_krnl_1}] -add {CLOCKREGION_X4Y4:CLOCKREGION_X5Y7}
create_pblock {pblock_gnblk2[3].spmv_clc_krnl_1}
add_cells_to_pblock [get_pblocks {pblock_gnblk2[3].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[3].spmv_calc_kernel}]]
resize_pblock [get_pblocks {pblock_gnblk2[3].spmv_clc_krnl_1}] -add {CLOCKREGION_X0Y0:CLOCKREGION_X1Y3}

create_pblock qdma
add_cells_to_pblock [get_pblocks qdma] [get_cells -quiet [list qdma_subsystem_inst]]
resize_pblock [get_pblocks qdma] -add {CLOCKREGION_X4Y0:CLOCKREGION_X7Y3}



create_generated_clock -name axil_aclk -source [get_pins qdma_subsystem_inst/qdma_wrapper_inst/clk_div_inst/clk_in1] -divide_by 2 [get_pins qdma_subsystem_inst/qdma_wrapper_inst/clk_div_inst/clk_out1]

set_false_path -through [get_pins -hierarchical -filter { NAME =~  "*config_wire*" && DIRECTION == "IN" && PARENT_CELL =~  "*spmv_calc_kernel*" }]

set_false_path -through [get_pins -hierarchical -filter { NAME =~  "*status_wire*" && PARENT_CELL =~  "*spmv_system_config*" }]

set_false_path -through [get_cells -hierarchical -filter { NAME =~  "*ctrl_reg*" && PARENT =~  "*axil_reg_inst*" }]

#set_false_path -from [get_clocks axil_aclk] -to [get_clocks axis_aclk]

#set_false_path -from [get_clocks axil_aclk] -to [get_clocks -of_object [get_nets axis_aclk]]

set_false_path -from [get_clocks axil_aclk] -to [get_clocks -of_object [get_nets axis_aclk]]
