vlib work
vdel -all
vlib work
vlog +acc +cover -coveropt 3  -f file.list 
vsim -coverage -vopt work.top +TESTCASE=fulltest 
add wave -r *
run -all
#vcover report -html axi_cov
#-c -do "coverage save -onexit -directive -codeAll axi_cov ; run -all; exit"



