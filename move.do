vlib work
vlog MoveFSM.v
vsim MoveFSM
log {/*}
add wave {/*}

force {CLOCK_50} 0
force {SW[9]} 1
run 10ns

force {CLOCK_50} 1
force {SW[9]} 0
run 10ns

force {CLOCK_50} 0
force {SW[9]} 1
run 10ns

force {CLOCK_50} 1
run 10ns

force {CLOCK_50} 0 0ns, 1 {10ns} -r 20ns
run 60ns