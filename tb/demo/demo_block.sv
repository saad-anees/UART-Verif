class demo_block extends uvm_reg_block;
  `uvm_object_utils(demo_block)
  scratch_reg scratch;
  function new(string n="demo_block"); super.new(n,UVM_NO_COVERAGE); endfunction
  function void build();
    default_map=create_map("apb",0,4,UVM_LITTLE_ENDIAN,1);
    scratch=scratch_reg::type_id::create("scratch");
    scratch.configure(this); scratch.build(); default_map.add_reg(scratch,0,"RW");
    lock_model(); reset();
  endfunction
endclass
