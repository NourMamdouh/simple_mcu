///////////////// test bench ///////////////////////////////
module mcu_tb;
  parameter op_sz= 6;
  parameter mem_sz=5;
  parameter clk_period=10ns;
  reg clk_tb=0;
  always #(clk_period/2) clk_tb=~clk_tb;
  
  //////////////////////////
  reg reset;
  reg [mem_sz-1 : 0] op0;
  reg [op_sz-1 : 0] op1;
  reg [mem_sz-1 : 0] op2;
  reg [3:0] op;
  reg [op_sz-1 : 0] out;
  reg op_err ; 
  mcu #(.op_sz(op_sz), .mem_sz(mem_sz)) my_mcu (.clk(clk_tb), .reset(reset),.op0(op0),.op1(op1), .op2(op2),.op(op),.out(out),.op_err(op_err));
  
////////////////////////////// tasks /////////////////////////////
  task mcu_test_no_diplay(input reg rst,
                input reg [mem_sz-1 : 0] p0,
                input reg [op_sz-1 : 0] p1,
                input reg [mem_sz-1 : 0] p2,
                          input reg [3:0] op_code);
    reset=rst; op0=p0; op1=p1; op2=p2; op=op_code;
    #(clk_period);
   // $display("at time = %t: error = %d, out= %d",$time,op_err,out);
  endtask
  
  //////////////////////////////
  task add_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    localparam op_num=0;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    add_verification(R_addr1,R_addr2,W_adrr);
    
  endtask
  
  ///////////////////////////
  task subtract_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
     localparam op_num= 1;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    subtract_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  //////////////////////////////
  task multiply_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
      localparam op_num=2;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    mult_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  //////////////////////////
  task divide_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
      localparam op_num=3;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    divide_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  //////////////////////////
  task AND_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
      localparam op_num=4;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    AND_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  ///////////////////////////
  task OR_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
      localparam op_num=5;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    OR_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  /////////////////////////////
  task XOR_tst(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
      localparam op_num=6;
    
    mcu_test_no_diplay(0,R_addr1,R_addr2,W_adrr,op_num);
    XOR_verification(R_addr1,R_addr2,W_adrr);
  endtask
  
  ///////////////////////////
  task read_tst(input reg [mem_sz-1 : 0] R_addr);
      localparam op_num=7;
    
      mcu_test_no_diplay(0,R_addr,0,0,op_num);
      read_verification(R_addr);
  endtask
  
  ////////////////////////////
  task write_tst(input reg [mem_sz-1 : 0] W_adrr,
                 input reg [op_sz-1 : 0] data);
      localparam op_num=8;
    
    mcu_test_no_diplay(0,W_adrr,data,0,op_num);
    write_verification(W_adrr,data);
  endtask
  
  ////////////////////////////
  task mcu_rst();
    mcu_test_no_diplay(1,0,0,0,0);
  endtask
    
  ///////////////////////////////////////////////////////
  task check_Error_detector(input reg [3:0] wrong_op_code);
    $display("---------------------------------");
    op=wrong_op_code;
    if(op_err) begin
      $display("Error detector works properly.");
    end
    else begin
      $display("something is wrong with the error detector.");
    end
  endtask

////////////////////////////// functions /////////////////////////////
  function void add_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])+(my_mcu.my_mem.mem[R_addr2]))) begin
      $display("addition operation is done successfully, %d + %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]); 
    end
    else begin
      $display("something is wrong with add operation, result is not as expected !!");
    end 
    
  endfunction
  
  //////////////////////////////////////
  function void subtract_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])-(my_mcu.my_mem.mem[R_addr2]))) begin
      $display("subtraction operation is done successfully, %d - %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with subtract operation, result is not as expected !!");
    end
  endfunction
  
  //////////////////////////////////////////
  function void mult_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])*(my_mcu.my_mem.mem[R_addr2]))) begin
        $display("multiplication operation is done successfully, %d * %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with multiply operation, result is not as expected !!");
    end
  endfunction
  
  ///////////////////////////////////////
  function void divide_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])/(my_mcu.my_mem.mem[R_addr2]))) begin
        $display("division operation is done successfully, %d / %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with divide operation, result is not as expected !!");
    end
  endfunction
  
  /////////////////////////////////////////
  function void AND_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])&(my_mcu.my_mem.mem[R_addr2]))) begin
        $display("AND operation is done successfully, %d AND %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with AND operation, result is not as expected !!");
    end
  endfunction
  
  /////////////////////////////////////
  function void OR_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])|(my_mcu.my_mem.mem[R_addr2]))) begin
        $display("OR operation is done successfully, %d OR %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with OR operation, result is not as expected !!");
    end
  endfunction
  
  /////////////////////////////////////////
  function void XOR_verification(input reg [mem_sz-1 : 0] R_addr1,
              input reg [op_sz-1 : 0] R_addr2,
              input reg [mem_sz-1 : 0] W_adrr);
    $display("---------------------------------");
    check_op_err();
    if( my_mcu.my_mem.mem[W_adrr] == ((my_mcu.my_mem.mem[R_addr1])^(my_mcu.my_mem.mem[R_addr2]))) begin
        $display("XOR operation is done successfully, %d XOR %d = %d",my_mcu.my_mem.mem[R_addr1],my_mcu.my_mem.mem[R_addr2], my_mcu.my_mem.mem[W_adrr]);
    end
    else begin
      $display("something is wrong with XOR operation, result is not as expected !!");
    end
  endfunction
  
  ///////////////////////////////////////////////
  function void read_verification(input reg [mem_sz-1 : 0] R_addr);
    $display("---------------------------------");
    check_op_err();
    if(out == my_mcu.my_mem.mem[R_addr] ) begin
      $display("Read operation is done successfully, output port value is ",out);
    end
    else begin
      $display("something is wrong with read operation, result is not as expected !!");
    end
  endfunction
  
  /////////////////////////////////////////////
  function void write_verification(input reg [mem_sz-1 : 0] W_addr,
                                   input reg [op_sz-1 : 0] data);
    $display("---------------------------------");
    check_op_err();
    if(data == my_mcu.my_mem.mem[W_addr] ) begin
      $display("Write operation is done successfully, location 0X%x has the valuse %d ",W_addr,data);
    end
    else begin
      $display("something is wrong with write operation, result is not as expected !!");
    end
  endfunction
  
  ///////////////////////////////////
  function void check_op_err();
        if(~op_err) begin
      $display("No error is detected.");
    end
    else begin
      $display("An error is detected.");
    end
  endfunction
      
//////////////////////////////////////////////////////////////////////
  
  initial begin
    mcu_rst();
    /////////////////////
    read_tst(0);
    write_tst(0,9);
    write_tst(1,3);
    write_tst(2,2);
    add_tst(0,1,3);
    subtract_tst(0,1,4);
    multiply_tst(0,1,5);
    divide_tst(0,1,6);
    AND_tst(0,1,7);
    OR_tst(0,1,8);
    XOR_tst(0,1,9);
    read_tst(2);
    ///////////////////////
    check_Error_detector(9); //makes sure op_err=1 in case of wrong op_code
    check_Error_detector(12);
    $display("---------------------------------");
    $finish();
  end
  
endmodule