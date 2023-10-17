
`timescale 1 ns / 1 ps

	module axi_master_w #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M00_AXI
		parameter  C_M_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		parameter integer C_M_AXI_BURST_LEN	= 16,
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		parameter integer C_M_AXI_DATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M00_AXI
		// input wire  m_axi_init_axi_txn,
        // input wire  m_axi_init_axi_read,
        input wire  m_axi_init_axi_write,
		// output wire  m_axi_r_done,
        output wire  m_axi_w_done,
		input wire  m_axi_aclk,
		input wire  m_axi_aresetn,
		output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid,
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr,
		output wire [7 : 0] m_axi_awlen,
		output wire [2 : 0] m_axi_awsize,
		output wire [1 : 0] m_axi_awburst,
		output wire  m_axi_awlock,
		output wire [3 : 0] m_axi_awcache,
		output wire [2 : 0] m_axi_awprot,
		output wire [3 : 0] m_axi_awqos,
		output wire  m_axi_awvalid,
		input wire  m_axi_awready,
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata,
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb,
		output wire  m_axi_wlast,
		output wire  m_axi_wvalid,
		input wire  m_axi_wready,
		input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid,
		input wire [1 : 0] m_axi_bresp,
		input wire  m_axi_bvalid,
		output wire  m_axi_bready,

        input wire [C_M_AXI_DATA_WIDTH -1:0] write_length,

        input wire [C_M_AXI_DATA_WIDTH -1:0] write_base_addr
	);
// Instantiation of Axi Bus Interface M00_AXI
	axi_master_w_ctrl # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M_AXI_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M_AXI_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M_AXI_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH)
	) axi_master_w_ctrl (
		.INIT_AXI_READ(m_axi_init_axi_read),
        .INIT_AXI_WRITE(m_axi_init_axi_write),

		.WRITE_DONE(m_axi_w_done),
        // .READ_DONE(m_axi_r_done),
		.M_AXI_ACLK(m_axi_aclk),
		.M_AXI_ARESETN(m_axi_aresetn),
		.M_AXI_AWID(m_axi_awid),
		.M_AXI_AWADDR(m_axi_awaddr),
		.M_AXI_AWLEN(m_axi_awlen),
		.M_AXI_AWSIZE(m_axi_awsize),
		.M_AXI_AWBURST(m_axi_awburst),
		.M_AXI_AWLOCK(m_axi_awlock),
		.M_AXI_AWCACHE(m_axi_awcache),
		.M_AXI_AWPROT(m_axi_awprot),
		.M_AXI_AWQOS(m_axi_awqos),
		.M_AXI_AWVALID(m_axi_awvalid),
		.M_AXI_AWREADY(m_axi_awready),
		.M_AXI_WDATA(m_axi_wdata),
		.M_AXI_WSTRB(m_axi_wstrb),
		.M_AXI_WLAST(m_axi_wlast),
		.M_AXI_WVALID(m_axi_wvalid),
		.M_AXI_WREADY(m_axi_wready),
		.M_AXI_BID(m_axi_bid),
		.M_AXI_BRESP(m_axi_bresp),
		.M_AXI_BVALID(m_axi_bvalid),
		.M_AXI_BREADY(m_axi_bready),
        .write_length(write_length),
        .write_base_addr(write_base_addr)
        
	);

	// Add user logic here

	// User logic ends

	endmodule
