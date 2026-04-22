# Bug caught by formal: BVALID drops before BREADY

This is the one bug I left in `rtl/axi4lite_slave_buggy.sv` on purpose
so sby would have something to fail on. The failing property is `a01`
in `fv/axi4lite_fv_top.sv`, which encodes the AXI VALID-stability
rule:

```systemverilog
always @(posedge aclk)
    if (f_past_valid && aresetn && $past(aresetn) && $past(bvalid) && !$past(bready))
        a01 : assert(bvalid);
```

sby reports:

```
summary: counterexample trace: fv/prove_buggy_bmc/engine_0/trace.vcd
summary:   failed assertion axi4lite_fv_top.a01 at axi4lite_fv_top.sv:76 step 5
DONE (FAIL, rc=2)
```

Solver time was well under a second.

## The bug

AXI4 / AXI4-Lite says that once a `VALID` goes high it has to stay
high until the matching `READY` is sampled high on the same clock
edge. The common beginner mistake is to drop `BVALID` the cycle the
FSM enters `W_RESP`, or to drop it based on an internal "I'm done"
flag instead of the actual `BVALID && BREADY` handshake. That's what
this buggy version does:

```systemverilog
W_RESP: begin
    bvalid  <= 1'b0;        // drops regardless of BREADY
    awready <= 1'b1;
    w_state <= W_IDLE;
end
```

In simulation this is easy to miss, because if BREADY is usually high
in the same cycle BVALID rises, the handshake completes immediately
and the bug is invisible. Formal, on the other hand, will try the
exact pathological case -- BREADY held low for one cycle after BVALID
goes high -- and that's the stimulus that exposes the violation.

## The counterexample

sby returns a 5-step trace
(`fv/prove_buggy_bmc/engine_0/trace.vcd`). The essential sequence:

| Step | aresetn | w_state | awvalid | awready | wvalid | wready | bvalid | bready |
|------|---------|---------|---------|---------|--------|--------|--------|--------|
| 0    | 0       | W_IDLE  | 0       | 0       | 0      | 0      | 0      | 0      |
| 1    | 1       | W_IDLE  | 1       | 0       | 0      | 0      | 0      | 0      |
| 2    | 1       | W_IDLE  | 1       | 1       | 0      | 0      | 0      | 0      |
| 3    | 1       | W_DATA  | 0       | 0       | 1      | 1      | 0      | 0      |
| 4    | 1       | W_RESP  | 0       | 0       | 0      | 0      | **1**  | **0**  |
| 5    | 1       | W_IDLE  | 0       | 0       | 0      | 0      | **0**  | 0      |

At step 4 the slave raises `BVALID`, but `BREADY` is still low. At
step 5 the slave drops `BVALID` anyway -- that's the violation. A
compliant master that only raises `BREADY` on step 6 would miss the
response entirely, which is the actual functional impact.

I opened the VCD in Surfer and the `bvalid` trace makes the bug really
obvious -- it's the only signal that goes high for exactly one cycle
and then drops without a matching `bready` pulse.

## Fix

Guard the drop on the actual handshake -- the golden version is:

```systemverilog
W_RESP: begin
    if (bvalid && bready) begin
        bvalid  <= 1'b0;
        awready <= 1'b1;
        w_state <= W_IDLE;
    end
end
```

Running `sby -f fv/prove.sby` against this version closes `a01` along
with the other 14 properties at BMC depth 20.

## Notes for myself

- The counterexample is only 5 steps long, so this is well within
  anything BMC can see. That also means it's the kind of thing a
  directed test *could* have caught if I'd thought to specifically
  stress the BREADY-delayed case. Formal just doesn't need me to have
  thought of it.
- The assertion uses `$past(bvalid) && !$past(bready) |-> bvalid` as
  the stability check. The first time I wrote this I forgot the
  `f_past_valid` guard and got a spurious fail in cycle 0.
- `sby` printed the exact source location
  (`axi4lite_fv_top.sv:76.13-76.33 step 5`) which made it easy to tie
  the failure back to the assertion in the harness.
