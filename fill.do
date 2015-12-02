# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog  fill.v aluAddress.v controlpath.v dataPath.v pixelRateDivider.v gamescreen.qip startscreen.qip win.qip lose.qip

#load simulation using mux as the top level simulation module
vsim memory_game

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

#force -repeat 20ns {clock} 1 0ns, 0  10ns
run 100ns