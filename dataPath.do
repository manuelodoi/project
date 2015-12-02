# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog  aluAddress.v  dataPath.v pixelRateDivider.v 

#load simulation using mux as the top level simulation module
vsim dataPath

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force -repeat 20ns {Clock} 1 0ns, 0  10ns
force -drive {enDrawCount} 1
force -drive {Reset} 0
force -drive {aluOp} 2'd2
run 10000ns