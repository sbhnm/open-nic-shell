//这个模块可以将连续但是分立的axi请求聚合成猝发的axi请求
module axi_demux_r #(
    parameter integer C_M_AXI_BURST_LEN	= 16,
    parameter integer C_M_AXI_ID_WIDTH	= 1,
    parameter integer C_M_AXI_ADDR_WIDTH	= 48,
    parameter integer C_S_AXI_DATA_WIDTH	= 32,
	parameter integer C_M_AXI_DATA_WIDTH	= 256

) (
        input wire  clk,
		input wire  rstn,

		output wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_arid,
		(*mark_debug = "true"*)
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
		output wire [7 : 0] m_axi_arlen,
		output wire [5 : 0] m_axi_arsize,
		output wire [1 : 0] m_axi_arburst,
		output wire  m_axi_arlock,
		output wire [3 : 0] m_axi_arcache,
		output wire [2 : 0] m_axi_arprot,
		output wire [3 : 0] m_axi_arqos,
		(*mark_debug = "true"*)
		output reg  m_axi_arvalid,
		(*mark_debug = "true"*)
		input wire  m_axi_arready,
		input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid,
		(*mark_debug = "true"*)
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
		input wire [1 : 0] m_axi_rresp,
		(*mark_debug = "true"*)
		input wire  m_axi_rlast,
		(*mark_debug = "true"*)
		input wire  m_axi_rvalid,
		(*mark_debug = "true"*)
		output wire  m_axi_rready,

		input wire [C_M_AXI_ID_WIDTH-1 : 0] s_axi_arid,
		(*mark_debug = "true"*)
		input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [7 : 0] s_axi_arlen,
		input wire [2 : 0] s_axi_arsize,
		input wire [1 : 0] s_axi_arburst,
		input wire  s_axi_arlock,
		input wire [3 : 0] s_axi_arcache,
		input wire [2 : 0] s_axi_arprot,
		input wire [3 : 0] s_axi_arqos,
		(*mark_debug = "true"*)
		input wire  s_axi_arvalid,
		(*mark_debug = "true"*)
		output wire  s_axi_arready,
		output wire [C_M_AXI_ID_WIDTH-1 : 0] s_axi_rid,
		(*mark_debug = "true"*)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rlast,
		(*mark_debug = "true"*)
		output wire  s_axi_rvalid,
		(*mark_debug = "true"*)
		input wire  s_axi_rready
        
);
	integer i;
	wire addr_hit;
	assign addr_hit = (Req_addr >= m_axi_read_addr & Req_addr < m_axi_araddr + addr_gap);

	assign m_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m_axi_arid = 0;
	assign m_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m_axi_arburst	= 2'b01;
	assign m_axi_arlock = 1'b0;
	assign m_axi_arcache	= 4'b0010;
	assign m_axi_arprot	= 3'h0;
	assign m_axi_arqos	= 4'h0;


	// assign s_axi_arready = addr_hit;
	assign s_axi_rid = 0;
	assign s_axi_rresp = 0;
	assign s_axi_rlast = s_axi_rvalid;
    reg [C_M_AXI_ADDR_WIDTH-1:0] m_axi_read_addr;
	assign m_axi_araddr = m_axi_read_addr;
	function integer clogb2 (input integer bit_depth);              
  	begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end                                                           
  	endfunction   
	integer addr_gap = C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8;

	//AR请求产生逻辑
	always @(posedge clk ) begin
		if(~rstn)begin
			m_axi_read_addr<=48'h9877654321;
			m_axi_arvalid<=0;
		end
		else if(m_axi_arready & m_axi_arvalid)begin
				m_axi_arvalid<=0;	
		end
		else begin
			if(s_axi_arvalid)begin
				if(addr_hit)begin
					m_axi_read_addr<= m_axi_read_addr;
					// m_axi_arvalid<=0;
				end
				else begin
					m_axi_read_addr<= s_axi_araddr & ~{32'h0, addr_gap-1};
					m_axi_arvalid<=1;
				end
			end
			
			
		end
	end


	

	reg [16:0] BurstIndex;
	// reg []
	
	reg [C_S_AXI_DATA_WIDTH-1:0] BurstDataBuffer [(C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN) -1 :0];

	wire [C_M_AXI_ADDR_WIDTH-1:0] Req_addr;

	// reg Rea_en;

	reg [(C_M_AXI_BURST_LEN) -1:0] BufferValidMap;

	assign m_axi_rready = 1;
	//RDATA Valid,索引控制逻辑
	always @(posedge clk ) begin
		if(~rstn)begin
			BurstIndex<=0;
		end
		else begin
			if(m_axi_rready & m_axi_rvalid & ~m_axi_rlast)begin
				BurstIndex <= BurstIndex + 1;
			end
			else if(m_axi_rready & m_axi_rvalid & m_axi_rlast)begin
				BurstIndex <= 0;
			end
		end
	end
	//维护Buffer
	always @(posedge clk ) begin
		if(~rstn)begin
			BufferValidMap<=0;
			// s_axi_arready <=1;
		end
		else begin
			if(s_axi_arvalid & s_axi_arready)begin
				if(~addr_hit)begin
					BufferValidMap<=0;
					// s_axi_arready <=0;
				end
			end
			if(m_axi_rready & m_axi_rvalid)begin
				BufferValidMap[BurstIndex]<=1;
				// s_axi_arready <=1;
				for(i = 0;i< C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH;i=i+1)
					BurstDataBuffer[(C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH) * BurstIndex +  i]<=m_axi_rdata[C_S_AXI_DATA_WIDTH * i +: C_S_AXI_DATA_WIDTH];
			end
		end
	end

	// reg Req_en;
	(*mark_debug = "true"*)
	wire Fifo_ar_full;
	(*mark_debug = "true"*)
	wire Fifo_ar_empty;
	Fifo #(
		.DATA_WIDTH(48)
	) Fifo_ar
	(
		.clk(clk),
		.rst(~rstn),
		.data_in(s_axi_araddr),
		.data_out(Req_addr),
		.rd_en(s_axi_rvalid & s_axi_rready),
		.wr_en(s_axi_arvalid & s_axi_arready),
		.empty(Fifo_ar_empty),
		.full(Fifo_ar_full)
	);
	assign s_axi_arready = ~Fifo_ar_full;
	// assign s_axi_arready = 1;
	assign s_axi_rvalid = ~Fifo_ar_empty & 
		addr_hit & 
		BufferValidMap[(Req_addr-m_axi_read_addr) * C_M_AXI_BURST_LEN / addr_gap] &
		s_axi_rready;
	assign s_axi_rdata = BurstDataBuffer[(Req_addr-m_axi_read_addr) * (C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN)/addr_gap ];


	// always @(posedge clk ) begin
	// 	if((Req_addr >= m_axi_read_addr & Req_addr < m_axi_araddr + addr_gap))begin
	// 		if(BufferValidMap[(Req_addr-m_axi_read_addr) * C_M_AXI_BURST_LEN / addr_gap])begin
	// 			if(s_axi_rready)begin
	// 				s_axi_rvalid <= 1;
	// 				// Req_en<=0;
	// 				s_axi_rdata <= 
	// 			end
	// 		end
	// 		else begin
	// 			s_axi_rvalid <= 0;
	// 		end
	// 	end
	// 	else begin
	// 		s_axi_rvalid <= 0;
	// 	end
	// end

endmodule