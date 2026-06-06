`timescale 1ns/1ps

module cache_controller_tb;

    // Parametrii sistemului
    parameter BLOCK_SIZE    = 256;
    parameter ADDRESS_WIDTH = 21;
    parameter INDEX_WIDTH   = 8;  // Adaptat pentru 256 seturi (4-way)
    parameter TAG_WIDTH     = 10; // Adaptat pentru 4-way
    parameter OFFSET_WIDTH  = 3;
    parameter WORD_SIZE     = 32;
    parameter NBLOCKS       = 256; 
    parameter MEM_FILE      = "tb/mem_data.txt";

    // Perioada de ceas
    parameter CLK_PERIOD_NS       = 200;
    parameter MISS_LATENCY_CYCLES = 6;
    parameter HIT_LATENCY_CYCLES  = 2;

    // Semnale generate de testbench (reg)
    reg clock;
    reg rst_n;
    reg [20:0] caddress;
    reg [31:0] cdin;
    reg rden;
    reg wren;

    // Semnale de interconectare si rezultate (wire)
    wire [31:0]  cdout;
    wire         hit;
    wire [255:0] mdin;
    wire [255:0] mdout;
    wire [17:0]  maddress;
    wire         mrden;
    wire         mwren;

    // Generarea semnalului de ceas
    initial begin
        clock = 1'b1;
        forever #(CLK_PERIOD_NS / 2) clock = ~clock;
    end

    // Task pentru asteptare
    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(posedge clock);
        end
    endtask

    // Task pentru cerere de citire (Read)
    task cache_read;
        input [20:0] addr;
        input integer wait_cycles_n;
        begin
            caddress <= addr;
            cdin     <= 32'd0;
            rden     <= 1'b1;
            wren     <= 1'b0;
            wait_cycles(wait_cycles_n);
            rden     <= 1'b0;
            wren     <= 1'b0;
            wait_cycles(1);
        end
    endtask

    // Instantierea Controlerului de Cache
    cache_controller DUT_CACHE (
        .clock(clock),
        .rst_n(rst_n),
        .caddress(caddress),
        .cdin(cdin),
        .rden(rden),
        .wren(wren),
        .hit(hit),
        .cdout(cdout),
        .mdin(mdin),
        .mdout(mdout),
        .maddress(maddress),
        .mrden(mrden),
        .mwren(mwren)
    );

    // Instantierea Memoriei Principale
    main_memory #(
        .FILE(MEM_FILE)
    ) DUT_MEM (
        .clock(clock),
        .din(mdout),
        .address(maddress),
        .rden(mrden),
        .wren(mwren),
        .dout(mdin)
    );

    // Declaratii pentru lucrul cu fisierul de log
    integer file_id;
    integer idx;

    // Stimuli de test
    initial begin
        //$dumpfile("cache_controller_tb.vcd");
        //$dumpvars;

        // Initializare
        caddress = 21'd0;
        cdin     = 32'd0;
        rden     = 1'b0;
        wren     = 1'b0;
        rst_n    = 1'b0;

        wait_cycles(2);
        rst_n = 1'b1;
        wait_cycles(1);

        // Citire la "rece" (Cold read): asteptam un MISS, dureaza MISS_LATENCY_CYCLES
        cache_read(21'h00004, MISS_LATENCY_CYCLES);

        // Citire acelasi set/tag/linie (Wider constants truncate to the same 21-bit address)
        cache_read(21'h00004, HIT_LATENCY_CYCLES);

        // Acelasi cache line, offset diferit: asteptam HIT
        cache_read(21'h00005, HIT_LATENCY_CYCLES);
        cache_read(21'h00006, HIT_LATENCY_CYCLES);
        cache_read(21'h00007, HIT_LATENCY_CYCLES);

        wait_cycles(2);
        
        if (file_id != 0) begin
            $fclose(file_id);
        end
        $stop;
    end

    initial begin
        file_id = $fopen("rezultat/cache_rez.txt", "w");
        
        if (file_id == 0) begin
            $display("EROARE: Nu s-a putut crea fisierul rezultat/cache_rez.txt!");
        end
    end

    always @(posedge clock) begin
        if (file_id != 0) begin
            $fdisplay(file_id, "TIMP: %5d | addr: %b | hit: %b | cdout: %b", $time, caddress, hit, cdout);
            
            // Parcurgem toate cele 256 de seturi, dar afi??m DOAR dac? au date valide
            for (idx = 0; idx < 256; idx = idx + 1) begin
                if (DUT_CACHE.valid_0[idx] || DUT_CACHE.valid_1[idx] || DUT_CACHE.valid_2[idx] || DUT_CACHE.valid_3[idx]) begin
                    $fdisplay(file_id, "SET %3d | Way0 (Valid=%b): %h", idx, DUT_CACHE.valid_0[idx], DUT_CACHE.mem_0[idx]);
                    $fdisplay(file_id, "        | Way1 (Valid=%b): %h", DUT_CACHE.valid_1[idx], DUT_CACHE.mem_1[idx]);
                    $fdisplay(file_id, "        | Way2 (Valid=%b): %h", DUT_CACHE.valid_2[idx], DUT_CACHE.mem_2[idx]);
                    $fdisplay(file_id, "        | Way3 (Valid=%b): %h", DUT_CACHE.valid_3[idx], DUT_CACHE.mem_3[idx]);
                end
            end
            $fdisplay(file_id, "\n");
        end
    end

endmodule
