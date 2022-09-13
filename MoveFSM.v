module MoveFSM(CLOCK_50, 
					SW, KEY, //my inputs
					VGA_CLK,   						//	VGA Clock
					VGA_HS,							//	VGA H_SYNC
					VGA_VS,							//	VGA V_SYNC
					VGA_BLANK_N,						//	VGA BLANK
					VGA_SYNC_N,						//	VGA SYNC
					VGA_R,   						//	VGA Red[9:0]
					VGA_G,	 						//	VGA Green[9:0]
					VGA_B   						//	VGA Blue[9:0]
					);
					
	input 			CLOCK_50;
	input 	[3:0] KEY;
	input 	[9:0]	SW;
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]

	wire draw, erase, set_dir, update_x, update_y, plot, clr, xtemp, ytemp ;
	wire [2:0] counterA;
	wire [23:0] rateDivider;
	
	vga_adapter VGA(
			.resetn(SW[9]),
			.clock(CLOCK_50),
			.colour(clr),
			.x(xtemp),
			.y(ytemp),
			.plot(plot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	datapath d1(CLOCK_50, SW[9], KEY[0], KEY[1], KEY[2], KEY[3], 
						draw, erase, set_dir, update_x, update_y,
						plot, clr, xtemp, ytemp, counterA, rateDivider);
						
	control c1(CLOCK_50, SW[9], counterA, rateDivider, draw, erase, set_dir, 
					update_x, update_y);
endmodule

//may need to include rate divider 
module datapath(clk, resetn, RightN, UpN, DownN, LeftN, 
					draw, erase, set_dir, update_x, update_y,
					plot, clr, xtemp, ytemp, counterA, rateDivider);
	input clk, resetn, RightN, UpN, DownN, LeftN;
	input draw, erase, set_dir, update_x, update_y;
	output reg plot;
	output reg [2:0] clr;
	output reg [8:0] xtemp;
	output reg [7:0] ytemp;
	output reg [2:0] counterA;
	output reg [23:0] rateDivider;
	reg [1:0] dir;
	reg [8:0] X;
	reg [7:0] Y;
	
	localparam  RIGHT       = 2'd0,
               UP   			= 2'd1,
               DOWN      	= 2'd2,
               LEFT   		= 2'd3;
	
	// input logic for X register
	always@(posedge clk) begin
		if(!resetn) begin
			X <= 9'd64;
		end
		else if (update_x) begin
			if (dir == RIGHT) begin
				if (X == 9'd160) begin
					X <= 9'd0;
				end
				else begin
					X <= X + 1;
				end
			end
			if (dir == LEFT) begin
				if (X == 9'd0) begin
					X <= 9'd160;
				end 
				else begin
					X <= X - 1;
				end
			end
		end
		else begin
			X <= X;
		end
	end
		
	// input logic for Y register
		always@(posedge clk) begin
			if(!resetn) begin
				Y <= 8'd60;
			end
			else if (update_y) begin
				if (dir == UP) begin
					if (Y == 8'd0) begin
						Y <= 8'd120;
					end
					else begin
						Y <= Y - 1;
					end
				end
				if (dir == DOWN) begin
					if (Y == 8'd120) begin
						Y <= 8'd0;
					end 
					else begin
						Y <= Y + 1;
					end
				end
			end
			else begin
				Y <= Y;
			end
		end
	
	// input logic for dir register
	always@(posedge clk) begin
			if(!resetn) begin
				dir <= RIGHT;
			end
			else if (set_dir) begin 
				if (!RightN) begin
					if (dir != LEFT)
							dir <= RIGHT; 
				end
				else if (!UpN) begin
							if (dir != DOWN)
									dir <= UP;
				end
				else if (!DownN) begin
							if (dir != UP)
									dir <= DOWN;
				end
				else if (!LeftN) begin
							if (dir != RIGHT)
									dir <= LEFT;
				end
				else begin
					dir <= dir;
				end
			end
			else begin
				dir <= dir;
			end
	end
	
	// for drawing or erasing 2x2 square
	always@(posedge clk) begin
		if (!resetn) begin
			xtemp <= 9'd64;
			ytemp <= 8'd60;
			counterA <= 3'd0;
			rateDivider <= 24'd9999999;
			plot <= 1'b0;
			clr <= 3'b111;
		end
		else if (draw || erase) begin
			if (draw) begin
				clr <= 3'b111;
			end
			else begin
				clr <= 3'b000;
			end
			plot <= 1'b1;
			xtemp <= X + counterA[0];
			ytemp <= Y + counterA[1];
			counterA <= counterA + 1;
		end
		else begin
			clr <= 3'b111;
			plot <= 1'b0;
			counterA <= 3'd0;
			xtemp <= xtemp;
			ytemp <= ytemp;
			if ((!set_dir) && (!update_x) && (!update_y)) begin
				if (rateDivider == 24'd0) begin
					rateDivider = 24'd9999999;
				end
				else begin
					rateDivider = rateDivider - 1;
				end
			end
		end
	end
endmodule
		

module control(clk, resetn, counterA, rateDivider, draw, erase, set_dir, 
					update_x, update_y);
	input clk, resetn;
	input [2:0] counterA;
	input [23:0] rateDivider;
	output reg draw, erase, set_dir, update_x, update_y;
	
	reg [2:0] current_state, next_state; 
    
    localparam  WAIT1			= 3'd0, //this WAIT state may cause snake to flash onscreen
					 DRAW       	= 3'd1,
                WAIT2     		= 3'd2, //WAIT states allow use of same counter for draw and erase
                ERASE   		= 3'd3,
                SET_DIR       = 3'd4,
                UPDATE_X	   = 3'd5,
                UPDATE_Y      = 3'd6;
					 
	// Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
					 WAIT1 :next_state = (counterA == 3'd0)? DRAW : WAIT1;
                DRAW: next_state = (counterA == 3'd4)? WAIT2 : DRAW; 	
					 WAIT2: next_state = ((counterA == 3'd0) && (rateDivider == 24'd0))? ERASE : WAIT2;
                ERASE: next_state = (counterA == 3'd4)? SET_DIR : ERASE;				 
                SET_DIR: next_state = UPDATE_X; 				 
                UPDATE_X: next_state = UPDATE_Y; 			 
                UPDATE_Y: next_state = WAIT1; 
            default:     next_state = WAIT1; 
        endcase
    end // state_table
    
	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        draw = 1'b0;
		  erase = 1'b0;
        set_dir = 1'b0;
        update_x = 1'b0;
        update_y = 1'b0;

        case (current_state)
				WAIT1: begin
					draw = 1'b0;
				   erase = 1'b0;
				   set_dir = 1'b0;
				   update_x = 1'b0;
				   update_y = 1'b0;
				end
            DRAW: begin
                draw = 1'b1;
					 erase = 1'b0;
				    set_dir = 1'b0;
				    update_x = 1'b0;
				    update_y = 1'b0;
            end
				WAIT2: begin
					 draw = 1'b0;
				    erase = 1'b0;
				    set_dir = 1'b0;
				    update_x = 1'b0;
				    update_y = 1'b0;

				end
            ERASE: begin
					 draw = 1'b0;
                erase = 1'b1;
					 set_dir = 1'b0;
					 update_x = 1'b0;
					 update_y = 1'b0;
                end
            SET_DIR: begin
                draw = 1'b0;
					 erase = 1'b0;
					 set_dir = 1'b1;
					 update_x = 1'b0;
					 update_y = 1'b0;
            end
            UPDATE_X: begin
                draw = 1'b0;
					 erase = 1'b0;
					 set_dir = 1'b0;
					 update_x = 1'b1;
					 update_y = 1'b0;
            end
				UPDATE_Y: begin
                draw = 1'b0;
					 erase = 1'b0;
					 set_dir = 1'b0;
					 update_x = 1'b0;
					 update_y = 1'b1;
            end
        endcase
    end // enable_signals
	 
	  // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= WAIT1;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
