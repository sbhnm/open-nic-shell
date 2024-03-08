i = 0
for _ in range(0,64,4):
    
    print('{:08X}{:08X}{:08X}{:08X}{:08X}{:08X}{:08X}{:08X},'.format(i+7,i+6,i+5,i+4,i+3,i+2,i+1,i+0))
    i = i+8
i = 0
for _ in range(0,64):
    print('{:08X}{:08X},'.format(i+1,i+0))
    i = i+2
