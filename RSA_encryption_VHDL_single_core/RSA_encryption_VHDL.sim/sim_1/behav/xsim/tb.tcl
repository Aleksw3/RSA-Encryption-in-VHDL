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
add_wave clk done start 
#reset_n 
#add_wave n_key d_key e_key message cipher mess 
add_wave msgin_valid msgin_ready 

# core
add_wave core/mux_select core/curr_state_core
add_wave core/init

# rl_exp
add_wave core/rl_exp/curr_state_exp core/rl_exp/MonPro_busy core/rl_exp/mux_select
add_wave core/rl_exp/C_reg core/rl_exp/S_reg 


# MonPro C
add_wave core/rl_exp/MonPro_C_en core/rl_exp/MonPro_S_en
add_wave core/rl_exp/MonPro_C/busy
add_wave core/rl_exp/MonPro_S/busy
add_wave core/rl_exp/MonPro_C_X core/rl_exp/MonPro_S_X

# MonPro S


# answers
add_wave cipher message

run 2000ns