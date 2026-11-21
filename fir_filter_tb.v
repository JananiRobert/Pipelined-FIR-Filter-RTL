`timescale 1ns / 1ps

module fir_filter_tb;

    reg clk;
    reg rst;
    reg valid_in;
    reg signed [15:0] sample_in;

    wire valid_out;
    wire signed [33:0] data_out;

    // Match the DUT's default coefficients: 0.25, 0.25, 0.25, 0.25
    fir_filter dut (
        .clk(clk),
        .rst(rst),
        .valid_in(valid_in),
        .sample_in(sample_in),
        .valid_out(valid_out),
        .data_out(data_out)
    );

    // 10 ns clock period
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Reference-model history and expected pipeline
    reg signed [15:0] hist1, hist2, hist3;
    reg signed [33:0] expected_s1, expected_s2, expected_out;
    reg expected_valid_s1, expected_valid_s2, expected_valid_out;

    reg signed [31:0] m0, m1, m2, m3;
    integer errors;
    integer checks;

    // Compute reference result for the sample presented at this clock edge.
    // The expected result is delayed through two registers to match the DUT.
    always @(posedge clk) begin
        if (rst) begin
            hist1 <= 16'sd0;
            hist2 <= 16'sd0;
            hist3 <= 16'sd0;
            expected_s1 <= 34'sd0;
            expected_s2 <= 34'sd0;
            expected_out <= 34'sd0;
            expected_valid_s1 <= 1'b0;
            expected_valid_s2 <= 1'b0;
            expected_valid_out <= 1'b0;
        end else begin
            m0 = sample_in * 16'sd8192;
            m1 = hist1     * 16'sd8192;
            m2 = hist2     * 16'sd8192;
            m3 = hist3     * 16'sd8192;

            expected_s1 <=
                $signed({{2{m0[31]}},m0}) +
                $signed({{2{m1[31]}},m1}) +
                $signed({{2{m2[31]}},m2}) +
                $signed({{2{m3[31]}},m3});

            expected_s2 <= expected_s1;
            expected_out <= expected_s2;

            expected_valid_s1 <= valid_in;
            expected_valid_s2 <= expected_valid_s1;
            expected_valid_out <= expected_valid_s2;

            hist3 <= hist2;
            hist2 <= hist1;
            hist1 <= sample_in;

            // Wait for nonblocking assignments in the DUT and reference model.
            #1;
            if (valid_out !== expected_valid_out) begin
                $display("ERROR: valid mismatch at time %0t", $time);
                errors = errors + 1;
            end

            if (valid_out && (data_out !== expected_out)) begin
                $display("ERROR: data mismatch at time %0t: DUT=%0d EXPECTED=%0d",
                         $time, data_out, expected_out);
                errors = errors + 1;
            end

            if (valid_out) begin
                checks = checks + 1;
                $display("PASS: time=%0t output=%0d", $time, data_out);
            end
        end
    end

    // Drive input on falling edges to avoid race conditions with the DUT.
    task apply_sample;
        input signed [15:0] value;
        input              is_valid;
        begin
            @(negedge clk);
            sample_in = value;
            valid_in = is_valid;
        end
    endtask

    initial begin
        rst = 1'b1;
        valid_in = 1'b0;
        sample_in = 16'sd0;
        hist1 = 0; hist2 = 0; hist3 = 0;
        expected_s1 = 0; expected_s2 = 0; expected_out = 0;
        expected_valid_s1 = 0; expected_valid_s2 = 0;
        expected_valid_out = 0;
        errors = 0;
        checks = 0;

        repeat (3) @(negedge clk);
        rst = 1'b0;

        // A short sequence of positive, negative and zero samples
        apply_sample(16'sd1000, 1'b1);
        apply_sample(16'sd2000, 1'b1);
        apply_sample(-16'sd1000, 1'b1);
        apply_sample(16'sd500, 1'b1);
        apply_sample(16'sd0, 1'b1);
        apply_sample(-16'sd500, 1'b1);
        apply_sample(16'sd2500, 1'b1);
        apply_sample(16'sd0, 1'b0);
        apply_sample(16'sd0, 1'b0);
        apply_sample(16'sd0, 1'b0);
        apply_sample(16'sd0, 1'b0);

        // Flush the pipeline
        repeat (4) @(negedge clk);
        valid_in = 1'b0;

        if (errors == 0 && checks > 0)
            $display("TEST PASSED: %0d valid output samples checked.", checks);
        else
            $display("TEST FAILED: errors=%0d, valid checks=%0d", errors, checks);

        $finish;
    end

endmodule
