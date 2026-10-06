// Version 1 runnable example: one read/write scratch register.
module demo_regs(input logic clk,rst_n,psel,penable,pwrite,
  input logic [15:0] paddr,input logic [31:0] pwdata,
  output logic [31:0] prdata,output logic pready,pslverr);
  logic [31:0] scratch;
  assign pready=1'b1;
  assign pslverr=psel && penable && paddr!=0;
  assign prdata=paddr==0 ? scratch : 32'b0;
  always_ff @(posedge clk or negedge rst_n)
    if(!rst_n) scratch<=0;
    else if(psel && penable && pwrite && !pslverr) scratch<=pwdata;
endmodule
