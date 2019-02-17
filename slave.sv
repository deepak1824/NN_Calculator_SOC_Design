`include "ahbif.svh"

module slave (s_AHBIF.AHBS s);
reg [1:0] sHRESP_d;
reg sHREADY_d;
reg [31:0] sHRDATA_d;

reg [31:0] R0;

always @(posedge s.HCLK or s.HRESET) begin

        if (s.HRESET) begin
        
         s.sHRESP = 2'b00;
         s.sHREADY = 1;
         s.sHRDATA = 0;
       //  ns = IDLE;
        
        end 
        
        else begin
        s.sHRESP = sHRESP_d;
        s.sHREADY = sHREADY_d;
        s.sHRDATA = sHRDATA_d;
    //    ns = ps;
        
        end
        
end 

always @(*) begin
sHREADY_d = 1;
sHRESP_d = 2'b00;
sHRDATA_d = 0;

    if (s.HREADYin) begin
    
                if (s.HSEL && s.HTRANS != 2'b00) begin
                        
                    if (!s.HWRITE) begin
                    
                        sHRDATA_d = R0;
                        sHREADY_d = 1;
                        sHRESP_d = 2'b00;
                    end  
                    else begin
                        sHRDATA_d = 0;
                        sHREADY_d = 1;
                        sHRESP_d = 2'b00;
                        R0 = s.sHWDATA;
                    end 
                    
          //      else if ((HSEL==0 || HSEL==1)  && HTRANS==2'b00) begin
                
                       
              //  end 
        end 
    else begin
            
            sHRDATA_d = 0;
            sHREADY_d = 1;
            sHRESP_d = 2'b00;
    end 
end 
endmodule 
                    
                        
                        

//    case(ns)
    
    
//         IDLE : begin
//         
//                 if (!HREADYin) begin
//                 
//                     ps = IDLE;
//                 end 
//                 else 
//                     ps = SEL;
//                 
//                 end
//                 
//         SEL : begin
//         
//                 if (HSEL) begin
//                 
//                     case(1'b1) 
//                     
//                             (HWRITE==0) : begin
//                             
//                                           sHRDATA_d = R0;
//                                           sHREADY_d = 1;
//                                           sHRESP_d = 2'b00;
//                                           ps = FINAL;
//                                           end
//                                           
//                             (HWRITE==1) : begin
//                             
//                                           sHRDATA_d = 0;
//                                           sHREADY_d = 1;
//                                           sHRESP_d = 2'b00;
//                                           R0 = sHWDATA;
//                                           ps = FINAL;
//                                           end 
//                     endcase
                                          
                                          
                
                    
                    
        
                    

