`default_nettype none

module blinky (
    input wire gpio_20, // 12M onboard clock in
    output wire led_blue,
    output wire led_green,
    output wire led_red,

    output wire gpio_28, // Debugging
    output wire gpio_3,  // HSYNC
    output wire gpio_48, // VSYNC
    output wire gpio_45, // R
    output wire gpio_47, // G
    output wire gpio_46, // B
    output wire gpio_2,  // DEN (Optional)
);
    // Clock signal PLL for 25.125MHz 640x480 VGA
    clock_480p vga_clk(
        .clk_pix(pixclk),
        .clk_pix_locked(pll_locked),
        .clk_cpu(cpuclk),
        .gpio_12m(gpio_20)
    );  
    
    wire logic ledr;
    wire logic ledg;
    wire logic ledb;

    // Green is for good
    assign ledr = ~pll_locked;
    assign ledg = pll_locked;
    assign ledb = 1'b0;

    wire logic pixclk;
    wire logic cpuclk;
    wire logic pll_locked;

    // Status LED driver
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

    // VGA signals
    wire logic HSYNC_OUT, VSYNC_OUT, OUT_DEN, R_OUT, G_OUT, B_OUT;

    // Video drawing signals
    logic [9:0] sx, sy, frame;

    // Drive the VGA
    simple_480p vga_drv(
        .clk_pix(pixclk),
        .rst_pix(~pll_locked),
        .sx,
        .sy,
        .hsync(HSYNC_OUT),
        .vsync(VSYNC_OUT),
        .de(OUT_DEN),
        .frame
    );

    // Pixel offset for drawing
    // Right smack in the center of the screen :P
    parameter OX = 640/2-20;
    parameter OY = 480/2-3;

    // Checks whether the pixel is in the drawing region
    wire logic aoc_drawing;
    assign aoc_drawing = (sx <= (40-1+OX)) && (sy <= (6-1+OY)) && (sx >= OX) && (sy >= OY);    

    // Clock signal for solver:
    //  - Inverted so calculations/ROM access is done when pixel is NOT being samples
    //  - Only pulses when within the drawing region
    wire aoc_clk;
    assign aoc_clk = (~pixclk) && aoc_drawing;

    // Instantiate solver and IO
    wire draw;
    wire [7:0] dbg;
    crt aoc_solver(
        .clk(aoc_clk),    // Clock only when in the drawing "screen"
        .x(sx[7:0] - OX),
        .y(sy[7:0] - OY),
        .rst(~VSYNC_OUT), // Reset on VSYNC (every frame)
        .signal(draw),    // Pixel out
        .DEBUG(dbg)
    );

    // Painting logic
    always_comb begin
        if (OUT_DEN) begin
            R_OUT = aoc_drawing && draw;
            G_OUT = aoc_drawing && draw;
            B_OUT = aoc_drawing && draw;
        end else begin
            R_OUT = 0;
            G_OUT = 0;
            B_OUT = 0;
        end
    end

    // Output the VGA/DVI signals
    SB_IO #(
        .PIN_TYPE(6'b010100)  // PIN_OUTPUT_REGISTERED
    ) vga_io [5:0] (
        .PACKAGE_PIN({ gpio_3, gpio_48, gpio_45, gpio_47, gpio_46, gpio_2 }),
        .OUTPUT_CLK(pixclk),
        .D_OUT_0({ HSYNC_OUT, VSYNC_OUT, R_OUT, G_OUT, B_OUT, OUT_DEN }),
        .D_OUT_1()
    );
endmodule