// Useful for invalid-address/access tests which intentionally bypass RAL policy.
class apb_access_seq extends uvm_sequence #(apb_item);
  `uvm_object_utils(apb_access_seq)
  bit wr; bit [15:0] address; bit [31:0] value; bit error;
  function new(string n="apb_access_seq"); super.new(n); endfunction
  task body();
    apb_item t=apb_item::type_id::create("t");
    start_item(t); t.write=wr; t.addr=address; t.data=value; finish_item(t);
    value=t.data; error=t.error;
  endtask
endclass
