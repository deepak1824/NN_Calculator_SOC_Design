module AHBBusmaster (AHBMIntf.AHBM master, AHBSInt.AHBS slave, nnIntf.nn neural);

parameter IDLE = 2'b00;
parameter NONSEQ = 2'b10;
parameter SINGLE = 3'b000;
parameter _32bits = 3'b010;


typedef enum {SIDLE, WRITE_R0, GETCOMMAND, READ_R0, SWAIT} states;
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

always @(*)
begin
    master.mHTRANS = IDLE;
    master.mHBUSREQ = 0;
    master.mHWDATA = hwdata_d;
    master.mADDR = addr_d;
    master.mMHSIZE = _32bits;
    master.mHBURST = SINGLE;
    master.mHWRITE = 0;
    
    neural.sel = 0;
    neural.RW = 0;
    neural.din = 0;
    neural.addr = 0;
    
    neural_RW_d = neural_RW;
    neural_sel_d = neural_sel
    r0_d = r0;
    
    done_d = 0;
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
    
    case(ps)
    
        SIDLE :
        begin
            ns = SIDLE;
            if (r0)
            begin
                master.mHBUSREQ = 1;
                ns = GETCOMMAND;
            end
        end
        
        GETCOMMAND :                                // NEED TO CHECK FOR READY
        begin
            ns = GETCOMMAND;
            master.mHBUSREQ = 1;
            if (master.mHGRANT)
            begin
                master.mHTRANS = NONSEQ;
                master.mHSIZE = _32bits;
                master.mHBURST = SINGLE;
                master.mHWRITE = 0;
                master.mHADDR = r0;
                ns = WRITE_R0;
            end
        end
        
        WRITE_R0 :                  // Get first word
        begin
            ns = WRITE_R0;
            if (master.mHREADY)
            begin
                config_reg_d = master.mHRDATA;
                ns = READ_R0;
            end
        end
        
        READ_R0 :
        begin
            case(1'b1)
            
                config_reg[31:24] == 8'd1 :
                begin
                    command_ns = LOADMEM;
                    master.mHBUSREQ = 1;
                    LoadMem_start_d = 1;
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
                    r0_d = r0 + 4;
                    ns = READ_R0;
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
                    if (neural.pushout)
                    begin
                        master.mHBUSREQ = 1;
                        r0_d = r0 + 4;
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
                    ns = SIDLE;
                end
                
            endcase
        end
            
        SWAIT :
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
//             case(1'b1)
//                 LoadMem_start_d :
//                     command_ns = LOADMEM;
//                 SaveMem_start_d :
//                     command_ns = SAVEMEM;
//                 SetMem_start_d :
//                     command_ns = SETMEM;
//             endcase
        end
        
        LOADMEM :
        begin
            
            case (LoadMem_ps)
            
                LIDLE :  
                begin
                    LoadMem_ns = LIDLE;
                    if (LoadMem_start)
                    begin
                        master.mHBUSREQ = 1;
                        LoadMem_ns = GETSECONDWORD;
                    end
                end
                
                GETSECONDWORD :
                begin
                    LoadMem_ns = GETTHIRDWORD;
                    return_state = GETSECONDWORD;
                    master.mHBUSREQ = 1;
                    case (1'b1)
                        !master.mHGRANT :
                            LoadMem_ns = LWAIT;
                        !master.mHREADY :
                            LoadMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                end
                
                GETTHIRDWORD :
                begin
                    LoadMem_ns = GETDATA;
                    return_state = GETTHIRDWORD;
                    master.mHBUSREQ = 1;
                    case(1'b1)
                        !master.mHGRANT :
                            LoadMem_ns = LWAIT;
                        !master.mHREADY :
                            LoadMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    MainMemory_Address_d = master.mHRDATA;
                    r0_d = r0 + 4;
                end
                
                GETDATA :
                begin
                    LoadMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state = GETDATA;
                    shurukar_d = 1;
                    if (!master.mHREADY)
                    begin
                        shurukar_d = 0;
                        LoadMem_ns = NOREADY;
                    end
                    NN_Address_d = master.mHRDATA[31] ? 20'h20000 : 20'h40000;
                end
                
                LWAIT :
                begin
                    LoadMem_ns = LWAIT;
                    master.mHBUSREQ = 1;
                    if (master.mHGRANT)
                    begin
                        LoadMem_ns = return_state;
                    end
                end
                
                NOREADY :
                begin
                    LoadMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADY)
                        LoadMem_ns = return_state;
                end
                
            
            endcase
            
        end
    
        SAVEMEM :
        begin
        
            case(SaveMem_ns)
                
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
                    return_state = GETSECONDWORD;
                    master.mHBUSREQ = 1;
                    case (1'b1)
                        !master.mHGRANT :
                            SaveMem_ns = LWAIT;
                        !master.mHREADY :
                            SaveMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                end
                
                GETTHIRDWORD :
                begin
                    SaveMem_ns = GETDATA;
                    return_state = GETTHIRDWORD;
                    master.mHBUSREQ = 1;
                    case(1'b1)
                        !master.mHGRANT :
                            SaveMem_ns = LWAIT;
                        !master.mHREADY :
                            SaveMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    NN_Address_d = master.mHRDATA[31] ? 20'h20000 : 20'h40000;
                    r0_d = r0 + 4;
                end
                
                GETDATA :
                begin
                    SaveMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state = GETDATA;
                    shurukar_d = 1;
                    if (!master.mHREADY)
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
                        SaveMem_ns = return_state;
                    end
                end
                
                NOREADY :
                begin
                    SaveMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADY)
                        SaveMem_ns = return_state;
                end
                
            
            endcase
            
        end        
        
        SETMEM :
        begin
        
            case(SetMem_ns)
                
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
                    return_state = GETSECONDWORD;
                    master.mHBUSREQ = 1;
                    case (1'b1)
                        !master.mHGRANT :
                            SetMem_ns = LWAIT;
                        !master.mHREADY :
                            SetMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    r0_d = r0 + 4;
                end
                
                GETTHIRDWORD :
                begin
                    SetMem_ns = GETDATA;
                    return_state = GETTHIRDWORD;
                    master.mHBUSREQ = 1;
                    case(1'b1)
                        !master.mHGRANT :
                            SetMem_ns = LWAIT;
                        !master.mHREADY :
                            SetMem_ns = NOREADY;
                    endcase
                    master.mHTRANS = NONSEQ;
                    master.mSIZE = _32bits;
                    master.mHBURST = SINGLE;
                    master.mHWRITE = 0;
                    master.mHADDR = r0;
                    MainMemory_Address_d = master.mHRDATA;
                    r0_d = r0 + 4;
                end
                
                GETDATA :
                begin
                    SetMem_ns = LIDLE;
                    master.mHBUSREQ = 1;
                    return_state = GETDATA;
                    shurukar_d = 1;
                    if (!master.mHREADY)
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
                        SetMem_ns = return_state;
                    end
                end
                
                NOREADY :
                begin
                    SetMem_ns = NOREADY;
                    master.mHBUSREQ = 1;
                    if (master.mHREADY)
                        SetMem_ns = return_state;
                end
                
            
            endcase
            
        end        
        
    endcase 

    
    case(address_ps)
    
    MIDLE :
    begin
        address_ns = MIDLE;
        master.mHTRANS = IDLE;
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
    
    NON_SEQUENTIAL :
    begin
        master.mHBUSREQ = 1;
        if (master.mHGRANT && master.mHREADY)
        begin
            master.mHTRANS = NONSEQ;
            master.mHSIZE = _32bits;
            master.mHBURST = SINGLE;
            master.mHADDR = MainMemory_Address;
            master.mHWRITE = RW ? 1 : 0;
//             NN_RW_d = RW ? 1: 0;
        end
        else
        begin
//             address_ns = NON_SEQUENTIAL;
//         end
            case (1'b1)
        
            !master.mHREADY :
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
        end
    end

    SEQUENTIAL :
    begin
        master.mHTRANS = NONSEQ;
        master.mHSIZE = _32bits;
        master.mHBURST = SINGLE;
        master.mHADDR = MainMemory_Address + 4;
        master.mHWRITE = RW ? 1 : 0;
        master.mHWDATA = neural.dout;
//         Rdata = master.mHRDATA;
        neural.Sel = neural_sel;
        neural.RW = neural_RW;
        neural.din = master.mHRDATA;
        NN_Address_d = NN_Address + 1;
        neural.addr = NN_Address;
//         nn.addr = 
        case (1'b1)
        
        counter == 1 :
        begin
            done_d = 1;
            counter_d = counter - 1;
            address_ns = MIDLE;
        end
        !master.mHREADY :
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
    
    LAST_TRANSFER :
    begin
        address_ns = MWAIT;
        if(master.mHREADY)
        begin
            neural.Sel = neural_sel;
            neural.RW = neural_RW;
            address_ns = MIDLE;
            master.HWDATA = neural.dout;
            neural.addr = NN_Address;
            neural.din = master.mHRDATA;
//             done_d = 1;
        end
    end
    
    MWAIT :
    begin
        address_ns = SEQUENTIAL;
        master.mHBUSREQ = 1;
        master.mHTRANS = NONSEQ;
        master.mHADDR = MainMemory_Address_d;
        master.mHBURST = SINGLE;
        master.mHWRITE = 0;
        master.mHSIZE = _32bits;
        master.mHWDATA = hwdata_d;
//         Rdata = rdata_d;
        if (!master.mHGRANT || !master.mHREADY)
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



always @(master.HCLK or master.HRESET)
    if(master.HRESET)
    begin
        ps <= #1 SIDLE;
        r0 <= #1 0;
        command_ps <= #1 CIDLE;
        LoadMem_ps <= #1 LIDLE;
        address_ps <= #1 MIDLE;
//         SaveMem_ps <= #1 IDLE;
//         SetMem_ps <= #1 IDLE;
        hwdata <= #1 0;
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
    end
    else
    begin
        ps <= #1 ns;
        command_ps <= #1 command_ns;
        LoadMem_ps <= #1 LoadMem_ns;
        address_ps <= #1 address_ns;
//         SetMem_ps <= #1 SetMem_ns;
        counter <= #1 counter_d;
        Transfers <= #1 Transfers_d;
        RW <= #1 RW_d;
        shurukar <= #1 shurukar_d;
        done <= #1 done_d;
        neural_RW <= #1 neural_RW_d;
        neural_sel <= #1 neural_sel_d;
        if (!master.mHGRANT || !master.mHREADY)
        begin
            r0 <= #1 r0;
            MainMemory_Address <= #1 MainMemory_Address;
            NN_Address <= #1 NN_Address;
//             Rdata <= #1 Rdata;
            SetMem_data <= #1 SetMem_data;
            hwdata <= #1 hwdata;
        end
        else
        begin
            r0 <= #1 r0_d;
            MainMemory_Address <= #1 MainMemory_Address_d;
            NN_Address <= #1 NN_Address_d;
//             Rdata <= #1 Rdata_d;
            SetMem_data <= #1 SetMem_data_d;
            hwdata <= #1 master.mHWDATA;
//             Rdata <= #1 master.mHRDATA;
        end
    end
endmodule
