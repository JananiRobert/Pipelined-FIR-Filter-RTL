`timescale 1ns / 1ps
// Reference version without arithmetic pipeline registers.
// This module is useful for architectural comparison. It uses the same
// 4-tap fixed-point equation and updates its sample delay line each clock.

module fir_filter_unpipelined #(
    parameter signed [15:0] H0 = 16'sd8192,
    parameter signed [15:0] H1 = 16'sd8192,
    parameter signed [15:0] H2 = 16'sd8192,
    parameter signed [15:0] H3 = 16'sd8192
)(
    input wire clk,
    input wire rst,
    input wire signed [15:0] sample_in,
    output wire signed [33:0] data_out
);
    reg signed [15:0] x1, x2, x3;
    wire signed [31:0] p0, p1, p2, p3;
    wire signed [32:0] s01, s23;

    assign p0 = sample_in * H0;
    assign p1 = x1        * H1;
    assign p2 = x2        * H2;
    assign p3 = x3        * H3;

    assign s01 = $signed({p0[31],p0}) + $signed({p1[31],p1});
    assign s23 = $signed({p2[31],p2}) + $signed({p3[31],p3});
    assign data_out = $signed({s01[32],s01}) +
                      $signed({s23[32],s23});

    always @(posedge clk) begin
        if (rst) begin
            x1 <= 16'sd0;
            x2 <= 16'sd0;
            x3 <= 16'sd0;
        end else begin
            x3 <= x2;
            x2 <= x1;
            x1 <= sample_in;
        end
    end
endmodule
