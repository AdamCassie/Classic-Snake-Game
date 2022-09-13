vlib work
vlog MoveFSM.v
vsim datapath
log {/*}
add wave {/*}

force {clk} 0
force {resetn} 1
run 10ns

force {clk} 1
force {resetn} 0
run 10ns

force {clk} 0
force {resetn} 1
force {UpN} 0
run 10ns

force {clk} 1
force {UpN} 1
force {LeftN} 0
force {set_dir} 1
run 10ns

force {clk} 0
force {DownN} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {DownN} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {LeftN} 1
force {RightN} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {set_dir} 0
force {UpN} 0
force {RightN} 1
run 10ns

force {clk} 1
force {resetn} 0
run 10ns

force {clk} 0
force {resetn} 1
force {update_x} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {update_x} 0
force {resetn} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {update_x} 1
force {resetn} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {resetn} 0
force {update_x} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {update_x} 1
force {resetn} 1
run 10ns

force {clk} 1
force {update_x} 0
force {update_y} 1
force {dir[1]} 0
force {dir[0]} 0
run 10ns

force {clk} 0
force {dir[1]} 0
force {dir[0]} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {resetn} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {resetn} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {update_y} 0
force {erase} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0 0ns, 1 {10ns} -r 20ns
run 60ns

force {clk} 0
force {erase} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {draw} 0
force {resetn} 0
run 10ns

force {clk} 1
run 10ns

force {clk} 0
force {resetn} 1
force {draw} 1
run 10ns

force {clk} 1
run 10ns

force {clk} 0 0ns, 1 {10ns} -r 20ns
run 60ns