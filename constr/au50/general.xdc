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
set_operating_conditions -design_power_budget 63

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




# create_pblock {pblock_gnblk2[0].spmv_clc_krnl_1}
# add_cells_to_pblock [get_pblocks {pblock_gnblk2[0].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[0].axi_Xi_crossbar} {box_250mhz_inst/spmv_calc_top/genblk2[0].spmv_calc_kernel}]]
# resize_pblock [get_pblocks {pblock_gnblk2[0].spmv_clc_krnl_1}] -add {CLOCKREGION_X0Y0:CLOCKREGION_X0Y3}
# create_pblock {pblock_gnblk2[1].spmv_clc_krnl_1}
# add_cells_to_pblock [get_pblocks {pblock_gnblk2[1].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[1].axi_Xi_crossbar} {box_250mhz_inst/spmv_calc_top/genblk2[1].spmv_calc_kernel}]]
# resize_pblock [get_pblocks {pblock_gnblk2[1].spmv_clc_krnl_1}] -add {CLOCKREGION_X1Y0:CLOCKREGION_X1Y3}
# create_pblock {pblock_gnblk2[2].spmv_clc_krnl_1}
# add_cells_to_pblock [get_pblocks {pblock_gnblk2[2].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[2].axi_Xi_crossbar} {box_250mhz_inst/spmv_calc_top/genblk2[2].spmv_calc_kernel}]]
# resize_pblock [get_pblocks {pblock_gnblk2[2].spmv_clc_krnl_1}] -add {CLOCKREGION_X2Y0:CLOCKREGION_X2Y3}
# create_pblock {pblock_gnblk2[3].spmv_clc_krnl_1}
# add_cells_to_pblock [get_pblocks {pblock_gnblk2[3].spmv_clc_krnl_1}] [get_cells -quiet [list {box_250mhz_inst/spmv_calc_top/genblk2[3].axi_Xi_crossbar} {box_250mhz_inst/spmv_calc_top/genblk2[3].spmv_calc_kernel}]]
# resize_pblock [get_pblocks {pblock_gnblk2[3].spmv_clc_krnl_1}] -add {CLOCKREGION_X3Y0:CLOCKREGION_X3Y3}
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets axil_aclk]
