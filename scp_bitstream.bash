scp hxz@10.51.26.188://home/data1/open-nic-shell/build/au50/pcie_spmv/pcie_spmv.runs/impl_1/pcie_spmv.bit .
scp hxz@10.51.26.188://home/data1/open-nic-shell/build/au50/pcie_spmv/pcie_spmv.runs/impl_1/pcie_spmv.ltx .

# echo 8 > /sys/bus/pci/devices/0000\:04\:00.0/qdma/qmax
# dma-ctl qdma4000 q start idx 0
# sudo dma-to-device -d /dev/qdma04000-ST-0
# dma-ctl qdma04000 reg read bar 2 0x1000
# dma-ctl qdma04000 q add idx 0 mode st dir h2c
# dma-ctl qdma04000 reg write bar 2 0x1000 0x01