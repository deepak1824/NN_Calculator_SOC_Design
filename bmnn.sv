//
// interface to student bus master to nn block
//


module bmnn(mAHBIF.AHBM master,sAHBIF.AHBS slave,nnIntf.nn_drv neural);


parameter IDLE = 2'b00;
parameter NONSEQ = 2'b10;
parameter SINGLE = 3'b000;
parameter _32bits = 3'b010;


typedef enum {SIDLE, GETCOMMAND, WRITE_R0, READ_R0, SWAIT} states;
states ps,ns;

typedef enum {CIDLE, LOADMEM, SAVEMEM, SETMEM} command_states;
command_states command_ps,command_ns,return_state;

typedef enum {LIDLE, GETSECONDWORD, GETTHIRDWORD, GETDATA, LWAIT, NOREADY} LoadMem_states;
LoadMem_states LoadMem_ps, LoadMem_ns, SaveMem_ns, SaveMem_ps, SetMem_ns, SetMem_ps;

typedef enum {MIDLE, NON_SEQUENTIAL, SEQUENTIAL, LAST_TRANSFER, MWAIT} master_states;
master_states address_ns,address_ps;

logic [31:0] r0_d;
reg[31:0]  r0;

logic [31:0] config_reg_d;
reg [31:0] config_reg;

logic [31:0] SetMem_data_d;
reg [31:0] SetMem_data;

reg [31:0] hwdata_d;
reg [31:0] addr_d;

/*      Control Signals     */
logic shurukar_d;
reg shurukar;

logic done_d;
reg done;

logic LoadMem_start_d;
logic SaveMem_start_d;
logic StartNN_start_d;
logic WaitNN_start_d;
logic SetMem_start_d;
logic EndBM_start_d;

reg LoadMem_start;
reg SaveMem_start;
reg StartNN_start;
reg WaitNN_start;
reg SetMem_start;
reg EndBM_start;

logic RW_d;
reg RW;

logic NN_RW_d;
reg NN_RW;

/*      Control Signals     */


logic [31:0] MainMemory_Address_d;
logic [31:0] NN_Address_d;

reg [31:0] MainMemory_Address;
reg [31:0] NN_Address;

logic [31:0] Rdata_d;
reg [31:0] Rdata;

logic [23:0] Transfers_d;
reg [23:0] Transfers;

logic [23:0] counter_d;
reg [23:0] counter;

logic neural_sel_d;
reg neural_sel;

logic neural_RW_d;
reg neural_RW;


reg [1:0] sHRESP_d;
reg sHREADY_d;
reg [31:0] sHRDATA_d;
reg [31:0] temp;
reg[31:0] ns_slave,ps_slave;
reg [2:0] hello,hello_d;
reg sHREADYin_d,sHSEL_d,sHWRITE_d;

//reg [31:0] R0;


/*      Slave       */

/*always @(posedge master.HCLK or master.HRESET) begin

        if (master.HRESET) begin
        
         slave.sHRESP = 2'b00;
         slave.sHREADY = 1;
         slave.sHRDATA = 0;
       //  ns = IDLE;
        
        end 
        
        else begin
        slave.sHRESP = sHRESP_d;
        slave.sHREADY = sHREADY_d;
        slave.sHRDATA = sHRDATA_d;
    //    ns = ps;
        
        end
        
end */

/*always @(*) begin
sHREADY_d = 1;
sHRESP_d = 2'b00;
sHRDATA_d = 0;

    if (slave.sHREADYin) begin
    
                if (slave.sHSEL && slave.sHTRANS != 2'b00) begin
                        
                    if (!slave.sHWRITE) begin
                    
                        sHRDATA_d = r0;
                        sHREADY_d = 1;
                        sHRESP_d = 2'b00;
                    end  
                    else begin
                        sHRDATA_d = 0;
                        sHREADY_d = 1;
                        sHRESP_d = 2'b00;
                        temp = slave.sHWDATA;
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
end*/

/*ways @(*) begin

sHREADY_d = 1;
sHRESP_d = 2'b00;
sHRDATA_d = 0;

        case (ns_slave) 
        
                0 : begin
                        if (slave.sHREADYin && slave.sHSEL) begin
                        
                            if (slave.sHWRITE==1) begin
                    
                                ps_slave = 1;
                            end 
                            else begin
                                ps_slave = 2;
                        
                        else begin
                        ps_slave = 0;
                        sHRDATA_d = 0;
                        sHREADY_d = 1;
                        sHRESP_d = 2'b00;
                        end 
                    end 
                1 : begin
                        
                                    sHRDATA_d = 0;
                                    sHREADY_d = 1;
                                    sHRESP_d = 2'b00;
                                    r0 = slave.sHWDATA;
                                    if (slave.HWRITE==0) begin
                                        ps_slave = 2;
                                    end 
                                    else 
                                    ps_slave  = 1;
//                         if (slave.sHSEL && slave.sHTRANS != 2'b00) begin
//                         
//                                 if (!slave.sHWRITE) begin
                    
                                    sHRDATA_d = r0;
                                    sHREADY_d = 1;
                                    sHRESP_d = 2'b00;
                                    ps_slave = 0;
                                end  
                                else begin
                                    sHRDATA_d = 0;
                                    sHREADY_d = 1;
                                    sHRESP_d = 2'b00;
                                    r0 = slave.sHWDATA;
                                    ps_slave = 0;
                                end 
                            end 
                    end 
        endcase
end */

/*      Slave       */

// always @(*) begin
// slave.sHRDATA = 0;
//         case (hello)
//         
//                 0 : begin
//                         if (sHREADYin_d && sHSEL_d) begin
//                             hello_d = 1;
//                         end 
//                         else 
//                             hello_d = 0;
//                         
//                     end 
//                 1 : begin
//                         if (sHWRITE_d) begin
//                             slave.sHRDATA = 0;
//                             slave.sHREADY = 1;
//                             slave.sHRESP = 2'b00;
//                             r0_d = slave.sHWDATA;
//                             hello_d = 0;
//                         end 
//                         else begin
//                             slave.sHRDATA = r0;
//                             slave.sHREADY = 1;
//                             slave.sHRESP = 2'b00;
//                             hello_d = 1;
//                         end 
//                     end 
//             endcase
// end 
                            
        
            

/*      Master      */

always @(*)
begin
    master.mHTRANS = IDLE;
    master.mHBUSREQ = 0;
    master.mHWDATA = hwdata_d;
   // master.mHADDR = addr_d;
    master.mHSIZE = _32bits;
    master.mHBURST = SINGLE;
    master.mHWRITE = 0;
    master.mHADDR = 0;
    
    neural.sel = 0;
    neural.RW = 0;
    neural.din = 0;
    neural.addr = 0;
    
    neural_RW_d = neural_RW;
    neural_sel_d = neural_sel;
    r0_d = r0;
    shurukar_d = 0;
    done_d = 0;
    RW_d = RW;
//     Rdata = 0;              //  check
    
    counter_d = counter;
    Transfers_d = Transfers;
    
    
    LoadMem_start_d = 0;
    SaveMem_start_d = 0;
    SetMem_start_d = 0;
    config_reg_d = config_reg;
    master.mHBUSREQ = 0;
    
    ns = ps;
    command_ns = command_ps;
    address_ns = address_ps;
    
    slave.sHRDATA = 0;
    sHREADY_d = 1;
    sHRESP_d = 2'b00;
    sHRDATA_d = 0;

    case (hello)
        
                0 : begin
                        if (sHREADYin_d && sHSEL_d) begin
                            hello_d = 1;
                        end 
                        else 
                            hello_d = 0;
                        
                    end 
                1 : begin
                        if (sHWRITE_d) begin
                            slave.sHRDATA = 0;
                            slave.sHREADY = 1;
                            slave.sHRESP = 2'b00;
                            r0_d = slave.sHWDATA;
                            hello_d = 0;
                        end 
                        else begin
                            slave.sHRDATA = r0;
                            slave.sHREADY = 1;
                            slave.sHRESP = 2'b00;
                            hello_d = 1;
                        end 
                    end 
            endcase
    
    case(ps)
    
        SIDLE :         //0
        begin
            ns = SIDLE;
            if (r0)
            begin
                master.mHBUSREQ = 1;
                ns = GETCOMMAND;
            end
        end
        
        GETCOMMAND :           //1                     // NEED TO CHECK FOR READY
        begin
            master.mHBUSREQ = 1;
            if (!master.mHGRANT || !master.mHREADYin)
                ns = GETCOMMAND;
            else
            begin
                master.mHTRANS = NONSEQ;
                master.mHSIZE = _32bits;
                master.mHBURST = SINGLE;
                master.mHWRITE = 0;
                master.mHADDR = r0;
                ns = WRITE_R0;
            end
          /*  else if (master.mHGRANT && !master.mHBUSREQ) begin
                ns = SIDLE;
            end */
        end
        
        WRITE_R0 :           //2       // Get first word
        begin
            ns = WRITE_R0;
            if (master.mHREADYin)
            begin
                config_reg_d = master.mHRDATA;
                ns = READ_R0;
            end
        end
        
        READ_R0 :   //3
        begin
            case(1'b1)
            
                config_reg[31:24] == 8'd1 :
                begin
                    command_ns = LOADMEM;
                    master.mHBUSREQ = 1;
                    LoadMem_start_d = 1;
                    RW_d = 0;
//                     Transfers_d = master.mHRDATA[23:0];
                    Transfers_d = config_reg[23:0];
                    neural_sel_d = 1;
                    neural_RW_d = 1;
                    r0_d = r0 + 4;
                    ns = SWAIT;
                end
                
                config_reg[31:24] == 8'd2 :
                begin
                    command_ns = SAVEMEM;
                    master.mHBUSREQ = 1;
                    SaveMem_start_d = 1;
                    RW_d = 1;
//                     Transfers_d = r0[23:0];
                    Transfers_d = config_reg[23:0];
                    neural_sel_d = 1;
                    neural_RW_d = 0;
                    r0_d = r0 + 4;
                    ns = SWAIT;
                end
                
                config_reg[31:24] == 8'd3 :
                begin
                    master.mHBUSREQ = 1;
                    neural.addr = 32'h2;
                    neural.din = 32'hace;
                    neural.sel = 0;
                    neural.RW = 0;
                    neural_sel_d = 0;
                    neural_RW_d = 0;
                    RW_d = 0;
                    r0_d = r0 + 4;
                    ns = GETCOMMAND;
                end
                
                config_reg[31:24] == 8'd4 :
                begin
                    ns = READ_R0;
                    neural.sel = 0;
                    neural.RW = 0;
                    neural.addr = 0;
                    neural.din = 0;
                    neural_sel_d = 0;
                    neural_RW_d = 0;
                    RW_d = 0;
                    if (neural.pushout)
                    begin
                        master.mHBUSREQ = 1;
                        r0_d = r0 + 4;
                        ns = GETCOMMAND;
                    end
                end
                
                config_reg[31:24] == 8'd5 :
                begin
                    command_ns = SETMEM;
                    neural.sel = 0;
                    neural.RW = 0;
                    neural.din = 0;
                    neural.addr = 0;
                    neural_sel_d = 0;
                    neural_RW_d = 0;
                    master.mHBUSREQ = 1;
                    RW_d = 1;
                    SetMem_start_d = 1;
                    Transfers_d = 1;
                    r0_d = r0 + 4;
                    ns = SWAIT;
                end
                
                config_reg[31:24] == 8'h0f :
                begin
                    r0_d = 0;
                    neural_sel_d = 0;
                    neural_RW_d = 0;
                    RW_d = 0;
                    ns = SIDLE;
                end
                
            endcase
        end
            
        SWAIT :     //4
        begin
            ns = SWAIT;
            if (done)
            begin
                master.mHBUSREQ = 1;
                r0_d = r0 + 4;
                ns = GETCOMMAND;
            end
        end
    
    endcase
    
    
    case(command_ps)
    
        CIDLE :
        begin
            command_ns = CIDLE;
            return_state = CIDLE;
            case(1'b1)
                LoadMem_start_d :
                    command_ns = LOADMEM;
                SaveMem_start_d :
                    command_ns = SAVEMEM;
                SetMem_start_d :
                    command_ns = SETMEM;
            endcase
        end
        
        LOADMEM :
        begin
            
            case (LoadMem_ps)
            
                LIDLE :  //0
                begin
                    LoadMem_ns = LIDLE;
                    if (LoadMem_start)
                    begin
                        master.mHBUSREQ = 1;
                        LoadMem_ns = GETSECONDWORD;
                    end
                end
                
                GETSECONDWORD :     //1
                begin
                    LoadMem_ns = GETTHIRDWORD;
                    return_state = command_states'(GETSECONDWORD);
                    master.mHBUSREQ = 1;
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                    case (1'b1)
                        !master.mHGRANT :
                            LoadMem_ns = LWAIT;
                        !master.mHREADYin :
                        begin
                            r0_d = r0;
                            LoadMem_ns = NOREADY;
                        end
                    endcase
                    
                end
                
                GETTHIRDWORD :      //2
                begin
                    LoadMem_ns = GETDATA;
                    return_state = command_states'(GETTHIRDWORD);
                    master.mHBUSREQ = 1;
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    MainMemory_Address_d = master.mHRDATA;
//                     r0_d = r0 + 4;
                    case(1'b1)
                        !master.mHGRANT :
                            LoadMem_ns = LWAIT;
                        !master.mHREADYin :
                        begin
                            r0_d = r0;
                            LoadMem_ns = NOREADY;
                        end
                    endcase
                end
                
                GETDATA :       //3
                begin
                    LoadMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state = command_states'(GETDATA);
                    shurukar_d = 1;
                    if (!master.mHREADYin)
                    begin
                        shurukar_d = 0;
                        LoadMem_ns = NOREADY;
                    end
                    NN_Address_d = master.mHRDATA[31] ? (20'h20000 + master.mHRDATA) : (20'h40000 + master.mHRDATA);
                end
                
                LWAIT :     //4
                begin
                    LoadMem_ns = LWAIT;
                    master.mHBUSREQ = 1;
                    if (master.mHGRANT)
                    begin
                        LoadMem_ns = LoadMem_states'(return_state);
                    end
                end
                
                NOREADY ://5
                begin
                    LoadMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADYin)
                        LoadMem_ns = LoadMem_states'(return_state);
                end
                
            
            endcase
            
        end
    
        SAVEMEM :
        begin
        
            case(SaveMem_ps)
                
                LIDLE :  
                begin
                    SaveMem_ns = LIDLE;
                    if (SaveMem_start)
                    begin
                        master.mHBUSREQ = 1;
                        SaveMem_ns = GETSECONDWORD;
                    end
                end
                
                GETSECONDWORD :
                begin
                    SaveMem_ns = GETTHIRDWORD;
                    return_state = command_states'(GETSECONDWORD);
                    master.mHBUSREQ = 1;
                    case (1'b1)
                        !master.mHGRANT :
                            SaveMem_ns = LWAIT;
                        !master.mHREADYin :
                            SaveMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                end
                
                GETTHIRDWORD :
                begin
                    SaveMem_ns = GETDATA;
                    return_state = command_states'(GETTHIRDWORD);
                    master.mHBUSREQ = 1;
                    case(1'b1)
                        !master.mHGRANT :
                            SaveMem_ns = LWAIT;
                        !master.mHREADYin :
                            SaveMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    NN_Address_d = master.mHRDATA[31] ? (20'h20000 + master.mHRDATA): (20'h40000 + master.mHRDATA);
//                     r0_d = r0 + 4;
                end
                
                GETDATA :
                begin
                    SaveMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state = command_states'(GETDATA);
                    shurukar_d = 1;
                    if (!master.mHREADYin)
                    begin
                        shurukar_d = 0;
                        SaveMem_ns = NOREADY;
                    end
                    MainMemory_Address_d = master.mHRDATA;
                end
                
                LWAIT :
                begin
                    SaveMem_ns = LWAIT;
                    master.mHBUSREQ = 1;
                    if (master.mHGRANT)
                    begin
                        SaveMem_ns = LoadMem_states'(return_state);
                    end
                end
                
                NOREADY :
                begin
                    SaveMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADYin)
                        SaveMem_ns = LoadMem_states'(return_state);
                end
                
            
            endcase
            
        end        
        
        SETMEM :
        begin
        
            case(SetMem_ps)
                
                LIDLE :  
                begin
                    SetMem_ns = LIDLE;
                    if (SetMem_start)
                    begin
                        master.mHBUSREQ = 1;
                        SetMem_ns = GETSECONDWORD;
                    end
                end
                
                GETSECONDWORD :
                begin
                    SetMem_ns = GETTHIRDWORD;
                    return_state = command_states'(GETSECONDWORD);
                    master.mHBUSREQ = 1;
                    case (1'b1)
                        !master.mHGRANT :
                            SetMem_ns = LWAIT;
                        !master.mHREADYin :
                            SetMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                end
                
                GETTHIRDWORD :
                begin
                    SetMem_ns = GETDATA;
                    return_state = command_states'(GETTHIRDWORD);
                    master.mHBUSREQ = 1;
                    case(1'b1)
                        !master.mHGRANT :
                            SetMem_ns = LWAIT;
                        !master.mHREADYin :
                            SetMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mHSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    MainMemory_Address_d = master.mHRDATA;
//                     r0_d = r0 + 4;
                end
                
                GETDATA :
                begin
                    SetMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state =command_states'(GETDATA);
                    shurukar_d = 1;
                    if (!master.mHREADYin)
                    begin
                        shurukar_d = 0;
                        SetMem_ns = NOREADY;
                    end
                    SetMem_data_d = master.mHRDATA;
                end
                
                LWAIT :
                begin
                    SetMem_ns = LWAIT;
                    master.mHBUSREQ = 1;
                    if (master.mHGRANT)
                    begin
                        SetMem_ns =LoadMem_states'(return_state);
                    end
                end
                
                NOREADY :
                begin
                    SetMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADYin)
                        SetMem_ns = LoadMem_states'(return_state);
                end
                
            
            endcase
            
        end        
        
    endcase 

    
    case(address_ps)
    
    MIDLE :     //0
    begin
        address_ns = MIDLE;
      //  master.mHTRANS = IDLE;
        if (shurukar)
        begin
            master.mHBUSREQ = 1;
            counter_d = Transfers;
//             address_ns = Get_Bus;
            address_ns = NON_SEQUENTIAL;
        end
    end
    
//     Get_Bus :
//     begin
//         address_ns = Get_Bus;
//         master.mHBUSREQ = 1;
//         if (HGRANT)
//         begin
//             counter_d = counter - 1;
//             address_ns = Non_Sequential;
//         end
//     end
    
    NON_SEQUENTIAL :        //1
    begin
        master.mHBUSREQ = 1;
        if (master.mHGRANT && master.mHREADYin)
        begin
            master.mHTRANS = NONSEQ;
            master.mHSIZE = _32bits;
            master.mHBURST = SINGLE;
            master.mHADDR = MainMemory_Address;
            master.mHWRITE = RW ? 1 : 0;

//             NN_RW_d = RW ? 1: 0;
        end
//         else
//         begin
//             address_ns = NON_SEQUENTIAL;
//         end
            case (1'b1)
        
            !master.mHREADYin :
                address_ns = MWAIT;
            !(counter == 1) :
            begin
                counter_d = counter - 1;
                address_ns = SEQUENTIAL;
            end
            counter == 1:
            begin
                done_d = 1;
                counter_d = counter - 1;
                address_ns = LAST_TRANSFER;
            end
            endcase
//         end
    end

    SEQUENTIAL :        //2
    begin
        master.mHTRANS = NONSEQ;
        master.mHSIZE = _32bits;
        master.mHBURST = SINGLE;
        master.mHADDR = MainMemory_Address + 4;
        MainMemory_Address_d = MainMemory_Address + 4;
        master.mHWRITE = RW ? 1 : 0;
        master.mHWDATA = neural.dout;
//         Rdata = master.mHRDATA;
        neural.sel = neural_sel;
        neural.RW = neural_RW;
        neural.din = master.mHRDATA;
        NN_Address_d = NN_Address + 1;
        neural.addr = NN_Address;
//         nn.addr = 
        case (1'b1)
        
        counter == 0 :
        begin
//             counter_d = counter - 1;
            done_d = 1;
            address_ns = LAST_TRANSFER;
        end
        !master.mHREADYin :
        begin
            master.mHBUSREQ = 1;
            address_ns = MWAIT;
        end
        default :
        begin
            master.mHBUSREQ = 1;
            counter_d = counter - 1;
            address_ns = SEQUENTIAL;
        end
        
        endcase
    end
    
    LAST_TRANSFER :     //3
    begin
        address_ns = LAST_TRANSFER;
        if(master.mHREADYin)
        begin
            neural.sel = neural_sel;
            neural.RW = neural_RW;
            address_ns = MIDLE;
            master.mHWDATA = neural.dout;
            neural.addr = NN_Address;
            neural.din = master.mHRDATA;
//             done_d = 1;
        end
    end
    
    MWAIT :         //4
    begin
        address_ns = SEQUENTIAL;
        master.mHBUSREQ = 1;
        master.mHTRANS = NONSEQ;
        master.mHADDR = MainMemory_Address_d;
        master.mHBURST = SINGLE;
        master.mHWRITE = 0;
        master.mHSIZE = _32bits;
        master.mHWDATA = hwdata_d;
        neural.addr = NN_Address;
        neural.din = master.mHRDATA;
        neural.sel = neural_sel;
        neural.RW = neural_RW;
//         Rdata = rdata_d;
        if (!master.mHGRANT || !master.mHREADYin)
            address_ns = MWAIT;
        else
            counter_d = counter - 1;
    end

    endcase
end

// always @(*)
// begin
//     master.mHTRANS = MIDLE;
//     master.mHBUSREQ = 0;
//     master.mHWDATA = hwdata_d;
//     master.mADDR = addr_d;
//     master.mMHSIZE = _32bits;
//     master.mHBURST = SINGLE;
//     master.mHWRITE = 0;
//     
//     done_d = 0;
//     Rdata = 0;
//     counter_d = counter;
//     address_ns = address_ps;
//     
//     case(address_ps)
//     
//     MIDLE :
//     begin
//         address_ns = MIDLE;
//         master.mHTRANS = IDLE;
//         if (shurukar)
//         begin
//             master.mHBUSREQ = 1;
//             counter_d = Transfers;
// //             address_ns = Get_Bus;
//             address_ns = NON_SEQUENTIAL;
//         end
//     end
//     
// //     Get_Bus :
// //     begin
// //         address_ns = Get_Bus;
// //         master.mHBUSREQ = 1;
// //         if (HGRANT)
// //         begin
// //             counter_d = counter - 1;
// //             address_ns = Non_Sequential;
// //         end
// //     end
//     
//     NON_SEQUENTIAL :
//     begin
//         master.mHBUSREQ = 1;
//         if (master.mHGRANT && master.mHREADY)
//         begin
//             master.mHTRANS = NONSEQ;
//             master.mHSIZE = _32bits;
//             master.mHBURST = SINGLE;
//             master.mHADDR = MainMemory_Address;
//             master.mHWRITE = RW ? 1 : 0;
//             NN_RW_d = RW ? 1: 0;
//         end
//         else
//         begin
//             address_ns = NON_SEQUENTIAL;
//         end
//         case (1'b1)
//     
//         !master.mHREADY :
//             address_ns = MWAIT;
//         !(counter == 1) :
//         begin
//             counter_d = counter - 1;
//             address_ns = SEQUENTIAL;
//         end
//         counter == 1:
//         begin
//             done = 1;
//             address_ns = LAST_TRANSFER;
//         end
//         endcase
//         end
// 
//     SEQUENTIAL :
//     begin
//         master.mHTRANS = NONSEQ;
//         master.mHSIZE = _32bits;
//         master.mHBURST = SINGLE;
//         master.mHADDR = MainMemory_Address + 4;
//         master.mHWRITE = RW ? 1 : 0;
//         master.mHWDATA = neural.dout;
// //         Rdata = master.mHRDATA;
//         neural.Sel = 1;
//         neural.RW = NN_RW;
//         neural.din = master.mHRDATA;
//         NN_Address_d = NN_Address + 1;
//         neural.addr = NN_Address;
// //         nn.addr = 
//         case (1'b1)
//         
//         counter == 1 :
//         begin
//             done = 1;
//             address_ns = MIDLE;
//         end
//         !master.mHREADY :
//         begin
//             master.mHBUSREQ = 1;
//             address_ns = MWAIT;
//         end
//         default :
//         begin
//             master.mHBUSREQ = 1;
//             counter_d = counter - 1;
//             address_ns = SEQUENTIAL;
//         end
//         
//         endcase
//     end
//     
//     LAST_TRANSFER :
//     begin
//         address_ns = MWAIT;
//         if(master.mHREADY)
//         begin
//             neural.Sel = 1;
//             neural.RW = NN_RW;
//             address_ns = MIDLE;
//             master.HWDATA = neural.dout;
//             neural.addr = NN_Address;
//             neural.din = master.mHRDATA;
//             done_d = 1;
//         end
//     end
//     
//     MWAIT :
//     begin
//         address_ns = SEQUENTIAL;
//         master.mHBUSREQ = 1;
//         master.mHTRANS = NONSEQ;
//         master.mHADDR = MainMemory_Address_d;
//         master.mHBURST = SINGLE;
//         master.mHWRITE = 0;
//         master.mHSIZE = _32bits;
//         master.mHWDATA = hwdata_d;
// //         Rdata = rdata_d;
//         if (!master.mHGRANT || !master.mHREADY)
//             address_ns = MWAIT;
//         else
//             counter_d = counter - 1;
//     end
// //     Sequential :
// //     begin
// //         HBUSREQ = 1;
// //         HTRANS = SEQ;
// //         HSIZE = _32bits;
// //         HADDR = MainMemory_Address + 4;
// //         HWRITE = write_d;
// //         HWDATA = Data;
// //         RDATA = HRDATA;
// //         case(1'b1)
// //             
// //         endcase
// //     end
// //
//     endcase
// end



always @(posedge master.HCLK or posedge master.HRESET)
    if(master.HRESET)
    begin
        ps <= #1 SIDLE;
        r0 <= #1 0;
        hello <= #1 0;
        ns_slave <= #1 0;
        sHREADYin_d <= #1 0;
        sHSEL_d <= #1 0;
        sHWRITE_d <= #1 0;
        command_ps <= #1 CIDLE;
        LoadMem_ps <= #1 LIDLE;
        address_ps <= #1 MIDLE;
        config_reg <= #1 0;
        LoadMem_start <= #1 0;
        SaveMem_start <= #1 0;
        SetMem_start <= #1 0;
        RW <= #1 0;
//         SaveMem_ps <= #1 IDLE;
//         SetMem_ps <= #1 IDLE;
        hwdata_d <= #1 0;
        counter <= #1 0;
        Transfers <= #1 0;
        RW <= #1 0;
        shurukar <= #1 0;
        MainMemory_Address <= #1 0;
        NN_Address <= #1 0;
        Rdata <= #1 0;
        done <= #1 0;
        SetMem_data <= #1 0;
        neural_RW <= #1 0;
        neural_sel <= #1 0;
        slave.sHRESP <= #1 2'b00;
         slave.sHREADY <= #1 1;
         slave.sHRDATA <= #1 0;
    end
    else
    begin
        ps <= #1 ns;
        hello <= #1 hello_d;
        sHREADYin_d <= #1 slave.sHREADYin;
        sHSEL_d <= #1 slave.sHSEL;
        sHWRITE_d <= #1 slave.sHWRITE;
        ns_slave <= #1 ps_slave;
        command_ps <= #1 command_ns;
        LoadMem_ps <= #1 LoadMem_ns;
        SaveMem_ps <= #1 SaveMem_ns;
        SetMem_ps <= #1 SetMem_ns;
        address_ps <= #1 address_ns;
        config_reg <= #1 config_reg_d;
        LoadMem_start <= #1 LoadMem_start_d;
        SaveMem_start <= #1 SaveMem_start_d;
        SetMem_start <= #1 SetMem_start_d;
        RW <= #1 RW_d;
//         SetMem_ps <= #1 SetMem_ns;
        counter <= #1 counter_d;
        Transfers <= #1 Transfers_d;
        RW <= #1 RW_d;
        shurukar <= #1 shurukar_d;
        done <= #1 done_d;
        neural_RW <= #1 neural_RW_d;
        neural_sel <= #1 neural_sel_d;
        slave.sHRESP <= #1 sHRESP_d;
        slave.sHREADY <= #1 sHREADY_d;
        slave.sHRDATA <= #1 sHRDATA_d;
        r0 <= #1 r0_d;


        if (!master.mHGRANT || !master.mHREADYin)
        begin
//             r0 <= #1 r0;
            MainMemory_Address <= #1 MainMemory_Address;
            NN_Address <= #1 NN_Address;
//             Rdata <= #1 Rdata;
            SetMem_data <= #1 SetMem_data;
            hwdata_d <= #1 hwdata_d;
        end
        else
        begin
//             r0 <= #1 r0_d;
            MainMemory_Address <= #1 MainMemory_Address_d;
            NN_Address <= #1 NN_Address_d;
//             Rdata <= #1 Rdata_d;
            SetMem_data <= #1 SetMem_data_d;
            hwdata_d <= #1 master.mHWDATA;
//             Rdata <= #1 master.mHRDATA;
        end
    end

/*      Master      */

endmodule : bmnn
