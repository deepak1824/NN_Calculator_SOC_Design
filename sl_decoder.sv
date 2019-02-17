module sl_decoder ( input reg [31:0] addr_final,output reg SEL1,SEL2,SEL3,SEL4,SEL5,reg [4:0] sel_out);
//reg [31:0] addr_final;

//reg SEL1,SEL2,SEL3,SEL4,SEL5;
//reg [4:0] sel_out ;
//output reg sel;
parameter int add1 = 32'hfffeff00;
parameter int add2 = 32'hfffeff04;
parameter int add3 = 32'hfffeff08;
parameter int add4 = 32'hfffeff0c;

always @(*) begin

    if (addr_final == add1) begin
            SEL1 = 1;
            SEL2 = 0;
            SEL3 = 0;
            SEL4 = 0;
            SEL5 = 0;
            sel_out = {SEL1,SEL2,SEL3,SEL4,SEL5};
          //  sel=0;
    end
    else if (addr_final == add2) begin
            SEL1 = 0;
            SEL2 = 1;
            SEL3 = 0;
            SEL4 = 0;
            SEL5 = 0;
         //   sel=0;
            sel_out = {SEL1,SEL2,SEL3,SEL4,SEL5};
    end 
    else if (addr_final == add3) begin
            SEL1 = 0;
            SEL2 = 0;
            SEL3 = 1;
            SEL4 = 0;
            SEL5 = 0;
          //  sel=0;
          sel_out = {SEL1,SEL2,SEL3,SEL4,SEL5};
    end 
    else if (addr_final == add4) begin
            SEL1 = 0;
            SEL2 = 0;
            SEL3 = 0;
            SEL4 = 1;
            SEL5 = 0;
           // sel=0;
           sel_out = {SEL1,SEL2,SEL3,SEL4,SEL5};
    end 
    else   begin
            SEL1 = 0;
            SEL2 = 0;
            SEL3 = 0;
            SEL4 = 0;
            SEL5 = 1;
          //  sel=0;
          sel_out = {SEL1,SEL2,SEL3,SEL4,SEL5};
    end 
   /* else begin
            SEL1 = 0;
            SEL2 = 0;
            SEL3 = 0;
            SEL4 = 0;
            SEL5 = 0;
            sel_out = {SEL1,SEL2,SEL3,SEL4,SEL4};
           // sel = 1;
    end */
            
end 
endmodule
