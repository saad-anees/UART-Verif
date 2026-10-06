#!/usr/bin/env python3
"""Simulator exit status alone is not a reliable UVM pass/fail indicator."""
import re,sys
from pathlib import Path
s=Path(sys.argv[1]).read_text(errors="replace")
# Accept zero-count UVM summaries, reject actual reports and nonzero summaries.
bad=[]
for line in s.splitlines():
    if re.search(r"(?:UVM_ERROR|UVM_FATAL)\s*:\s*[1-9]",line): bad.append(line)
    elif re.search(r"(?:UVM_ERROR|UVM_FATAL)\s+(?:@|\S+\()",line): bad.append(line)
    elif re.search(r"(?:^|# )\*\* (?:Error|Fatal):|Error-\[|Fatal-\[",line): bad.append(line)
    elif re.search(r"(?:^|# )Error:|Assertion.*(?:failed|failure)",line,re.I): bad.append(line)
if "TEST PASSED" not in s or "TEST FAILED" in s or bad:
    print("FAIL:",sys.argv[1]); print("\n".join(bad[:20]));sys.exit(1)
print("PASS:",sys.argv[1])
