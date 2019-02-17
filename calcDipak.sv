
typedef struct packed signed
{
    reg signed [23:0] i0,i1,i2,i3,i4,i5,i6,i7,i8;
    reg signed [15:0] w0,w1,w2,w3,w4,w5,w6,w7;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] Neuron_number;
} inputs;

typedef struct packed signed
{
    logic signed [47:0] Sum;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic [9:0] Ninputs;
    logic [10:0] Neuron_number;
} outputs;

typedef struct packed signed
{
    logic signed [39:0] out0;
    logic signed [39:0] out1;
    logic signed [39:0] out2;
    logic signed [39:0] out3;
    logic signed [39:0] out4;
    logic signed [39:0] out5;
    logic signed [39:0] out6;
    logic signed [39:0] out7;
    
} DW_output;


module calc(input Finish,stopin,pushin,clk,reset,done_from_rcalculator,inputs in,output reg Finish_out,pushout,busy,outputs out);

// inputs iw_d,iw_q;
outputs p1_d,p1_q,p2_d,p2_q,p3_d,p3_q,p4_d,p4_q,p5_d,p5_q,p6_d,p6_q,/*p7_d,p7_q,*/out_d;
DW_output o1_d,o1_q,o2_d,o2_q,o3_d,o3_q,o4_d,o4_q;
inputs in_d,in_q;

logic Finish_d;
logic last_d;

logic [9:0] Ninputs;
    logic [16:0] NeuronTable;
    logic [4:0] PostShift;
    logic [4:0] NeuronShift;
    logic [16:0] Oloc;
    logic signed [47:0] Sum;
       logic signed [39:0] m0,m1,m2,m3,m4;
    logic [10:0] NeuronNumber;

typedef enum [3:0] {IDLE,GET_INPUT,/*DW02_WAIT1,DW02_WAIT2,*/ADD1,ADD2,ADD3,ADD4,HOLD,COMPLETE,Wait_for_Rcal} states;
states ns,ps;

// DW02_mult_3_stage#(40,40)e0({16'd0,iw_d.i0[23:0]},{24'd0,iw_d.w0},1'b1,clk,o1_d.out0);
// DW02_mult_3_stage#(40,40)e1({16'd0,iw_d.i1[23:0]},{24'd0,iw_d.w1},1'b1,clk,o1_d.out1);
// DW02_mult_3_stage#(40,40)e2({16'd0,iw_d.i2[23:0]},{24'd0,iw_d.w2},1'b1,clk,o1_d.out2);
// DW02_mult_3_stage#(40,40)e3({16'd0,iw_d.i3[23:0]},{24'd0,iw_d.w3},1'b1,clk,o1_d.out3);
// DW02_mult_3_stage#(40,40)e4({16'd0,iw_d.i4[23:0]},{24'd0,iw_d.w4},1'b1,clk,o1_d.out4);

// DW02_mult_3_stage#(40,40)e0({16'd0,iw_d.i0[23:0]},{24'd0,iw_d.w0},1'b1,clk,o0);
// DW02_mult_3_stage#(40,40)e1({16'd0,iw_d.i1[23:0]},{24'd0,iw_d.w1},1'b1,clk,o1);
// DW02_mult_3_stage#(40,40)e2({16'd0,iw_d.i2[23:0]},{24'd0,iw_d.w2},1'b1,clk,o2);
// DW02_mult_3_stage#(40,40)e3({16'd0,iw_d.i3[23:0]},{24'd0,iw_d.w3},1'b1,clk,o3);
// DW02_mult_3_stage#(40,40)e4({16'd0,iw_d.i4[23:0]},{24'd0,iw_d.w4},1'b1,clk,o4);

always @(*) begin
//     iw_d = iw_q;
    in_d = in_q;
	p1_d = p1_q;
	p2_d = p2_q;
	p3_d = p3_q;
	p4_d = p4_q;	
	p5_d = p5_q;
	p6_d = p6_q;
// 	p7_d = p7_q;
	Finish_d = Finish ? 1 : 0;
	busy = 0;
	o1_d = o1_q;
    o2_d =  o2_q;
    o3_d = o3_q;
    o4_d = o4_q;
	out_d = out;
	case (ns) 

		IDLE: begin           //0
			pushout  = 1;
// 			busy = 0;
			if (pushin) begin
				ps = GET_INPUT;
// 				in_d = in;
				Finish_d = 0;
			end
			else begin
				ps = IDLE;
				
			end
			end


		GET_INPUT:            //1
            begin
			pushout = 0;
			o1_d.out0 = in.i0 * in.w0;
			o1_d.out1 = in.i1 * in.w1;
			o1_d.out2 = in.i2 * in.w2;
			o1_d.out3 = in.i3 * in.w3;
			o1_d.out4 = in.i4 * in.w4;
			o1_d.out5 = in.i5 * in.w5;
			o1_d.out6 = in.i6 * in.w6;
            o1_d.out7 = in.i7 * in.w7;
// 			iw_d = in;
            p1_d.NeuronTable = in.NeuronTable;
            p1_d.PostShift = in.PostShift;
            p1_d.NeuronShift = in.NeuronShift;
            p1_d.Oloc = in.Oloc;
            p1_d.Ninputs = in.Ninputs;
            p1_d.Neuron_number = in.Neuron_number;
			busy = 1;
//             ps = DW02_WAIT1;
            ps = ADD1;
            end
		      
// 		DW02_WAIT1: begin         //2
//             pushout = 0;
// 			ps = DW02_WAIT2;
// 			p1_d.NeuronTable = iw_q.NeuronTable;
// 			p1_d.PostShift = iw_q.PostShift;
// 			p1_d.NeuronShift = iw_q.NeuronShift;
// 			p1_d.Oloc = iw_q.Oloc;
// 			busy = 1;
// 			end
// 
// 		DW02_WAIT2: begin     //3
// 			ps = ADD1;
// 			pushout = 0;
// 			p2_d = p1_q;
// 			busy = 1;
// 			end

		ADD1: begin           //4
            p2_d = p1_q;
            pushout = 0;
			o2_d.out1 = o1_q.out0 + o1_q.out1;
			o2_d.out2 = o1_q.out2 + o1_q.out3;
			o2_d.out3 = o1_q.out4 + o1_q.out5;
			o2_d.out4 = o1_q.out6 + o1_q.out7;
			ps = ADD2;
			busy = 1;
		end
		
		ADD2: begin           //5
            p3_d = p2_q;
            pushout = 0;
			o3_d.out1 = o2_q.out1 + o2_q.out2;
			o3_d.out2 = o2_q.out3 + o2_q.out4;
			busy = 1;
			ps = ADD3;
		end
		
		ADD3: begin           //6
            p4_d = p3_q;
            pushout = 0;
            o4_d = o3_q.out1 + o3_q.out2;
			ps = ADD4;
			busy = 1;
		end
		
		ADD4: begin           //7
            p5_d = p4_q;
            pushout = 0;
			p5_d.Sum = o4_q;
			busy = 1;
			ps = HOLD;
		end 	

		HOLD :            //8
        begin
            p6_d = p5_q;
            pushout = 0;
            busy = 1;
//             p2_d = p1_q;
            ps = COMPLETE;
            if (stopin)
                ps = HOLD;
        end

		COMPLETE: begin           //9
				busy = 1;
				out_d = p6_q;
				ps = IDLE;
				pushout = 1;
//                     busy = 0;
                    if (Finish)
                        Finish_d = 1;
                end
			  
        Wait_for_Rcal :
        begin
            busy = 1;
            pushout = 0;
            if (done_from_rcalculator)
            begin
                pushout = 1;
                ps = IDLE;
            end
            else
                ps = Wait_for_Rcal;
        end
		default : begin
            ps = IDLE;
            pushout = 1;
            end
	endcase
end 


always @(posedge clk or posedge reset) begin
	if (reset) begin
		ns <= #1 IDLE;
// 		iw_q <= #1 0;
        in_q <= #1 0;
		p1_q <= #1 0;
		p2_q <= #1 0;
		p3_q <= #1 0;
		p4_q <= #1 0;
		p5_q <= #1 0;
		p6_q <= #1 0;
// 		p7_q <= #1 0;
		Finish_out <= #1 0;
		out <= #1 0;
		o1_q <= #1 0;
		o2_q <= #1 0;
		o3_q <= #1 0;
		o4_q <= #1 0;
		
		NeuronTable <= #1 0;
        PostShift <= #1 0;
        NeuronShift <= #1 0;
        Oloc <= #1 0;
        Sum <= #1 0;
        m0 <= #1 0;
        m1 <= #1 0;
        m2 <= #1 0;
        m3 <= #1 0;
        m4 <= #1 0;
        last_d <= #1 0;
        Ninputs <= #1 0;
        NeuronNumber <= #1 0;
	end
	else begin
//         iw_q <= #1 iw_d;
        in_q <= #1 in_d;
        p1_q <= #1 p1_d;
		p2_q <= #1 p2_d;
		p3_q <= #1 p3_d;
		p4_q <= #1 p4_d;
		p5_q <= #1 p5_d;
		p6_q <= #1 p6_d;
// 		p7_q <= #1 p7_d;
		Finish_out <= #1 Finish_d;
		ns <= #1 ps;
		o1_q <= #1 o1_d;
		o2_q <= #1 o2_d;
		o3_q <= #1 o3_d;
		o4_q <= #1 o4_d;
		out <= #1 out_d;
		
		NeuronTable <= #1 p6_d.NeuronTable;
        PostShift <= #1 p6_d.PostShift;
        NeuronShift <= #1 p6_d.NeuronShift;
        Oloc <= #1 p6_d.Oloc;
        Sum <= #1 p6_d.Sum;
        m0 <= #1 o1_q.out0;
        m1 <= #1 o1_q.out1;
        m2 <= #1 o1_q.out2;
        m3 <= #1 o1_q.out3;
        m4 <= #1 o1_q.out4;
        Ninputs <= #1 in.Ninputs;
        NeuronNumber <= #1 in.Neuron_number;
        end
end

endmodule				  
