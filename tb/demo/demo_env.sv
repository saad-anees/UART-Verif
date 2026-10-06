class demo_env extends base_env;
  `uvm_component_utils(demo_env)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function uvm_reg_block create_register_model();
    demo_block b=demo_block::type_id::create("rm"); b.build(); return b;
  endfunction
endclass
