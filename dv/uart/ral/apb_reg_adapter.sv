class apb_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(apb_reg_adapter)
  function new(string n="apb_reg_adapter");
    super.new(n); supports_byte_enable=0; provides_responses=0;
  endfunction
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    apb_item t=apb_item::type_id::create("ral_apb");
    if (rw.addr > 'hffff) `uvm_fatal("ADDR","APB address exceeds 16 bits")
    t.addr=rw.addr[15:0]; t.write=(rw.kind==UVM_WRITE); t.data=rw.data[31:0];
    return t;
  endfunction
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    apb_item t;
    if (!$cast(t,bus_item)) `uvm_fatal("CAST","Adapter expected apb_item")
    rw.kind=t.write ? UVM_WRITE : UVM_READ;
    rw.addr=t.addr; rw.data=t.data; rw.n_bits=32;
    rw.status=t.error ? UVM_NOT_OK : UVM_IS_OK;
  endfunction
endclass
