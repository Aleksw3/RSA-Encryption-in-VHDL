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

# Exp_0_port_map
add_wave core/Exp_0_port_map/curr_state_exp core/Exp_0_port_map/curr_state_mp
add_wave core/curr_msgin_exp core/curr_msgout_exp
add_wave core/exp_0_busy core/exp_0_init core/exp_0_done core/exp_1_busy
add_wave core/key_e_d core/key_n core/R2N core/Exp_0_port_map/message_reg
add_wave core/msgin_valid core/msgin_valid_reg core/msgin_data
add_wave core/exp_0_init core/exp_1_init core/init
# add_wave core/Exp_0_port_map/MonPro_S_out_rdy core/Exp_0_port_map/MonPro_C_out_rdy
add_wave core/Exp_0_port_map/MonPro_S/EN core/Exp_0_port_map/MonPro_C/EN
#add_wave core/Exp_0_port_map/KSA_enable core/Exp_0_port_map/KSA_counter
#add_wave core/Exp_0_port_map/KSA_input_X core/Exp_0_port_map/KSA_input_Y

add_wave core/Exp_0_port_map/S_reg 
add_wave core/Exp_0_port_map/C_reg
# add_wave core/Exp_0_port_map/C_reg core/Exp_0_port_map/C_s
# add_wave core/Exp_0_port_map/S_reg core/Exp_0_port_map/S_s
# add_wave core/Exp_0_port_map/MonPro_C_busy core/Exp_0_port_map/MonPro_S_busy
# add_wave core/Exp_0_port_map/key_shift_reg

# add_wave core/Exp_0_port_map/MonPro_C_en core/Exp_0_port_map/MonPro_S_en


# MonPro C
# add_wave core/Exp_0_port_map/MonPro_C_X core/Exp_0_port_map/MonPro_C_Y 
# add_wave core/Exp_0_port_map/MonPro_S_X core/Exp_0_port_map/MonPro_S_Y
# add_wave core/Exp_0_port_map/MonPro_S/A_r core/Exp_0_port_map/MonPro_S/B_r
# add_wave core/Exp_0_port_map/MonPro_S/C core/Exp_0_port_map/MonPro_S/D
#add_wave core/Exp_0_port_map/MonPro_C_Carry_out core/Exp_0_port_map/MonPro_C_Sum_out
#add_wave core/Exp_0_port_map/MonPro_S_Carry_out core/Exp_0_port_map/MonPro_S_Sum_out
# add_wave core/Exp_0_port_map/MonPro_S/compressor_sum core/Exp_0_port_map/MonPro_S/compressor_carry
# add_wave core/Exp_0_port_map/MonPro_C/compressor_sum core/Exp_0_port_map/MonPro_C/compressor_carry

#add_wave core/Exp_0_port_map/KSA_output

# add_wave core/Exp_0_port_map/MonPro_C_en core/Exp_0_port_map/MonPro_S_en
# add_wave core/Exp_0_port_map/MonPro_C/busy
# add_wave core/Exp_0_port_map/MonPro_S/busy
# add_wave core/Exp_0_port_map/done
add_wave core/Exp_0_port_map/counter
# MonPro S
# add_wave core/Exp_0_port_map/MonPro_C/X_s core/Exp_0_port_map/MonPro_C/Y_s 
#core/Exp_0_port_map/MonPro_C/Z_s core/Exp_0_port_map/MonPro_C/N_s
# add_wave core/Exp_0_port_map/MonPro_S/X_s core/Exp_0_port_map/MonPro_S/Y_s 
#core/Exp_0_port_map/MonPro_S/Z_s core/Exp_0_port_map/MonPro_S/N_s


# answers
add_wave core/msgout_data
add_wave core/output_message expected
# add_wave cipher message done
# add_wave msgout_valid msgin_ready msgin_valid

run 340us