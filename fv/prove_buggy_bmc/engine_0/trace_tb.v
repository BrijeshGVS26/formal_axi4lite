`ifndef VERILATOR
module testbench;
  reg [4095:0] vcdfile;
  reg clock;
`else
module testbench(input clock, output reg genclock);
  initial genclock = 1;
`endif
  reg genclock = 1;
  reg [31:0] cycle = 0;
  reg [0:0] PI_wvalid;
  reg [4:0] PI_araddr;
  reg [0:0] PI_arvalid;
  reg [0:0] PI_rready;
  reg [0:0] PI_aresetn;
  reg [0:0] PI_bready;
  reg [0:0] PI_awvalid;
  reg [0:0] PI_aclk;
  reg [4:0] PI_awaddr;
  reg [3:0] PI_wstrb;
  reg [31:0] PI_wdata;
  axi4lite_fv_top UUT (
    .wvalid(PI_wvalid),
    .araddr(PI_araddr),
    .arvalid(PI_arvalid),
    .rready(PI_rready),
    .aresetn(PI_aresetn),
    .bready(PI_bready),
    .awvalid(PI_awvalid),
    .aclk(PI_aclk),
    .awaddr(PI_awaddr),
    .wstrb(PI_wstrb),
    .wdata(PI_wdata)
  );
`ifndef VERILATOR
  initial begin
    if ($value$plusargs("vcd=%s", vcdfile)) begin
      $dumpfile(vcdfile);
      $dumpvars(0, testbench);
    end
    #5 clock = 0;
    while (genclock) begin
      #5 clock = 0;
      #5 clock = 1;
    end
  end
`endif
  initial begin
`ifndef VERILATOR
    #1;
`endif
    // UUT.$auto$async2sync.\cc:107:execute$679  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$685  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$691  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$703  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$709  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$715  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$721  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$727  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$733  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$739  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$745  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$751  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$757  = 1'b0;
    // UUT.$auto$async2sync.\cc:107:execute$763  = 1'b0;
    // UUT.$auto$async2sync.\cc:116:execute$683  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$695  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$707  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$713  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$719  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$731  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$737  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$743  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$749  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$755  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$761  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$767  = 1'b1;
    // UUT.$auto$async2sync.\cc:116:execute$773  = 1'b1;
    UUT._witness_.anyinit_procdff_591 = 1'b1;
    UUT._witness_.anyinit_procdff_592 = 2'b00;
    UUT._witness_.anyinit_procdff_593 = 1'b1;
    UUT._witness_.anyinit_procdff_594 = 2'b00;
    UUT._witness_.anyinit_procdff_595 = 1'b1;
    UUT._witness_.anyinit_procdff_596 = 2'b00;
    UUT._witness_.anyinit_procdff_597 = 1'b1;
    UUT._witness_.anyinit_procdff_598 = 1'b0;
    UUT._witness_.anyinit_procdff_599 = 1'b0;
    UUT._witness_.anyinit_procdff_600 = 1'b1;
    UUT._witness_.anyinit_procdff_601 = 1'b0;
    UUT._witness_.anyinit_procdff_602 = 1'b0;
    UUT._witness_.anyinit_procdff_603 = 1'b0;
    UUT._witness_.anyinit_procdff_604 = 1'b1;
    UUT._witness_.anyinit_procdff_605 = 1'b0;
    UUT._witness_.anyinit_procdff_606 = 1'b0;
    UUT._witness_.anyinit_procdff_607 = 1'b1;
    UUT._witness_.anyinit_procdff_608 = 1'b0;
    UUT._witness_.anyinit_procdff_609 = 1'b0;
    UUT._witness_.anyinit_procdff_610 = 1'b1;
    UUT._witness_.anyinit_procdff_611 = 1'b0;
    UUT._witness_.anyinit_procdff_612 = 1'b0;
    UUT._witness_.anyinit_procdff_613 = 5'b00001;
    UUT._witness_.anyinit_procdff_614 = 1'b0;
    UUT._witness_.anyinit_procdff_615 = 1'b0;
    UUT._witness_.anyinit_procdff_616 = 32'b00000000000000000000000000000000;
    UUT._witness_.anyinit_procdff_617 = 4'b0000;
    UUT._witness_.anyinit_procdff_618 = 1'b0;
    UUT._witness_.anyinit_procdff_619 = 1'b0;
    UUT._witness_.anyinit_procdff_620 = 5'b00001;
    UUT._witness_.anyinit_procdff_621 = 1'b1;
    UUT.aresetn_d = 1'b0;
    UUT.dut.arready = 1'b0;
    UUT.dut.awready = 1'b0;
    UUT.dut.bresp = 2'b00;
    UUT.dut.bvalid = 1'b0;
    UUT.dut.r_state = 2'b00;
    UUT.dut.raddr_q = 5'b00000;
    UUT.dut.rdata = 32'b00000000000000000000000000000000;
    UUT.dut.rresp = 2'b00;
    UUT.dut.rvalid = 1'b0;
    UUT.dut.w_state = 2'b00;
    UUT.dut.waddr_q = 5'b00000;
    UUT.dut.wready = 1'b0;
    UUT.f_exp_rdata = 32'b00000000000000000000000000000000;
    UUT.f_exp_rdata_valid = 1'b0;
    UUT.f_past_valid = 1'b0;
    UUT.f_watch_data = 32'b00000000000000000000000000000000;
    UUT.f_watch_valid = 1'b0;
    UUT.f_watch_idx = 3'b000;
    UUT.dut.mem[3'b000] = 32'b00000000000000000000000000000000;

    // state 0
    PI_wvalid = 1'b0;
    PI_araddr = 5'b00000;
    PI_arvalid = 1'b0;
    PI_rready = 1'b0;
    PI_aresetn = 1'b0;
    PI_bready = 1'b0;
    PI_awvalid = 1'b0;
    PI_aclk = 1'b0;
    PI_awaddr = 5'b00000;
    PI_wstrb = 4'b0000;
    PI_wdata = 32'b00000000000000000000000000000000;
  end
  always @(posedge clock) begin
    // state 1
    if (cycle == 0) begin
      PI_wvalid <= 1'b0;
      PI_araddr <= 5'b10000;
      PI_arvalid <= 1'b0;
      PI_rready <= 1'b1;
      PI_aresetn <= 1'b1;
      PI_bready <= 1'b0;
      PI_awvalid <= 1'b1;
      PI_aclk <= 1'b0;
      PI_awaddr <= 5'b00001;
      PI_wstrb <= 4'b0000;
      PI_wdata <= 32'b00000000000000000000000000000000;
    end

    // state 2
    if (cycle == 1) begin
      PI_wvalid <= 1'b1;
      PI_araddr <= 5'b00001;
      PI_arvalid <= 1'b0;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_bready <= 1'b0;
      PI_awvalid <= 1'b1;
      PI_aclk <= 1'b0;
      PI_awaddr <= 5'b00001;
      PI_wstrb <= 4'b0000;
      PI_wdata <= 32'b00001100000000000000000001000010;
    end

    // state 3
    if (cycle == 2) begin
      PI_wvalid <= 1'b0;
      PI_araddr <= 5'b00001;
      PI_arvalid <= 1'b0;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_bready <= 1'b0;
      PI_awvalid <= 1'b0;
      PI_aclk <= 1'b0;
      PI_awaddr <= 5'b00000;
      PI_wstrb <= 4'b0000;
      PI_wdata <= 32'b00001100000000000000000001000010;
    end

    // state 4
    if (cycle == 3) begin
      PI_wvalid <= 1'b0;
      PI_araddr <= 5'b00001;
      PI_arvalid <= 1'b1;
      PI_rready <= 1'b1;
      PI_aresetn <= 1'b1;
      PI_bready <= 1'b0;
      PI_awvalid <= 1'b0;
      PI_aclk <= 1'b0;
      PI_awaddr <= 5'b01000;
      PI_wstrb <= 4'b0000;
      PI_wdata <= 32'b00000000000000000000000000001000;
    end

    // state 5
    if (cycle == 4) begin
      PI_wvalid <= 1'b0;
      PI_araddr <= 5'b00001;
      PI_arvalid <= 1'b1;
      PI_rready <= 1'b0;
      PI_aresetn <= 1'b1;
      PI_bready <= 1'b0;
      PI_awvalid <= 1'b0;
      PI_aclk <= 1'b0;
      PI_awaddr <= 5'b00000;
      PI_wstrb <= 4'b0100;
      PI_wdata <= 32'b00000000000000000000000000000000;
    end

    genclock <= cycle < 5;
    cycle <= cycle + 1;
  end
endmodule
