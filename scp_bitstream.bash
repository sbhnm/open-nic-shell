scp hxz@10.51.26.188://home/hxz/Documents/open_nic/open-nic-shell/build/au50/open_nic_shell/open_nic_shell.runs/impl_1/open_nic_shell.bit .
scp hxz@10.51.26.188://home/hxz/Documents/open_nic/open-nic-shell/build/au50/open_nic_shell/open_nic_shell.runs/impl_1/open_nic_shell.ltx .
# echo 8 > /sys/bus/pci/devices/0000\:04\:00.0/qdma/qmax
# dma-ctl qdma4000 q start idx 0
# sudo dma-to-device -d                                                                                             /dev/qdma04000-ST-0
# dma-ctl qdma04000 q add idx 0 mode st dir h2c