class apb_coverage extends uvm_subscriber #(apb_item);
  `uvm_component_utils(apb_coverage)
  covergroup transfers with function sample(bit wr, bit err, int unsigned waits);
    option.per_instance=1;
    direction: coverpoint wr;
    response: coverpoint err;
    latency: coverpoint waits { bins zero={0}; bins short_wait={[1:4]}; bins long_wait={[5:99]}; }
    direction_response: cross direction,response;
  endgroup
  function new(string n, uvm_component p); super.new(n,p); transfers=new; endfunction
  function void write(apb_item t); transfers.sample(t.write,t.error,t.wait_cycles); endfunction
endclass
