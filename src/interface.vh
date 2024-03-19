`define KEEP  (* keep="TRUE" *)
`define DEBUG (* mark_debug = "true" *)


  interface	axi4
  #(
  parameter	ADDR_WIDTH = 32,
  parameter	DATA_WIDTH = 32,
  parameter	ID_WIDTH   = 4
  );
   logic		[ADDR_WIDTH-1:0]ARADDR;
   logic		[1:0]ARBURST;
   logic		[3:0]ARCACHE;
   logic		[ID_WIDTH-1:0]ARID;
   logic		[7:0]ARLEN;
   logic		ARLOCK;
   logic		[2:0]ARPROT;
   logic		[3:0]ARQOS;
   logic		ARREADY;
   logic		[3:0]ARREGION;
   logic		[2:0]ARSIZE;
   logic		ARVALID;
   logic		[ADDR_WIDTH-1:0]AWADDR;
   logic		[1:0]AWBURST;
   logic		[3:0]AWCACHE;
   logic		[ID_WIDTH-1:0]AWID;
   logic		[7:0]AWLEN;
   logic		AWLOCK;
   logic		[2:0]AWPROT;
   logic		[3:0]AWQOS;
   logic		AWREADY;
   logic		[3:0]AWREGION;
   logic		[2:0]AWSIZE;
   logic		AWVALID;
   logic		[ID_WIDTH-1:0]BID;
   logic		BREADY;
   logic		[1:0]BRESP;
   logic		BVALID;
   logic		[DATA_WIDTH-1:0]RDATA;
   logic		[ID_WIDTH-1:0]RID;
   logic		RLAST;
   logic		RREADY;
   logic		[1:0]RRESP;
   logic		RVALID;
   logic		[DATA_WIDTH-1:0]WDATA;
   logic		WLAST;
   logic		WREADY;
   logic		[DATA_WIDTH/8-1:0]WSTRB;
   logic		WVALID;


  //interconnect  -> S_AXI 
  modport		slave
  (
  input			ARADDR,
  input			ARBURST,
  input			ARCACHE,
  input			ARID,
  input			ARLEN,
  input			ARLOCK,
  input			ARPROT,
  input			ARQOS,
  output			ARREADY,
  input			ARREGION,
  input			ARSIZE,
  input			ARVALID,

  input			AWADDR,
  input			AWBURST,
  input			AWCACHE,
  input			AWID,
  input			AWLEN,
  input			AWLOCK,
  input			AWPROT,
  input			AWQOS,
  output			AWREADY,
  input			AWREGION,
  input			AWSIZE,
  input			AWVALID,

  output			BID,
  input			BREADY,
  output			BRESP,
  output			BVALID,
  output			RDATA,
  output			RID,
  output			RLAST,
  input			RREADY,
  output			RRESP,
  output			RVALID,
  input			WDATA,
  input			WLAST,
  output			WREADY,
  input			WSTRB,
  input			WVALID
  );


  //interconnect M_AXI -> connect
  modport		master
  (
  output			ARADDR,
  output			ARBURST,
  output			ARCACHE,
  output			ARID,
  output			ARLEN,
  output			ARLOCK,
  output			ARPROT,
  output			ARQOS,
  input			ARREADY,
  output			ARREGION,
  output			ARSIZE,
  output			ARVALID,

  output			AWADDR,
  output			AWBURST,
  output			AWCACHE,
  output			AWID,
  output			AWLEN,
  output			AWLOCK,
  output			AWPROT,
  output			AWQOS,
  input			AWREADY,
  output			AWREGION,
  output			AWSIZE,
  output			AWVALID,

  input			BID,
  output			BREADY,
  input			BRESP,
  input			BVALID,
  input			RDATA,
  input			RID,
  input			RLAST,
  output			RREADY,
  input			RRESP,
  input			RVALID,
  output			WDATA,
  output			WLAST,
  input			WREADY,
  output			WSTRB,
  output			WVALID
  );

 endinterface


interface stream #(
parameter	DATA_WIDTH = 1
);
 logic [DATA_WIDTH-1:0] tdata;
 logic  tvalid;
 logic  tready;

modport		master
(
    input tready,
    output tvalid,
    output tdata
);

modport		slave
(
    output tready,
    input tvalid,
    input tdata
);


endinterface
