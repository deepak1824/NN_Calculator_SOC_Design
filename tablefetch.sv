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
    logic [9:0] NInputs;
    logic [10:0] NeuronNumber;
} output_struct;

module tablefetch(output output_struct out_q, reg [7:0][16:0]config_address,reg [7:0][15:0]data_mem_address,reg push,reg stop_out,reg bus_request, reg Finish,input clk,reset,shurukar,stopin,bus_grant,done_from_rcalculator,[15:0] OutLoc,[31:0]r0,[255:0]config_data,[191:0]data_mem_data);


output_struct out_d;

typedef struct packed
{
    logic [3:0] reserved;
    logic [16:0] location;
    logic [10:0] layer;
} Layer_table;

Layer_table Layer1_d,Layer1_q,Layer2_d,Layer2_q;

typedef struct packed
{
    logic [22:0] Flags;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] NeuronTable;
    logic [16:0] Wimap;
    logic [16:0] Nimap;
    logic [16:0] Oloc;
    logic [16:0] Lbase;
    logic [9:0] Ninputs;
} Neuron_table;

Neuron_table Table_d,Table_q;

typedef struct packed signed
{
    logic signed [15:0] weight0;
    logic signed [15:0] weight1;
    logic signed [15:0] weight2;
    logic signed [15:0] weight3;
    logic signed [15:0] weight4;
    logic signed [15:0] weight5;
    logic signed [15:0] weight6;
    logic signed [15:0] weight7;
} weights;

weights w_d,w_q;

typedef struct packed signed
{
    logic signed [23:0] input1;
    logic signed [23:0] input2;
    logic signed [23:0] input3;
} input_struct;

input_struct i1,i2,i3;

typedef struct packed
{
    logic [23:0] extra_input1;
    logic [23:0] extra_input2;
    logic [23:0] extra_input3;
} holding_input_struct;

holding_input_struct h1_d,h1_q,h2_d,h2_q;


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
} inputs;

inputs i_d,i_q;

typedef enum [3:0] {Idle,Fetch_layer1, Fetch_layer2,Fetch_neuron_table, Fetch_weights,Fetch_inputs,Push_data,Check_input_count,Fetch_next_weights_inputs,Fetch_3,Fetch_2,Check_neuron_count,Check_layer,Wait_for_Rcalculator, Wait_for_grant} states;

states ps,ns,return_state;


/*      Counter Variables       */
logic [1:0] input_counter_d;
reg [1:0] input_counter;

logic [10:0] index_d;
reg [10:0] index;

logic [31:0] offset_d;
reg [31:0] offset;

logic [31:0] woffset_d;
reg [31:0] woffset;

logic [31:0] layer_offset_d;
reg [31:0] layer_offset;

/*      Status Variables        */
logic done;
logic Finish_d;
logic push_d;
logic [1:0] carry_d;
reg [1:0] carry;
/*      Memory variables        */
logic [255:0] config_reg;
logic [191:0] data_reg;



/*      Neuron table variables  */
logic [10:0] Neuron_number_d;
reg [10:0] Neuron_number;

logic [9:0] Ninputs_d;
reg [9:0] Ninputs;

logic [10:0] Clayer_d;
reg [10:0] Clayer;

reg shurukar_d;
/*      Timepass Debug variables      */

logic problem_d;
reg problem;
logic [16:0] temp,temp1,temp2,temp3;
reg [16:0] Lbase, Oloc, Nimap, Wimap, NeuronTable;
reg [16:0] Ntable;
reg [4:0] PostShift,NeuronShift;
reg [22:0] Flags;
logic [16:0] Loc;

reg signed [15:0] W0,W1,W2,W3,W4,W5,W6,W7;
reg signed [23:0] I0,I1,I2,I3,I4,I5,I6,I7;

always @(*)
begin

    data_mem_address = 0;
    config_address = 0;
    input_counter_d = input_counter;
    index_d = index;
    Ninputs_d = Ninputs;
    done = 0;
    push_d = 0;
    bus_request = 1;
    stop_out = 0;
    w_d = w_q;
    i_d = i_q;
    out_d = out_q;
    Table_d = Table_q;
    Layer2_d = Layer2_q;
    Layer1_d = Layer1_q;
    Finish_d = Finish;
    Neuron_number_d = Neuron_number;
    offset_d = offset;
    woffset_d = woffset;
    carry_d = carry;
    layer_offset_d = layer_offset;
    Clayer_d = Clayer;
    ns = ps;
    return_state = ps;
    problem_d = 0;
    case(ps)
    
        Idle :  //0
        begin
            ns = Idle;
            config_address = 0;
            index_d = 0;
            input_counter_d = 0;
            if (shurukar)
            begin
                config_address = r0;
                Finish_d = 0;
                if (bus_grant)
                    ns = Fetch_layer1;
                else
                    ns = Wait_for_grant;
            end
            return_state = ps;

        end
        
        Fetch_layer1 :  //1
        begin
            Layer1_d.layer = config_reg[31:21];
            Layer1_d.location = config_reg[20:4];
            Layer1_d.reserved = 0;
            config_address = config_reg[20:4];
            stop_out = 1;
            Clayer_d = config_reg[31:21];
            if (bus_grant)
                ns = Fetch_layer2;
            else
                ns = Wait_for_grant;
            return_state = ps;
        end
        
        Fetch_layer2 :  //2
        begin
            Layer2_d.layer = config_reg[31:21];
            Layer2_d.location = config_reg[20:4];
            Layer2_d.reserved = 0;
            config_address[0] = config_reg[20:4];
            config_address[1] = config_reg[20:4] + 17'd1;
            config_address[2] = config_reg[20:4] + 17'd2;
            config_address[3] = config_reg[20:4] + 17'd3;
            stop_out = 1;
            if (bus_grant)
                ns = Fetch_neuron_table;
            else
                ns = Wait_for_grant;
                
            
            return_state = ps;
        end
        
        Fetch_neuron_table :    //3
        begin
            Table_d.Ninputs = config_reg[127:118];
            Table_d.Lbase = config_reg[117:101];
            Table_d.Oloc = config_reg[100:84];
            Table_d.Nimap = config_reg[83:67];
            Table_d.Wimap = config_reg[66:50];
            Table_d.NeuronTable = config_reg[49:33];
            Table_d.NeuronShift = config_reg[32:28];
            Table_d.PostShift = config_reg[27:23];
            Table_d.Flags = config_reg[22:0];
            config_address[0] = config_reg[83:67];              //3
            config_address[1] = config_reg[83:67] + 17'd1;      //3
            config_address[2] = config_reg[83:67] + 17'd2;      //3
            config_address[3] = config_reg[66:50];
            config_address[4] = config_reg[66:50] + 17'd1;
            config_address[5] = config_reg[66:50] + 17'd2;
            config_address[6] = config_reg[66:50] + 17'd3;
            stop_out = 1;
            if (bus_grant)
            begin
                ns = Fetch_weights;
                Neuron_number_d = Neuron_number - 10'd1;
            end
            else
                ns = Fetch_neuron_table;
            return_state = ps;
        end
        
        Fetch_weights :  //4
        begin
            data_mem_address[0] = config_reg[9:0] + Table_q.Lbase;
            data_mem_address[1] = config_reg[19:10] + Table_q.Lbase;
            data_mem_address[2] = config_reg[29:20] + Table_q.Lbase;
            data_mem_address[3] = config_reg[41:32] + Table_q.Lbase;
            data_mem_address[4] = config_reg[51:42] + Table_q.Lbase;            
            data_mem_address[5] = config_reg[61:52] + Table_q.Lbase;
            data_mem_address[6] = config_reg[73:64] + Table_q.Lbase;
            data_mem_address[7] = config_reg[83:74] + Table_q.Lbase;
            h1_d.extra_input1 = config_reg[93:84] + Table_q.Lbase;
            h2_d.extra_input1 = config_reg[83:74] + Table_q.Lbase;
            h2_d.extra_input2 = config_reg[93:84] + Table_q.Lbase;
//             data_mem_address[8] = config_reg[91:82] + Table_q.Lbase;
            w_d.weight0 = config_reg[111:96];
            w_d.weight1 = config_reg[127:112];
            w_d.weight2 = config_reg[143:128];
            w_d.weight3 = config_reg[159:144];
            w_d.weight4 = config_reg[175:160];
            w_d.weight5 = config_reg[191:176];
            w_d.weight6 = config_reg[207:192];
            w_d.weight7 = config_reg[223:208];
            input_counter_d = input_counter + 10'd1;
            if (((data_mem_address[0] == OutLoc) || (data_mem_address[1] == OutLoc) || (data_mem_address[2] == OutLoc) || (data_mem_address[3] == OutLoc) || (data_mem_address[4] == OutLoc) || (data_mem_address[5] == OutLoc)|| (data_mem_address[6] == OutLoc) || (data_mem_address[7] == OutLoc)) && !done_from_rcalculator)
                problem_d = 1;
            else
                problem_d = 0;
            
            if (bus_grant)
                ns = Fetch_inputs;
            else
                ns = Fetch_weights;
            stop_out = 1;
            
            
            
            return_state = ps;
        end
        
        Fetch_inputs :  //5
        begin
            i_d.input0 = data_reg[23:0];
            i_d.input1 = data_reg[47:24];
            i_d.input2 = data_reg[71:48];
            i_d.input3 = data_reg[95:72];
            i_d.input4 = data_reg[119:96];
            i_d.input5 = data_reg[143:120];
            i_d.input6 = data_reg[167:144];
            i_d.input7 = data_reg[191:168];
            case(1'b1)
            
                Ninputs == 7 :
                begin
                    w_d.weight7 = 0;
                    i_d.input7 = 0;
                end
                Ninputs == 6 :
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                end
                Ninputs == 5 :
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    w_q.weight5 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                    i_d.input5 = 0;
                end
                Ninputs == 4 :
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    w_q.weight5 = 0;
                    w_q.weight4 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                    i_d.input5 = 0;
                    i_d.input4 = 0;
                end
                Ninputs == 3 :
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    w_q.weight5 = 0;
                    w_q.weight4 = 0;
                    w_q.weight3 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                    i_d.input5 = 0;
                    i_d.input4 = 0;
                    i_d.input3 = 0;
                end
                Ninputs == 2 :
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    w_q.weight5 = 0;
                    w_q.weight4 = 0;
                    w_q.weight3 = 0;
                    w_q.weight2 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                    i_d.input5 = 0;
                    i_d.input4 = 0;
                    i_d.input3 = 0;
                    i_d.input2 = 0;
                end
                Ninputs == 1:
                begin
                    w_q.weight7 = 0;
                    w_q.weight6 = 0;
                    w_q.weight5 = 0;
                    w_q.weight4 = 0;
                    w_q.weight3 = 0;
                    w_q.weight2 = 0;
                    w_q.weight1 = 0;
                    i_d.input7 = 0;
                    i_d.input6 = 0;
                    i_d.input5 = 0;
                    i_d.input4 = 0;
                    i_d.input3 = 0;
                    i_d.input2 = 0;
                    i_d.input1 = 0;
                end
            
            endcase
            stop_out = 1;
            ns = Push_data;
        end
        
        Push_data :     //6
        begin
            if (stopin)
            begin
                w_d = w_q;
                i_d = i_q;
                ns = Push_data;
            end
            else
            begin
                push_d = 1;
                out_d.input0 = i_q.input0;
                out_d.input1 = i_q.input1;
                out_d.input2 = i_q.input2;
                out_d.input3 = i_q.input3;
                out_d.input4 = i_q.input4;
                out_d.input5 = i_q.input5;
                out_d.input6 = i_q.input6;
                out_d.input7 = i_q.input7;
                out_d.weight0 = w_q.weight0;
                out_d.weight1 = w_q.weight1;
                out_d.weight2 = w_q.weight2;
                out_d.weight3 = w_q.weight3;
                out_d.weight4 = w_q.weight4;
                out_d.weight5 = w_q.weight5;
                out_d.weight6 = w_q.weight6;
                out_d.weight7 = w_q.weight7;
                out_d.NeuronTable = Table_q.NeuronTable;
                out_d.NeuronShift = Table_q.NeuronShift;
                out_d.PostShift = Table_q.PostShift;
                out_d.Oloc = Table_q.Oloc;
                out_d.NInputs = Ninputs;
                out_d.NeuronNumber = Neuron_number;
                ns = Check_input_count;
            end
            stop_out = 1;
        end
        
        Check_input_count :     //7
        begin
            if (Ninputs > 10'd8)
            begin
                ns = Fetch_next_weights_inputs;
                offset_d = input_counter == 0 ? offset + 2 : offset + 3;
                woffset_d = woffset + 4;
            end
            else        
            begin
                ns = Check_neuron_count;
            end 
            
            stop_out = 1;
        end
        
        Fetch_next_weights_inputs : //8
        begin
            if(bus_grant)
            begin
                Ninputs_d = Ninputs - 10'd8;
                config_address[0] = Table_q.Nimap + offset;
                config_address[1] = Table_q.Nimap + offset + 17'd1;
                config_address[2] = Table_q.Nimap + offset + 17'd2;
                config_address[3] = Table_q.Wimap + woffset;
                config_address[4] = Table_q.Wimap + woffset + 17'd1;
                config_address[5] = Table_q.Wimap + woffset + 17'd2;
                config_address[6] = Table_q.Wimap + woffset + 17'd3;
    //             ns = Fetch_3;
            end
            case(1'b1)
                input_counter == 1 :
                begin
//                     offset_d = offset + 3;
                    ns = bus_grant ? Fetch_3 : Fetch_next_weights_inputs;
                end
                input_counter == 2 :
                begin
//                     offset_d = offset + 3;
                    input_counter_d = 0;
                    ns = bus_grant ? Fetch_2 : Fetch_next_weights_inputs;
                end
                input_counter == 0 :
                begin
//                     offset_d = offset + 2 ;
                    ns = bus_grant ? Fetch_weights : Fetch_next_weights_inputs;
                end
            endcase
            stop_out = 1;
            return_state = ps;
        end
        
        Fetch_3 :       //9
        begin
            data_mem_address[0] = h1_q.extra_input1;
            data_mem_address[1] = config_reg[9:0] + Table_q.Lbase;
            data_mem_address[2] = config_reg[19:10] + Table_q.Lbase;
            data_mem_address[3] = config_reg[29:20] + Table_q.Lbase;
            data_mem_address[4] = config_reg[41:32] + Table_q.Lbase;
            data_mem_address[5] = config_reg[51:42] + Table_q.Lbase;            
            data_mem_address[6] = config_reg[61:52] + Table_q.Lbase;
            data_mem_address[7] = config_reg[73:64] + Table_q.Lbase;
            h2_d.extra_input1 = config_reg[83:74] + Table_q.Lbase;
            h2_d.extra_input2 = config_reg[93:84] + Table_q.Lbase;
//             data_mem_address[8] = config_reg[91:82] + Table_q.Lbase;
            w_d.weight0 = config_reg[111:96];
            w_d.weight1 = config_reg[127:112];
            w_d.weight2 = config_reg[143:128];
            w_d.weight3 = config_reg[159:144];
            w_d.weight4 = config_reg[175:160];
            w_d.weight5 = config_reg[191:176];
            w_d.weight6 = config_reg[207:192];
            w_d.weight7 = config_reg[223:208];
            input_counter_d = input_counter + 10'd1;
            if (bus_grant)
            ns = Fetch_inputs;
            else
                ns = Fetch_3;
            if (((data_mem_address[0] == OutLoc) || (data_mem_address[1] == OutLoc) || (data_mem_address[2] == OutLoc) || (data_mem_address[3] == OutLoc) || (data_mem_address[4] == OutLoc) || (data_mem_address[5] == OutLoc)|| (data_mem_address[6] == OutLoc) || (data_mem_address[7] == OutLoc)))
                problem_d = 1;
            else
                problem_d = 0;   
            stop_out = 1;
            return_state = ps;
        end
        
        Fetch_2 :       //10
        begin
            data_mem_address[0] = h2_q.extra_input1;
            data_mem_address[1] = h2_q.extra_input2;
            data_mem_address[2] = config_reg[9:0] + Table_q.Lbase;
            data_mem_address[3] = config_reg[19:10] + Table_q.Lbase;
            data_mem_address[4] = config_reg[29:20] + Table_q.Lbase;
            data_mem_address[5] = config_reg[41:32] + Table_q.Lbase;
            data_mem_address[6] = config_reg[51:42] + Table_q.Lbase;            
            data_mem_address[7] = config_reg[61:52] + Table_q.Lbase;
            w_d.weight0 = config_reg[111:96];
            w_d.weight1 = config_reg[127:112];
            w_d.weight2 = config_reg[143:128];
            w_d.weight3 = config_reg[159:144];
            w_d.weight4 = config_reg[175:160];
            w_d.weight5 = config_reg[191:176];
            w_d.weight6 = config_reg[207:192];
            w_d.weight7 = config_reg[223:208];
            input_counter_d = 0;
            if (bus_grant)
                ns = Fetch_inputs;
            else
                ns = Fetch_2;
            stop_out = 1;
            return_state = ps;
             if (((data_mem_address[0] == OutLoc) || (data_mem_address[1] == OutLoc) || (data_mem_address[2] == OutLoc) || (data_mem_address[3] == OutLoc) || (data_mem_address[4] == OutLoc) || (data_mem_address[5] == OutLoc)|| (data_mem_address[6] == OutLoc) || (data_mem_address[7] == OutLoc)))
                problem_d = 1;
            else
                problem_d = 0;   
        end
        Check_neuron_count :    //11
        begin
            done = 1;
            offset_d = 0;
            woffset_d = 0;
            carry_d = 0;
            input_counter_d = 0;
            if (Neuron_number)
            begin
//                 Neuron_number_d = Neuron_number - 10'd1;
                config_address[0] = Layer2_q.location + index + 17'd0;
                config_address[1] = Layer2_q.location + index + 17'd1;
                config_address[2] = Layer2_q.location + index + 17'd2;
                config_address[3] = Layer2_q.location + index + 17'd3;
                if (bus_grant)
                    ns = Fetch_neuron_table;
                else
                    ns = Check_neuron_count;
            end
            else
            begin
                index_d = 0;
//                 layer_offset_d = layer_offset + 1;
//                 Clayer_d = Clayer - 1;
                ns = Wait_for_Rcalculator;
//                 ns = Check_layer;
            end
            stop_out = 1;
            return_state = ps;
            
        end
        
        Wait_for_Rcalculator :
        begin
            if(done_from_rcalculator)
            begin
                layer_offset_d = layer_offset + 1;
                Clayer_d = Clayer - 1;
                ns = Check_layer;
            end
            else
                ns = Wait_for_Rcalculator;
            stop_out = 1;
        end
        
        Check_layer :   //12
        begin
//             index_d = 0;
            if (Clayer)
            begin
                config_address = Layer1_q.location + layer_offset;
                stop_out = 1;
                ns = Fetch_layer2;
            end
            else
            begin
                ns = Idle;
                Finish_d = 1;
                stop_out = 0;
            
            end
//             ns = Idle;
//             Finish_d = 1;
//             stop_out = 0;
        end
        
        Wait_for_grant :
        begin
            config_address = config_reg;
            data_mem_address = config_reg;
            stop_out = 1;
            ns = return_state;
        end
    endcase
    
end



always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        ps <= #1 Idle;
        input_counter <= #1 0;
        index <= #1 0;
        Ninputs <= #1 0;
        Neuron_number <= #1 0;
        config_reg <= #1 0;
        data_reg <= #1 0;   
        w_q <= #1 0;
        i_q <= #1 0;
        Table_q <= #1 0;
        Finish <= #1 0;
        Layer1_q <= #1 0;
        Layer2_q <= #1 0;
        out_q <= #1 0;
        push <= #1 0;
        h1_q <= #1 0;
        h2_q <= #1 0;
        Ninputs <= #1 0;
        Oloc <= #1 0;
        Lbase <= #1 0;
        Nimap <= #1 0;
        Wimap <= #1 0;
        PostShift <= #1 0;
        NeuronShift <= #1 0;
        Flags <= #1 0;
        NeuronTable <= #1 0;
        W0 <= #1 0;
        W1 <= #1 0;
        W2 <= #1 0;
        W3 <= #1 0;
        W4 <= #1 0;
        W5 <= #1 0;
        W6 <= #1 0;
        W7 <= #1 0;
        I0 <= #1 0;
        I1 <= #1 0;
        I2 <= #1 0;
        I3 <= #1 0;
        I4 <= #1 0;
        I5 <= #1 0;
        offset <= #1 0;
        woffset <= #1 0;
        carry <= #1 0;
        Loc <= #1 0;
        Ntable <= #1 0;
        Clayer <= #1 0;
        layer_offset <= #1 0;
        problem <= #1 0;
     
//         I6 <= #1 0;
//         I7 <= #1 0;
    end
    else
    begin
        if (problem_d)
            ps <= #1 ps;
        else
            ps <= #1 ns;
        if (problem_d || !bus_grant)
            input_counter <= #1 input_counter;
        else
            input_counter <= #1 input_counter_d;
        w_q <= #1 w_d;
        i_q <= #1 i_d;
        Table_q <= #1 Table_d;
        Finish <= #1 Finish_d;
        Layer1_q <= #1 Layer1_d;
        Layer2_q <= #1 Layer2_d;
        out_q <= #1 out_d;
        push <= #1 push_d;
        h1_q <= #1 h1_d;
        h2_q <= #1 h2_d;
        carry <= #1 carry_d;
        layer_offset <= #1 layer_offset_d;
        if (!bus_grant || problem_d)
        begin
            config_reg <= #1 config_reg;
            data_reg <= #1 data_reg;
        end
        else
        begin
            config_reg <= #1 config_data;
            data_reg <= #1 data_mem_data;
        end
        
        if (done && bus_grant)
            index <= #1 index_d + 10'd4;
        else if (!bus_grant)
            index <= #1 index;
        else
            index <= #1 index_d;
        
        if (ps == Fetch_neuron_table)
            Ninputs <= #1 Table_d.Ninputs;
        else
            Ninputs <= #1 Ninputs_d;
            
        if (ps == Fetch_layer2)
            Neuron_number <= #1 Layer2_d.layer;
        else
            Neuron_number <= #1 Neuron_number_d;
            
        Oloc <= #1 Table_d.Oloc;
        Lbase <= #1 Table_d.Lbase;
        Nimap <= #1 Table_d.Nimap;
        Wimap <= #1 Table_d.Wimap;
        PostShift <= #1 Table_d.PostShift;
        NeuronShift <= #1 Table_d.NeuronShift;
        Flags <= #1 Table_d.Flags;
        NeuronTable <= #1 Table_d.NeuronTable;
        offset <= #1 offset_d;
        woffset <= #1 woffset_d;
        W0 <= #1 w_q.weight0;
        W1 <= #1 w_q.weight1;
        W2 <= #1 w_q.weight2;
        W3 <= #1 w_q.weight3;
        W4 <= #1 w_q.weight4;
        W5 <= #1 w_q.weight5;
        W6 <= #1 w_q.weight6;
        W7 <= #1 w_q.weight7;
        I0 <= #1 i_q.input0;
        I1 <= #1 i_q.input1;
        I2 <= #1 i_q.input2;
        I3 <= #1 i_q.input3;
        I4 <= #1 i_q.input4;
        I5 <= #1 i_q.input5;
        I6 <= #1 i_q.input6;
        I7 <= #1 i_q.input7;
        Loc <= #1 Layer1_q.location;
        Ntable <= #1 Layer2_q.location;
        Clayer <= #1 Clayer_d;
        if (done_from_rcalculator)
            problem <= #1 0;
        else
            problem <= #1 problem_d;

    end
end


endmodule
