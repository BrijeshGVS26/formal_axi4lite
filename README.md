# Formal verification of an AXI4-Lite slave

Portfolio project. I wanted to actually try formal property
verification (not just read about it), so I wrote a tiny AXI4-Lite
slave and checked 15 SystemVerilog assertions on it using SymbiYosys
and Z3. Then I dropped one bug into a copy of the slave to see what
catching a real violation looks like.

Free tools, runs on a Mac. No EDA licence.

## What's in this repo

```
formal_axi4lite/
  rtl/
    axi4lite_slave.sv         # the golden slave
    axi4lite_slave_buggy.sv   # same slave, one bug injected on purpose
  fv/
    axi4lite_fv_top.sv        # formal top: assumes + 15 assertions + scoreboard
    prove.sby                 # sby config for the golden design
    prove_buggy.sby           # sby config for the buggy design
  docs/
    bugs_found.md             # walkthrough of the injected bug + its trace
    interview_prep.md         # Q&A I expect in a formal interview
    buggy_trace.png           # Surfer screenshot of the counterexample
  README.md
```

## Tools

- Yosys -- elaborates the SystemVerilog
- SymbiYosys (sby) -- front-end driver
- Z3 -- SMT backend that actually does the proving

All three install with Homebrew. On Apple Silicon some of them can be
annoying; the pre-built OSS CAD Suite tarball from the YosysHQ GitHub
releases page worked fine as a fallback.

Viewing VCDs on modern macOS was the most annoying part. The Homebrew
GTKWave cask ships a 32-bit binary macOS 14+ refuses to launch, and
the Perl wrapper it uses needs `Switch.pm` which isn't in core Perl
anymore (had to `sudo cpan -i Switch` and accept a bunch of config
defaults). Even after that the `gtkwave-bin` still wouldn't start
because of the macOS version check. I gave up and switched to Surfer
(`brew install surfer`) which just worked on the first try.

## How to run

```bash
# golden design -- 15/15 should pass
sby -f fv/prove.sby

# buggy design -- should fail on a01
sby -f fv/prove_buggy.sby
```

sby makes a workdir next to the .sby file. Counterexample traces land
at `fv/<taskdir>/engine_0/trace.vcd`.

## What got proven

Golden, `bmc: depth 20`:

```
[bmc] DONE (PASS, rc=0)   -- 15/15 assertions hold, ~28 s
[cvr] DONE (PASS, rc=0)   -- 3/3 cover points reached (steps 2, 4, 4)
```

Buggy, `bmc: depth 12`:

```
[bmc] DONE (FAIL, rc=2)  -- a01 (BVALID stability) violated at step 5
```

The injected bug drops `BVALID` in W_RESP without waiting for `BREADY`.
AXI4-Lite requires VALID to stay high until READY, so this is a direct
protocol violation. Solver found it in under a second.

The 15 assertions cover:

- VALID/READY stability (VALID must stay high until its READY)
- reset behaviour (BVALID/RVALID low during reset, no spurious pulses on reset-release)
- legal BRESP/RRESP encodings
- bounded-wait latency -- if the FSM is in its response state, the response signal has to already be valid
- read-after-write data integrity: an `anyconst` watch address + a
  scoreboard that mirrors `wdata`, compared against `rdata` when that
  address is read back

## Things I got stuck on

I didn't really understand k-induction properly when I started. My
first version of the bounded-wait property used an auxiliary counter
that incremented while waiting for the handshake to complete, and I
couldn't figure out why it kept failing induction. Took me a while
(and some reading) to realise that in an arbitrary start state the
counter could be anything, so of course the property wasn't inductive.
Replaced it with an FSM-state invariant:

```
assert (fv_w_state == W_RESP |-> bvalid)
```

which is directly k-inductive once you also assert `fv_w_state` is
always one of its three legal encodings. Same idea fixed the read-side
bounded wait, though that one needed two consecutive cycles in R_DATA
because the slave's read FSM registers `rdata` for one extra cycle
before raising `rvalid` -- I missed that on the first pass and the
assertion failed at base case step 3 until I added the `$past` guard.

Data integrity was worse. I spent a while trying to close `a14_inv`
under k-induction but kept running into the fact that `mem[]` is
unconstrained in the arbitrary start state -- the prover could start
with the scoreboard tracking one value and the memory holding
something completely different. I tried:

- Exposing `mem[f_watch_idx]` as a new output `fv_mem_at_watch` on the
  slave and adding a memory-shadow invariant
  `fv_mem_at_watch == f_watch_data`.
- Tightening the scoreboard write to match the slave's *exact* write
  condition (`fv_w_state == W_DATA && wvalid && wready`) so an arbitrary
  state where `wready` happens to be high outside W_DATA doesn't
  desync them.

That got me a lot closer but I couldn't fully close `a14_inv` in the
time I wanted to spend. Rather than leave a broken claim in the README
I dropped the `prf` task and kept BMC to depth 20. The assertions hold
for every 20-cycle prefix, which is still a real result -- it's just
not the "proof over all time" that k-induction gives you. This is
something I'd come back to.

One smaller thing that confused me for a bit: sby's `[script]` section
doesn't support the same task-name prefix (`prf: ...`) that `[options]`
does. I tried `prf: read -formal ...` expecting it to only run for the
prf task and got `ERROR: No such command: prf` from yosys. Took me a
minute to realise the prefix filter only works in some sections, not
all.

## What I'd do next

- Actually close k-induction on the data-integrity lemma. Probably
  needs a stronger whole-memory invariant, or abstracting `mem[]` with
  an `anyseq` at reset.
- Cover back-to-back transactions and interleaved read/write.
- Try the same flow on a bigger AXI4 slave with bursts.

