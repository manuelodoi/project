# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog counter15Bit.v

#load simulation using mux as the top level simulation module
vsim counter15Bit

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}

force -repeat 20ns {Clock} 1 0ns, 0  10ns
force {Reset} 0
force {Enable} 1
run 10000ns