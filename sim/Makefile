SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
SIM ?= vcs
TEST ?= uart_smoke_test
SEED ?= 1
COV ?= 1
GUI ?= 0
WAVES ?= 0
VERDI_HOME ?=
VERDI ?= $(if $(VERDI_HOME),$(VERDI_HOME)/bin/verdi,verdi)
VERDI_FLAGS ?=
export VERDI_HOME
UVM_HOME ?=
VCS ?= vcs
VLOG ?= vlog
VSIM ?= vsim
VLIB ?= vlib
VCS_FLAGS ?=
VLOG_FLAGS ?=
VSIM_FLAGS ?=
PLUSARGS ?=
TOP := tb_top
ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
BUILD := $(ROOT)/build/$(SIM)/uart
RUN := $(BUILD)/$(TEST)_seed$(SEED)
FSDB ?= $(RUN)/uart.fsdb
FSDB_PATH := $(abspath $(FSDB))
ifeq ($(filter $(SIM),vcs questa),)
$(error SIM must be vcs or questa)
endif
ifeq ($(filter $(WAVES),0 1),)
$(error WAVES must be 0 or 1)
endif
ifeq ($(WAVES),1)
ifneq ($(SIM),vcs)
$(error FSDB waveform capture supports SIM=vcs; use Questa's native waveform UI for SIM=questa)
endif
VCS_WAVE_FLAGS := -kdb +define+UART_FSDB
WAVE_PLUSARGS := +UART_FSDB "+FSDB_FILE=$(FSDB_PATH)"
endif
VCS_COV := $(if $(filter 1,$(COV)),-cm line+cond+tgl+branch+assert,)
QUESTA_COV := $(if $(filter 1,$(COV)),+cover=bcesft,)
.PHONY: all compile run regression clean help coverage waves verdi
all: run
help:
	@echo 'make -C sim [SIM=vcs|questa] [TEST=name] [SEED=1] [COV=1]'
	@echo 'VCS uses bundled UVM 1.2. Questa requires UVM_HOME pointing at UVM 1.2.'
	@echo 'Run make -C sim regression for UART; make -C sim coverage merges results.'
	@echo 'make -C sim waves VERDI_HOME=/tools/verdi captures FSDB with VCS.'
	@echo 'make -C sim verdi [TEST=name] [SEED=1] opens an existing FSDB and KDB.'
compile:
	@mkdir -p $(BUILD) $(RUN)
ifeq ($(SIM),vcs)
ifeq ($(WAVES),1)
	@test -d "$(VERDI_HOME)/share/PLI" || { echo 'Set VERDI_HOME to your Verdi installation containing share/PLI'; exit 2; }
endif
	cd $(ROOT) && $(VCS) -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
	  -f sim/uart.f -top $(TOP) -Mdir=$(BUILD)/csrc -o $(BUILD)/simv \
	  $(VCS_COV) $(if $(filter 1,$(COV)),-cm_dir $(RUN)/coverage.vdb,) -debug_access+all $(VCS_WAVE_FLAGS) $(VCS_FLAGS) -l $(BUILD)/compile.log
else
	@test -f "$(UVM_HOME)/src/uvm_pkg.sv" || { echo 'Set UVM_HOME to UVM 1.2 root'; exit 2; }
	$(VLIB) $(BUILD)/work
	cd $(ROOT) && $(VLOG) -sv -timescale 1ns/1ps -work $(BUILD)/work +define+UVM_NO_DPI +incdir+$(UVM_HOME)/src \
	  $(UVM_HOME)/src/uvm_pkg.sv -f sim/uart.f $(QUESTA_COV) \
	  $(VLOG_FLAGS) -l $(BUILD)/compile.log
endif
run: compile
	@mkdir -p $(RUN)
ifeq ($(SIM),vcs)
ifeq ($(WAVES),1)
	@mkdir -p "$(dir $(FSDB_PATH))"
	@rm -f "$(FSDB_PATH)"
endif
	cd $(RUN) && $(BUILD)/simv +UVM_TESTNAME=$(TEST) +ntb_random_seed=$(SEED) \
	  $(VCS_COV) -cm_dir $(RUN)/coverage.vdb $(WAVE_PLUSARGS) $(PLUSARGS) -l run.log
else
	cd $(RUN) && $(VSIM) $(if $(filter 1,$(GUI)),-gui,-c) \
	  -lib $(BUILD)/work $(TOP) -sv_seed $(SEED) $(if $(filter 1,$(COV)),-coverage,) \
	  +UVM_TESTNAME=$(TEST) $(PLUSARGS) $(VSIM_FLAGS) \
	  -do 'onerror {quit -code 1}; $(if $(filter 1,$(COV)),coverage save -onexit coverage.ucdb;) run -all; quit -f' \
	  -l run.log
endif
	python3 $(ROOT)/scripts/check_log.py $(RUN)/run.log
ifeq ($(WAVES),1)
	@test -s "$(FSDB_PATH)" || { echo 'FSDB was not generated; check Verdi dumper setup and run.log'; exit 2; }
endif

# Capture first; opening Verdi never recompiles or reruns the selected test.
waves:
	$(MAKE) -f $(ROOT)/sim/Makefile run SIM=vcs WAVES=1
verdi:
ifneq ($(SIM),vcs)
	@echo 'The verdi target uses the VCS FSDB/KDB flow. Select SIM=vcs.'; exit 2
else
	@test -s "$(FSDB_PATH)" || { echo 'Missing FSDB. Run make -C sim waves with the same TEST and SEED first.'; exit 2; }
	@test -d "$(BUILD)/simv.daidir" || { echo 'Missing VCS debug database. Re-run make -C sim waves.'; exit 2; }
	cd $(RUN) && $(VERDI) -dbdir "$(BUILD)/simv.daidir" -ssf "$(FSDB_PATH)" $(VERDI_FLAGS)
endif
TESTS := uart_smoke_test uart_ral_test uart_formats_test uart_random_test uart_errors_test uart_fifo_test uart_reset_test
SEEDS ?= 1 7 23
regression:
	@for test in $(TESTS); do \
	  for seed in $(SEEDS); do \
	    $(MAKE) -f $(ROOT)/sim/Makefile run SIM=$(SIM) TEST=$$test SEED=$$seed; \
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
	rm -rf $(ROOT)/build

# Optional RTL-only validation; commercial UVM flow remains the default.
VERILATOR ?= verilator
.PHONY: rtl-check
rtl-check:
	@mkdir -p $(ROOT)/build/rtl
	cd $(ROOT) && $(VERILATOR) --binary --timing -Wno-fatal --top-module rtl_smoke \
	  --Mdir $(ROOT)/build/rtl/obj rtl/uart_apb.sv tb/uart_rtl_smoke_tb.sv > build/rtl/compile.log 2>&1
	$(ROOT)/build/rtl/obj/Vrtl_smoke | tee $(ROOT)/build/rtl/run.log
	@grep -q RTL_TEST_PASSED $(ROOT)/build/rtl/run.log
