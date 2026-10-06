#!/usr/bin/env python3
"""Check that the Make failure gate rejects false passes."""
import subprocess,sys,tempfile
from pathlib import Path
checker=Path(__file__).with_name('check_log.py')
base='UVM_INFO test.sv(1) @ 10: uvm_test_top [TEST_RESULT] TEST PASSED\nUVM_ERROR : 0\nUVM_FATAL : 0\n'
cases=[(base,True),('',False),(base+'UVM_ERROR test.sv(25) @ 20: mismatch\n',False),
       (base+'# UVM_FATAL @ 0: timeout\n',False),(base+'UVM_ERROR : 2\n',False),
       (base+'# ** Error: assertion\n',False),(base+'Error: signal unknown\n',False),
       (base+'Assertion a_stable failed\n',False),(base+'TEST FAILED\n',False)]
with tempfile.TemporaryDirectory() as td:
    for i,(content,expected) in enumerate(cases):
        p=Path(td)/f'{i}.log';p.write_text(content)
        result=subprocess.run([sys.executable,str(checker),str(p)],capture_output=True)
        assert (result.returncode==0)==expected,(i,result.stdout.decode())
print(f'Log checker: {len(cases)} cases passed')
