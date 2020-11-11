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
add_wave u_rsa_core/state_msg u_rsa_core/rl_exp/curr_state_exp
add_wave msgin_valid msgin_ready u_rsa_core/init

# add_wave msgout_valid msgout_ready
# add_wave msgin_data u_rsa_core/msgin_data_reg 

# add_wave u_rsa_core/done u_rsa_core/busy u_rsa_core/init
add_wave u_rsa_core/rl_exp/R2N key_n key_e_d
add_wave u_rsa_core/rl_exp/C_reg u_rsa_core/rl_exp/S_reg
# add_wave u_rsa_core/rl_exp/C_s u_rsa_core/rl_exp/S_s
add_wave u_rsa_core/rl_exp/MonPro_C_X u_rsa_core/rl_exp/MonPro_C_Y
add_wave u_rsa_core/rl_exp/MonPro_S_X u_rsa_core/rl_exp/MonPro_S_Y
add_wave msgout_data expected_msgout_data
add_wave u_rsa_core/rl_exp/MP_busy
# add_wave u_rsa_core/rl_exp/counter
# add_wave u_rsa_core/rl_exp/MonPro_S/count
# add_wave u_rsa_core/rl_exp/MonPro_S/X_r u_rsa_core/rl_exp/MonPro_S/A_r u_rsa_core/rl_exp/MonPro_S/B_r u_rsa_core/rl_exp/MonPro_S/D u_rsa_core/rl_exp/MonPro_S/Y_r u_rsa_core/rl_exp/MonPro_S/isODD
# add_wave u_rsa_core/rl_exp/MonPro_S/N_r
# add_wave u_rsa_core/rl_exp/MonPro_S/compressor_sum
run 1000000ns