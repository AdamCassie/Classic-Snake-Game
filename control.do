vlib work
vlog MoveFSM.v
vsim control
log {/*}
add wave {/*}

force {clk} 0
force {resetn} 1
run 10ns

force {clk} 1
force {resetn} 0
force {counterA[2:0]} 000
force {rateDivider[23:0]} 100110001001011001111111
run 10ns

force {clk} 0
force {resetn} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {counterA[2]} 1
force {counterA[1]} 0
force {counterA[0]} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {counterA[2]} 0
force {counterA[1]} 0
force {counterA[0]} 0
force {rateDivider[23:0]} 000000000000000000000000
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {counterA[2]} 1
force {counterA[1]} 0
force {counterA[0]} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0 0ns, 1 {10ns} -r 20ns
run 100ns