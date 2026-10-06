#!/usr/bin/env python3
"""Semantic SystemVerilog check against a user-supplied UVM 1.2 tree."""
import argparse,os,shlex,sys
from pathlib import Path
try:
    import pyslang
except ImportError:
    sys.exit("Install pyslang: python3 -m pip install pyslang")
p=argparse.ArgumentParser()
p.add_argument("--uvm-home",required=True,type=Path)
p.add_argument("--suite",choices=["generic","uart"],default="uart")
a=p.parse_args()
u=a.uvm_home.resolve()/"src"
if not (u/"uvm_pkg.sv").is_file():sys.exit("UVM_HOME must contain src/uvm_pkg.sv")
os.chdir(Path(__file__).resolve().parents[1])
top="demo_top" if a.suite=="generic" else "tb_top"
args=["slang",f"+incdir+{u}","+define+UVM_NO_DPI",str(u/"uvm_pkg.sv"),
      "-f",f"sim/{a.suite}.f","--top",top,"--timescale","1ns/1ps"]
d=pyslang.driver.Driver();d.addStandardArgs()
if not (d.parseCommandLine(shlex.join(args)) and d.processOptions() and d.parseAllSources()):sys.exit(1)
c=d.createCompilation();d.reportCompilation(c,False)
sys.exit(0 if d.reportDiagnostics(False) else 1)
