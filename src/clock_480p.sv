// Project F Library - 640x480p60 Clock Generation (iCE40)
// (C)2022 Will Green, open source hardware released under the MIT License
// Learn more at https://projectf.io

`default_nettype none
`timescale 1ns / 1ps

// Generates 25.125 MHz (640x480 59.8 Hz) with 12 MHz input clock
// iCE40 PLLs are documented in Lattice TN1251 and ICE Technology Library

module clock_480p (
    input wire logic gpio_12m,        // gpio_20
    output      logic clk_pix,        // pixel clock
    output      logic clk_cpu,        // 1/2 pix
    output      logic clk_pix_locked  // pixel clock locked?
    );

    localparam FEEDBACK_PATH="SIMPLE";
    localparam DIVR=4'b0000;
    localparam DIVF=7'b1000010;
    localparam DIVQ=3'b101;
    localparam FILTER_RANGE=3'b001;

    logic locked;
    // SB_PLL40_PAD #(
    //     .FEEDBACK_PATH(FEEDBACK_PATH),
    //     .DIVR(DIVR),
    //     .DIVF(DIVF),
    //     .DIVQ(DIVQ),
    //     .FILTER_RANGE(FILTER_RANGE)
    // ) SB_PLL40_PAD_inst (
    //     .PACKAGEPIN(clk_12m),
    //     .PLLOUTGLOBAL(clk_pix),  // use global clock network
    //     .RESETB(rst),
    //     .BYPASS(1'b0),
    //     .LOCK(locked)
    // );

    SB_PLL40_2F_CORE #(
        .DIVR(DIVR), 
        .DIVF(DIVF), 
        .DIVQ(DIVQ), 
        .FEEDBACK_PATH(FEEDBACK_PATH),
        .FILTER_RANGE(FILTER_RANGE),
        .PLLOUT_SELECT_PORTA("GENCLK_HALF"),
        .PLLOUT_SELECT_PORTB("GENCLK")
    ) pll_inst (
        .LOCK(locked),            // signal indicates PLL lock (useful as a reset)
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .REFERENCECLK(gpio_12m),     // input reference clock
        .PLLOUTGLOBALA(clk_cpu),    // PLL output half speed clock (via global buffer)
        .PLLOUTGLOBALB(clk_pix)         // PLL output clock (via global buffer)
    );

    // ensure clock lock is synced with pixel clock
    logic locked_sync_0;
    always_ff @(posedge clk_pix) begin
        locked_sync_0 <= locked;
        clk_pix_locked <= locked_sync_0;
    end
endmodule