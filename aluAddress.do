# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog aluAddress.v

#load simulation using mux as the top level simulation module
vsim aluAddress

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#force -repeat 20ns {clock} 1 0ns, 0  10ns
force -drive {aluOp} 3'b011
force {startX} 1
force {startY} 1
force -drive {counter} 8'b11001000
run 100ns
force -drive {counter} 8'b11001001
run 100ns
force -drive {counter} 8'b11001010
run 100ns
force -drive {counter} 8'b11001011
run 100ns
force -drive {counter} 8'b11001100
run 100ns
force -drive {counter} 8'b11001101
run 100ns
force -drive {counter} 8'b11011101
run 100ns