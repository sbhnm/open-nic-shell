fileoffset=0
transtimes=2000

echo 8 > /sys/bus/pci/devices/0000\:04\:00.0/qdma/qmax
cd /home/hxz/Documents/open_nic/dma_ip_drivers/QDMA/linux-kernel/bin
dma-ctl qdma04000 reg read bar 2 0x1000
dma-ctl qdma04000 reg write bar 2 0x1000 0x01
dma-ctl qdma04000 q add idx 0 mode st dir h2c
dma-ctl qdma4000 q start idx 0 idx_ringsz 8192
# for ((i = 1;i<=$transtimes;i++))
# do  
    
    # dma-to-device -d /dev/qdma04000-ST-0 -s 25165824 -o $fileoffset -c 1 -f /home/hxz/Downloads/code_1.82.1-1694163687_amd64.deb 
    # fileoffset=$(($fileoffset+256))
    # sleep 0.005
# done

# dma-to-device -d /dev/qdma04000-ST-0 -s 8192 -c 1 -f /home/hxz/Downloads/code_1.82.1-1694163687_amd64.deb 