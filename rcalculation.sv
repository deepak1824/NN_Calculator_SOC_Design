typedef struct packed signed
{
    logic signed [47:0] Sum;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] NeuronNumber;
} pip;


module rcalculation(output reg Finish_out,bus_request,pushout,stop,done_to_tablefetch,reg [7:0][16:0]config_address,reg [7:0][15:0]data_mem_address,reg [23:0]data_mem_data,reg [15:0] Oloc,input shurukar,bus_grant,clk,reset,Finish,pip in,[255:0]config_data);


reg [23:0] data_mem_data_d;
reg [7:0][15:0] data_mem_address_d;
pip in1_d,in1_q,in2_d,in2_q;

reg done_to_tablefetch_d;

logic [9:0] Ninputs;
logic busy;
logic Finish_d;
reg signed [47:0] Sum;
reg signed [255:0] config_reg;

logic [10:0] Neuron_number;

typedef enum [3:0]{Idle, Store_Values, Shift_left_by_Neuronshift, Resize_to_32, Saturation, Fetch_W, Calculate_W_fraction,Twos_Complement,Multiply_with_R, Calculate_R, Postshift_R, Resize_to_24, Push_R } states;

states ps,ns;

typedef struct packed signed
{
    reg signed [47:0] W0;
    reg signed [23:0] W1;
    reg signed [23:0] W2;
    reg signed [23:0] W3;
} W_struct;

W_struct w1_d,w1_q, w2_d,w2_q,w3_d,w3_q;

// typedef struct packed
// {
//     reg [19:0] fraction;
//     reg [39:0] fraction2;
//     reg [35:0] fraction3;    
// } fraction_struct;
// 
// 
// fraction_struct f1_d, f1_q, f2_d,f2_q;

// logic [16:0] Oloc;
reg [19:0] fraction_d;
reg signed [20:0] fraction;
reg [39:0] fraction2_d;
reg signed [16:0] fraction2;
reg [35:0] fraction3_d;
reg signed [12:0] fraction3;
    
typedef struct packed signed
{
    reg signed [47:0] R1;
    reg signed [47:0] R2;
    reg signed [47:0] R3;
} R_struct;

// typedef struct packed signed
// {
//     reg signed [47:0] R1;
//     reg signed [47:0] R2;
//     reg signed [47:0] R3;
// } R_struct;

R_struct r1_d,r1_q;

logic signed [47:0] hold_reg_d;
reg signed [47:0] hold_reg;

logic signed [47:0] shift_value_d;
reg signed [47:0] shift_value;

logic signed [47:0] result_d;
reg signed [47:0] result;

logic signed [31:0] saturated_result_d;
reg signed [31:0] saturated_result;

// logic signed [63:0] R1_d,R2_d,R3_d;
// reg signed [63:0] R1_1,R2_1,R3_1;

logic signed [47:0] R_d;
reg signed [47:0] R;

logic signed [63:0] Postshifted_R;
reg signed [63:0] final_R;

logic signed [23:0] neuron_out_d;
reg signed [23:0] neuron_out;

logic signed [31:0] positive_threshold;
logic signed [31:0] negative_threshold;

reg signed [63:0] R1_d;
reg signed [127:0] R2_d;
reg signed [191:0] R3_d;
    
logic [16:0] Neurontable;

/*      Debug timepass signals      */

    reg signed [63:0] w0_d;
    reg signed [63:0] w0;

    reg signed [47:0] W0;
    reg signed [23:0] W1;
    reg signed [23:0] W2;
    reg signed [23:0] W3;


    
    
    
    reg signed [47:0] R1;
    reg signed [47:0] R2;
    reg signed [47:0] R3;

    reg [4:0] Neuronshift;

    reg signed [51:0] m0;
    reg signed [51:0] m1;
    reg signed [51:0] m2;
    reg signed [51:0] m3;

always @(*)
begin

positive_threshold = 32'h7fffffe;
negative_threshold = -32'h7fffffe;
data_mem_address = 0;
config_address = 0;
bus_request = 0;
in1_d = in;
in2_d = in1_q;
Postshifted_R = final_R;    //
neuron_out_d = neuron_out;//
stop = 0;//
pushout = 1;//
shift_value_d = shift_value;
result_d = result;
saturated_result_d = saturated_result;
done_to_tablefetch = 1;
// R1_d = R1_1;
// R2_d = R2_1;
// R3_d = R3_1;
R_d = R;
// f1_d = f1_q;
// f2_d = f2_q;
w1_d = w1_q;
w2_d = w2_q;
w3_d = w3_q;
r1_d = r1_q;
w0_d = w0;
Finish_d = Finish ? 1 : 0;
data_mem_data = data_mem_data_d;
data_mem_address = data_mem_address_d;
hold_reg_d = hold_reg;
ns = ps;
    case (ps)
    
        Idle :      //0
        begin
            stop = 0;
            pushout = 1;
            config_address = 0;
            busy = 0;
            ns = Idle;
            done_to_tablefetch = done_to_tablefetch_d;
            if (shurukar)
            begin
                Finish_d = 0;
                ns = Store_Values;
            end
        end
    
        Store_Values :  //1
        begin
            done_to_tablefetch = done_to_tablefetch_d;
            pushout = 0;
            done_to_tablefetch = 0;
            hold_reg_d = hold_reg + Sum;
            if (Ninputs <= 10'd8)
                ns = Shift_left_by_Neuronshift;
            else
                ns = Idle;
        end
        
        Shift_left_by_Neuronshift :     //2
        begin
             done_to_tablefetch = done_to_tablefetch_d;   
            shift_value_d = hold_reg_d >>> in1_q.NeuronShift;
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Resize_to_32;
        end
        
        Resize_to_32 :      //3
        begin
            done_to_tablefetch = done_to_tablefetch_d;
            result_d = shift_value;
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Saturation;
        end
        
        Saturation :        //4
        begin
            done_to_tablefetch = done_to_tablefetch_d;
            saturated_result_d = result[31:0];
            
            case (1'b1)
            
            result[47] :
            begin
                if (result < negative_threshold)
                    saturated_result_d = negative_threshold;
            end
            
            !result[47] :
            begin
                if (result > positive_threshold)
                    saturated_result_d = positive_threshold;
            end
            
            endcase
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Fetch_W;
        end
        
        Fetch_W :       //5
        begin
            done_to_tablefetch = done_to_tablefetch_d;
            config_address[0] = (saturated_result[27:20]*17'd3) + in1_q.NeuronTable;
            config_address[1] = (saturated_result[27:20]*17'd3) + in1_q.NeuronTable + 17'd1;
            config_address[2] = (saturated_result[27:20]*17'd3) + in1_q.NeuronTable + 17'd2;
//             f1_d.fraction = saturated_result[19:0];
//             f1_d.fraction2 = saturated_result[19:0] * saturated_result[19:0];
           fraction = saturated_result[19:0];
           fraction2_d = fraction * fraction;
           fraction2 = fraction2_d[39:24];
           fraction3_d = fraction2 * fraction;
           fraction3 = fraction3_d[35:24];
            stop = 1;
            pushout = 0;
            busy = 1;
            bus_request = 1;
            
//             W0 = {{12{0}},config_reg[23:0],{28'd0}};
//             W1 = {config_reg[47:24],{8'd0}};
//             W2 = {{4{0}},config_reg[71:48],{36'd0}};
//             W3 = {{8{0}},config_reg[95:72],{64'd0}};
//             fraction2 = {{32{0}},fraction} * {{32{0}},fraction};
//             fraction3 = {{64{0}},fraction} * {{64{0}},fraction} * {{64{0}},fraction};
            
            if (bus_grant)
                ns = Calculate_W_fraction;
            else
                ns = Fetch_W;
        end
        
        Calculate_W_fraction :      //6
        begin
         done_to_tablefetch = done_to_tablefetch_d;
            w1_d.W0 = {config_reg[23:0],{24'd0}};                                         // need to sign extend???
            w1_d.W1 = {config_reg[47:24]};
            w1_d.W2 = {config_reg[71:48]};
            w1_d.W3 = {config_reg[95:72]};
            
//             f2_d.fraction = f1_q.fraction;
//             f2_d.fraction2 = f1_q.fraction2;
//             f2_d.fraction3 = f1_q.fraction * f1_q.fraction2;
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Multiply_with_R;
//             ns = Twos_Complement;
        end        
//         
//         
        Multiply_with_R :       //7
        begin
       done_to_tablefetch = done_to_tablefetch_d;
            r1_d.R1 = w1_q.W1 * fraction;
            r1_d.R2 = w1_q.W2 * fraction2;
            r1_d.R3 = w1_q.W3 * fraction3;
            
//             m0 = w1_q.W1 * fraction;
//             m1 = w1_q.W2 * fraction2;
//             m2 = w1_q.W3 * fraction3;
//          
//             m0 = w1_q.W1 * f2_q.fraction;
//             m1 = w1_q.W2 * f2_q.fraction2[63:24];
//             m2 = w1_q.W3 * f2_q.fraction3[95:24];
            
            stop = 1;
            pushout = 0;
            busy = 1;
            w2_d = w1_q;
            
            ns = Calculate_R;
        end
                 
        Calculate_R :       //8
        begin
         done_to_tablefetch = done_to_tablefetch_d;
            R_d = w2_q.W0 + r1_q.R1 + r1_q.R2 + r1_q.R3;
//             m0_1 = m0; 
//             m0_2 = m1;
//             m0_3 = m2;
//             m0_4 =
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Postshift_R;
        end
        
        Postshift_R:        //9
        begin
          done_to_tablefetch = done_to_tablefetch_d;
            Postshifted_R = R << in1_q.PostShift;
            stop = 1;
            pushout = 0;
            busy = 1;
            ns = Resize_to_24;
        end
        
        Resize_to_24:       //10
        begin
          done_to_tablefetch = done_to_tablefetch_d;
            neuron_out_d = final_R[51:28];
            
            ns = Push_R;
            stop = 1;
            pushout = 0;
            busy = 1;
        end
//         
        Push_R :        //11
        begin
            hold_reg_d = 0;
            data_mem_address = in1_q.Oloc;
            data_mem_data = neuron_out;
            stop = 1;
            pushout = 1;
            busy = 1;
            bus_request = 1;
            if (bus_grant)
                ns = Idle;
            else
                ns = Push_R;
            if (Finish)
                Finish_d = 1;
//             if (Neuron_number == 0)
                done_to_tablefetch = 1;

        end
        
    endcase

end


always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        ps <= #1 Idle;
        shift_value <= #1 0;
        result <= #1 0;
        saturated_result <= #1 0;
//         f1_q.fraction <= #1 0;
//         f2_q <= #1 0;
        w1_q <= #1 0;
        w2_q <= #1 0;
        w3_q <= #1 0;
        r1_q <= #1 0;
        in1_q <= #1 0;
        in2_q <= #1 0;
//         R1_1 <= #1 0;
//         R2_1 <= #1 0;
//         R3_1 <= #1 0;
        R <= #1 0;
        final_R <= #1 0;
        neuron_out <= #1 0;
        Sum <= #1 0;
        config_reg <= #1 0;
        Finish_out <= #1 0;
        data_mem_data_d <= #1 0;
        data_mem_address_d <= #1 0;
        done_to_tablefetch_d <= #1 0;
        W0 <= #1 0;
        W1 <= #1 0;
        W2 <= #1 0;
        W3 <= #1 0;
//         fraction <= #1 0;
//         fraction2 <= #1 0;
//         fraction3 <= #1 0;
        R1 <= #1 0;
        R2 <= #1 0;
        R3 <= #1 0;
        Ninputs <= #1 0;
        hold_reg <= #1 0;
        Neuronshift <= #1 0;
        Neurontable <= #1 0;
        w0 <= #1 0;
        Oloc <= #1 0;
        Neuron_number <= #1 0;
        Oloc <= #1 0;
//         done_to_tablefetch <= #1 0;
    end
    else
    begin
        ps <= #1 ns;
        shift_value <= #1 shift_value_d;
        result <= #1 result_d;
        saturated_result <= #1 saturated_result_d;
        done_to_tablefetch_d <= #1 done_to_tablefetch;

        //         f1_q <= #1 f1_d;
//         f2_q <= #1 f2_d;
        w1_q <= #1 w1_d;
        w2_q <= #1 w2_d;
        w3_q <= #1 w3_d;
        r1_q <= #1 r1_d;
        in1_q <= #1 in1_d;
        in2_q <= #1 in2_d;
        Finish_out <= #1 Finish_d;
//         R1_1 <= #1 R1_d;
//         R2_1 <= #1 R2_d;
//         R3_1 <= #1 R3_d;
        R <= #1 R_d;
        final_R <= #1 Postshifted_R;
        neuron_out <= #1 neuron_out_d;
        Sum <= #1 in.Sum;
        config_reg <= #1 config_data;
        data_mem_data_d <= #1 data_mem_data;
        data_mem_address_d <= #1 data_mem_address;
 
//         fraction <= #1 f1_d.fraction;
//         fraction2 <= #1 f1_d.fraction2[63:24];
//         fraction3 <= #1 f2_q.fraction3[95:48];
        Neuronshift <= #1 in1_q.NeuronShift;
        W0 <= #1 w2_q.W0;
//         W0 <= #1 saturated_result[27:20];
        W1 <= #1 w1_d.W1;
        W2 <= #1 w1_d.W2;
        W3 <= #1 w1_q.W3;
        R1 <= #1 r1_q.R1;
        R2 <= #1 r1_q.R2;
        R3 <= #1 r1_q.R3;
        w0 <= #1 w0_d;
        Ninputs <= #1 in.Ninputs;
        hold_reg <= #1 hold_reg_d;
        Neurontable <= #1 in.NeuronTable;
        Neuron_number <= #1 in.NeuronNumber;
        Oloc <= #1 in.Oloc;
//         done_to_tablefetch <= #1 done_to_tablefetch_d;
    end
end

endmodule
