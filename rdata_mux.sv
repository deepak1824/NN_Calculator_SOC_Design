module rdata_mux( RDATA1,RDATA2,RDATA3,RDATA4,RDATA5,READY1,READY2,READY3,READY4,READY5,RESP1,RESP2,RESP3,RESP4,RESP5,clk,reset,sel,rdata_final,ready_final,resp_final);


input reg [31:0] RDATA1,RDATA2,RDATA3,RDATA4,RDATA5;
input reg  READY1,READY2,READY3,READY4,READY5;
input reg [1:0] RESP1,RESP2,RESP3,RESP4,RESP5;
output reg [31:0] rdata_final;
output reg  ready_final;
output reg [1:0] resp_final;
input reg [4:0] sel;
input logic clk,reset;
reg [4:0] sel_d;


always @(posedge clk or posedge reset) begin

    if (reset) begin
    
        sel_d <= #1 0;
    end 
    else begin
        
        sel_d <= #1 sel;
    end 
end
        

always @(*) begin
    
     if (sel_d == 5'b10000) begin
            rdata_final = RDATA1;
            ready_final = READY1;
            resp_final = RESP1; 
     end
    else if (sel_d == 5'b01000) begin
            rdata_final = RDATA2;
            ready_final = READY2;
            resp_final = RESP2; 
    end
    else if (sel_d == 5'b00100) begin
            rdata_final = RDATA3;
            ready_final = READY3;
            resp_final = RESP3; 
    end
    else if (sel_d == 5'b00010) begin
            rdata_final = RDATA4;
            ready_final = READY4;
            resp_final = RESP4; 
    end
    else if (sel_d == 5'b00001) begin
            rdata_final = RDATA5;
            ready_final = READY5;
            resp_final = RESP5; 
    end
    
end 
endmodule
