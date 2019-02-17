

module addr_mux (ADDR1,ADDR2,ADDR3,ADDR4,ADDR5,TRANS1,TRANS2,TRANS3,TRANS4,TRANS5,WRITE1,WRITE2,WRITE3,WRITE4,WRITE5,SIZE1,SIZE2,SIZE3,SIZE4,SIZE5,HBURST1,HBURST2,HBURST3,HBURST4,HBURST5,addr_sel,addr_final,trans_final,write_final,size_final,burst_final);

input reg [31:0] ADDR1,ADDR2,ADDR3,ADDR4,ADDR5;
input reg [1:0] TRANS1,TRANS2,TRANS3,TRANS4,TRANS5;
input reg WRITE1,WRITE2,WRITE3,WRITE4,WRITE5;
input reg [2:0] SIZE1,SIZE2,SIZE3,SIZE4,SIZE5;
input reg [2:0] HBURST1,HBURST2,HBURST3,HBURST4,HBURST5;
input reg [4:0] addr_sel;
output reg [31:0] addr_final;
output reg [1:0] trans_final;
output reg  write_final;
output reg [2:0] size_final;
output reg [2:0] burst_final;
 

// parameter int add1 = 32'hfffeff00;
// parameter int add2 = 32'hfffeff04;
// parameter int add3 = 32'hfffeff08;
// parameter int add4 = 32'hfffeff0c;
parameter int add5 = 32'h00000000;

/*always @(posedge clk or posedge reset) begin

    if (reset) begin
    
        addr_final_d <= #1 0;
    end 
    else begin
        addr_final_d <= #1 addr_final
*/

always @(*) begin

    case (1'b1) 
    
            (addr_sel == 5'b10000) : begin
                                    addr_final = ADDR1;
                                    trans_final = TRANS1;
                                    write_final = WRITE1;
                                    size_final = SIZE1;
                                    burst_final = HBURST1;
                                  end
                                  
            (addr_sel == 5'b01000) : begin
                                    addr_final = ADDR2;
                                    trans_final = TRANS2;
                                    write_final = WRITE2;
                                    size_final = SIZE2;
                                    burst_final = HBURST2;
                                  end
                                  
            (addr_sel == 5'b00100) : begin

                                    addr_final = ADDR3;
                                    trans_final = TRANS3;
                                    write_final = WRITE3;
                                    size_final = SIZE3;
                                    burst_final = HBURST3;
                                  end
                                  
            (addr_sel == 5'b00010) : begin
                                    addr_final = ADDR4;
                                    trans_final = TRANS4;
                                    write_final = WRITE4;
                                    size_final = SIZE4;
                                    burst_final = HBURST4;
                                  end
                                  
            (addr_sel == 5'b00001): begin
                                    addr_final = ADDR5;
                                    trans_final = TRANS5;
                                    write_final = WRITE5;
                                    size_final = SIZE5;
                                    burst_final = HBURST5;
                                  end
                    default     : begin
//                                     addr_final = (!add1 && !add2 && !add3 && !add4 && !(add5 inside {[32'h10000000 : 32'h3fffffff]}));
                                    addr_final = add5;
                                    trans_final = 2'b00;
                                  end 
                                  
    endcase
end 
endmodule
