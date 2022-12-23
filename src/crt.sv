`default_nettype none

module crt(
        input        clk,
        // input        rst,
        // input        en,
        // output [7:0] out,
        output reg signal,
        output signed [7:0] DEBUG
    );

    initial signal = 1'b1;

    // Pixel counter
    reg [7:0] count_reg = 8'b00000000;
    // 'X' register
    reg signed [7:0] reg_X = 8'b00000001;



    // ROM connections
    wire [7:0] rom_addr;
    wire signed [7:0] rom_data;
    ROM rom_instance (.addr(rom_addr), .data(rom_data));

    // last read from ROM
    reg signed [7:0] cur_rom = 8'b00000000;
    // Read addr
    assign rom_addr = count_reg;



    // X coordinate of current pixel
    wire [7:0] pixel_X;
    assign pixel_X = count_reg % 40;

    wire [7:0] pixel_diff;
    assign pixel_diff = pixel_X - reg_X;



    // DEBUG
    assign DEBUG = reg_X;



    // Pixel clock
    always @(posedge clk) begin
        // Next pixel
        count_reg <= count_reg + 1;
        // Evaluate addx
        reg_X <= reg_X + cur_rom;
        // PIXEL OUTPUT
        signal <= (pixel_diff == 0) | (pixel_diff == 8'b11111111) | (pixel_diff == 1);
        // rom_addr <= 8'b00000000;
        // rom_req_read <= 1'b1;
        // rom_req_read <= 1'b0;
    end


    // Read rom when rom is ready
    always @(negedge clk) begin
        cur_rom <= rom_data;
    end
endmodule