`default_nettype none

module axi4lite_slave #(
    parameter ADDR_WIDTH = 5,
    parameter DATA_WIDTH = 32
) (
    input  wire                         aclk,
    input  wire                         aresetn,

    input  wire [ADDR_WIDTH-1:0]        awaddr,
    input  wire                         awvalid,
    output reg                          awready = 1'b0,

    input  wire [DATA_WIDTH-1:0]        wdata,
    input  wire [DATA_WIDTH/8-1:0]      wstrb,
    input  wire                         wvalid,
    output reg                          wready  = 1'b0,

    output reg  [1:0]                   bresp   = 2'b00,
    output reg                          bvalid  = 1'b0,
    input  wire                         bready,

    input  wire [ADDR_WIDTH-1:0]        araddr,
    input  wire                         arvalid,
    output reg                          arready = 1'b0,

    output reg  [DATA_WIDTH-1:0]        rdata   = {DATA_WIDTH{1'b0}},
    output reg  [1:0]                   rresp   = 2'b00,
    output reg                          rvalid  = 1'b0,
    input  wire                         rready,

    // FV observation ports
    output wire [1:0]                   fv_w_state,
    output wire [1:0]                   fv_r_state,
    output wire [ADDR_WIDTH-1:0]        fv_waddr_q,
    output wire [ADDR_WIDTH-1:0]        fv_raddr_q,
    input  wire [ADDR_WIDTH-3:0]        fv_watch_idx,
    output wire [DATA_WIDTH-1:0]        fv_mem_at_watch
);

    localparam W_IDLE = 2'b00, W_DATA = 2'b01, W_RESP = 2'b10;
    localparam R_IDLE = 2'b00, R_DATA = 2'b01;

    reg [1:0]            w_state = W_IDLE;
    reg [1:0]            r_state = R_IDLE;
    reg [ADDR_WIDTH-1:0] waddr_q = {ADDR_WIDTH{1'b0}};
    reg [ADDR_WIDTH-1:0] raddr_q = {ADDR_WIDTH{1'b0}};

    assign fv_w_state = w_state;
    assign fv_r_state = r_state;
    assign fv_waddr_q = waddr_q;
    assign fv_raddr_q = raddr_q;
    assign fv_mem_at_watch = mem[fv_watch_idx];

    localparam MEM_DEPTH = (1 << (ADDR_WIDTH-2));
    reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
    integer i;
    initial for (i = 0; i < MEM_DEPTH; i = i + 1) mem[i] = {DATA_WIDTH{1'b0}};

    // Write FSM
    always @(posedge aclk) begin
        if (!aresetn) begin
            w_state <= W_IDLE;
            awready <= 1'b0;
            wready  <= 1'b0;
            bvalid  <= 1'b0;
            bresp   <= 2'b00;
            waddr_q <= {ADDR_WIDTH{1'b0}};
        end else begin
            case (w_state)
                W_IDLE: begin
                    bvalid <= 1'b0;
                    if (awvalid) begin
                        awready <= 1'b1;
                        waddr_q <= awaddr;
                        wready  <= 1'b1;
                        w_state <= W_DATA;
                    end else begin
                        awready <= 1'b0;
                        wready  <= 1'b0;
                    end
                end
                W_DATA: begin
                    awready <= 1'b0;
                    if (wvalid && wready) begin
                        mem[waddr_q[ADDR_WIDTH-1:2]] <= wdata;
                        wready  <= 1'b0;
                        bvalid  <= 1'b1;
                        bresp   <= 2'b00;
                        w_state <= W_RESP;
                    end
                end
                W_RESP: begin
                    if (bvalid && bready) begin
                        bvalid  <= 1'b0;
                        w_state <= W_IDLE;
                    end
                end
                default: w_state <= W_IDLE;
            endcase
        end
    end

    // Read FSM
    always @(posedge aclk) begin
        if (!aresetn) begin
            r_state <= R_IDLE;
            arready <= 1'b0;
            rvalid  <= 1'b0;
            rresp   <= 2'b00;
            rdata   <= {DATA_WIDTH{1'b0}};
            raddr_q <= {ADDR_WIDTH{1'b0}};
        end else begin
            case (r_state)
                R_IDLE: begin
                    rvalid <= 1'b0;
                    if (arvalid) begin
                        arready <= 1'b1;
                        raddr_q <= araddr;
                        r_state <= R_DATA;
                    end else begin
                        arready <= 1'b0;
                    end
                end
                R_DATA: begin
                    arready <= 1'b0;
                    if (!rvalid) begin
                        rdata  <= mem[raddr_q[ADDR_WIDTH-1:2]];
                        rresp  <= 2'b00;
                        rvalid <= 1'b1;
                    end else if (rvalid && rready) begin
                        rvalid  <= 1'b0;
                        r_state <= R_IDLE;
                    end
                end
                default: r_state <= R_IDLE;
            endcase
        end
    end

endmodule

`default_nettype wire
