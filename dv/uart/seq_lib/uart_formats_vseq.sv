class uart_formats_vseq extends uart_base_vseq;
  `uvm_object_utils(uart_formats_vseq)
  function new(string n="uart_formats_vseq"); super.new(n); endfunction
  task body();
    int divisors[3]='{8,16,31};
    bit[7:0] patterns[12]='{'h00,'hff,'h55,'haa,1,2,4,8,16,32,64,128};
    foreach(divisors[d]) for(int parity=0;parity<3;parity++)
      for(int stops=0;stops<2;stops++) begin
        configure_uart(divisors[d],parity!=0,parity==2,stops!=0);
        foreach(patterns[i]) begin transmit(patterns[i]); receive_and_read(patterns[i]); end
      end
  endtask
endclass
