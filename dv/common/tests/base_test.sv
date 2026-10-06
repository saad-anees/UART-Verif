class base_test extends uvm_test;
  `uvm_component_utils(base_test)
  function new(string n,uvm_component p); super.new(n,p); endfunction
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
    uvm_top.set_timeout(20ms,0);
  endfunction
  function void report_phase(uvm_phase phase);
    uvm_report_server s=uvm_report_server::get_server();
    if(s.get_severity_count(UVM_ERROR)==0 && s.get_severity_count(UVM_FATAL)==0)
      `uvm_info("TEST_RESULT","TEST PASSED",UVM_NONE)
    else `uvm_info("TEST_RESULT","TEST FAILED",UVM_NONE)
  endfunction
endclass
