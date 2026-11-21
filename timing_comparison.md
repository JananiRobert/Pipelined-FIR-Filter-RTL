# Timing comparison record

Use the same FPGA part, Vivado version, synthesis settings, and timing-analysis stage for both architectures.

| Metric | Pipelined FIR | Unpipelined reference |
|---|---:|---:|
| FPGA part | Fill from Vivado | Same part |
| Clock period constraint (ns) | Fill in | Same constraint |
| Worst path delay (ns) | Fill from report | Fill from report |
| WNS (ns) | Fill from report | Fill from report |
| Estimated Fmax (MHz) | Fill from report | Fill from report |
| LUT count | Fill from report | Fill from report |
| Register count | Fill from report | Fill from report |
| DSP count | Fill from report | Fill from report |

## How to estimate Fmax

If the reported critical-path delay is `Tcritical` ns, a rough timing-based estimate is:

`Fmax (MHz) = 1000 / Tcritical (ns)`

Prefer the frequency/timing values reported by Vivado for the chosen implementation stage. Clearly state whether the result is post-synthesis or post-implementation.

## Discussion prompts

1. Did the pipelined version reduce the longest combinational path?
2. How many additional registers were used?
3. Did the design use DSP blocks for multiplication?
4. What latency was introduced by the pipeline?
5. Did the measured maximum frequency improve for the selected FPGA?

Do not fill this table with assumed values. Add your actual Vivado report results.
