
`timescale 1 ns / 1 ps

	module axi_master_w_single_ctrl #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Base address of targeted slave
		parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 1,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 48,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line

		// Initiate AXI transactions

        input wire  INIT_AXI_WRITE,

		input wire [C_M_AXI_DATA_WIDTH-1:0] DATA_SEND,
		// Asserts when transaction is complete
		output reg  WRITE_DONE,
        // output wire  READ_DONE,
		// Asserts when ERROR is detected
		// output reg  ERROR,
		// Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output wire  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output wire  M_AXI_WLAST,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output wire  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output wire  M_AXI_BREADY,


        input wire [C_M_AXI_DATA_WIDTH -1:0] write_length,

        input wire [C_M_AXI_ADDR_WIDTH -1:0] write_base_addr
	);


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     

	// written data words.


	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	
	
	

	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	// assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	// assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};


	assign M_AXI_WLAST	= wvalid;

	assign M_AXI_WVALID	= wvalid;
	
	assign M_AXI_AWVALID = awvalid;

	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + write_base_addr;

	assign M_AXI_WDATA = DATA_SEND;



	reg Pre_INIT_AXI_WRITE;

	reg wvalid;
	reg awvalid;
	always @(posedge M_AXI_ACLK ) begin
		if(~M_AXI_ARESETN)begin
			wvalid<=0;
		end
		else if(~Pre_INIT_AXI_WRITE & INIT_AXI_WRITE)begin
			wvalid <= 1;	
		end
		else if(M_AXI_WREADY)begin
			wvalid <= 0;
		end
		
	end
	always @(posedge M_AXI_ACLK ) begin
		if(~M_AXI_ARESETN)begin
			awvalid<=0;
		end
		else if(~Pre_INIT_AXI_WRITE & INIT_AXI_WRITE)begin
			awvalid <= 1;	
		end
		else if(M_AXI_AWREADY)begin
			awvalid <= 0;
		end
		
	end

	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//  assign M_AXI_BREADY	= 1;

	always @(posedge M_AXI_ACLK)begin
		if(~M_AXI_ARESETN)begin
			WRITE_DONE<=0;
		end
		else if(INIT_AXI_WRITE)begin
			WRITE_DONE<=0;
		end
		else if(M_AXI_BVALID)begin
			WRITE_DONE<=1;
		end
		else begin
			WRITE_DONE<=WRITE_DONE;
		end
	end

	always @(posedge M_AXI_ACLK)                                     
	begin                                                                 
	if (M_AXI_ARESETN == 0)                                            
	begin                                                             
		axi_bready <= 1'b0; 

	end                                                               
	// accept/acknowledge bresp with axi_bready by the master           
	// when M_AXI_BVALID is asserted by slave                           
	else if (M_AXI_BVALID && ~axi_bready)                               
	begin                                                             
		axi_bready <= 1'b1;                                             
	end                                                               
	// deassert after one clock cycle                                   
	else if (axi_bready)                                                
	begin                                                             
		axi_bready <= 1'b0;
	end                                                               
	// retain the previous value                                        
	else                                                                
		axi_bready <= axi_bready;                                         
	end     
	


	always @(posedge M_AXI_ACLK ) begin
		Pre_INIT_AXI_WRITE <= INIT_AXI_WRITE;
	end



	endmodule
