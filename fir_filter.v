`timescale 1ns / 1ps
// 4-tap pipelined FIR filter
// Input and coefficients are signed Q1.15.
// Each product is Q2.30. The output is a 34-bit signed Q3.30 sum.
//
// Pipeline stages:
//   1. Four multipliers
//   2. Two pairwise additions
//   3. Final addition
//
// With valid_in asserted at a rising edge, valid_out and the matching
// data_out are produced two clock periods later (edge-to-edge latency).

module fir_filter #(
    parameter signed [15:0] H0 = 16'sd8192, // 0.25 in Q1.15
    parameter signed [15:0] H1 = 16'sd8192,
    parameter signed [15:0] H2 = 16'sd8192,
    parameter signed [15:0] H3 = 16'sd8192
)(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    valid_in,
    input  wire signed [15:0]      sample_in,
    output reg                     valid_out,
    output reg signed [33:0]       data_out
);

    // Previous input samples
    reg signed [15:0] x1, x2, x3;

    // Pipeline stage 1: multiplications
    reg signed [31:0] p0, p1, p2, p3;

    // Pipeline stage 2: pairwise sums (33 bits avoid overflow)
    reg signed [32:0] sum01, sum23;

    // Pipeline valid flags
    reg valid_s1, valid_s2;

    always @(posedge clk) begin
        if (rst) begin
            x1       <= 16'sd0;
            x2       <= 16'sd0;
            x3       <= 16'sd0;
            p0       <= 32'sd0;
            p1       <= 32'sd0;
            p2       <= 32'sd0;
            p3       <= 32'sd0;
            sum01    <= 33'sd0;
            sum23    <= 33'sd0;
            data_out <= 34'sd0;
            valid_s1 <= 1'b0;
            valid_s2 <= 1'b0;
            valid_out<= 1'b0;
        end else begin
            // Stage 1: current and delayed samples multiplied by coefficients
            p0 <= sample_in * H0;
            p1 <= x1        * H1;
            p2 <= x2        * H2;
            p3 <= x3        * H3;

            // Update delay line
            x3 <= x2;
            x2 <= x1;
            x1 <= sample_in;

            // Stage 2: pairwise additions
            sum01 <= $signed({p0[31], p0}) + $signed({p1[31], p1});
            sum23 <= $signed({p2[31], p2}) + $signed({p3[31], p3});

            // Stage 3: final addition
            data_out <= $signed({sum01[32], sum01}) +
                        $signed({sum23[32], sum23});

            // Valid pipeline aligned with the data pipeline
            valid_s1 <= valid_in;
            valid_s2 <= valid_s1;
            valid_out <= valid_s2;
        end
    end
endmodule
