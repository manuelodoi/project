# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog pixelratedivider.v

#load simulation using mux as the top level simulation module
vsim pixelRateDivider

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force -repeat 10ns {Clock} 1 0ns, 0  5ns
run 3000ms