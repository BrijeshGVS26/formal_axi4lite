`default_nettype none

module axi4lite_fv_top #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32,
    parameter MAX_WAIT   = 4
) (
    input wire aclk,
    input wire aresetn,
    input wire [ADDR_WIDTH-1:0] awaddr,
    input wire awvalid,
    input wire [DATA_WIDTH-1:0] wdata,
    input wire [DATA_WIDTH/8-1:0] wstrb,
    input wire wvalid,
    input wire bready,
    input wire [ADDR_WIDTH-1:0] araddr,
    input wire arvalid,
    input wire rready
);
    wire awready, wready, bvalid, arready, rvalid;
    wire [1:0] bresp, rresp, fv_w_state, fv_r_state;
    wire [DATA_WIDTH-1:0] rdata;
    wire [ADDR_WIDTH-1:0] fv_waddr_q, fv_raddr_q;
    wire [DATA_WIDTH-1:0] fv_mem_at_watch;

    (* anyconst *) reg [ADDR_WIDTH-3:0] f_watch_idx;

    axi4lite_slave #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) dut (
        .aclk(aclk), .aresetn(aresetn),
        .awaddr(awaddr), .awvalid(awvalid), .awready(awready),
        .wdata(wdata), .wstrb(wstrb), .wvalid(wvalid), .wready(wready),
        .bresp(bresp), .bvalid(bvalid), .bready(bready),
        .araddr(araddr), .arvalid(arvalid), .arready(arready),
        .rdata(rdata), .rresp(rresp), .rvalid(rvalid), .rready(rready),
        .fv_w_state(fv_w_state), .fv_r_state(fv_r_state),
        .fv_waddr_q(fv_waddr_q), .fv_raddr_q(fv_raddr_q),
        .fv_watch_idx(f_watch_idx), .fv_mem_at_watch(fv_mem_at_watch)
    );

    initial assume(!aresetn);

    reg f_past_valid = 1'b0;
    always @(posedge aclk) f_past_valid <= 1'b1;

    reg aresetn_d = 1'b0;
    always @(posedge aclk) aresetn_d <= aresetn;
    wire aresetn_rose = aresetn && !aresetn_d;

    always @(posedge aclk)
        if (f_past_valid && $past(aresetn))
            assume(aresetn);

    always @(posedge aclk) begin
        if (f_past_valid && $past(aresetn) && aresetn) begin
            if ($past(awvalid) && !$past(awready)) begin
                assume(awvalid);
                assume(awaddr == $past(awaddr));
            end
            if ($past(wvalid) && !$past(wready)) begin
                assume(wvalid);
                assume(wdata == $past(wdata));
                assume(wstrb == $past(wstrb));
            end
            if ($past(arvalid) && !$past(arready)) begin
                assume(arvalid);
                assume(araddr == $past(araddr));
            end
        end
    end
    always @(*) if (!aresetn) begin
        assume(!awvalid); assume(!wvalid); assume(!arvalid);
    end

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) && $past(bvalid) && !$past(bready))
            a01 : assert(bvalid);

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) && $past(rvalid) && !$past(rready))
            a02 : assert(rvalid);

    always @(posedge aclk)
        if (f_past_valid && !aresetn) a03 : assert(!bvalid);

    always @(posedge aclk)
        if (f_past_valid && !aresetn) a04 : assert(!rvalid);

    always @(posedge aclk)
        if (f_past_valid && $past(aresetn_rose))
            a05 : assert(!bvalid && !rvalid);

    always @(posedge aclk)
        if (aresetn && bvalid) a06 : assert(bresp == 2'b00 || bresp == 2'b10);

    always @(posedge aclk)
        if (aresetn && rvalid) a07 : assert(rresp == 2'b00 || rresp == 2'b10);

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) && $past(bvalid) && $past(bready))
            a08 : assert(!bvalid);

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) && $past(rvalid) && $past(rready))
            a09 : assert(!rvalid);

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) &&
            fv_w_state != 2'b00 && $past(fv_w_state) != 2'b00)
            a10 : assert(!awready);

    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) &&
            fv_r_state != 2'b00 && $past(fv_r_state) != 2'b00)
            a11 : assert(!arready);

    // Bounded-wait (inductive form): whenever the FSM is in its response
    // state, the corresponding response signal must already be valid. This
    // directly implies 1-cycle bounded-wait from wvalid/wready -> bvalid
    // (and arvalid/arready -> rvalid) without an auxiliary counter, and is
    // k-inductive given the FSM state invariant a15.
    always @(posedge aclk) if (aresetn) a12 : assert(fv_w_state != 2'b10 || bvalid);
    // a13: read-response bounded wait. Slave's R_DATA takes one cycle to
    // register rdata before asserting rvalid, so rvalid is guaranteed only
    // after two consecutive cycles in R_DATA. This is directly k-inductive.
    always @(posedge aclk)
        if (f_past_valid && aresetn && $past(aresetn) &&
            fv_r_state == 2'b01 && $past(fv_r_state) == 2'b01)
            a13 : assert(rvalid);

    reg [DATA_WIDTH-1:0] f_watch_data  = {DATA_WIDTH{1'b0}};
    reg                  f_watch_valid = 1'b0;
    // Scoreboard condition matches the slave's mem write condition EXACTLY
    // (fv_w_state == W_DATA && wvalid && wready). In an arbitrary induction
    // start state wready can be high in the wrong FSM state; matching the
    // slave's guard keeps the memory-shadow invariant inductive.
    always @(posedge aclk) begin
        if (!aresetn) begin
            f_watch_valid <= 1'b0;
            f_watch_data  <= {DATA_WIDTH{1'b0}};
        end else if (fv_w_state == 2'b01 && wvalid && wready &&
                     (fv_waddr_q[ADDR_WIDTH-1:2] == f_watch_idx)) begin
            f_watch_data  <= wdata;
            f_watch_valid <= 1'b1;
        end
    end

    reg [DATA_WIDTH-1:0] f_exp_rdata       = {DATA_WIDTH{1'b0}};
    reg                  f_exp_rdata_valid = 1'b0;
    always @(posedge aclk) begin
        if (!aresetn) begin
            f_exp_rdata       <= {DATA_WIDTH{1'b0}};
            f_exp_rdata_valid <= 1'b0;
        end else if (fv_r_state == 2'b01 && !rvalid &&
                     (fv_raddr_q[ADDR_WIDTH-1:2] == f_watch_idx)) begin
            f_exp_rdata       <= f_watch_data;
            f_exp_rdata_valid <= f_watch_valid;
        end
    end

    // Memory-shadow invariant: ties the scoreboard's tracked value to the
    // actual slave memory at f_watch_idx. One-step inductive: writes update
    // both mem and f_watch_data with the same value on the same cycle.
    // This is the key lemma that makes a14 k-inductive.
    always @(posedge aclk)
        if (aresetn && f_watch_valid)
            a14_inv : assert(fv_mem_at_watch == f_watch_data);

    always @(posedge aclk)
        if (aresetn && rvalid && f_exp_rdata_valid &&
            (fv_raddr_q[ADDR_WIDTH-1:2] == f_watch_idx))
            a14 : assert(rdata == f_exp_rdata);

    always @(posedge aclk)
        if (aresetn) a15 : assert(
            (fv_w_state == 2'b00 || fv_w_state == 2'b01 || fv_w_state == 2'b10) &&
            (fv_r_state == 2'b00 || fv_r_state == 2'b01));

    always @(posedge aclk) begin
        if (aresetn) begin
            c_write_completes : cover(bvalid && bready);
            c_read_completes  : cover(rvalid && rready);
            c_both_idle       : cover(!bvalid && !rvalid && (fv_w_state == 2'b00));
        end
    end

endmodule

`default_nettype wire
