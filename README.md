# Pipelined FIR Filter – RTL VLSI Project

## Task
**Task 7: Pipelined FIR Filter**

Design a 4-tap or 8-tap FIR filter using fixed-point arithmetic and investigate the effect of pipeline insertion on maximum clock frequency.

This repository contains a 4-tap implementation.

## Design specification

- Language: Verilog HDL (Verilog-2001 style)
- Tool flow: AMD/Xilinx Vivado
- Filter length: 4 taps
- Data type: signed 16-bit fixed-point samples (Q1.15)
- Coefficients: four signed 16-bit Q1.15 values
- Default coefficients: 8192, 8192, 8192, 8192 (0.25 each)
- Product width: 32 bits (Q2.30)
- Accumulator/output width: 34-bit signed
- Pipeline arithmetic stages: multiplication, pairwise addition, final addition

## FIR equation

`y[n] = h0*x[n] + h1*x[n-1] + h2*x[n-2] + h3*x[n-3]`

The input samples and coefficients are signed Q1.15 values. The products are retained in Q2.30 format. The output is the full-precision sum; it is not shifted or saturated back to 16 bits.

## Repository files

| File | Description |
|---|---|
| `fir_filter.v` | Pipelined 4-tap FIR RTL |
| `fir_filter_tb.v` | Self-checking simulation testbench |
| `fir_filter_unpipelined.v` | Combinational-arithmetic reference architecture |
| `constraints/fir_filter.xdc` | Example clock constraint |
| `timing_comparison.md` | Procedure for comparing timing results |

## Simulate in Vivado

1. Open **Vivado** and select **Create Project**.
2. Give the project a name, for example `Pipelined_FIR_Filter`.
3. Select **RTL Project** and optionally tick **Do not specify sources at this time**.
4. Add `fir_filter.v` as a Design Source.
5. Add `fir_filter_tb.v` as a Simulation Source.
6. If prompted, set `fir_filter_tb` as the simulation top module.
7. Click **Run Simulation → Run Behavioral Simulation**.
8. In the Tcl Console, or in the waveform window, inspect `valid_in`, `sample_in`, `valid_out`, and `data_out`.
9. The testbench prints PASS lines and a final `TEST PASSED` message if the checked outputs match.

The expected valid output is aligned to the three arithmetic register layers. The first input sample is reflected at the output after two rising-edge intervals.

## Synthesis and timing analysis

To investigate the effect of pipeline insertion, create two synthesis runs:
- Pipelined architecture: `fir_filter`
- Reference architecture: `fir_filter_unpipelined`

Use the same FPGA part, synthesis settings, and clock constraint for a fair comparison. In Vivado, run **Run Synthesis**, then **Open Synthesized Design → Report Timing Summary**. Record the worst negative slack, data path delay, and estimated maximum frequency for each architecture.

For a clock period sweep, change the clock period in the XDC or timing constraints and rerun implementation/timing analysis. Use the timing report from the same analysis stage for both designs.

**Important:** Do not enter made-up Fmax values. Record values from your own Vivado timing reports. The two architectures may map differently depending on the selected FPGA and synthesis settings.

## Example coefficient customization

The module parameters `H0` through `H3` can be changed when instantiating `fir_filter`. The defaults are equal coefficients of 0.25 in Q1.15.

## Notes

- Reset is synchronous and active high.
- `valid_in` marks an input sample as valid.
- `valid_out` marks the corresponding filtered output as valid.
- Arithmetic output is 34-bit signed Q3.30-style full-precision accumulation.
- This is a recreated reference implementation for the stated task. Confirm any coefficient, reset, interface, or coding-style requirements specified by your lab instructor before submission.
