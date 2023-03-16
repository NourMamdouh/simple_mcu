module ALU #(parameter op_sz = 32)(input [op_sz-1 : 0] in1,in2, input [2:0] op, output reg  [op_sz-1 : 0] out);
  always @(*) begin
    case (op)
      0: begin
        out = in1 + in2 ;
      end
      1: begin
        out = in1 - in2 ;
      end
      2: begin
        out = in1 * in2 ;
      end
      3: begin
        out = in1 / in2 ;
      end
      4: begin
        out = in1 & in2 ;
      end
      5: begin
        out = in1 | in2 ;
      end
      6: begin
        out = in1 ^ in2 ;
      end
      default: begin
        out = 0;
      end
    endcase
  end 
endmodule

////////////////////////////////////////////////////

module memory #(parameter op_sz=32, parameter mem_sz=10) (input [mem_sz-1 :0] R_addr1,R_addr2,W_addr, input [op_sz-1 :0] W_data, input w_en,reset,clk,
                                                          output [op_sz-1 :0] R_data1,R_data2 );
  reg [op_sz-1 :0] mem[0 : (2**mem_sz)-1];
  always @(posedge clk, posedge reset ) begin
    if(reset == 1) begin   
      for(integer i=0; i<(2**mem_sz) ; i=i+1) begin
        mem[i] <= {op_sz{1'b0}};
      end      
     end
      else begin
        if (w_en==1) begin
          mem[W_addr] <= W_data;
        end
      end
    end
    assign R_data1=mem[R_addr1];
    assign R_data2=mem[R_addr2];
endmodule

/////////////////////////////////////

module mcu #(
 parameter op_sz = 32,
 parameter mem_sz=10
)(
 input wire clk, reset,
 input wire [mem_sz-1 : 0] op0,
 input wire [op_sz-1 : 0] op1,
 input wire [mem_sz-1 : 0] op2,
 input wire [3:0] op,
 output wire [op_sz-1 : 0] out,
 output wire op_err
 //, output wire op_done
);
  //ALU instantiation
  wire [2:0]ALU_op; 
  wire [op_sz-1 : 0] alu_in1,alu_in2 ;
  reg [op_sz-1 : 0] alu_out;
  ALU #(.op_sz(op_sz)) my_alu(.in1(alu_in1),.in2(alu_in2),.op(ALU_op),.out(alu_out));
  //memory instantiation
  wire [mem_sz-1 : 0] R_addr1,R_addr2,W_addr;
  wire [op_sz-1 : 0] R_data1,R_data2,W_data;
  wire w_en;
  memory #(.op_sz(op_sz),.mem_sz(mem_sz)) my_mem(.R_addr1(R_addr1),.R_addr2(R_addr2),.W_addr(W_addr),.W_data(W_data),.w_en(w_en),.reset(reset),.clk(clk),.R_data1(R_data1),
                                      .R_data2(R_data2));
  //ALU coneections
  assign alu_in1= R_data1;
  assign alu_in2= R_data2;
  assign ALU_op = op[2:0];
  //memory connections 
  assign R_addr1 = op0 ;
  assign R_addr2 = op1[mem_sz-1 : 0] ;
  assign w_en = ((op == 7) || (op > 8))? 0 : 1;
  assign W_addr= (op == 8)? op0: op2; 
  assign W_data = (op === 8)? op1 : alu_out;
  /////////////////////////
  reg [op_sz-1 : 0] D_out;
  assign out = D_out;
  /////////////////////////
  assign op_err = (op>8)? 1 : 0;
  /////////////////////////
  always @(posedge clk) begin
    // no operation is allowed while reseting memory, out cannot change
    if(op==7 && ~reset) begin
      D_out <= R_data1;
    end
    else begin
      D_out = D_out;
    end
  end
endmodule

