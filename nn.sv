// `timescale 1ns/10ps
// 
// `include "nnintf.svh"
// `include "mem_intf.svh"
`include "tablefetch.sv"
`include "rcalculation.sv"
`include "arbiter.sv"
`include "calcDipak.sv"


 
typedef struct packed signed
{
    reg signed [23:0] i0,i1,i2,i3,i4,i5,i6,i7,i8;
    reg signed [15:0] w0,w1,w2,w3,w4,w5,w6,w7;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] NeuronNumber;
} to_nncalculator_struct;


typedef struct packed signed
{
    logic signed [23:0] input0;
    logic signed [23:0] input1;
    logic signed [23:0] input2;
    logic signed [23:0] input3;
    logic signed [23:0] input4;
    logic signed [23:0] input5;
    logic signed [23:0] input6;
    logic signed [23:0] input7;
    logic signed [23:0] input8;
    logic signed [15:0] weight0;
    logic signed [15:0] weight1;
    logic signed [15:0] weight2;
    logic signed [15:0] weight3;
    logic signed [15:0] weight4;
    logic signed [15:0] weight5;
    logic signed [15:0] weight6;
    logic signed [15:0] weight7;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] NeuronNumber;
} from_tablefetch_struct;


typedef struct packed signed
{
    logic signed [47:0] Sum;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] NeuronNumber;
} from_nncalculator_struct;


module nn(nnIntf.nn n1,memIntf.mem m1,cmemIntf.mem c1);


typedef enum [1:0] {Idle, Busy, Push}states;

states tablefetch_ns, tablefetch_ps, nncalculator_ns, nncalculator_ps, rcalculator_ns, rcalculator_ps;

to_nncalculator_struct inputs_d,inputs_q;

from_tablefetch_struct Data,Data_d,Data_q;

from_nncalculator_struct out;



/*      Interface signals      */

logic [31:0] dout_d;
logic pushout_d;
reg pushout;
logic bus_stop_d;
reg bus_stop;
logic [10:0] NeuronNumber;

/*      Interface signals      */



/*      Memory Interface signals       */

logic [7:0][16:0] configaddress_from_tablefetch;
logic [7:0][15:0] datamem_address_from_tablefetch;

logic [7:0][16:0] configaddress_from_tablefetch_d;
logic [7:0][15:0] datamem_address_from_tablefetch_d;

reg [7:0][16:0] configaddress_from_tablefetch_q;
reg [7:0][15:0] datamem_address_from_tablefetch_q;

logic [7:0][16:0] configaddress_from_rcalculation;
logic [7:0][15:0] datamem_address_from_rcalculation;

logic [7:0][16:0] configaddress_from_rcalculation_d;
logic [7:0][15:0] datamem_address_from_rcalculation_d;

reg [7:0][16:0] configaddress_from_rcalculation_q;
reg [7:0][15:0] datamem_address_from_rcalculation_q;

logic [7:0][16:0] Caddress;
logic [7:0][15:0] Daddress;

logic signed [23:0] data_reg;

/*      Memory Interface signals       */



/*      Status Signals*/

logic done_d;
reg done;

logic push_from_tablefetch_d;
reg push_from_tablefetch;

logic calculation_start;
logic calculation_done;
logic hold;
logic rcalculation_start;
logic rcalculation_done;
logic halt;

logic request_from_tablefetch_d;
reg request_from_tablefetch;

logic request_from_rcalculator;

logic finish_from_tablefetch_d;
reg finish_from_tablefetch;

logic finish_from_nncalculator,finish_from_rcalculator;
logic grant_to_rcalculator;
logic grant_to_tablefetch;
logic stop_from_rcalculator;
logic stop_to_tablefetch;

/*      Status Signals*/



/*      My signals      */

logic shurukar;
reg shurukar_d;
logic calctime_d;

logic [31:0] r0_d;
reg [31:0] r0;

logic [15:0] Outloc;
logic last_d;
// logic signed [47:0] Sum_d;
// reg signed [47:0] Sum;
// logic signed [47:0] Rinput;
// logic signed [23:0] R;


/*      My signals*/



/*      Timepass Debug Signals      */

// reg signed [15:0] W0,W1,W2,W3,W4,W5,W6,W7;
// reg signed [23:0] I0,I1,I2,I3,I4,I5,I6,I7;

/*      Timepass Debug Signals      */



/*      Module Instantiation        */

tablefetch tf1(Data,configaddress_from_tablefetch,datamem_address_from_tablefetch,push_from_tablefetch,done,request_from_tablefetch,finish_from_tablefetch,n1.clk,n1.reset,shurukar,hold,grant_to_tablefetch,stop_from_rcalculator,Outloc,32'h10,c1.d,m1.d);

calc nc1(finish_from_tablefetch,halt,calculation_start,n1.clk,n1.reset,stop_from_rcalculator,Data,finish_from_nncalculator,calculation_done,hold,out);

rcalculation rc1(finish_from_rcalculator,request_from_rcalculator,rcalculation_done,halt,stop_from_rcalculator,configaddress_from_rcalculation,datamem_address_from_rcalculation,data_reg,Outloc,rcalculation_start,grant_to_rcalculator,n1.clk,n1.reset,finish_from_nncalculator,out,c1.d);

arbiter a1(grant_to_rcalculator,grant_to_tablefetch,Caddress,Daddress,request_from_rcalculator,request_from_tablefetch,configaddress_from_tablefetch,configaddress_from_rcalculation,datamem_address_from_tablefetch,datamem_address_from_rcalculation);

/*      Module Instantiation        */


assign n1.dout = dout_d;
assign n1.pushout = pushout;
assign n1.bus_stop = bus_stop;


always @(*)
begin
    c1.aw = 0;
	c1.write = 0;
	c1.wd = 0;
	c1.a = Caddress;
	m1.aw = 0;
	m1.write = 0;
	m1.wd = 0;
	m1.a = Daddress;
	dout_d = 0;
	pushout_d = 0;
	bus_stop_d = bus_stop;
	r0_d = r0;
	shurukar_d = 0;
	tablefetch_ns = tablefetch_ps;
    calculation_start = 0;
    rcalculation_start = 0;
    nncalculator_ns = nncalculator_ps;
    tablefetch_ns = tablefetch_ps;
    rcalculator_ns = rcalculator_ps;
	case(1'b1)
    
        bus_stop_d == 1 :
            dout_d = 0;

        n1.addr == 0 :
            r0_d = n1.din;
    
        n1.addr == 1 :
            calctime_d = 1;
        
        n1.addr == 20'h2 :
        begin
            if (n1.din == 32'hace)
                shurukar_d = 1;
            else
                shurukar_d = 0;
        end
        
        n1.addr >= 20'h20000 && n1.addr < 20'h40000 :
        begin
            if (n1.sel)
            begin
                if (n1.RW)
                begin
                    c1.aw = n1.addr;
                    c1.wd = n1.din;
                    c1.write = n1.RW;	
                end
                else
                begin
                    c1.a = n1.addr;
                    c1.write = n1.RW;
                    dout_d = #1 c1.d;
                end
            end
        end
        
        n1.addr >= 20'h40000 :
        begin
            if (n1.sel)
            begin
                if (n1.RW)
                begin
                    m1.aw = n1.addr;
                    m1.wd = n1.din;
                    m1.write = n1.RW;
                end
                else
                begin
                    m1.a = n1.addr;
                    m1.write = n1.RW;
                    dout_d = #1 {{8{m1.d[0][23]}},m1.d[0][23:0]};
                end
            end
        end

    endcase 

    
    case(tablefetch_ps)
    
        Idle :
        begin
            tablefetch_ns = Idle;
            if (shurukar)
            begin
                tablefetch_ns = Busy;
            end
        end
    
        Busy :
        begin
            if (push_from_tablefetch)
            begin
                tablefetch_ns = Push;
            end
            else
            begin
                if (done)
                    tablefetch_ns = Busy;
                else    
                    tablefetch_ns = Idle;
            end
        end
        
        Push :
        begin
            if (calculation_done)
            begin
                calculation_start = 1;
                tablefetch_ns = Busy;
            end
            else
                tablefetch_ns = Push;
        end
        
    endcase
    
    
    case(nncalculator_ps)
    
        Idle :
        begin
            nncalculator_ns = Idle;
            if (calculation_start)
            begin
                nncalculator_ns = Busy;
            end
        end
    
        Busy :
        begin
            if (calculation_done)
            begin
                nncalculator_ns = Push;
            end
            else
                nncalculator_ns = Busy;
        end
        
        Push :
        begin
            if (rcalculation_done)
            begin
                rcalculation_start = 1;
                nncalculator_ns = Idle;
            end
            else
                nncalculator_ns = Push;
        end
        
    endcase
    
    
    case(rcalculator_ps)
    
        Idle :
        begin
            rcalculator_ns = Idle;
            if (rcalculation_start)
            begin
                rcalculator_ns = Busy;
            end
        end
    
        Busy :
        begin
            if (rcalculation_done)
            begin
                m1.aw = Daddress;
                m1.write = 1;
                m1.wd = data_reg;
                rcalculator_ns = Idle;
            end
            else
                rcalculator_ns = Busy;
        end
        
    endcase

        if (finish_from_tablefetch && finish_from_nncalculator && finish_from_rcalculator)
            pushout_d = 1;
end


always @(posedge n1.clk or posedge n1.reset)
begin
    if (n1.reset)
    begin
        r0 <= #1 0;
		pushout <= #1 0;
		bus_stop <= #1 0;
        tablefetch_ps <= #1 Idle;
        nncalculator_ps <= #1 Idle;
        rcalculator_ps <= #1 Idle;
        shurukar <= #1 0;
//         configaddress_from_tablefetch_q <= #1 0;
//         configaddress_from_rcalculation_q <= #1 0;
//         Data_q <= #1 0;
//         shurukar <= #1 0;
//         push_from_tablefetch <= #1 0;
//         done <= #1 0;
//         W0 <= #1 0;
//         W1 <= #1 0;
//         W2 <= #1 0;
//         W3 <= #1 0;
//         W4 <= #1 0;
//         W5 <= #1 0;
//         W6 <= #1 0;
//         W7 <= #1 0;
//         I0 <= #1 0;
//         I1 <= #1 0;
//         I2 <= #1 0;
//         I3 <= #1 0;
//         I4 <= #1 0;
//         I5 <= #1 0;
//         I6 <= #1 0;
//         I7 <= #1 0;
    
    end
    else
    begin
        r0 <= #1 r0_d;
        pushout <= #1 pushout_d;
        bus_stop <= #1 bus_stop_d;
        tablefetch_ps <= #1 tablefetch_ns;
        nncalculator_ps <= #1 nncalculator_ns;
        rcalculator_ps <= #1 rcalculator_ns;
        shurukar <= #1 shurukar_d;
//         configaddress_from_tablefetch_q <= #1 configaddress_from_tablefetch_d;
//         configaddress_from_rcalculation_q <= #1 configaddress_from_rcalculation_d;
//         Data_q <= #1 Data_d;
//         shurukar <= #1 shurukar_d;
//         push_from_tablefetch <= #1 push_from_tablefetch_d;
//         done <= #1 done_d;
//         W0 <= #1 inputs.w0;
//         W1 <= #1 inputs.w1;
//         W2 <= #1 inputs.w2;
//         W3 <= #1 inputs.w3;
//         W4 <= #1 inputs.w4;
//         W5 <= #1 inputs.w5;
//         W6 <= #1 inputs.w6;
//         W7 <= #1 inputs.w7;
//         I0 <= #1 inputs.w0;
//         I1 <= #1 inputs.w1;
//         I2 <= #1 inputs.w2;
//         I3 <= #1 inputs.w3;
//         I4 <= #1 inputs.w4;
//         I5 <= #1 i2.input3;
//         I6 <= #1 0;
//         I7 <= #1 0;
    
    end
end

endmodule 
