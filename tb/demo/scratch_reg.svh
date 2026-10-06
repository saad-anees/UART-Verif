class scratch_reg extends uvm_reg;
  `uvm_object_utils(scratch_reg)
  uvm_reg_field data;
  function new(string n="scratch_reg"); super.new(n,32,UVM_NO_COVERAGE); endfunction
  function void build();
    data=uvm_reg_field::type_id::create("data");
    data.configure(this,32,0,"RW",0,0,1,1,0);
  endfunction
endclass
