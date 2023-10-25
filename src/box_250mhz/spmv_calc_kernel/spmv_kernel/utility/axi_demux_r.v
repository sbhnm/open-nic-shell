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
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr,
		output wire [7 : 0] m_axi_arlen,
		output wire [5 : 0] m_axi_arsize,
		output wire [1 : 0] m_axi_arburst,
		output wire  m_axi_arlock,
		output wire [3 : 0] m_axi_arcache,
		output wire [2 : 0] m_axi_arprot,
		output wire [3 : 0] m_axi_arqos,
		output reg  m_axi_arvalid,
		input wire  m_axi_arready,
		input wire [C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid,
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata,
		input wire [1 : 0] m_axi_rresp,
		input wire  m_axi_rlast,
		input wire  m_axi_rvalid,
		output wire  m_axi_rready,

		input wire [C_M_AXI_ID_WIDTH-1 : 0] s_axi_arid,
		input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [7 : 0] s_axi_arlen,
		input wire [2 : 0] s_axi_arsize,
		input wire [1 : 0] s_axi_arburst,
		input wire  s_axi_arlock,
		input wire [3 : 0] s_axi_arcache,
		input wire [2 : 0] s_axi_arprot,
		input wire [3 : 0] s_axi_arqos,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_M_AXI_ID_WIDTH-1 : 0] s_axi_rid,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rlast,
		output reg  s_axi_rvalid,
		input wire  s_axi_rready
        
);
	integer i;
	wire addr_hit;
	assign addr_hit = (s_axi_araddr >= m_axi_read_addr & s_axi_araddr < m_axi_araddr + addr_gap);

	assign m_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m_axi_arid = 0;
	assign m_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m_axi_arburst	= 2'b01;
	assign m_axi_arlock = 1'b0;
	assign m_axi_arcache	= 4'b0010;
	assign m_axi_arprot	= 3'h0;
	assign m_axi_arqos	= 4'h0;


	assign s_axi_arready = 1;
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
			m_axi_read_addr<=0;
			m_axi_arvalid<=0;
		end
		else begin
			if(s_axi_arvalid)begin
				if(addr_hit)begin
					m_axi_read_addr<= m_axi_read_addr;
					m_axi_arvalid<=0;
				end
				else begin
					m_axi_read_addr<= s_axi_araddr & ~{32'h0, addr_gap-1};
					m_axi_arvalid<=1;
				end
			end
			else if(m_axi_arready)begin
				m_axi_arvalid<=0;	
			end
			
		end
	end

	reg [16:0] BurstIndex;
	// reg []
	assign s_axi_rdata = BurstDataBuffer[(Req_addr-m_axi_read_addr) * (C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN)/addr_gap ];
	
	reg [C_S_AXI_DATA_WIDTH-1:0] BurstDataBuffer [(C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH)*(C_M_AXI_BURST_LEN) -1 :0];

	reg [C_M_AXI_ADDR_WIDTH-1:0] Req_addr;

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
		if(s_axi_arvalid)begin
			if(~addr_hit)begin
				BufferValidMap<=0;
			end
		end
		if(m_axi_rready & m_axi_rvalid)begin
			BufferValidMap[BurstIndex]<=1;

			for(i = 0;i< C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH;i=i+1)
				BurstDataBuffer[(C_M_AXI_DATA_WIDTH/C_S_AXI_DATA_WIDTH) * BurstIndex +  i]<=m_axi_rdata[C_S_AXI_DATA_WIDTH * i +: C_S_AXI_DATA_WIDTH];

		end
	end

	reg Req_en;
	always @(posedge clk ) begin
		if(s_axi_arvalid)begin
			Req_addr <= s_axi_araddr;
			Req_en<=1;
			s_axi_rvalid <= 0;
		end
		else if(Req_en)begin
			if(BufferValidMap[(Req_addr-m_axi_read_addr) * C_M_AXI_BURST_LEN / addr_gap])begin
				s_axi_rvalid <= 1;
				Req_en<=0;
			end
			else begin
				s_axi_rvalid <= 0;
			end
		end
		else begin
			s_axi_rvalid <= 0;
		end
	end

endmodule