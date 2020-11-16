set test [current_sim]
if {$test==""} {
	launch_simulation
} else {
	relaunch_sim
}
restart
set waves [get_waves -r *]
remove_wave $waves

# tb
add_wave clk  reset_n 
add_wave u_rsa_core/curr_msgin_exp u_rsa_core/curr_msgout_exp
add_wave msgin_valid msgin_ready u_rsa_core/init
add_wave msgin_last
add_wave msgout_last
add_wave msgout_valid msgout_ready
add_wave u_rsa_core/msgin_data
add_wave u_rsa_core/msgin_data_reg
add_wave msgin_counter msgout_counter
add_wave msgout_data
add_wave u_rsa_core/exp_0_output u_rsa_core/exp_1_output u_rsa_core/exp_2_output u_rsa_core/exp_3_output
add_wave u_rsa_core/Exp_0_port_map/MESSAGE
add_wave u_rsa_core/exp_0_busy u_rsa_core/exp_1_busy u_rsa_core/exp_2_busy u_rsa_core/exp_3_busy

run 4ms