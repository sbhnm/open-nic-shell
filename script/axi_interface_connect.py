# namelist=[
    
#     "awid",
#   "awaddr",
#   "awlen",
#   "awsize",
#   "awburst",
#   "awlock",
#   "awcache",
#   "awprot",
#   "awqos",
#   "awvalid",
#   "awready",
#   "wdata",
#   "wstrb",
#   "wlast",
#   "wvalid",
#   "wready",
#   "bid",
#   "bresp",
#   "bvalid",
#   "bready",
#   "arid",
#   "araddr",
#   "arlen",
#   "arsize",
#   "arburst",
#   "arlock",
#   "arcache",
#   "arprot",
#   "arqos",
#   "arvalid",
#   "arready",
#   "rid",
#   "rdata",
#   "rresp",
#   "rlast",
#   "rvalid",
#   "rready"
# ]
namelist=[
"awaddr",
"awlen",
"awvalid",
"awready",
"wdata",
"wstrb",
"wlast",
"wvalid",
"wready",
"bresp",
"bvalid",
"bready",
"araddr",
"arlen",
"arvalid",
"arready",
"rdata",
"rresp",
"rlast",
"rvalid",
"rready"
]
for item in namelist:
    # interfacestr= "axi_Xi[0].{0},axi_Xi[1].{0},axi_Xi[2].{0},axi_Xi[3].{0}".format(item.upper())
    # print(".s_axi_{}( {{{}}} ),".format(item,interfacestr))
    print(".s_axi_{}(axi_port.{}),".format(item,item.upper()))
    
    
