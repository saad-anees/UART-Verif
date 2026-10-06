class uart_coverage extends uvm_subscriber #(uart_item);
  `uvm_component_utils(uart_coverage)
  covergroup frames with function sample(bit tx,bit [7:0] data,bit parity_en,
      bit odd,bit stop2,int unsigned divisor,bit pe,bit fe);
    option.per_instance=1;
    direction: coverpoint tx;
    payload: coverpoint data {
      bins zero={8'h00}; bins ones={8'hff}; bins alternating[]={8'h55,8'haa};
      bins walking_one[]={1,2,4,8,16,32,64,128};
      bins other=default;
    }
    parity_mode: coverpoint (parity_en ? (odd ? 2 : 1) : 0) {
      bins none={0}; bins even_p={1}; bins odd_p={2};
    }
    stops: coverpoint stop2;
    baud: coverpoint divisor { bins fast={8}; bins nominal={16}; bins odd_div={31}; bins other=default; }
    errors: coverpoint {pe,fe} { bins clean={0}; bins parity_only={2}; bins frame_only={1}; bins both={3}; }
    formats: cross direction,parity_mode,stops,baud;
    rx_errors: cross direction,errors {
      ignore_bins tx_injected=binsof(direction) intersect {1} && binsof(errors) intersect {1,2,3};
    }
  endgroup
  function new(string n,uvm_component p); super.new(n,p); frames=new; endfunction
  function void write(uart_item t);
    frames.sample(t.is_tx,t.data,t.parity_en,t.odd,t.stop2,t.divisor,t.parity_error,t.frame_error);
  endfunction
  function void report_phase(uvm_phase phase);
    `uvm_info("COVERAGE",$sformatf("UART frame instance coverage %.2f%%",frames.get_inst_coverage()),UVM_LOW)
  endfunction
endclass
