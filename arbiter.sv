module arbiter(output reg grant1,reg grant0,reg [7:0][16:0]config_address,reg [7:0][15:0]data_mem_address,input request1,request0,[7:0][16:0]Caddress0,[7:0][16:0]Caddress1,[7:0][15:0]Maddress0,[7:0][15:0]Maddress1);


always @(*)
begin


    if (request1)
    begin
        grant0 = 0;
        grant1 = 1;
        config_address = Caddress1;
        data_mem_address = Maddress1;
    end
    else
    begin
        grant0 = 1;
        grant1 = 0;
        config_address = Caddress0;
        data_mem_address = Maddress0;
    end
    
end



endmodule 
