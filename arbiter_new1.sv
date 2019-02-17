module arbiter_new1 (input reg REQ1,REQ2,REQ3,REQ4,REQ5,clk,reset, output reg GRANT1,GRANT2,GRANT3,GRANT4,GRANT5,reg[4:0] grant_out);

//reg [4:0] count,count_d;
reg [3:0] ns,ps;
reg GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d;
reg [4:0] grant_out_d;
//reg grant_out = {GRANT1,GRANT2,GRANT3,GRANT4,GRANT5};

always @(posedge clk or posedge  reset) begin

	if (reset) begin
		ns <= #1 1;
	//	count <= #1 0;
		GRANT1 <= #1 0;
		GRANT2 <= #1 0;
		GRANT3 <= #1 0;
		GRANT4 <= #1 0;
		GRANT5 <= #1 0;
		grant_out <= #1 0;
	end
	else begin
		ns <= #1 ps;
		
		//count <= #1 count_d + 1;
		GRANT1 <= #1 GRANT1_d;
		GRANT2 <= #1 GRANT2_d;
		GRANT3 <= #1 GRANT3_d;
		GRANT4 <= #1 GRANT4_d;
		GRANT5 <= #1 GRANT5_d;
		grant_out <= #1 grant_out_d;
		
	end
end

always @(*) begin
//count_d = count;
GRANT1_d = 0;
GRANT2_d = 0;
GRANT3_d = 0;
GRANT4_d = 0;
GRANT5_d = 0;
ps = 1;
	case (ns)

		1: begin

			case (1'b1)

				REQ5 : begin

					GRANT5_d = 1;
					ps = 2;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					 
					end
				REQ1 : begin
					GRANT1_d = 1;
					ps = 3;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ2 : begin
					GRANT2_d = 1;
					
					ps = 4;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
				       end
				REQ3 : begin
					GRANT3_d = 1;
					
					ps = 5;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ4 : 	begin
					GRANT4_d = 1;
					
					ps = 1;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
                default : grant_out_d = 5'b00000;
                
			endcase
		    end

		2: begin
	
			case (1'b1)

				REQ1 : begin

					GRANT1_d = 1;
					
					ps = 3;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ2 : begin
					GRANT2_d = 1;
					
					ps = 4;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ3 : begin
					GRANT3_d = 1;
					
					ps = 5;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
				       end
				REQ4 : begin
					GRANT4_d = 1;
					
					ps = 1;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ5 : 	begin
					GRANT5_d = 1;
					
					ps = 2;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
                default : grant_out_d = 5'b00000;
                
			endcase
		    end

		3: begin

			case (1'b1)

				REQ2 : begin

					GRANT2_d = 1;
					
					ps = 4;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ3 : begin
					GRANT3_d = 1;
					
					ps = 5;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ4 : begin
					GRANT4_d = 1;
					
					ps = 1;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
				       end
				REQ5 : begin
					GRANT5_d = 1;
					
					ps = 2;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ1 : 	begin
					GRANT1_d = 1;
					
					ps = 3;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
                default : grant_out_d = 5'b00000;
                
			endcase
		    end
	
		4: begin
			
			case (1'b1)

				REQ3 : begin

					GRANT3_d = 1;
					
					ps = 5;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ4 : begin
					GRANT4_d = 1;
					
					ps = 1;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ5 : begin
					GRANT5_d = 1;
					
					ps = 2;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
				       end
				REQ1 : begin
					GRANT1_d = 1;
					
					ps = 3;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ2 : 	begin
					GRANT2_d = 1;
					
					ps = 4;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
                default : grant_out_d = 5'b00000;
                
			endcase
		    end

		5 : begin
			case (1'b1)

				REQ4 : begin

					GRANT4_d = 1;
					
					ps = 1;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ5 : begin
					GRANT5_d = 1;
					
					ps = 2;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ1 : begin
					GRANT1_d = 1;
					
					ps = 3;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
				       end
				REQ2 : begin
					GRANT2_d = 1;
					
					ps = 4;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
				REQ3 : 	begin
					GRANT3_d = 1;
					
					ps = 5;
					grant_out_d = {GRANT1_d,GRANT2_d,GRANT3_d,GRANT4_d,GRANT5_d};
					
					end
                default : grant_out_d = 5'b00000;
                
			endcase
		    end
	endcase
end 

endmodule


			
