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
add_wave u_rsa_core/msgin_valid_reg u_rsa_core/msgin_ready u_rsa_core/init
add_wave u_rsa_core/msgin_last_reg
add_wave u_rsa_core/msgout_last
add_wave u_rsa_core/msgout_valid u_rsa_core/msgin_valid_reg u_rsa_core/msgout_ready_reg
add_wave u_rsa_core/msgin_data_reg
add_wave u_rsa_core/msgin_data_reg0 u_rsa_core/msgin_data_reg1 u_rsa_core/msgin_data_reg2 u_rsa_core/msgin_data_reg3 u_rsa_core/msgin_data_reg4
add_wave msgin_counter msgout_counter
add_wave msgout_data
add_wave u_rsa_core/exp_0_output u_rsa_core/exp_1_output u_rsa_core/exp_2_output u_rsa_core/exp_3_output u_rsa_core/exp_4_output
add_wave u_rsa_core/Exp_0_port_map/MESSAGE
add_wave u_rsa_core/exp_0_busy u_rsa_core/exp_1_busy u_rsa_core/exp_2_busy u_rsa_core/exp_3_busy u_rsa_core/exp_4_busy

run 4ms