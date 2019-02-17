//
// The AHB Fabric module
//

`include "addr_mux.sv"
`include "wrdata_mux.sv"
`include "sl_decoder.sv"
`include "rdata_mux.sv"
//`include "ahbif.svh"
`include "arbiter_new1.sv"


module fabric(mAHBIF.AHBMfab m0,mAHBIF.AHBMfab m1,mAHBIF.AHBMfab m2,mAHBIF.AHBMfab m3,mAHBIF.AHBMfab mt,
              sAHBIF.AHBSfab s0,sAHBIF.AHBSfab s1,sAHBIF.AHBSfab s2,sAHBIF.AHBSfab s3,sAHBIF.AHBSfab st);


reg [31:0] addr_final;
reg [1:0] trans_final;
reg  write_final;
reg [2:0] size_final;
reg [2:0] burst_final;
reg [31:0] wrdata_final;
reg [31:0] rdata_final;
reg  ready_final;
reg [1:0] resp_final;

//reg [4:0] sel = {s0.sHSEL,s1.sHSEL,s2.sHSEL,s3.sHSEL,st.sHSEL};
reg [4:0] grant_out;
reg [4:0] sel_out;
//reg [4:0] addr_sel = {m0.mHGRANT,m1.mHGRANT,m2.mHGRANT,m3.mHGRANT,mt.mHGRANT};

addr_mux mux1(m0.mHADDR,m1.mHADDR,m2.mHADDR,m3.mHADDR,mt.mHADDR,m0.mHTRANS,m1.mHTRANS,m2.mHTRANS,m3.mHTRANS,mt.mHTRANS,m0.mHWRITE,m1.mHWRITE,m2.mHWRITE,m3.mHWRITE,mt.mHWRITE,m0.mHSIZE,m1.mHSIZE,m2.mHSIZE,m3.mHSIZE,mt.mHSIZE,m0.mHBURST,m1.mHBURST,m2.mHBURST,m3.mHBURST,mt.mHBURST,grant_out,addr_final,trans_final,write_final,size_final,burst_final);


wrdata_mux w1(m0.mHWDATA,m1.mHWDATA,m2.mHWDATA,m3.mHWDATA,mt.mHWDATA,grant_out,m0.HCLK,m0.HRESET,wrdata_final );


sl_decoder d1(addr_final,s0.sHSEL,s1.sHSEL,s2.sHSEL,s3.sHSEL,st.sHSEL,sel_out);

rdata_mux r1( s0.sHRDATA,s1.sHRDATA,s2.sHRDATA,s3.sHRDATA,st.sHRDATA,s0.sHREADY,s1.sHREADY,s2.sHREADY,s3.sHREADY,st.sHREADY,s0.sHRESP,s1.sHRESP,s2.sHRESP,s3.sHRESP,st.sHRESP,s0.HCLK,s0.HRESET,sel_out,rdata_final,ready_final,resp_final);


arbiter_new1 n1 (m0.mHBUSREQ,m1.mHBUSREQ,m2.mHBUSREQ,m3.mHBUSREQ,mt.mHBUSREQ,m0.HCLK,m0.HRESET,m0.mHGRANT,m1.mHGRANT,m2.mHGRANT,m3.mHGRANT,mt.mHGRANT,grant_out);



always @(*) begin

//////////////// address///////////////
s0.sHADDR = addr_final;
s1.sHADDR = addr_final;
s2.sHADDR = addr_final;
s3.sHADDR = addr_final;
st.sHADDR = addr_final;

////////////////////htrans//////////////////
s0.sHTRANS = trans_final;
s1.sHTRANS = trans_final;
s2.sHTRANS = trans_final;
s3.sHTRANS = trans_final;
st.sHTRANS = trans_final;

///////////////hwrite/////////////////////////
s0.sHWRITE = write_final;
s1.sHWRITE = write_final;
s2.sHWRITE = write_final;
s3.sHWRITE = write_final;
st.sHWRITE = write_final;

///////////////hsize//////////////////////////
s0.sHSIZE = size_final;
s1.sHSIZE = size_final;
s2.sHSIZE = size_final;
s3.sHSIZE = size_final;
st.sHSIZE = size_final;

/////////////hburst////////////////////////////
s0.sHBURST = burst_final;
s1.sHBURST = burst_final;
s2.sHBURST = burst_final;
s3.sHBURST = burst_final;
st.sHBURST = burst_final;

////////////write_data///////////////////
s0.sHWDATA = wrdata_final;
s1.sHWDATA = wrdata_final;
s2.sHWDATA = wrdata_final;
s3.sHWDATA = wrdata_final;
st.sHWDATA = wrdata_final;
end



always @(*) begin


///////////read data to master///////////////////
m0.mHRDATA = rdata_final;
m1.mHRDATA = rdata_final;
m2.mHRDATA = rdata_final;
m3.mHRDATA = rdata_final;
mt.mHRDATA = rdata_final;

///////////////readyin to master//////////////////////
m0.mHREADYin = ready_final;
m1.mHREADYin = ready_final;
m2.mHREADYin = ready_final;
m3.mHREADYin = ready_final;
mt.mHREADYin = ready_final;

///////////////readyin to slaves/////////////////////////////
s0.sHREADYin = ready_final;
s1.sHREADYin = ready_final;
s2.sHREADYin = ready_final;
s3.sHREADYin = ready_final;
st.sHREADYin = ready_final;

///////////////resp to master//////////////////////////
m0.mHRESP = resp_final;
m1.mHRESP = resp_final;
m2.mHRESP = resp_final;
m3.mHRESP = resp_final;
mt.mHRESP = resp_final;


end 
endmodule : fabric



//endmodule : fabric
