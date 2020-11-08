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
add_wave clk 
#done start 
#reset_n 
#add_wave n_key d_key e_key message cipher mess 
# add_wave msgin_valid msgin_ready 
# add_wave key

# # core
# add_wave core/init done
# add_wave core/key_e

# rl_exp
add_wave core/rl_exp/curr_state_exp core/rl_exp/curr_state_mp

#add_wave core/rl_exp/S_s core/rl_exp/S_reg 
#add_wave core/rl_exp/C_s core/rl_exp/C_reg
add_wave core/rl_exp/C_reg
add_wave core/rl_exp/S_reg 
#add_wave core/rl_exp/MonPro_C_busy core/rl_exp/MonPro_S_busy
add_wave core/rl_exp/key_shift_reg

add_wave core/rl_exp/MonPro_C_en core/rl_exp/MonPro_S_en


# MonPro C
add_wave core/rl_exp/MonPro_C_X core/rl_exp/MonPro_C_Y core/rl_exp/MonPro_S_X core/rl_exp/MonPro_S_Y
# add_wave core/rl_exp/MonPro_C_en core/rl_exp/MonPro_S_en
# add_wave core/rl_exp/MonPro_C/busy
# add_wave core/rl_exp/MonPro_S/busy
add_wave core/rl_exp/counter
# MonPro S


# answers
add_wave core/msgout_data
add_wave cipher message

run 26000ns