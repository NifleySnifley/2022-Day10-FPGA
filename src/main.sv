module blinky (
    input wire gpio_20, // 12M onboard clock in
    output wire led_blue,
    output wire led_green,
    output wire led_red,

    output wire gpio_28, // Pixel Clock (DVI)
    output wire gpio_3,  // HSYNC
    output wire gpio_48, // VSYNC
    output wire gpio_45, // R
    output wire gpio_47, // G
    output wire gpio_46, // B
    output wire gpio_2,  // DEN (Optional)
);
    wire logic ledr;
    wire logic ledg;
    wire logic ledb;

    assign ledr = ~pll_locked;
    assign ledg = 0'b1;
    assign ledb = 0'b0;

    wire logic pixclk;
    wire logic cpuclk;
    wire logic pll_locked;

    clock_480p vga_clk(
        .clk_pix(pixclk),
        .clk_pix_locked(pll_locked),
        .clk_cpu(cpuclk),
        .gpio_12m(gpio_20)
    );

    SB_IO #(
    .PIN_TYPE(6'b010000)  // PIN_OUTPUT_DDR
    ) vga_clk_io (
        .PACKAGE_PIN(gpio_28),
        .OUTPUT_CLK(pixclk),
        .D_OUT_0(1'b0),
        .D_OUT_1(1'b1)
    );


    SB_RGBA_DRV rgb (
        .RGBLEDEN (1'b1),
        .RGB0PWM  (ledg),
        .RGB1PWM  (ledb),
        .RGB2PWM  (ledr),
        .CURREN   (1'b1),
        .RGB0     (led_blue),
        .RGB1     (led_green),
        .RGB2     (led_red)
    );
    defparam rgb.CURRENT_MODE = "0b1";
    defparam rgb.RGB0_CURRENT = "0b000001";
    defparam rgb.RGB1_CURRENT = "0b000001";
    defparam rgb.RGB2_CURRENT = "0b000001";

    wire logic HSYNC_OUT, VSYNC_OUT, OUT_DEN, R_OUT, G_OUT, B_OUT;

    logic [9:0] sx, sy;

    // Drive the VGA
    simple_480p vga_drv(
        .clk_pix(pixclk),
        .rst_pix(!pll_locked),
        .sx,
        .sy,
        .hsync(HSYNC_OUT),
        .vsync(VSYNC_OUT),
        .de(OUT_DEN)
    );

    always_comb begin
        R_OUT = sx < 100;
        G_OUT = 0;
        B_OUT = 0;
    end

    SB_IO #(
        .PIN_TYPE(6'b010100)  // PIN_OUTPUT_REGISTERED
    ) vga_io [5:0] (
        .PACKAGE_PIN({ gpio_3, gpio_48, gpio_45, gpio_47, gpio_46, gpio_2 }),
        .OUTPUT_CLK(pixclk),
        .D_OUT_0({ HSYNC_OUT, VSYNC_OUT, R_OUT, G_OUT, B_OUT, OUT_DEN }),
        .D_OUT_1()
    );

endmodule