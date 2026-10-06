SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
SIM ?= vcs
SUITE ?= uart
TEST ?= $(if $(filter generic,$(SUITE)),generic_smoke_test,uart_smoke_test)
SEED ?= 1
COV ?= 1
GUI ?= 0
UVM_HOME ?=
VCS ?= vcs
VLOG ?= vlog
VSIM ?= vsim
VLIB ?= vlib
VCS_FLAGS ?=
VLOG_FLAGS ?=
VSIM_FLAGS ?=
PLUSARGS ?=
TOP := $(if $(filter generic,$(SUITE)),demo_top,tb_top)
ROOT := $(CURDIR)
BUILD := $(ROOT)/build/$(SIM)/$(SUITE)
RUN := $(BUILD)/$(TEST)_seed$(SEED)
ifeq ($(filter $(SIM),vcs questa),)
$(error SIM must be vcs or questa)
endif
ifeq ($(filter $(SUITE),generic uart),)
$(error SUITE must be generic or uart)
endif
VCS_COV := $(if $(filter 1,$(COV)),-cm line+cond+tgl+branch+assert,)
QUESTA_COV := $(if $(filter 1,$(COV)),+cover=bcesft,)
.PHONY: all compile run regression clean help coverage
all: run
help:
	@echo 'make [SIM=vcs|questa] [SUITE=generic|uart] [TEST=name] [SEED=1] [COV=1]'
	@echo 'VCS uses bundled UVM 1.2. Questa requires UVM_HOME pointing at UVM 1.2.'
	@echo 'Run make regression for the selected suite; make coverage merges results.'
compile:
	@mkdir -p $(BUILD) $(RUN)
ifeq ($(SIM),vcs)
	$(VCS) -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
	  -f sim/$(SUITE).f -top $(TOP) -Mdir=$(BUILD)/csrc -o $(BUILD)/simv \
	  $(VCS_COV) $(if $(filter 1,$(COV)),-cm_dir $(RUN)/coverage.vdb,) -debug_access+all $(VCS_FLAGS) -l $(BUILD)/compile.log
else
	@test -f "$(UVM_HOME)/src/uvm_pkg.sv" || { echo 'Set UVM_HOME to UVM 1.2 root'; exit 2; }
	$(VLIB) $(BUILD)/work
	$(VLOG) -sv -timescale 1ns/1ps -work $(BUILD)/work +define+UVM_NO_DPI +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv -f sim/$(SUITE).f $(QUESTA_COV) \
	  $(VLOG_FLAGS) -l $(BUILD)/compile.log
endif
run: compile
	@mkdir -p $(RUN)
ifeq ($(SIM),vcs)
	cd $(RUN) && $(BUILD)/simv +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) \
	  $(VCS_COV) -cm_dir $(RUN)/coverage.vdb $(PLUSARGS) -l run.log
else
	cd $(RUN) && $(VSIM) $(if $(filter 1,$(GUI)),-gui,-c) \
	  -lib $(BUILD)/work $(TOP) -sv_seed $(SEED) $(if $(filter 1,$(COV)),-coverage,) \
	  +UVM_TESTNAME=$(TEST) $(PLUSARGS) $(VSIM_FLAGS) \
	  -do 'onerror {quit -code 1}; $(if $(filter 1,$(COV)),coverage save -onexit coverage.ucdb;) run -all; quit -f' \
	  -l run.log
endif
	python3 scripts/check_log.py $(RUN)/run.log
TESTS := $(if $(filter generic,$(SUITE)),generic_smoke_test,uart_smoke_test uart_ral_test uart_formats_test uart_random_test uart_errors_test uart_fifo_test uart_reset_test)
SEEDS ?= 1 7 23
regression:
	@for test in $(TESTS); do \
	  for seed in $(SEEDS); do \
	    $(MAKE) run SIM=$(SIM) SUITE=$(SUITE) TEST=$$test SEED=$$seed; \
	  done; \
	done
coverage:
ifeq ($(SIM),vcs)
	urg -dir $(BUILD)/*/coverage.vdb -report $(BUILD)/coverage_report
else
	vcover merge $(BUILD)/merged.ucdb $(BUILD)/*/coverage.ucdb
	vcover report -details $(BUILD)/merged.ucdb > $(BUILD)/coverage.txt
endif
clean:
	rm -rf build

# Optional RTL-only validation; commercial UVM flow remains the default.
VERILATOR ?= verilator
.PHONY: rtl-check
rtl-check:
	@mkdir -p build/rtl
	$(VERILATOR) --binary --timing -Wno-fatal --top-module rtl_smoke \
	  --Mdir $(ROOT)/build/rtl/obj rtl/uart_apb.sv tb/rtl_smoke.sv > build/rtl/compile.log 2>&1
	$(ROOT)/build/rtl/obj/Vrtl_smoke | tee build/rtl/run.log
	@grep -q RTL_TEST_PASSED build/rtl/run.log
