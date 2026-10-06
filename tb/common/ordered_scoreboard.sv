// Reusable ordered comparator. Specialize T and override compare_items for
// protocols with tolerance/masking. Out-of-order protocols need an ID matcher.
class ordered_scoreboard #(type T=apb_item) extends uvm_scoreboard;
  `uvm_component_param_utils(ordered_scoreboard #(T))
  uvm_tlm_analysis_fifo #(T) expected, actual;
  int unsigned compared;
  bit pending_expected;
  function new(string n, uvm_component p);
    super.new(n,p); expected=new("expected",this); actual=new("actual",this);
  endfunction
  virtual function bit compare_items(T e,T a); return e.compare(a); endfunction
  task run_phase(uvm_phase phase);
    T e,a;
    forever begin
      expected.get(e); pending_expected=1; actual.get(a);
      if(!compare_items(e,a)) `uvm_error("MISMATCH","Ordered transaction mismatch")
      compared++; pending_expected=0;
    end
  endtask
  function void check_phase(uvm_phase phase);
    if(pending_expected || expected.used()!=0 || actual.used()!=0)
      `uvm_error("UNDRAINED","Scoreboard has unmatched transactions")
  endfunction
endclass
