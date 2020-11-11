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
# done start 
# reset_n 
# add_wave n_key d_key e_key message cipher mess 
# add_wave msgin_valid msgin_ready 
# add_wave key

# # core
# add_wave core/init done
# add_wave core/key_e

# rl_exp
add_wave core/rl_exp/curr_state_exp core/rl_exp/curr_state_mp
add_wave core/key_e_d core/key_n core/R2N core/rl_exp/message_reg
# add_wave core/rl_exp/S_reg 
# add_wave core/rl_exp/C_reg
# add_wave core/rl_exp/C_reg core/rl_exp/C_s
# add_wave core/rl_exp/S_reg core/rl_exp/S_s
# add_wave core/rl_exp/MonPro_C_busy core/rl_exp/MonPro_S_busy
# add_wave core/rl_exp/key_shift_reg

# add_wave core/rl_exp/MonPro_C_en core/rl_exp/MonPro_S_en


# MonPro C
add_wave core/rl_exp/MonPro_C_X core/rl_exp/MonPro_C_Y 
add_wave core/rl_exp/MonPro_S_X core/rl_exp/MonPro_S_Y
add_wave core/rl_exp/MonPro_S/A_r core/rl_exp/MonPro_S/B_r
add_wave core/rl_exp/MonPro_S/C core/rl_exp/MonPro_S/D
add_wave core/rl_exp/MonPro_S/compressor_sum core/rl_exp/MonPro_S/compressor_carry
add_wave core/rl_exp/MonPro_S/compressor_sum_shifted
add_wave core/rl_exp/MonPro_S/KSA_result

# add_wave core/rl_exp/MonPro_C_en core/rl_exp/MonPro_S_en
# add_wave core/rl_exp/MonPro_C/busy
# add_wave core/rl_exp/MonPro_S/busy
# add_wave core/rl_exp/done
# add_wave core/rl_exp/counter
# MonPro S
# add_wave core/rl_exp/MonPro_C/X_s core/rl_exp/MonPro_C/Y_s 
#core/rl_exp/MonPro_C/Z_s core/rl_exp/MonPro_C/N_s
# add_wave core/rl_exp/MonPro_S/X_s core/rl_exp/MonPro_S/Y_s 
#core/rl_exp/MonPro_S/Z_s core/rl_exp/MonPro_S/N_s


# answers
add_wave core/msgout_data
add_wave core/output_message
# add_wave cipher message done
# add_wave msgout_valid msgin_ready msgin_valid

run 340us